//
//  TMSConst.h
//  FFMpegTest
//
//  Created by santian_mac on 2021/7/15.
//

#ifndef TMSConst_h
#define TMSConst_h

#define kAudioAACFramesPerPacket                    1024
#define kAudioRecorderSampleRate                    44100
#define kAudioRecorderChannelCount                  2

#define kBitsPerChannel 32  //s16

#define WRITE_PCM_TO_DISK 0

#define INPUT_BUS  1 
#define OUTPUT_BUS 0

#define MAX_BUFFER_COUNT 3

#define MAX_AUDIO_FRAME_DURATION   2
#define MIN_AUDIO_FRAME_DURATION   1

#define MAX_VIDEO_FRAME_DURATION   2
#define MIN_VIDEO_FRAME_DURATION   1

#define TMSCheckStatus(status, log)    if(status != 0) {\
int bigEndian = CFSwapInt32HostToBig(status);\
char *statusTex = (char*)&bigEndian;\
NSLog(@"%@ error: %s",log,statusTex); return;\
}

#endif /* TMSConst_h */
