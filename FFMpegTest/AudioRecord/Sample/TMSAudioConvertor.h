//
//  TMSAudioConvertor.h
//  FFMpegTest
//
//  Created by santian_mac on 2021/7/23.
//

#import "TMSAudioOutput.h"
#import "TMSAudioInput.h"

NS_ASSUME_NONNULL_BEGIN

@interface TMSAudioConvertor : TMSAudioOutput<TMSAudioInput>
/** 希望输出的格式，smaleRate设为0，则采取跟输入一样的sampleRate, 声道数也一样 */
@property (nonatomic, assign) AudioStreamBasicDescription outputDesc;
@end

NS_ASSUME_NONNULL_END
