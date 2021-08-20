//
//  TMSQueueVideoObject.m
//  FFMpegTest
//
//  Created by TmmmS on 2021/7/10.
//

#import "TMSQueueVideoObject.h"

@implementation TMSQueueVideoObject{
    AVFrame *frame;
}
- (void)dealloc {
    if(frame) {
        av_frame_free(&frame);
    }
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self->frame = av_frame_alloc();
    }
    return self;
}
- (AVFrame *)frame {
    return self->frame;
}
@end
