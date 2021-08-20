//
//  TMSAudioInput.h
//  FFMpegTest
//
//  Created by santian_mac on 2021/7/23.
//

#import <Foundation/Foundation.h>
#import "TMSAudioBufferData.h"

@protocol TMSAudioInput <NSObject>

-(void)setAudioDesc:(AudioStreamBasicDescription)audioDesc;
-(AudioStreamBasicDescription)audioDesc;

-(void)receiveNewAudioBuffers:(TMSAudioBufferData *)bufferData;

@optional

//inputIndex是在target里，当前类作为第几个输入源，用于多个输入源的TMSAudioInput，区分不同输入源，比如混音
-(void)receiveNewAudioBuffers:(TMSAudioBufferData *)bufferData inputIndex:(NSInteger)inputIndex;

@end
