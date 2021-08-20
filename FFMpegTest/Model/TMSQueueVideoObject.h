//
//  TMSQueueVideoObject.h
//  FFMpegTest
//
//  Created by TmmmS on 2021/7/10.
//

#import <Foundation/Foundation.h>
#import <libavcodec/avcodec.h>
#import <libavformat/avformat.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMSQueueVideoObject : NSObject
@property (nonatomic, assign)double unit;
@property (nonatomic, assign)double pts;
@property (nonatomic, assign)double duration;
- (instancetype)init;
- (AVFrame *)frame;
@end

NS_ASSUME_NONNULL_END
