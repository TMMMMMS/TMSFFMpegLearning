//
//  TMSAudioRecorder.m
//  FFMpegTest
//
//  Created by santian_mac on 2021/7/23.
//

#import "TMSAudioRecorder.h"
#import <AVFoundation/AVFoundation.h>

/*
 input bus / input element: 连接设备硬件输入端(如:麦克风)

 output bus / output element: 连接设备硬件输出端(如:扬声器)
 */

@interface TMSAudioRecorder ()
{
    AudioFileTypeID fileTypeID;
    AudioComponentInstance audioUnit;
    
    struct AudioBuffer audioBuffer;
    
    ExtAudioFileRef mAudioFileRef;
    
    NSMutableArray<id> *_targets;
}
@end

@implementation TMSAudioRecorder

- (void)start {
    
    OSStatus status;
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output; // we want to ouput
    desc.componentSubType = kAudioUnitSubType_RemoteIO; // we want in and ouput
    desc.componentFlags = 0; // must be zero
    desc.componentFlagsMask = 0; // must be zero
    desc.componentManufacturer = kAudioUnitManufacturer_Apple; // select provider
    
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    status = AudioComponentInstanceNew(inputComponent, &audioUnit);
    TMSCheckStatus(status, @"AudioComponentInstanceNew");
    
    // 启用输入端
    UInt32 flag = 1;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input, // 开启输入
                                  INPUT_BUS, //element1是硬件到APP的组件
                                  &flag, // 开启，输出YES
                                  sizeof(flag));
    TMSCheckStatus(status, @"enable input io");
    
    flag = 0;
    status = AudioUnitSetProperty(audioUnit,
                                      kAudioOutputUnitProperty_EnableIO,
                                      kAudioUnitScope_Output,
                                      OUTPUT_BUS,
                                      &flag,
                                      sizeof(flag));

    //音频流的格式，采样率 声道  样本类型等
    AudioStreamBasicDescription audioFormat;
    FillOutASBDForLPCM (audioFormat, kAudioRecorderSampleRate, kAudioRecorderChannelCount, kBitsPerChannel, kBitsPerChannel, true, false, false);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  INPUT_BUS,
                                  &audioFormat,
                                  sizeof(audioFormat));
    TMSCheckStatus(status, @"set record output format");
    
    //输出回调，在这里接收输出数据
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = recordingCallback;
    callbackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global,
                                  INPUT_BUS,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    TMSCheckStatus(status, @"SetInputCallback");

    flag = 0;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_ShouldAllocateBuffer,
                                  kAudioUnitScope_Input,
                                  INPUT_BUS,
                                  &flag,
                                  sizeof(flag));
    TMSCheckStatus(status, @"ShouldAllocateBuffer");

    status = AudioUnitInitialize(audioUnit);
    TMSCheckStatus(status, @"AudioUnitInitialize");
    
    self.audioDesc = audioFormat;  //tanspost to next unit
    
    //audio session
    NSError *error = nil;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setPreferredSampleRate:kAudioRecorderSampleRate error:&error];
    if (error) {
        NSLog(@"setPreferredSampleRate error");
        return;
    }
    
    [session setCategory:AVAudioSessionCategoryPlayAndRecord
             withOptions:AVAudioSessionCategoryOptionMixWithOthers
                   error:&error];
    if (error) {
        NSLog(@"setCategory error");
        return;
    }
    
    [session setActive:YES error:&error];
    if (error) {
        NSLog(@"active audio session error");
        return;
    }
    
    AudioOutputUnitStart(audioUnit);
    
    _recording = YES;
    
    NSLog(@"recorder started!!");
}

- (void)stop {
    
    AudioOutputUnitStop(audioUnit);
    AudioComponentInstanceDispose(audioUnit);
    
    ExtAudioFileDispose(mAudioFileRef);
    
    _recording = NO;
}

- (void)setupAudioBufferListWithNumberFrames:(UInt32)inNumberFrames {
    
    self.bufferData = TMSAllocAudioBufferData(self.audioDesc, inNumberFrames);
}

#pragma mark - audio unit callback

/*
     inRefCon:开发者自己定义的任何数据,一般将本类的实例传入,因为回调函数中无法直接调用OC的属性与方法,此参数可以作为OC与回调函数沟通的桥梁.即传入本类对象.

     ioActionFlags: 描述上下文信息

     inTimeStamp: 包含采样的时间戳

     inBusNumber: 调用此回调函数的总线数量

     inNumberFrames: 此次调用包含了多少帧数据

     ioData: 音频数据
 */
static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    
    OSStatus status;
    TMSAudioRecorder *audioRecorder = (__bridge TMSAudioRecorder* )inRefCon;

    //sampleRate是一秒钟的采样次数，不是样本数，每次采样形成一个frame，即一帧；每次采样，每个声道采样一次，也就是一个frame，n个channel,n个sample。只有在单声道时，sampleRate才等于一秒钟的样本数。
    
    if (!audioRecorder.bufferData) {
        [audioRecorder setupAudioBufferListWithNumberFrames:inNumberFrames];
    }
    
    //audio unit的数据导到AudioBufferList
    status = AudioUnitRender(audioRecorder->audioUnit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, audioRecorder.bufferData->bufferList);
    if (status != noErr) {
        NSLog(@"AudioUnitRender error");
    }
    
#if WRITE_PCM_TO_DISK
    
    static int createCount = 0;
    static FILE *vF = NULL;
    if (createCount == 0) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *audioDic = [audioRecorder getPCMFileDirectory];
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"yyyy_MM_dd__HH_mm_ss";
        NSString *newString = [format stringFromDate:[NSDate date]];
        NSString *pcmFilePath = [audioDic stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", newString, @"pcm"]];
        if(![fileManager fileExistsAtPath:audioDic])
        {
            [fileManager createDirectoryAtPath:audioDic withIntermediateDirectories:YES attributes:nil error:nil];
            
        }
        vF = fopen([pcmFilePath UTF8String], "wb++");
    }
    
    void    *bufferData = audioRecorder.bufferData->bufferList->mBuffers[0].mData;
    UInt32   bufferSize = audioRecorder.bufferData->bufferList->mBuffers[0].mDataByteSize;
    
    fwrite((uint8_t *)bufferData, 1, bufferSize, vF);
    
    createCount++;

#endif
    
    [audioRecorder transportAudioBuffersToNext];

    return noErr;
}

- (NSString *)getPCMFileDirectory {
    
    NSString *paths = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *audioDict = [paths stringByAppendingPathComponent:@"audio"];
    return audioDict;
}


@end
