//
//  TMSAudioBufferData.h
//  FFMpegTest
//
//  Created by santian_mac on 2021/7/23.
//

#ifndef TMSAudioBufferData_h
#define TMSAudioBufferData_h

#import <AudioToolbox/AudioToolbox.h>

typedef struct{
    
    AudioBufferList *bufferList;
    UInt32 inNumberFrames;
    int refCount;
    
} TMSAudioBufferData;

#ifdef __cplusplus
extern "C" {
#endif

    TMSAudioBufferData *TMSCreateAudioBufferData(AudioBufferList *bufferList, UInt32 inNumberFrames);
    TMSAudioBufferData *TMSAllocAudioBufferData(AudioStreamBasicDescription audioDesc, UInt32 inNumberFrames);
    void TMSRefAudioBufferData(TMSAudioBufferData *bufferData);
    void TMSCopyAudioBufferData(TMSAudioBufferData **srcBufferData, TMSAudioBufferData **destBufferData);
    void TMSUnrefAudioBufferData(TMSAudioBufferData *bufferData);

#ifdef __cplusplus
}
#endif

#endif /* TMSAudioBufferData_h */
