//
//  TMSFilter.h
//  FFMpegTest
//
//  Created by santian_mac on 2021/7/13.
//

#import <Foundation/Foundation.h>
#import <libavcodec/avcodec.h>
#import <libavformat/avformat.h>
#import <libavfilter/avfilter.h>
#import <libavfilter/buffersrc.h>
#import <libavfilter/buffersink.h>
#import <libavutil/opt.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMSFilter : NSObject
- (instancetype)initWithCodecContext:(AVCodecContext *)codecContext
                       formatContext:(AVFormatContext *)formatContext
                              stream:(AVStream *)stream;
- (BOOL)getTargetFormatFrameWithInputFrame:(AVFrame *)inputFrame outputFrame:(AVFrame *_Nonnull*_Nonnull)outputFrame;
@end

NS_ASSUME_NONNULL_END
