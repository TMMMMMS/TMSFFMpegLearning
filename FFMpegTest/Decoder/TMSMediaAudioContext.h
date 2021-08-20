//
//  TMSMediaAudioContext.h
//  FFMpegTest
//
//  Created by TmmmS on 2021/7/7.
//

#import <Foundation/Foundation.h>
#import "TMSAudioInformation.h"
#import <libavcodec/avcodec.h>
#import <libavformat/avformat.h>
#import <libswscale/swscale.h>
#import <libavutil/imgutils.h>
#import <libswresample/swresample.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMSMediaAudioContext : NSObject
@property(nonatomic, assign, readonly)NSInteger streamIndex;
/// 最后一帧的pts
@property(nonatomic, assign, readonly)int64_t lastFramePts;

- (instancetype)initWithAVStream:(AVStream *)stream formatContext:(AVFormatContext *)formatContext;
- (BOOL)decodePacket:(AVPacket *)packet outBuffer:(uint8_t *_Nonnull* _Nonnull )buffer outBufferSize:(int64_t *)outBufferSize;
- (AVFormatContext *)formatContext;
- (AVCodecContext *)codecContext;
/// 播放器参数
- (struct TMSAudioInformation)audioInformation;
- (float)oneFrameDuration;
@end

NS_ASSUME_NONNULL_END
