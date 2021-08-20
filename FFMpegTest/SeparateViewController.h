//
//  SeparateViewController.h
//  FFMpegTest
//
//  Created by TmmmS on 2021/7/3.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@interface SeparateViewController : UIViewController
- (void)readNextAudioFrame:(AudioQueueBufferRef)aqBuffer;
@end

NS_ASSUME_NONNULL_END
