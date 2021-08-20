//
//  TMSObjectQueue.h
//  FFMpegTest
//
//  Created by TmmmS on 2021/7/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMSObjectQueue : NSObject
- (id _Nullable)dequeue;
- (void)enqueue:(id)object;
- (NSInteger)count;
@end

NS_ASSUME_NONNULL_END
