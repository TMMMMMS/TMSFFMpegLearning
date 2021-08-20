//
//  TMSH264Encoder.h
//  FFMpegTest
//
//  Created by santian_mac on 2021/7/14.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMSH264Encoder : NSObject
+ (instancetype)getInstance;
- (void)setFileSavedPath:(NSString *)path;
- (int)setEncoderVideoWidth:(int)width height:(int)height bitrate:(int)bitrate;
- (void)encoderToH264:(CMSampleBufferRef)sampleBuffer;
- (void)freeH264Resource;
@end

NS_ASSUME_NONNULL_END
