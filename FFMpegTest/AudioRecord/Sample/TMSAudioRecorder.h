//
//  TMSAudioRecorder.h
//  FFMpegTest
//
//  Created by santian_mac on 2021/7/23.
//

#import "TMSAudioOutput.h"

NS_ASSUME_NONNULL_BEGIN

@interface TMSAudioRecorder : TMSAudioOutput

@property (nonatomic, assign, readonly) BOOL recording;

-(void)start;

-(void)stop;

@end

NS_ASSUME_NONNULL_END
