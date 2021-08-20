//
//  TMSMediaVideoContext.m
//  FFMpegTest
//
//  Created by TmmmS on 2021/7/10.
//

#import "TMSMediaVideoContext.h"
#import "TMSFilter.h"

@interface TMSMediaVideoContext ()
{
    AVFormatContext *formatContext;
    AVStream *stream;
    AVCodec *codec;
    AVCodecContext *codecContext;
    int streamIndex;
    AVFrame *frame;
}
@property (nonatomic, strong)TMSFilter *filter;
@property(nonatomic, assign)int64_t lastFramePts;
@end
    
@implementation TMSMediaVideoContext
- (void)dealloc {
    if(self->codecContext) {
        avcodec_close(codecContext);
        avcodec_free_context(&codecContext);
    }
    if(frame) {
        av_frame_unref(frame);
        av_frame_free(&frame);
    }
}
- (instancetype)initWithAVStream:(AVStream *)stream
                   formatContext:(nonnull AVFormatContext *)formatContext {
    self = [super init];
    if(self) {
        self->stream = stream;
        self->formatContext = formatContext;
        if(![self setupDecode]) {
            return NULL;
        }
        self.filter = [[TMSFilter alloc] initWithCodecContext:codecContext
                                               formatContext:formatContext
                                                      stream:formatContext->streams[streamIndex]];
        if(!self.filter) {
            return NULL;
        }
        [self setupLastPacketPts];
        self->frame = av_frame_alloc();
    }
    return self;
}
#pragma mark -
- (BOOL)setupDecode {
    
    int ret = 0;
    AVCodecParameters *codecParameters = stream->codecpar;
    self->codec = avcodec_find_decoder(codecParameters->codec_id);
    if(!(self->codec)) goto fail;
    self->codecContext = avcodec_alloc_context3(self->codec);
    if(!(self->codecContext)) goto fail;
    ret = avcodec_parameters_to_context(self->codecContext, codecParameters);
    if(ret < 0) goto fail;
    
    ret = avcodec_open2(self->codecContext, self->codec, NULL);
    if(ret < 0) goto fail;
    
    NSLog(@"=================== Video Information ===================");
    NSLog(@"FPS: %f", av_q2d(stream->avg_frame_rate));
    NSLog(@"Duration: %d Seconds", (int)(stream->duration * av_q2d(stream->time_base)));
    NSLog(@"Size: (%d, %d)", self->codecContext->width, self->codecContext->height);
    NSLog(@"Decodec: %s", self->codec->long_name);
    NSLog(@"=========================================================");
    return YES;
fail:
    return NO;
}
- (void)setupLastPacketPts {
    int64_t duration = stream->duration;
    AVRational time_base = stream->time_base;
    AVRational fps = stream->avg_frame_rate;
    _lastFramePts = duration - time_base.den / fps.num;
}

#pragma mark - Public
- (NSInteger)streamIndex {
    return self->stream->index;
}
- (AVCodecContext *)codecContext {
    return self->codecContext;
}
- (int)fps {
    return av_q2d(stream->avg_frame_rate);
}
- (BOOL)decodePacket:(AVPacket *)packet frame:(AVFrame **)frame {
    
    int ret = avcodec_send_packet(self.codecContext, packet);
    if(ret != 0) return NO;
    AVFrame *outputFrame = *frame;
    ret = avcodec_receive_frame(self.codecContext, self->frame);
    if(ret != 0) return NO;
//    switch (self->frame->pict_type) {
//        case AV_PICTURE_TYPE_I:
//            NSLog(@"I帧");
//            break;
//        case AV_PICTURE_TYPE_P:
//            NSLog(@"P帧");
//            break;
//        case AV_PICTURE_TYPE_B:
//            NSLog(@"B帧");
//            break;
//        default:
//            break;
//    }
    if(ret != 0) return NO;
    
    [self.filter getTargetFormatFrameWithInputFrame:self->frame
                                outputFrame:&outputFrame];
    return YES;
}

- (float)oneFrameDuration {
    float d = 1.0f / av_q2d(stream->avg_frame_rate);
    return d;
}
@end
