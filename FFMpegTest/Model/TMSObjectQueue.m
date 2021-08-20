//
//  TMSObjectQueue.m
//  FFMpegTest
//
//  Created by TmmmS on 2021/7/6.
//

#import "TMSObjectQueue.h"
#import <pthread.h>

@interface TMSObjectQueue()
{
    pthread_mutex_t locker;
}
@property(nonatomic, strong)NSMutableArray *storage;
@end

@implementation TMSObjectQueue

- (instancetype)init {
    self = [super init];
    if (self) {
        _storage = [[NSMutableArray alloc] init];
        pthread_mutex_init(&locker, NULL);
    }
    return self;
}

#pragma mark - Public
- (id _Nullable)dequeue {
    id obj = NULL;
    pthread_mutex_lock(&locker);
    if(_storage.count == 0) {
        pthread_mutex_unlock(&locker);
        return NULL;
    }
    obj = _storage.lastObject;
    [_storage removeLastObject];
    pthread_mutex_unlock(&locker);
    return obj;
}
- (void)enqueue:(id)object {
    pthread_mutex_lock(&locker);
    [_storage insertObject:object atIndex:0];
    pthread_mutex_unlock(&locker);
}
- (NSInteger)count {
    NSInteger count = 0;
    pthread_mutex_lock(&locker);
    count = _storage.count;
    pthread_mutex_unlock(&locker);
    return count;
}
@end
