//
//  TMSAACFileWriter.m
//  FFMpegTest
//
//  Created by santian_mac on 2021/7/23.
//

#import "TMSAACFileWriter.h"
#import <AVFoundation/AVFoundation.h>

@interface TMSAACFileWriter ()
{
    AudioStreamBasicDescription _audioDesc;
    
    AudioFileID audioFile;
    UInt32 packetIndex;
}
@end

@implementation TMSAACFileWriter

- (instancetype)init {
    
    if (self == [super init]) {
        _filePath = [self getDefaultFilePath];
    }
    return self;
}

- (NSString *)getDefaultFilePath {
    
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [[searchPaths objectAtIndex:0] stringByAppendingPathComponent:@"audio"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:documentPath]) {
        [fileManager createDirectoryAtPath:documentPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy_MM_dd_HH_mm_ss";
    NSString *newString = [format stringFromDate:[NSDate date]];
    
    NSString *fullFileName = [NSString stringWithFormat:@"%@.%@",newString,@"aac"];
    
    return [documentPath stringByAppendingPathComponent:fullFileName];
}

- (void)setFilePath:(NSString *)filePath {
    _filePath = [[filePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"aac"];
    [self setupAudioFile];
}

- (void)setAudioDesc:(AudioStreamBasicDescription)audioDesc {
    _audioDesc = audioDesc;
    [self setupAudioFile];
}

- (AudioStreamBasicDescription)audioDesc {
    return _audioDesc;
}

- (void)receiveNewAudioBuffers:(TMSAudioBufferData *)bufferData {
    [self audioFileWriteAudioBuffers:bufferData];
}

#pragma mark - AVAssetWriter
- (void)setupAudioFile {
    
    if (_audioDesc.mSampleRate == 0 || _filePath == nil) {
        return;
    }
    
    NSURL *fileURL = [NSURL fileURLWithPath:_filePath];
    OSStatus status = AudioFileCreateWithURL((__bridge CFURLRef)fileURL, kAudioFileAAC_ADTSType, &(_audioDesc), kAudioFileFlags_EraseFile, &audioFile);
    if (status != noErr) {
        NSLog(@"AudioFileCreateWithURL error");
    }
    
    packetIndex = 0;
    totalSize = 0;
}

float totalSize = 0;
- (void)audioFileWriteAudioBuffers:(TMSAudioBufferData *)bufferData {
    
    AudioBuffer inBuffer = bufferData->bufferList->mBuffers[0];
    
    //write packet kAudioFileAAC_ADTSType
    AudioStreamPacketDescription packetDesc = {0, 0, inBuffer.mDataByteSize};
    UInt32 packetNum = 1;
    
    OSStatus status = AudioFileWritePackets(audioFile, NO, inBuffer.mDataByteSize, &packetDesc, packetIndex, &packetNum, inBuffer.mData);
    if (status != noErr) {
        NSLog(@"AudioFileWritePackets error");
    }
    
    totalSize += inBuffer.mDataByteSize;
    
    packetIndex++;
}

- (void)close {
    
    AudioFileClose(audioFile);
    memset(&_audioDesc, 0, sizeof(_audioDesc));
    _filePath = nil;
    
    NSLog(@"录音结束");
    
#if !WRITE_PCM_TO_DISK
    NSLog(@"输出的aac文件大小：%.3fM",totalSize/1024/1024);
#endif
}

@end
