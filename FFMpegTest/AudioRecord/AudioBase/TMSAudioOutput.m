//
//  TMSAudioOutput.m
//  FFMpegTest
//
//  Created by santian_mac on 2021/7/23.
//

#import "TMSAudioOutput.h"

@interface TMSAudioOutput ()
{
    NSMutableArray *_targets;
    
    NSMutableDictionary *_targetInputIndex;
}
@end

@implementation TMSAudioOutput

- (instancetype)init {
    if (self = [super init]) {
        _targets = [[NSMutableArray alloc] init];
        _targetInputIndex = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (NSArray *)targets {
    return [_targets copy];
}

- (void)addTarget:(id<TMSAudioInput>)target {
    [self addTarget:target inputIndex:0];
}

- (void)addTarget:(id<TMSAudioInput>)target inputIndex:(NSInteger)inputIndex {
    [_targets addObject:target];
    
    if (_audioDesc.mSampleRate != 0) {
        [target setAudioDesc:_audioDesc];
    }
    
    [_targetInputIndex setObject:@(inputIndex) forKey:[target description]];
}

- (void)setAudioDesc:(AudioStreamBasicDescription)audioDesc {
    _audioDesc = audioDesc;
    
    AudioStreamBasicDescription outputDesc = [self outputAudioDescWithInputDesc:audioDesc];
    for (id<TMSAudioInput> target in _targets) {
        [target setAudioDesc:outputDesc];
    }
}

- (AudioStreamBasicDescription)outputAudioDescWithInputDesc:(AudioStreamBasicDescription)audioDesc {
    return audioDesc; //默认输出与输入一样的格式
}

- (void)transportAudioBuffersToNext {
    
    for (id<TMSAudioInput>target in _targets) {
        [target receiveNewAudioBuffers:self.bufferData];
    }
}

@end
