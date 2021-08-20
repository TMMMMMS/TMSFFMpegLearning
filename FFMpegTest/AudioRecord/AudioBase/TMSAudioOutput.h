//
//  TMSAudioOutput.h
//  FFMpegTest
//
//  Created by santian_mac on 2021/7/23.
//

#import <Foundation/Foundation.h>
#import "TMSAudioInput.h"
#import "TMSAudioBufferData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TMSAudioOutput : NSObject

@property (nonatomic, assign) TMSAudioBufferData *bufferData;

@property (nonatomic, assign) AudioStreamBasicDescription audioDesc;

@property (nonatomic, copy, readonly) NSArray *targets;

//输入和输出不同时需要重载，比如格式转换组件
-(AudioStreamBasicDescription)outputAudioDescWithInputDesc:(AudioStreamBasicDescription)audioDesc;

//当前环节处理结束，调用此方法把数据传输到下一个环节，数据必须放在bufferData里
-(void)transportAudioBuffersToNext;

-(void)addTarget:(id<TMSAudioInput>)target;

@end

NS_ASSUME_NONNULL_END
