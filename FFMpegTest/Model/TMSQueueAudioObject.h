//
//  TMSQueueAudioObject.h
//  FFMpegTest
//
//  Created by TmmmS on 2021/7/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMSQueueAudioObject : NSObject
@property (nonatomic, assign, readonly)float pts;
@property (nonatomic, assign, readonly)float duration;
- (instancetype)initWithLength:(int64_t)length pts:(float)pts duration:(float)duration;
- (uint8_t *)data;
- (int64_t)length;
- (void)updateLength:(int64_t)length;
@end

NS_ASSUME_NONNULL_END
