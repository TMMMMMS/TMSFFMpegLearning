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
    
    AVAssetWriter *_writer;
    AVAssetWriterInput *_audioInput;
    
    double relativeStartTime;
    
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
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy_MM_dd__HH_mm_ss";
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

#pragma mark - AVAssetWriter
- (void)setupWriter {
    
    if (_audioDesc.mSampleRate != 0 && _filePath != nil) {
        NSError *error = nil;
        _writer = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:_filePath] fileType:AVFileTypeAppleM4A error:&error];
        
        AudioChannelLayout acl;
        bzero(&acl, sizeof(acl));
        acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
        
        NSDictionary *audioSettings = @{
            AVFormatIDKey : @(kAudioFormatMPEG4AAC),
            AVNumberOfChannelsKey : @(_audioDesc.mChannelsPerFrame),
            AVSampleRateKey : @(_audioDesc.mSampleRate),
            AVEncoderBitRateKey : @(64000),
            AVChannelLayoutKey : [NSData dataWithBytes: &acl length: sizeof( acl )]
        };
        _audioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:audioSettings];
        _audioInput.expectsMediaDataInRealTime = NO;
        
        
        [_writer addInput:_audioInput];
        
        BOOL succeed = [_writer startWriting];
        [_writer startSessionAtSourceTime:[self getTimeStamp]];
        if (!succeed) {
            NSLog(@"audio writer startWriting!");
        }
    }
}

- (void)assetWriteAudioBuffers:(TMSAudioBufferData *)bufferData {
    
    AudioBuffer inBuffer = bufferData->bufferList->mBuffers[0];
    
    CMBlockBufferRef BlockBuffer = NULL;
    OSStatus status = CMBlockBufferCreateWithMemoryBlock(NULL, inBuffer.mData, inBuffer.mDataByteSize,kCFAllocatorNull, NULL, 0, inBuffer.mDataByteSize, kCMBlockBufferAlwaysCopyDataFlag, &BlockBuffer);
    if (status != noErr) {
        NSLog(@"create memory block error");
    }
    
    CMSampleBufferRef sampleBuffer = NULL;
    CMFormatDescriptionRef formatDescription;
    status = CMFormatDescriptionCreate ( kCFAllocatorDefault, // Allocator
                                        kCMMediaType_Audio,
                                        kAudioFormatMPEG4AAC,
                                        NULL,
                                        &formatDescription);
    if (status != noErr) {
        NSLog(@"CMFormatDescriptionCreate error");
    }
    
    CMSampleTimingInfo sampleTimingInfo = {[self getDurationFor:bufferData],[self getTimeStamp],kCMTimeInvalid };
    size_t sampleSizeInfo = inBuffer.mDataByteSize;
    
    status = CMSampleBufferCreate(kCFAllocatorDefault, BlockBuffer, YES, NULL, NULL, formatDescription, 1, 1, &sampleTimingInfo, 1, &sampleSizeInfo, &sampleBuffer);
    if (status != noErr) {
        NSLog(@"CMSampleBufferCreate error");
    }
    
    BOOL succeed = [_audioInput appendSampleBuffer:sampleBuffer];
    if (!succeed) {
        AVAssetWriterStatus status = _writer.status;
        NSLog(@"write audio input error!, writer status: %ld, error: %@",status, _writer.error);
    }
}

- (CMTime)getTimeStamp {
    
    if (relativeStartTime == 0) {
        relativeStartTime = CACurrentMediaTime();
    }
    
    double relativeTime = CACurrentMediaTime() - relativeStartTime;
    return CMTimeMakeWithSeconds(relativeTime, _audioDesc.mSampleRate);
}

- (CMTime)getDurationFor:(TMSAudioBufferData *)bufferData {
    return CMTimeMake(bufferData->inNumberFrames, _audioDesc.mSampleRate);
}

@end
