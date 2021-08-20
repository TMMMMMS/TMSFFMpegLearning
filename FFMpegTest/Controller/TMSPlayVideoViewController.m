//
//  TMSPlayVideoViewController.m
//  FFMpegTest
//
//  Created by santian_mac on 2021/8/19.
//

#import "TMSPlayVideoViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <pthread.h>

#import "TMSAudioInformation.h"
#import "TMSQueueAudioObject.h"
#import "TMSQueueVideoObject.h"
#import "TMSObjectQueue.h"
#import "TMSAudioQueuePlayer.h"
#import "TMSMediaAudioContext.h"
#import "TMSMediaVideoContext.h"
#import "TMSVideoPlayer.h"
#import "TMSGLRenderView.h"

typedef NS_ENUM(NSInteger, TMSPlayState) {
    TMSPlayStateNone,
    TMSPlayStateLoading,
    TMSPlayStatePlaying,
    TMSPlayStatePause,
    TMSPlayStateStop
};

NS_INLINE void _NotifyWaitThreadWakeUp(NSCondition *condition) {
    /// To prevent current thread wait lead to wake up signal can’t reache to sleeping thread.
    /// Send signal dispatch on main thread.
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        [condition signal];
    });
}

NS_INLINE void _SleepThread(NSCondition *condition) {
    [condition wait];
}

@interface TMSPlayVideoViewController ()<TMSAudioQueuePlayerDelegate, TMSVideoPlayerDelegate>
{
    AVFormatContext *avformat_context;
    AVPacket *packet;
    
    pthread_mutex_t mutex;
    double audio_clock;
    double video_clock;
    double tolerance_scope;
    
    dispatch_queue_t decode_dispatch_queue;
    dispatch_queue_t audio_play_dispatch_queue;
    dispatch_queue_t video_render_dispatch_queue;
}
@property (nonatomic, strong)TMSObjectQueue *audioFrameCacheQueue;
@property (nonatomic, strong)TMSObjectQueue *videoFrameCacheQueue;
@property (nonatomic, strong)NSCondition *decodeCondition;
@property (nonatomic, strong)NSCondition *audioPlayCondition;
@property (nonatomic, strong)NSCondition *videoRenderCondition;

@property (nonatomic, assign, getter=isDecodeComplete)BOOL decodeComplete;
@property (nonatomic, assign)TMSPlayState playState;

@property (nonatomic, strong)TMSAudioQueuePlayer *audioPlayer;
@property (nonatomic, strong)TMSMediaAudioContext *mediaAudioContext;

@property(nonatomic, strong) TMSVideoPlayer *videoPlayer;
@property (nonatomic, strong)TMSMediaVideoContext *mediaVideoContext;
@property(nonatomic, strong) TMSGLRenderView *renderView;

@property(nonatomic, assign) BOOL exitPage;
@end

@implementation TMSPlayVideoViewController

