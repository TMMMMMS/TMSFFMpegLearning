//
//  TMSMediaVideoContext.h
//  FFMpegTest
//
//  Created by TmmmS on 2021/7/10.
//

#import <Foundation/Foundation.h>
#import <libavcodec/avcodec.h>
#import <libavformat/avformat.h>
#import <libswscale/swscale.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMSMediaVideoContext : NSObject
@property(nonatomic, assign, readonly)NSInteger streamIndex;
/// 最后一帧的pts
@property(nonatomic, assign, readonly)int64_t lastFramePts;

/// 初始化VideoContext
/// @param stream 视频流AVStream
/// @param formatContext AVFormatContext
- (instancetype)initWithAVStream:(AVStream *)stream
                   formatContext:(nonnull AVFormatContext *)formatContext;
- (AVCodecContext *)codecContext;
- (int)fps;
- (BOOL)decodePacket:(AVPacket *)packet frame:(AVFrame *_Nonnull*_Nonnull)frame;
- (float)oneFrameDuration;
@end

NS_ASSUME_NONNULL_END
