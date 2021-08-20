//
//  SeparateViewController.m
//  FFMpegTest
//
//  Created by TmmmS on 2021/7/3.
//

#import "SeparateViewController.h"
#import <AudioToolbox/AudioToolbox.h>
//#import <libavcodec/avcodec.h>
//#import <libavformat/avformat.h>
//#import <libswscale/swscale.h>
//#import <libavutil/imgutils.h>
//#import <libswresample/swresample.h>
#import <pthread.h>

#import "SeparateViewController.h"

#import "TMSAudioInformation.h"
#import "TMSQueueAudioObject.h"
#import "TMSQueueVideoObject.h"
#import "TMSObjectQueue.h"
#import "TMSAudioQueuePlayer.h"
#import "TMSMediaAudioContext.h"
#import "TMSMediaVideoContext.h"
#import "TMSVideoPlayer.h"
#import "TMSGLRenderView.h"

//#define MAX_BUFFER_COUNT 3
//
//#define MAX_AUDIO_FRAME_DURATION   2
//#define MIN_AUDIO_FRAME_DURATION   1
//
//#define MAX_VIDEO_FRAME_DURATION   2
//#define MIN_VIDEO_FRAME_DURATION   1

//NS_INLINE void _NotifyWaitThreadWakeUp(NSCondition *condition) {
//    /// To prevent current thread wait lead to wake up signal can’t reache to sleeping thread.
//    /// Send signal dispatch on main thread.
//    dispatch_queue_t queue = dispatch_get_main_queue();
//    dispatch_async(queue, ^{
//        [condition signal];
//    });
//}
//
//NS_INLINE void _SleepThread(NSCondition *condition) {
//    [condition wait];
//}

@interface SeparateViewController ()
//{
//    AVFormatContext *avformat_context;
//    AVPacket *packet;
//
//    pthread_mutex_t mutex;
//    double audio_clock;
//    double video_clock;
//    double tolerance_scope;
//
//    dispatch_queue_t decode_dispatch_queue;
//    dispatch_queue_t audio_play_dispatch_queue;
//    dispatch_queue_t video_render_dispatch_queue;
//}
//@property (nonatomic, strong)TMSObjectQueue *audioFrameCacheQueue;
//@property (nonatomic, strong)TMSObjectQueue *videoFrameCacheQueue;
//@property (nonatomic, strong)NSCondition *decodeCondition;
//@property (nonatomic, strong)NSCondition *audioPlayCondition;
//@property (nonatomic, strong)NSCondition *videoRenderCondition;
//
//@property (nonatomic, assign, getter=isDecodeComplete)BOOL decodeComplete;
////@property (nonatomic, assign)TMSPlayState playState;
//
//@property (nonatomic, strong)TMSAudioQueuePlayer *audioPlayer;
//@property (nonatomic, strong)TMSMediaAudioContext *mediaAudioContext;
//
//@property(nonatomic, strong) TMSVideoPlayer *videoPlayer;
//@property (nonatomic, strong)TMSMediaVideoContext *mediaVideoContext;
//@property(nonatomic, strong) TMSGLRenderView *renderView;
//
//@property(nonatomic, assign) BOOL exitPage;
@end

@implementation SeparateViewController

- (void)backAction {
//    self.exitPage = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor orangeColor];
    
//    [self.view addSubview:self.renderView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
//    packet = av_packet_alloc();
//
//    decode_dispatch_queue = dispatch_queue_create("decode queue", DISPATCH_QUEUE_SERIAL);
//    audio_play_dispatch_queue = dispatch_queue_create("audio play queue", DISPATCH_QUEUE_SERIAL);
//    video_render_dispatch_queue = dispatch_queue_create("video render queue", DISPATCH_QUEUE_SERIAL);
//
//    self.playState = TMSPlayStateNone;
//
//    pthread_mutex_init(&mutex, NULL);
//    audio_clock = 0;
//    video_clock = 0;
//    tolerance_scope = 0;
//
//    self.audioFrameCacheQueue = [[TMSObjectQueue alloc] init];
//    self.videoFrameCacheQueue = [[TMSObjectQueue alloc] init];
//    self.decodeCondition = [[NSCondition alloc] init];
//    self.audioPlayCondition = [[NSCondition alloc] init];
//    self.videoRenderCondition = [[NSCondition alloc] init];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"flutter" ofType:@"mp4"];
//    NSString *outPath = [NSString stringWithFormat:@"/Users/mahua/Desktop/test.yuv"];
//    NSString *pcmPath = [NSString stringWithFormat:@"/Users/mahua/Desktop/test.pcm"];
//    [self ffpmegDecodeVideoInPath:filePath outPath:outPath];
//    [self ffpmegDecodeAudioWithzInPath:filePath outPath:pcmPath];
//    [self ffpmegDecodeAudioWithInPath:filePath];
//    [self ffpmegDecodeVideoWithInPath:filePath];
    
//    [self playWithFilePath:filePath];
}