- (void)backAction {
    self.exitPage = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    [self.view addSubview:self.renderView];
    
    packet = av_packet_alloc();

    decode_dispatch_queue = dispatch_queue_create("decode queue", DISPATCH_QUEUE_SERIAL);
    audio_play_dispatch_queue = dispatch_queue_create("audio play queue", DISPATCH_QUEUE_SERIAL);
    video_render_dispatch_queue = dispatch_queue_create("video render queue", DISPATCH_QUEUE_SERIAL);

    self.playState = TMSPlayStateNone;

    pthread_mutex_init(&mutex, NULL);
    audio_clock = 0;
    video_clock = 0;
    tolerance_scope = 0;

    self.audioFrameCacheQueue = [[TMSObjectQueue alloc] init];
    self.videoFrameCacheQueue = [[TMSObjectQueue alloc] init];
    self.decodeCondition = [[NSCondition alloc] init];
    self.audioPlayCondition = [[NSCondition alloc] init];
    self.videoRenderCondition = [[NSCondition alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"flutter" ofType:@"mp4"];
    [self playWithFilePath:filePath];
}

- (BOOL)playWithFilePath:(NSString *)filePath {
    
    avformat_context = avformat_alloc_context();
    const char *url = [filePath UTF8String];
    
    int ret = avformat_open_input(&avformat_context, url, NULL, NULL);
    if(ret != 0) goto fail;
    
    ret = avformat_find_stream_info(avformat_context, NULL);
    if(ret < 0) goto fail;
    if(avformat_context->nb_streams == 0) goto fail;
    if(![self setupMediaContext]) goto fail;
    
    self.decodeComplete = NO;
    [self start];
    return YES;
fail:
    if(avformat_context) {
        avformat_close_input(&avformat_context);
    }
    return NO;
}

- (BOOL)setupMediaContext {
    
    self.playState = TMSPlayStateNone;
    
    for(int i = 0; i < avformat_context->nb_streams; i ++) {
        
        AVStream *stream = avformat_context->streams[i];
        enum AVMediaType mediaType = stream->codecpar->codec_type;
        if(mediaType == AVMEDIA_TYPE_VIDEO) {
            self.mediaVideoContext = [[TMSMediaVideoContext alloc] initWithAVStream:stream
                                                                 formatContext:avformat_context];
            
            if(!_mediaVideoContext) return NO;
            
            [self.view addSubview:self.renderView];
            
            self.videoPlayer = [[TMSVideoPlayer alloc] initWithQueue:video_render_dispatch_queue
                                                             render:self.renderView
                                                                fps:[self.mediaVideoContext fps]
                                                              avctx:self.mediaVideoContext.codecContext
                                                             stream:stream
                                                           delegate:self];
            
            self->tolerance_scope = 1.0f / av_q2d(stream->avg_frame_rate);
            
        } else if(mediaType == AVMEDIA_TYPE_AUDIO) {
            
            self.mediaAudioContext = [[TMSMediaAudioContext alloc] initWithAVStream:stream
                                                                 formatContext:avformat_context];
            
            self.audioPlayer = [[TMSAudioQueuePlayer alloc] initWithAudioInformation:self.mediaAudioContext.audioInformation delegate:self];
            
        }
    }
    return YES;
}
- (void)start {
    
    self.playState = TMSPlayStateLoading;
    [self decode];
    self->audio_clock = 0;
    self->video_clock = 0;
    
}

- (void)stop {
    [self stopVideoPlay];
    [self stopAudioPlay];
}

- (void)decode {
    
    dispatch_async(decode_dispatch_queue, ^{
        while (true) {
            
            if (self.exitPage) {
                return;
            }
            
            float audioCacheDuration = [self.audioFrameCacheQueue count] * [self.mediaAudioContext oneFrameDuration];
            float videoCacheDuration = [self.videoFrameCacheQueue count] * [self.mediaVideoContext oneFrameDuration];
            
            //nslog(@"【Cache】%f, %f", videoCacheDuration, audioCacheDuration);
            
            if((!self.mediaVideoContext || videoCacheDuration >= MAX_AUDIO_FRAME_DURATION) &&
               (!self.mediaAudioContext || audioCacheDuration >= MAX_VIDEO_FRAME_DURATION)) {
                NSLog(@"Decode wait...");
                if(self.playState == TMSPlayStateLoading) {
                    self.playState = TMSPlayStatePlaying;
                    [self startAudioPlay];
                    [self startVideoPlay];
                }
                _SleepThread(self.decodeCondition);
                NSLog(@"Decode resume");
            }
            
            av_packet_unref(self->packet);
            int ret_code = av_read_frame(self->avformat_context, self->packet);
            if(ret_code >= 0) {
                if (self.mediaVideoContext && self->packet->stream_index == self.mediaVideoContext.streamIndex) {
                    
                    uint64_t duration = self->avformat_context->streams[self.mediaVideoContext.streamIndex]->duration;
                    
                    TMSQueueVideoObject *obj = [[TMSQueueVideoObject alloc] init];
                    float unit = av_q2d(self->avformat_context->streams[self.mediaVideoContext.streamIndex]->time_base);
                    obj.unit = unit;
                    AVFrame *frame = obj.frame;
                    BOOL ret = [self.mediaVideoContext decodePacket:self->packet frame:&frame];
                    obj.pts = obj.frame->pts * unit;
                    obj.duration = [self.mediaVideoContext oneFrameDuration];
//                        NSLog(@"【PTS】【Video】: %f, duration: %lld, last: %lld, repeat: %d", frame->pts * unit, duration, self->packet->duration, frame->repeat_pict);
                    if(ret) {
                        [self.videoFrameCacheQueue enqueue:obj];
                        videoCacheDuration = [self.videoFrameCacheQueue count] * [self.mediaVideoContext oneFrameDuration];
                        /// 通知视频渲染队列可以继续渲染了
                        /// 如果视频渲染队列未暂停则无作用
                        if(videoCacheDuration >= MIN_VIDEO_FRAME_DURATION) {
                            _NotifyWaitThreadWakeUp(self.videoRenderCondition);
                        }
                    }
                    
                } else if(self.mediaAudioContext && self->packet->stream_index == self.mediaAudioContext.streamIndex) {
                    
                    uint64_t duration = self->avformat_context->streams[self.mediaAudioContext.streamIndex]->duration;
                    float unit = av_q2d(self.mediaAudioContext.codecContext->time_base);
                    //nslog(@"【PTS】【Audio】: %f, duration: %lld, last: %lld", self->packet->pts * unit, duration, self->packet->duration);
                    int buffer_size = self.mediaAudioContext.audioInformation.buffer_size;
                    TMSQueueAudioObject *obj = [[TMSQueueAudioObject alloc] initWithLength:buffer_size pts:self->packet->pts * unit duration:self->packet->duration * unit];
                    uint8_t *buffer = obj.data;
                    int64_t bufferSize = 0;
                    BOOL ret = [self.mediaAudioContext decodePacket:self->packet outBuffer:&buffer outBufferSize:&bufferSize];
                    if(ret) {
                        [obj updateLength:bufferSize];
                        [self.audioFrameCacheQueue enqueue:obj];
                        audioCacheDuration = [self.audioFrameCacheQueue count] * [self.mediaAudioContext oneFrameDuration];
                        /// 通知音频渲染队列可以继续渲染了
                        /// 如果音频渲染队列未暂停则无作用
                        if(audioCacheDuration >= MIN_AUDIO_FRAME_DURATION) {
                            _NotifyWaitThreadWakeUp(self.audioPlayCondition);
                        }
                    }
                    
                }
            } else {
                /// read end of file
                if(ret_code == AVERROR_EOF) {
                    pthread_mutex_lock(&(self->mutex));
                    self.decodeComplete = YES;
                    pthread_mutex_unlock(&(self->mutex));
                }
            }
            pthread_mutex_lock(&(self->mutex));
            BOOL isDecodeComplete = self.isDecodeComplete;
            pthread_mutex_unlock(&(self->mutex));
            if(isDecodeComplete) break;
        }
        NSLog(@"Decode completed, read end of file.");
    });
}

#pragma mark - Video
- (void)startVideoPlay {
    if(self.mediaVideoContext) {
        [self.videoPlayer startPlay];
    }
}

- (void)stopVideoPlay {
    if(self.mediaVideoContext) {
        [self.videoPlayer stopPlay];
    }
}

#pragma mark - TMSVideoPlayerDelegate
- (void)readNextVideoFrame {
    
    dispatch_async(video_render_dispatch_queue, ^{
        
        float videoCacheDuration = [self.videoFrameCacheQueue count] * [self.mediaVideoContext oneFrameDuration];
        pthread_mutex_lock(&(self->mutex));
        BOOL isDecodeComplete = self.isDecodeComplete;
        pthread_mutex_unlock(&(self->mutex));
        if(videoCacheDuration < MIN_VIDEO_FRAME_DURATION && !isDecodeComplete) {
            //nslog(@"Video is not enough, wait...");
            _NotifyWaitThreadWakeUp(self.decodeCondition);
            _SleepThread(self.videoRenderCondition);
        }
        if(videoCacheDuration < MAX_VIDEO_FRAME_DURATION) {
            _NotifyWaitThreadWakeUp(self.decodeCondition);
        }
        TMSQueueVideoObject *obj = [self _readNextVideoFrameBySyncAudio];
//        TMSQueueVideoObject *obj = [self.videoFrameCacheQueue dequeue];
        if(obj) {
            [self.videoPlayer renderFrame:obj.frame];
        } else {
            if(isDecodeComplete) {
                NSLog(@"Video frame render completed.");
                [self.videoPlayer stopPlay];
            }
        }
    });
}

- (void)updateVideoClock:(float)pts duration:(float)duration {
    pthread_mutex_lock(&mutex);
    video_clock = pts + duration;
    pthread_mutex_unlock(&mutex);
}

- (TMSQueueVideoObject *)_readNextVideoFrameBySyncAudio {
    
    pthread_mutex_lock(&(self->mutex));
    /// 读取当前的音频时钟时间
    double ac = self->audio_clock;
    pthread_mutex_unlock(&(self->mutex));
    TMSQueueVideoObject *obj = NULL;
    /// 统计路过的视频帧数量
    int readCount = 0;
    /// 首先读取一帧视频数据
    obj = [self.videoFrameCacheQueue dequeue];
    readCount ++;
    /// 计算当前视频帖播放结束时的时间点
    double vc = obj.pts + obj.duration;
    NSLog(@"[Sync] AC: %f, VC: %f, 差值: %f, syncDuration: %f", ac, vc, fabs(ac - vc), self->tolerance_scope);
    if(ac - vc > self->tolerance_scope) {
        /// 视频太慢,丢弃当前帧继续读取下一帧
        /// 这里认为读取下一帧或者更下一帧不会造成视频缓冲队列枯竭,所以未做等待处理
        /// 因为时时同步能形成的时间差比较有限
        while (ac - vc > self->tolerance_scope) {
            TMSQueueVideoObject *_nextObj = [self.videoFrameCacheQueue dequeue];
            if(!_nextObj) break;
            obj = _nextObj;
            vc = obj.pts + obj.duration;
            readCount ++;
        }
        NSLog(@"[Sync]音频太快,视频追赶跳过: %d 帧", (readCount - 1));
    } else if (vc - ac > self->tolerance_scope) {
        /// 视频太快,暂停一下再接着渲染显示当前视频帧
        float sleep_time = vc - ac;
        NSLog(@"[Sync]视频太快,视频等待:%f", sleep_time);
        usleep(sleep_time * 1000 * 1000);
    } else {
        NSLog(@"[Sync]音频在误差允许范围内: %f, %f", fabs(ac - vc), self->tolerance_scope);
    }
    return obj;
}

#pragma mark - Audio
- (void)startAudioPlay {
    if(self.mediaAudioContext) {
        [self.audioPlayer play];
    }
}
- (void)stopAudioPlay {
    if(self.mediaAudioContext) {
        [self.audioPlayer stop];
    }
}

- (void)readNextAudioFrame:(AudioQueueBufferRef)aqBuffer {
    dispatch_async(audio_play_dispatch_queue, ^{
        
        float audioCacheDuration = [self->_audioFrameCacheQueue count] * [self->_mediaAudioContext oneFrameDuration];
        pthread_mutex_lock(&(self->mutex));
        BOOL isDecodeComplete = self.isDecodeComplete;
        pthread_mutex_unlock(&(self->mutex));
        if(audioCacheDuration < MIN_AUDIO_FRAME_DURATION && !isDecodeComplete) {
            //nslog(@"Audio is not enough, wait…");
            _NotifyWaitThreadWakeUp(self.decodeCondition);
            _SleepThread(self.audioPlayCondition);
        }
        TMSQueueAudioObject *obj = [self.audioFrameCacheQueue dequeue];
        if(audioCacheDuration < MAX_AUDIO_FRAME_DURATION) {
            _NotifyWaitThreadWakeUp(self.decodeCondition);
        }
        if(obj) {
            [self.audioPlayer receiveData:obj.data length:obj.length aqBuffer:aqBuffer pts:obj.pts duration:obj.duration];
        } else {
            if(isDecodeComplete) {
                //nslog(@"Audio frame play completed.");
                [self.audioPlayer stop];
            }
        }
    });
}

- (void)updateAudioClock:(float)pts duration:(float)duration {
    pthread_mutex_lock(&mutex);
    audio_clock = pts + duration;
    pthread_mutex_unlock(&mutex);
}

- (TMSGLRenderView *)renderView{
    
    if (!_renderView) {
        _renderView = [[TMSGLRenderView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _renderView;
}

- (void)dealloc {
    
    if(avformat_context) {
        avformat_close_input(&avformat_context);
        avformat_free_context(avformat_context);
    }
    if(packet) {
        av_packet_unref(packet);
        av_packet_free(&packet);
    }
    pthread_mutex_destroy(&mutex);
    
    [self stop];
    
    NSLog(@"%@--dealloc", NSStringFromClass([self class]));
}

@end
