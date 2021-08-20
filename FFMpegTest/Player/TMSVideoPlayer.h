//
//  TMSVideoPlayer.h
//  FFMpegTest
//
//  Created by TmmmS on 2021/7/10.
//

#import <Foundation/Foundation.h>
#import <libavcodec/avcodec.h>
#import <libavformat/avformat.h>

@class TMSGLRenderView;

NS_ASSUME_NONNULL_BEGIN

@protocol TMSVideoPlayerDelegate <NSObject>
- (void)readNextVideoFrame;
- (void)updateVideoClock:(float)pts duration:(float)duration;
@end

@interface TMSVideoPlayer : NSObject

@property (nonatomic, weak)id<TMSVideoPlayerDelegate> delegate;
- (instancetype)initWithQueue:(dispatch_queue_t)queue
                       render:(TMSGLRenderView *)videoRender
                          fps:(int)fps
                        avctx:(AVCodecContext *)avctx
                       stream:(AVStream *)stream
                     delegate:(id<TMSVideoPlayerDelegate>)delegate;
- (void)renderFrame:(AVFrame *)frame;
- (void)startPlay;
- (void)stopPlay;
@end

NS_ASSUME_NONNULL_END