//- (void)ffpmegDecodeVideoInPath:(NSString *)inPath outPath:(NSString *)outPath{
//
//    /*解码步骤
//     1.注册组件(av_register_all());
//     2.打开封装格式。也就是打开文件。
//     3.查找视频流(视频中包含视频流,音频流，字幕流)
//     4.查找解码器
//     5.打开解码器
//     6.循环每一帧，去解码
//     7.解码完成，关闭资源
//
//     */
//
//    int operationResult = 0;
//
//
//    //第二步:打开文件
//    avformat_context = avformat_alloc_context();
//    const char *url = [inPath UTF8String];
//    operationResult = avformat_open_input(&avformat_context, url, NULL, NULL);   //avformatcontext传的是二级指针（可以复习下二级指针的知识)
//    if(operationResult != 0){
//        //        av_log(NULL, 1, "打开文件失败");
//        //nslog(@"打开文件失败");
//        return;
//    }
//
//    //第三步:查找视频流
//     operationResult = avformat_find_stream_info(avformat_context, NULL);
//    if(operationResult != 0){
////        av_log(NULL, 1, "查找视频流失败");
//        //nslog(@"查找视频流失败");
//        return;
//    }
//
//    /* 第四步:查找解码器
//       * 查找视频流的index
//       * 根据视频流的index获取到avCodecContext
//       * 根据avCodecContext获取解码器
//     */
//    int streamIndex = -1;
//    for (int i = 0 ; i < avformat_context->nb_streams; i++){
//        if(avformat_context -> streams[i] -> codecpar -> codec_type == AVMEDIA_TYPE_VIDEO){
//            streamIndex = i;   //拿到视频流的index
//            //nslog(@"获取到了视频流");
//            break;
//        }
//    }
//    AVCodecParameters *codecParameters = avformat_context -> streams[streamIndex]->codecpar;
//    //根据解码器上下文拿到解码器id ,然后得到解码器
//    AVCodec *decodeCodec = avcodec_find_decoder(codecParameters->codec_id);
//    //根据视频流的index拿到解码器上下文
//    AVCodecContext *avcodec_context = avcodec_alloc_context3(decodeCodec);
//
//    //nslog(@"解码器为%s",decodeCodec -> name);
//    //第五步:打开解码器
//    operationResult = avcodec_open2(avcodec_context, decodeCodec, NULL);
//    if(operationResult != 0){
//        //        av_log(NULL, 1, "打开解码器失败");
//        //nslog(@"打开解码器失败");
//        return;
//    }
//
//    //第六步:开始解码
//    //结构体大小计算：字节对齐原则
//    AVPacket *packet = (AVPacket *)av_malloc(sizeof(AVPacket));
//    //开辟一块内存空间
//    AVFrame *avframe_in = av_frame_alloc();
//
//    //创建一个yuv420视频像素数据格式缓冲区(一帧数据)
//    AVFrame *avframe_yuv420 = av_frame_alloc();
//    //给缓冲区设置类型->yuv420类型
//    //得到YUV420P缓冲区大小
//    //参数一：视频像素数据格式类型->YUV420P格式
//    //参数二：一帧视频像素数据宽 = 视频宽
//    //参数三：一帧视频像素数据高 = 视频高
//    //参数四：字节对齐方式->默认是1
//    int bufferSize = av_image_get_buffer_size(AV_PIX_FMT_YUV420P, avcodec_context -> width, avcodec_context -> height, 1);
//    //开辟一块内存空间
//    uint8_t *data = (uint8_t *)av_malloc(bufferSize);
//    //向avframe_yuv420p->填充数据
//    //参数一：目标->填充数据(avframe_yuv420p)
//    //参数二：目标->每一行大小
//    //参数三：原始数据
//    //参数四：目标->格式类型
//    //参数五：宽
//    //参数六：高
//    //参数七：字节对齐方式
//    av_image_fill_arrays(avframe_yuv420 -> data,
//                         avframe_yuv420 -> linesize,
//                         data, AV_PIX_FMT_YUV420P,
//                         avcodec_context -> width,
//                         avcodec_context -> height,
//                         1);
//
//
//    //拿到格式转换上下文
//    //4、注意：在这里我们不能够保证解码出来的一帧视频像素数据格式是yuv格式
//    //参数一：源文件->原始视频像素数据格式宽
//    //参数二：源文件->原始视频像素数据格式高
//    //参数三：源文件->原始视频像素数据格式类型
//    //参数四：目标文件->目标视频像素数据格式宽
//    //参数五：目标文件->目标视频像素数据格式高
//    //参数六：目标文件->目标视频像素数据格式类型
//    struct SwsContext *sws_context = sws_getContext(avcodec_context -> width,
//                                             avcodec_context -> height,
//                                             avcodec_context -> pix_fmt,
//                                             avcodec_context -> width,
//                                             avcodec_context -> height,
//                                             AV_PIX_FMT_YUV420P,
//                                             SWS_BICUBIC,
//                                             NULL,
//                                             NULL,
//                                             NULL);
//
//
//    int y_size,u_size,v_size;
//
//    long decodeIndex = 0;
//
//    const char *outpath = [outPath UTF8String];
//    FILE *yuv420p_file = fopen(outpath, "wb+");
//    if (yuv420p_file == NULL){
//        //nslog(@"输出文件打开失败");
//        return;
//    }
//
//    while (av_read_frame(avformat_context, packet) == 0) {
//        if(packet -> stream_index == streamIndex){  //如果是视频流
//            avcodec_send_packet(avcodec_context, packet);
//
//            operationResult = avcodec_receive_frame(avcodec_context, avframe_in);
//            if(operationResult == 0){   //解码成功
//                switch (avframe_in->pict_type) {
//                    case AV_PICTURE_TYPE_I:
//                        //nslog(@"I帧");
//                        break;
//                    case AV_PICTURE_TYPE_P:
//                        //nslog(@"P帧");
//                        break;
//                    case AV_PICTURE_TYPE_B:
//                        //nslog(@"B帧");
//                        break;
//                    default:
//                        break;
//                }
//
//                //进行类型转换:将解码出来的原像素数据转成我们需要的yuv420格式
//                //4、注意：在这里我们不能够保证解码出来的一帧视频像素数据格式是yuv格式
//                //视频像素数据格式很多种类型: yuv420P、yuv422p、yuv444p等等...
//                //保证：我的解码后的视频像素数据格式统一为yuv420P->通用的格式
//                //进行类型转换: 将解码出来的视频像素点数据格式->统一转类型为yuv420P
//
//                //sws_scale作用：进行类型转换的
//                //参数一：视频像素数据格式上下文
//                //参数二：原来的视频像素数据格式->输入数据
//                //参数三：原来的视频像素数据格式->输入画面每一行大小
//                //参数四：原来的视频像素数据格式->输入画面每一行开始位置(填写：0->表示从原点开始读取)
//                //参数五：原来的视频像素数据格式->输入数据行数
//                //参数六：转换类型后视频像素数据格式->输出数据
//                //参数七：转换类型后视频像素数据格式->输出画面每一行大小
//                sws_scale(sws_context, (const uint8_t *const *)avframe_in->data, avframe_in ->linesize, 0, avcodec_context -> height, avframe_yuv420 -> data, avframe_yuv420 -> linesize);
//
//                //格式已经转换完成，写入yuv420p文件到本地.
//                //  YUV: Y代表亮度,UV代表色度
//                // YUV420格式知识: 一个Y代表一个像素点,4个像素点对应一个U和V.  4*Y = U = V
//                y_size = avcodec_context -> width * avcodec_context -> height;
//                u_size = y_size / 4;
//                v_size = y_size / 4;
//
//                //依次写入Y、U、V部分
//                fwrite(avframe_yuv420 -> data[0], 1, y_size, yuv420p_file);
//                fwrite(avframe_yuv420 -> data[1], 1, u_size, yuv420p_file);
//                fwrite(avframe_yuv420 -> data[2], 1, v_size, yuv420p_file);
//
//                decodeIndex++;
//                //                av_log(NULL, 1, "解码到第%ld帧了",decodeIndex);
//                //nslog(@"解码到第%ld帧了",decodeIndex);
//            }
//        }
//    }
//
//    //第七步:关闭资源
//    av_packet_free(&packet);
//    fclose(yuv420p_file);
//    av_frame_free(&avframe_in);
//    av_frame_free(&avframe_yuv420);
//    free(data);
//    avcodec_close(avcodec_context);
//    avformat_free_context(avformat_context);
//    //nslog(@"视频解码完成");
//}
//
//- (void)ffpmegDecodeAudioInPath:(NSString *)inPath outPath:(NSString *)outPath {
//
//    //第一步：组册组件
//
//    //第二步：打开封装格式->打开文件
//
//    //参数一：封装格式上下文
//
//    //作用：保存整个视频信息(解码器、编码器等等...)
//
//    //信息：码率、帧率等...
//
//    avformat_context = avformat_alloc_context();
//
//    //参数二：视频路径
//
//    const char *url = [inPath UTF8String];
//
//    //参数三：指定输入的格式
//
//    //参数四：设置默认参数
//
//    int avformat_open_input_result = avformat_open_input(&avformat_context, url,NULL, NULL);
//
//    if (avformat_open_input_result != 0){
//
//        //nslog(@"打开文件失败");
//
//        return;
//
//    }
//
//    //nslog(@"打开文件成功");
//
//    //第三步：拿到视频基本信息
//
//    //参数一：封装格式上下文
//
//    //参数二：指定默认配置
//
//    int avformat_find_stream_info_result = avformat_find_stream_info(avformat_context,NULL);
//
//    if (avformat_find_stream_info_result <0){
//
//        //nslog(@"查找失败");
//        return;
//
//    }
//
//    //第四步：查找音频解码器
//
//    //第一点：查找音频流索引位置
//
//    int av_stream_index = -1;
//
//    for (int i =0; i < avformat_context->nb_streams; ++i) {
//
//        if (avformat_context->streams[i]->codecpar -> codec_type == AVMEDIA_TYPE_AUDIO){
//
//            av_stream_index = i;
//            break;
//
//        }
//
//    }
//
//    //第二点：获取音频解码器上下文
//    AVCodecParameters *codecParameters = avformat_context -> streams[av_stream_index]->codecpar;
//    //根据解码器上下文拿到解码器id ,然后得到解码器
//    AVCodec *decodeCodec = avcodec_find_decoder(codecParameters->codec_id);
//    if (decodeCodec == NULL){
//        //nslog(@"查找音频解码器失败");
//        return;
//
//    }
//    //根据视频流的index拿到解码器上下文
//    AVCodecContext *avcodec_context = avcodec_alloc_context3(decodeCodec);
//    if (avcodec_context == NULL) {
//        //nslog(@"查找解码器上下文失败");
//        return;
//    }
//
//    int ret = avcodec_parameters_to_context(avcodec_context, codecParameters);
//    if (ret < 0) {
//        //nslog(@"avcodec_parameters_to_context失败");
//        return;
//    }
//    //第五步：打开音频解码器
//    ret = avcodec_open2(avcodec_context, decodeCodec, NULL);
//    if (ret < 0){
//        //nslog(@"打开音频解码器失败");
//        return;
//    }
//
//    struct TMSAudioInformation audioInformation;
//    audioInformation.format = AV_SAMPLE_FMT_S16;
//    audioInformation.channels = 2;
//    audioInformation.buffer_size = av_samples_get_buffer_size(NULL,
//                                                              audioInformation.channels,
//                                                              avcodec_context->frame_size,
//                                                              audioInformation.format, 1);
//    audioInformation.rate = avcodec_context->sample_rate;
//    audioInformation.bytesPerSample = audioInformation.channels * av_get_bytes_per_sample(audioInformation.format);
//    audioInformation.bitsPerChannel = 8 * av_get_bytes_per_sample(audioInformation.format);
//
//    self.audioPlayer = [[TMSAudioQueuePlayer alloc] initWithAudioInformation:audioInformation delegate:(id)self];
//
//    //nslog(@"=================== Audio Information ===================");
//    //nslog(@"Sample Rate: %d", avcodec_context->sample_rate);
//    //nslog(@"FMT: %d, %s", avcodec_context->sample_fmt, av_get_sample_fmt_name(avcodec_context->sample_fmt));
//    //nslog(@"Channels: %d", avcodec_context->channels);
//    //nslog(@"Channel Layout: %llu", avcodec_context->channel_layout);
//    //nslog(@"Decodec: %s", decodeCodec->long_name);
//    //nslog(@"=========================================================");
//
//    //第六步：读取音频压缩数据->循环读取
//
//    //创建音频压缩数据帧
//
//    //音频压缩数据->acc格式、mp3格式
//
//    //创建音频采样数据帧
//
//    AVFrame* avframe = av_frame_alloc();
//
//    //音频采样上下文->开辟了一快内存空间->pcm格式等...
//
//    //设置参数
//
//    //参数一：音频采样数据上下文
//
//    //上下文：保存音频信息(记录)->目录
//
//    //参数二：out_ch_layout->输出声道布局类型(立体声、环绕声、机器人等等...)
//
//    //立体声
//    int64_t out_ch_layout = AV_CH_LAYOUT_STEREO;
//
//    //参数三：out_sample_fmt->输出采样精度->编码
//    //直接指定
//    enum AVSampleFormat out_sample_fmt = AV_SAMPLE_FMT_S16;
//
//    //例如：采样精度8位 = 1字节，采样精度16位 = 2字节
//
//    //参数四：out_sample_rate->输出采样率(44100HZ)
//    int out_sample_rate = avcodec_context->sample_rate;
//
//    //参数五：in_ch_layout->输入声道布局类型
//    int64_t in_ch_layout = avcodec_context->channel_layout;
//
//    //参数六：in_sample_fmt->输入采样精度
//    enum AVSampleFormat in_sample_fmt = avcodec_context->sample_fmt;
//
//    //参数七：in_sample_rate->输入采样率
//    int in_sample_rate = avcodec_context->sample_rate;
//
//    //参数八：log_offset->log日志->从那里开始统计
//    int log_offset =0;
//
//    //参数九：log_ctx->log上下文
//    SwrContext* swr_context = swr_alloc_set_opts(NULL,
//                                                 out_ch_layout,
//                                                 out_sample_fmt,
//                                                 out_sample_rate,
//                                                 in_ch_layout,
//                                                 in_sample_fmt,
//                                                 in_sample_rate,
//                                                 log_offset,NULL);;
//
//
//    //初始化音频采样数据上下文
//    swr_init(swr_context);
//
////    //输出音频采样数据
////
////    //缓冲区大小 = 采样率(44100HZ) * 采样精度(16位 = 2字节)
////
////    int MAX_AUDIO_SIZE =44100 * 2;
////
////    uint8_t *out_buffer = (uint8_t *)av_malloc(MAX_AUDIO_SIZE);
////
////    //输出声道数量
////    int out_nb_channels = av_get_channel_layout_nb_channels(out_ch_layout);
//
//
//    //打开文件
////    const char *coutFilePath = [outPath UTF8String];
////
////    FILE* out_file_pcm = fopen(coutFilePath,"wb");
////
////    if (out_file_pcm ==NULL){
////
////        //nslog(@"打开音频输出文件失败");
////        return;
////
////    }
//
//    //计算：4分钟一首歌曲 = 240ms = 4MB
//
//    //现在音频时间：24ms->pcm格式->8.48MB
//
//    //如果是一首4分钟歌曲->pcm格式->85MB
//
//    self.decodeComplete = NO;
//
//    self.playState = TMSPlayStateLoading;
//
//    dispatch_async(decode_dispatch_queue, ^{
//
//        int current_index = 0;
//
//        while (true) {
//
//            float oneFrameDuration = avcodec_context->frame_size * 1.0f * av_get_bytes_per_sample(avcodec_context->sample_fmt) * avcodec_context->channels / avcodec_context->sample_rate;
//
//            float audioCacheDuration = [_audioFrameCacheQueue count] * oneFrameDuration;
//            if(audioCacheDuration >= MAX_AUDIO_FRAME_DURATION) {
//                //nslog(@"Decode wait...");
//                if(self.playState == TMSPlayStateLoading) {
//                    self.playState = TMSPlayStatePlaying;
//                    [self.audioPlayer play];
//                }
//                _SleepThread(self.decodeCondition);
//                //nslog(@"Decode resume");
//            }
//
//            av_packet_unref(packet);
//            int ret = av_read_frame(avformat_context, packet);
//            if (ret) {
//
//                //nslog(@"stream_index-->%d", packet->stream_index);
//                if (packet->stream_index == av_stream_index) {
//
//                    uint64_t duration = avformat_context->streams[av_stream_index]->duration;
//                    float unit = av_q2d(avcodec_context->time_base);
//                    //nslog(@"【PTS】【Audio】: %f, duration: %lld, last: %lld", packet->pts * unit, duration, packet->duration);
//                    int buffer_size = audioInformation.buffer_size;
//
//                    TMSQueueAudioObject *obj = [[TMSQueueAudioObject alloc] initWithLength:buffer_size pts:packet->pts * unit duration:packet->duration * unit];
//                    uint8_t *buffer = obj.data;
//                    int64_t bufferSize = 0;
//
//                    //第七步：音频解码
//
//                    //1、发送一帧音频压缩数据包->音频压缩数据帧ios ffmpeg 视频编码
//
//    //                av_packet_unref(avpacket);
//                    int ret = avcodec_send_packet(avcodec_context, packet);
//
//                    //2、解码一帧音频压缩数据包->得到->一帧音频采样数据->音频采样数据帧
//    //                av_frame_unref(avframe);
//                    ret = avcodec_receive_frame(avcodec_context, avframe);
//                    if (ret == 0){
//
//                        //表示音频压缩数据解码成功
//
//                        //3、类型转换(音频采样数据格式有很多种类型)
//
//                        //我希望我们的音频采样数据格式->pcm格式->保证格式统一->输出PCM格式文件
//
//                        //swr_convert:表示音频采样数据类型格式转换器
//
//                        //参数一：音频采样数据上下文
//
//                        //参数二：输出音频采样数据
//
//                        //参数三：输出音频采样数据->大小
//
//                        //参数四：输入音频采样数据
//
//                        //参数五：输入音频采样数据->大小
//
//                        ret = swr_convert(swr_context,
//                                    &buffer,
//                                    avframe->nb_samples,
//                                    (const uint8_t **)avframe->data,
//                                    avframe->nb_samples);
//                        bufferSize = ret * audioInformation.bytesPerSample;
//
//                        [obj updateLength:bufferSize];
//                        [self.audioFrameCacheQueue enqueue:obj];
//                        audioCacheDuration = [self.audioFrameCacheQueue count] * oneFrameDuration;
//                        /// 通知音频渲染队列可以继续渲染了
//                        /// 如果音频渲染队列未暂停则无作用
//                        if(audioCacheDuration >= MIN_AUDIO_FRAME_DURATION) {
//                            _NotifyWaitThreadWakeUp(self.audioPlayCondition);
//                        }
//
//                        //参数四：输出音频采样数据格式
//
//                        //参数五：字节对齐方式
//
//    //                    int out_buffer_size = av_samples_get_buffer_size(NULL,
//    //                                                                     out_nb_channels,
//    //                                                                     nb_samples,
//    //                                                                     out_sample_fmt,
//    //                                                                     1);
//
//                        //5、写入文件(你知道要写多少吗？)
//
//    //                    fwrite(out_buffer,1, out_buffer_size, out_file_pcm);
//
//                        current_index++;
//
//                        //nslog(@"当前音频解码第%d帧", current_index);
//
//                    }
//                }
//
//            } else {
//                /// read end of file
//                if(ret == AVERROR_EOF) {
//                    pthread_mutex_lock(&(mutex));
//                    self.decodeComplete = YES;
//                    pthread_mutex_unlock(&(mutex));
//                }
//            }
//
//            pthread_mutex_lock(&(mutex));
//            BOOL isDecodeComplete = self.isDecodeComplete;
//            pthread_mutex_unlock(&(mutex));
//            if(isDecodeComplete) break;
//        }
//
//        av_packet_free(&packet);
//
//        swr_free(&swr_context);
//
////        av_free(out_buffer);
//
//        av_frame_free(&avframe);
//
//        avcodec_close(avcodec_context);
//
//        avformat_free_context(avformat_context);
//        //nslog(@"音频解码完成");
//
//    });
//
//}

