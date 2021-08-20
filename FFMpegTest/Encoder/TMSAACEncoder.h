//
//  TMSAACEncoder.h
//  FFMpegTest
//
//  Created by TmmmS on 2021/7/17.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

struct TMSAudioEncderData {
    void    * _Nonnull data;
    int     size;
    int64_t pts;
    UInt32  outputPackets;
    AudioStreamPacketDescription *outputPacketDescriptions;
};

typedef struct TMSAudioEncderData *TMSAudioEncderDataRef;

NS_ASSUME_NONNULL_BEGIN

@interface TMSAACEncoder : NSObject
{
    @public
    AudioConverterRef           mAudioConverter;
    AudioStreamBasicDescription mDestinationFormat;
    AudioStreamBasicDescription mSourceFormat;
}

/**
 Init Audio Encoder
 @param sourceFormat source audio data format
 @param destFormatID destination audio data format
 @param isUseHardwareEncode Use hardware / software encode
 @return object.
 */
- (instancetype)initWithSourceFormat:(AudioStreamBasicDescription)sourceFormat
                        destFormatID:(AudioFormatID)destFormatID
                          sampleRate:(float)sampleRate
                 isUseHardwareEncode:(BOOL)isUseHardwareEncode;

/**
 Encode Audio Data
 @param sourceBuffer source audio data
 @param sourceBufferSize source audio data size
 @param pts audio data timestamp
 @param completeHandler get audio data after encoding
 */
- (void)encodeAudioWithSourceBuffer:(void *)sourceBuffer
                   sourceBufferSize:(UInt32)sourceBufferSize
                                pts:(int64_t)pts
                    completeHandler:(void(^)(TMSAudioEncderDataRef audioDataRef))completeHandler;


- (void)freeEncoder;

@end

NS_ASSUME_NONNULL_END
