//
//  TMSAudioBufferData.c
//  FFMpegTest
//
//  Created by santian_mac on 2021/7/23.
//

#include <stdio.h>
#include "TMSAudioBufferData.h"

TMSAudioBufferData *TMSCreateAudioBufferData(AudioBufferList *bufferList, UInt32 inNumberFrames){
    
    TMSAudioBufferData *bufferData = (TMSAudioBufferData*)malloc(sizeof(TMSAudioBufferData));
    if (bufferList) bufferData->bufferList = bufferList;
    bufferData->inNumberFrames = inNumberFrames;
    bufferData->refCount = 1;
    
    return bufferData;
}

TMSAudioBufferData *TMSAllocAudioBufferData(AudioStreamBasicDescription audioDesc, UInt32 inNumberFrames){
    
    AudioBufferList *bufferList = malloc(sizeof(AudioBufferList));
    
    /*kAudioFormatFlagIsNonInterleaved表示音频源是非交错的，在回调函数中需要对
          ioData->mBuffers数组分别填充各声道的数据。
          kAudioFormatFlagIsBigEndian可以指定大端存储的数据。
        */
    bool isNonInterleaved = audioDesc.mFormatFlags & kAudioFormatFlagIsNonInterleaved;
    if (isNonInterleaved) {
        bufferList->mNumberBuffers = 2;
        
        bufferList->mBuffers[0].mDataByteSize = inNumberFrames *
        audioDesc.mBytesPerFrame;
        bufferList->mBuffers[0].mNumberChannels = 1;
        bufferList->mBuffers[0].mData = malloc( bufferList->mBuffers[0].mDataByteSize ); // buffer size
        
        bufferList->mBuffers[1].mDataByteSize = bufferList->mBuffers[0].mDataByteSize;
        bufferList->mBuffers[1].mNumberChannels = bufferList->mBuffers[0].mNumberChannels;
        bufferList->mBuffers[1].mData = malloc( bufferList->mBuffers[0].mDataByteSize );
        
        memset(bufferList->mBuffers[0].mData, 0, bufferList->mBuffers[0].mDataByteSize);
        memset(bufferList->mBuffers[1].mData, 0, bufferList->mBuffers[0].mDataByteSize);
        
    }else{
        
        bufferList->mNumberBuffers = 1;
        
        bufferList->mBuffers[0].mDataByteSize = inNumberFrames *
        audioDesc.mBytesPerFrame;
        bufferList->mBuffers[0].mNumberChannels = audioDesc.mChannelsPerFrame;
        bufferList->mBuffers[0].mData = malloc( bufferList->mBuffers[0].mDataByteSize ); // buffer size
    }
    
    return TMSCreateAudioBufferData(bufferList, inNumberFrames);
}

void TMSRefAudioBufferData(TMSAudioBufferData *bufferData){
    bufferData->refCount = bufferData->refCount + 1;
}

void TMSCopyAudioBufferData(TMSAudioBufferData **srcBufferData, TMSAudioBufferData **destBufferData){
    (*srcBufferData)->refCount = (*srcBufferData)->refCount +1;
    *destBufferData = *srcBufferData;
}

void TMSUnrefAudioBufferData(TMSAudioBufferData *bufferData){
    
    bufferData->refCount = bufferData->refCount - 1;
    if (bufferData->refCount == 0) {
        
//        printf("free buffer data\n");
        free(bufferData);
    }
}