//- (void)ffpmegDecodeAudioWithInPath:(NSString *)inPath {
//
//    avformat_context = avformat_alloc_context();
//
//    const char *url = [inPath UTF8String];
//
//    int ret = avformat_open_input(&avformat_context, url,NULL, NULL);
//
//    if (ret !=0){
//        //nslog(@"打开文件失败");
//        return;
//    }
//
//    //nslog(@"打开文件成功");
//    ret = avformat_find_stream_info(avformat_context,NULL);
//
//    if (ret <0){
//        //nslog(@"查找失败");
//        return;
//    }
//
//    int av_stream_index = -1;
//    for (int i =0; i < avformat_context->nb_streams; ++i) {
//        //判断是否是音频流
//        if (avformat_context->streams[i]->codecpar -> codec_type == AVMEDIA_TYPE_AUDIO){
//
//            av_stream_index = i;
//            break;
//        }
//    }
//
//    self.mediaAudioContext = [[TMSMediaAudioContext alloc] initWithAVStream:avformat_context->streams[av_stream_index]
//                                                         formatContext:avformat_context];
//    self.audioPlayer = [[TMSAudioQueuePlayer alloc] initWithAudioInformation:self.mediaAudioContext.audioInformation delegate:(id)self];
//
//    self.decodeComplete = NO;
//
//    self.playState = TMSPlayStateLoading;
//    [self decode];
//
//}

