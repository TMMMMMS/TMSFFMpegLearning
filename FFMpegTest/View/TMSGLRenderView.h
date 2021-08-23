//
//  TMSGLRenderView.h
//  FFMpegTest
//
//  Created by TmmmS on 2021/7/10.
//

#import <UIKit/UIKit.h>
#import <libavcodec/avcodec.h>
#import <libavformat/avformat.h>

@class TMSMediaVideoContext;

NS_ASSUME_NONNULL_BEGIN

@interface TMSGLRenderView : UIView
- (void)displayWithFrame:(AVFrame *)yuvFrame;
@end

NS_ASSUME_NONNULL_END
