//
//  TMSAudioUnit.h
//  FFMpegTest
//
//  Created by santian_mac on 2021/7/15.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TMSAudioUnitRecordDelegate <NSObject>

- (void)encodeAudioWithSourceBuffer:(void *)sourceBuffer
                   sourceBufferSize:(UInt32)sourceBufferSize
                                pts:(int64_t)pts;

@end

@interface TMSAudioUnit : NSObject
{
    AudioStreamBasicDescription     dataFormat;
    
@public
    AudioUnit                       m_audioUnit;
    AudioBufferList                 *m_audioBufferList;
}
@property (nonatomic, weak) id<TMSAudioUnitRecordDelegate> delegate;
- (void)startAudioUnitRecorder;  // start recorder
- (void)stopAudioUnitRecorder;   // stop recorder
@end

NS_ASSUME_NONNULL_END