//- (void)ffpmegDecodeVideoWithInPath:(NSString *)inPath {
//
//    avformat_context = avformat_alloc_context();
//
//    const char *url = [inPath UTF8String];
//
//    int ret = avformat_open_input(&avformat_context, url,NULL, NULL);
//
//    if (ret !=0){
//        //nslog(@"打开文件失败");
//        return;
//    }
//
//    //nslog(@"打开文件成功");
//    ret = avformat_find_stream_info(avformat_context,NULL);
//
//    if (ret <0){
//        //nslog(@"查找失败");
//        return;
//    }
//
//    int av_stream_index = -1;
//    for (int i =0; i < avformat_context->nb_streams; ++i) {
//        //判断是否是音频流
//        if (avformat_context->streams[i]->codecpar -> codec_type == AVMEDIA_TYPE_VIDEO){
//            av_stream_index = i;
//            break;
//        }
//    }
//
//    self.mediaVideoContext = [[TMSMediaVideoContext alloc] initWithAVStream:avformat_context->streams[av_stream_index]
//                                                         formatContext:avformat_context];
//
//    self.videoPlayer = [[TMSVideoPlayer alloc] initWithQueue:video_render_dispatch_queue
//                                                     render:self.renderView
//                                                        fps:[self.mediaVideoContext fps]
//                                                      avctx:self.mediaVideoContext.codecContext
//                                                     stream:avformat_context->streams[av_stream_index]
//                                                   delegate:(id)self];
//
//
//    self.decodeComplete = NO;
//    self.playState = TMSPlayStateLoading;
//    [self decode];
//
//}

