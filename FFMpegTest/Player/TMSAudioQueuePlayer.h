//
//  TMSAudioQueuePlayer.h
//  FFMpegTest
//
//  Created by TmmmS on 2021/7/7.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "TMSAudioInformation.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TMSAudioQueuePlayerDelegate <NSObject>
- (void)readNextAudioFrame:(AudioQueueBufferRef)aqBuffer;
- (void)updateAudioClock:(float)pts duration:(float)duration;
@end
@interface TMSAudioQueuePlayer : NSObject
- (instancetype)initWithAudioInformation:(struct TMSAudioInformation)audioInformation
                                delegate:(id<TMSAudioQueuePlayerDelegate>)delegate;
- (void)receiveData:(uint8_t *)data length:(int64_t)length
           aqBuffer:(AudioQueueBufferRef)aqBuffer
                pts:(float)pts
           duration:(float)duration;
- (void)reuseAudioQueueBuffer:(AudioQueueBufferRef)aqBuffer;
- (void)play;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
