//
//  TMSLiveStreamingViewController.m
//  FFMpegTest
//
//  Created by TmmmS on 2021/8/21.
//

#import "TMSLiveStreamingViewController.h"
#import <LFLiveKit.h>

@interface TMSLiveStreamingViewController ()<LFLiveSessionDelegate>
@property (nonatomic, strong) LFLiveSession *liveSession;
@property(nonatomic, strong) UIView *previewView;
@end

@implementation TMSLiveStreamingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.previewView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.previewView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.previewView];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startLive];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self stopLive];
}

- (void)startLive {
    LFLiveStreamInfo *streamInfo = [LFLiveStreamInfo new];
//    streamInfo.url = @"rtmp://192.168.110.19:1950/ppx/room";
    streamInfo.url = @"rtmp://192.168.110.19:1935/hls/live1";
    [self.liveSession startLive:streamInfo];
}

- (void)stopLive{
    [self.liveSession stopLive];
}

//状态监听的回调函数
- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange: (LFLiveState)state {
    NSLog(@"LFLiveState = %zd", state);
}

- (void)liveSession:(nullable LFLiveSession *)session debugInfo:(nullable LFLiveDebug*)debugInfo {
    NSLog(@"%s", __func__);
}
//推流错误的回调函数
- (void)liveSession:(nullable LFLiveSession*)session errorCode:(LFLiveSocketErrorCode)errorCode {
    NSLog(@"LFLiveSocketErrorCode = %zd", errorCode);
}

- (LFLiveSession*)liveSession {
    if (!_liveSession) {
        _liveSession = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:[LFLiveVideoConfiguration defaultConfiguration]];
        // 预览视图
        _liveSession.preView = self.previewView;
        // 设置为后置摄像头
        _liveSession.captureDevicePosition = AVCaptureDevicePositionBack;
        _liveSession.delegate = self;
        _liveSession.reconnectCount = 5;
        _liveSession.reconnectInterval = 3;
        
        _liveSession.running = YES;
    }
    return _liveSession;
}

@end