//- (BOOL)playWithFilePath:(NSString *)filePath {
//
//    avformat_context = avformat_alloc_context();
//    const char *url = [filePath UTF8String];
//
//    int ret = avformat_open_input(&avformat_context, url, NULL, NULL);
//    if(ret != 0) goto fail;
//
//    ret = avformat_find_stream_info(avformat_context, NULL);
//    if(ret < 0) goto fail;
//    if(avformat_context->nb_streams == 0) goto fail;
//    if(![self setupMediaContext]) goto fail;
//
//    self.decodeComplete = NO;
//    [self start];
//    return YES;
//fail:
//    if(avformat_context) {
//        avformat_close_input(&avformat_context);
//    }
//    return NO;
//}
//
//- (BOOL)setupMediaContext {
//
//    self.playState = TMSPlayStateNone;
//
//    for(int i = 0; i < avformat_context->nb_streams; i ++) {
//
//        AVStream *stream = avformat_context->streams[i];
//        enum AVMediaType mediaType = stream->codecpar->codec_type;
//        if(mediaType == AVMEDIA_TYPE_VIDEO) {
//            self.mediaVideoContext = [[TMSMediaVideoContext alloc] initWithAVStream:stream
//                                                                 formatContext:avformat_context];
//
//            if(!_mediaVideoContext) return NO;
//
//            [self.view addSubview:self.renderView];
//
//            self.videoPlayer = [[TMSVideoPlayer alloc] initWithQueue:video_render_dispatch_queue
//                                                             render:self.renderView
//                                                                fps:[self.mediaVideoContext fps]
//                                                              avctx:self.mediaVideoContext.codecContext
//                                                             stream:stream
//                                                           delegate:self];
//
//            self->tolerance_scope = 1.0f / av_q2d(stream->avg_frame_rate);
//
//        } else if(mediaType == AVMEDIA_TYPE_AUDIO) {
//
//            self.mediaAudioContext = [[TMSMediaAudioContext alloc] initWithAVStream:stream
//                                                                 formatContext:avformat_context];
//
//            self.audioPlayer = [[TMSAudioQueuePlayer alloc] initWithAudioInformation:self.mediaAudioContext.audioInformation delegate:self];
//
//        }
//    }
//    return YES;
//}
//- (void)start {
//
//    self.playState = TMSPlayStateLoading;
//    [self decode];
//    self->audio_clock = 0;
//    self->video_clock = 0;
//
//}
//
//- (void)stop {
//    [self stopVideoPlay];
//    [self stopAudioPlay];
//}
//
//- (void)decode {
//
//    dispatch_async(decode_dispatch_queue, ^{
//        while (true) {
//
//            if (self.exitPage) {
//                return;
//            }
//
//            float audioCacheDuration = [self.audioFrameCacheQueue count] * [self.mediaAudioContext oneFrameDuration];
//            float videoCacheDuration = [self.videoFrameCacheQueue count] * [self.mediaVideoContext oneFrameDuration];
//
//            //nslog(@"【Cache】%f, %f", videoCacheDuration, audioCacheDuration);
//
//            if((!self.mediaVideoContext || videoCacheDuration >= MAX_AUDIO_FRAME_DURATION) &&
//               (!self.mediaAudioContext || audioCacheDuration >= MAX_VIDEO_FRAME_DURATION)) {
//                NSLog(@"Decode wait...");
//                if(self.playState == TMSPlayStateLoading) {
//                    self.playState = TMSPlayStatePlaying;
//                    [self startAudioPlay];
//                    [self startVideoPlay];
//                }
//                _SleepThread(self.decodeCondition);
//                NSLog(@"Decode resume");
//            }
//
//            av_packet_unref(self->packet);
//            int ret_code = av_read_frame(self->avformat_context, self->packet);
//            if(ret_code >= 0) {
//                if (self.mediaVideoContext && self->packet->stream_index == self.mediaVideoContext.streamIndex) {
//
//                    uint64_t duration = self->avformat_context->streams[self.mediaVideoContext.streamIndex]->duration;
//
//                    TMSQueueVideoObject *obj = [[TMSQueueVideoObject alloc] init];
//                    float unit = av_q2d(self->avformat_context->streams[self.mediaVideoContext.streamIndex]->time_base);
//                    obj.unit = unit;
//                    AVFrame *frame = obj.frame;
//                    BOOL ret = [self.mediaVideoContext decodePacket:self->packet frame:&frame];
//                    obj.pts = obj.frame->pts * unit;
//                    obj.duration = [self.mediaVideoContext oneFrameDuration];
////                        NSLog(@"【PTS】【Video】: %f, duration: %lld, last: %lld, repeat: %d", frame->pts * unit, duration, self->packet->duration, frame->repeat_pict);
//                    if(ret) {
//                        [self.videoFrameCacheQueue enqueue:obj];
//                        videoCacheDuration = [self.videoFrameCacheQueue count] * [self.mediaVideoContext oneFrameDuration];
//                        /// 通知视频渲染队列可以继续渲染了
//                        /// 如果视频渲染队列未暂停则无作用
//                        if(videoCacheDuration >= MIN_VIDEO_FRAME_DURATION) {
//                            _NotifyWaitThreadWakeUp(self.videoRenderCondition);
//                        }
//                    }
//
//                } else if(self.mediaAudioContext && self->packet->stream_index == self.mediaAudioContext.streamIndex) {
//
//                    uint64_t duration = self->avformat_context->streams[self.mediaAudioContext.streamIndex]->duration;
//                    float unit = av_q2d(self.mediaAudioContext.codecContext->time_base);
//                    //nslog(@"【PTS】【Audio】: %f, duration: %lld, last: %lld", self->packet->pts * unit, duration, self->packet->duration);
//                    int buffer_size = self.mediaAudioContext.audioInformation.buffer_size;
//                    TMSQueueAudioObject *obj = [[TMSQueueAudioObject alloc] initWithLength:buffer_size pts:self->packet->pts * unit duration:self->packet->duration * unit];
//                    uint8_t *buffer = obj.data;
//                    int64_t bufferSize = 0;
//                    BOOL ret = [self.mediaAudioContext decodePacket:self->packet outBuffer:&buffer outBufferSize:&bufferSize];
//                    if(ret) {
//                        [obj updateLength:bufferSize];
//                        [self.audioFrameCacheQueue enqueue:obj];
//                        audioCacheDuration = [self.audioFrameCacheQueue count] * [self.mediaAudioContext oneFrameDuration];
//                        /// 通知音频渲染队列可以继续渲染了
//                        /// 如果音频渲染队列未暂停则无作用
//                        if(audioCacheDuration >= MIN_AUDIO_FRAME_DURATION) {
//                            _NotifyWaitThreadWakeUp(self.audioPlayCondition);
//                        }
//                    }
//
//                }
//            } else {
//                /// read end of file
//                if(ret_code == AVERROR_EOF) {
//                    pthread_mutex_lock(&(self->mutex));
//                    self.decodeComplete = YES;
//                    pthread_mutex_unlock(&(self->mutex));
//                }
//            }
//            pthread_mutex_lock(&(self->mutex));
//            BOOL isDecodeComplete = self.isDecodeComplete;
//            pthread_mutex_unlock(&(self->mutex));
//            if(isDecodeComplete) break;
//        }
//        NSLog(@"Decode completed, read end of file.");
//    });
//}
//
//#pragma mark - Video
//- (void)startVideoPlay {
//    if(self.mediaVideoContext) {
//        [self.videoPlayer startPlay];
//    }
//}
//
//- (void)stopVideoPlay {
//    if(self.mediaVideoContext) {
//        [self.videoPlayer stopPlay];
//    }
//}
//
//#pragma mark - TMSVideoPlayerDelegate
//- (void)readNextVideoFrame {
//
//    dispatch_async(video_render_dispatch_queue, ^{
//
//        float videoCacheDuration = [self.videoFrameCacheQueue count] * [self.mediaVideoContext oneFrameDuration];
//        pthread_mutex_lock(&(self->mutex));
//        BOOL isDecodeComplete = self.isDecodeComplete;
//        pthread_mutex_unlock(&(self->mutex));
//        if(videoCacheDuration < MIN_VIDEO_FRAME_DURATION && !isDecodeComplete) {
//            //nslog(@"Video is not enough, wait...");
//            _NotifyWaitThreadWakeUp(self.decodeCondition);
//            _SleepThread(self.videoRenderCondition);
//        }
//        if(videoCacheDuration < MAX_VIDEO_FRAME_DURATION) {
//            _NotifyWaitThreadWakeUp(self.decodeCondition);
//        }
//        TMSQueueVideoObject *obj = [self _readNextVideoFrameBySyncAudio];
////        TMSQueueVideoObject *obj = [self.videoFrameCacheQueue dequeue];
//        if(obj) {
//            [self.videoPlayer renderFrame:obj.frame];
//        } else {
//            if(isDecodeComplete) {
//                NSLog(@"Video frame render completed.");
//                [self.videoPlayer stopPlay];
//            }
//        }
//    });
//}
//
//- (void)updateVideoClock:(float)pts duration:(float)duration {
//    pthread_mutex_lock(&mutex);
//    video_clock = pts + duration;
//    pthread_mutex_unlock(&mutex);
//}
//
//- (TMSQueueVideoObject *)_readNextVideoFrameBySyncAudio {
//
//    pthread_mutex_lock(&(self->mutex));
//    /// 读取当前的音频时钟时间
//    double ac = self->audio_clock;
//    pthread_mutex_unlock(&(self->mutex));
//    TMSQueueVideoObject *obj = NULL;
//    /// 统计路过的视频帧数量
//    int readCount = 0;
//    /// 首先读取一帧视频数据
//    obj = [self.videoFrameCacheQueue dequeue];
//    readCount ++;
//    /// 计算当前视频帖播放结束时的时间点
//    double vc = obj.pts + obj.duration;
//    NSLog(@"[Sync] AC: %f, VC: %f, 差值: %f, syncDuration: %f", ac, vc, fabs(ac - vc), self->tolerance_scope);
//    if(ac - vc > self->tolerance_scope) {
//        /// 视频太慢,丢弃当前帧继续读取下一帧
//        /// 这里认为读取下一帧或者更下一帧不会造成视频缓冲队列枯竭,所以未做等待处理
//        /// 因为时时同步能形成的时间差比较有限
//        while (ac - vc > self->tolerance_scope) {
//            TMSQueueVideoObject *_nextObj = [self.videoFrameCacheQueue dequeue];
//            if(!_nextObj) break;
//            obj = _nextObj;
//            vc = obj.pts + obj.duration;
//            readCount ++;
//        }
//        NSLog(@"[Sync]音频太快,视频追赶跳过: %d 帧", (readCount - 1));
//    } else if (vc - ac > self->tolerance_scope) {
//        /// 视频太快,暂停一下再接着渲染显示当前视频帧
//        float sleep_time = vc - ac;
//        NSLog(@"[Sync]视频太快,视频等待:%f", sleep_time);
//        usleep(sleep_time * 1000 * 1000);
//    } else {
//        NSLog(@"[Sync]音频在误差允许范围内: %f, %f", fabs(ac - vc), self->tolerance_scope);
//    }
//    return obj;
//}
//
//#pragma mark - Audio
//- (void)startAudioPlay {
//    if(self.mediaAudioContext) {
//        [self.audioPlayer play];
//    }
//}
//- (void)stopAudioPlay {
//    if(self.mediaAudioContext) {
//        [self.audioPlayer stop];
//    }
//}
//
//- (void)readNextAudioFrame:(AudioQueueBufferRef)aqBuffer {
//    dispatch_async(audio_play_dispatch_queue, ^{
//
//        float audioCacheDuration = [self->_audioFrameCacheQueue count] * [self->_mediaAudioContext oneFrameDuration];
//        pthread_mutex_lock(&(self->mutex));
//        BOOL isDecodeComplete = self.isDecodeComplete;
//        pthread_mutex_unlock(&(self->mutex));
//        if(audioCacheDuration < MIN_AUDIO_FRAME_DURATION && !isDecodeComplete) {
//            //nslog(@"Audio is not enough, wait…");
//            _NotifyWaitThreadWakeUp(self.decodeCondition);
//            _SleepThread(self.audioPlayCondition);
//        }
//        TMSQueueAudioObject *obj = [self.audioFrameCacheQueue dequeue];
//        if(audioCacheDuration < MAX_AUDIO_FRAME_DURATION) {
//            _NotifyWaitThreadWakeUp(self.decodeCondition);
//        }
//        if(obj) {
//            [self.audioPlayer receiveData:obj.data length:obj.length aqBuffer:aqBuffer pts:obj.pts duration:obj.duration];
//        } else {
//            if(isDecodeComplete) {
//                //nslog(@"Audio frame play completed.");
//                [self.audioPlayer stop];
//            }
//        }
//    });
//}
//
//- (void)updateAudioClock:(float)pts duration:(float)duration {
//    pthread_mutex_lock(&mutex);
//    audio_clock = pts + duration;
//    pthread_mutex_unlock(&mutex);
//}
//
//- (void)dealloc {
//
//    if(avformat_context) {
//        avformat_close_input(&avformat_context);
//        avformat_free_context(avformat_context);
//    }
//    if(packet) {
//        av_packet_unref(packet);
//        av_packet_free(&packet);
//    }
//    pthread_mutex_destroy(&mutex);
//
//    [self stop];
//
//    NSLog(@"%@--dealloc", NSStringFromClass([self class]));
//}
//
//- (TMSGLRenderView *)renderView{
//
//    if (!_renderView) {
//        _renderView = [[TMSGLRenderView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    }
//    return _renderView;
//}
@end
