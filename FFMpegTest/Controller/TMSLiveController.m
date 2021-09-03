//
//  TMSLiveController.m
//  FFMpegTest
//
//  Created by santian_mac on 2021/7/14.
//

#import "TMSLiveController.h"
#import <AVFoundation/AVFoundation.h>
#import "TMSAACEncoder.h"
#import "TMSSoftH264Encoder.h"
#import "TMSAudioRecorder.h"
#import "TMSAudioConvertor.h"
#import "TMSAACFileWriter.h"

@interface TMSLiveController ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) TMSAudioRecorder *audioRecorder;
@property (nonatomic, strong) TMSAACFileWriter *aacFileWriter;
@property (nonatomic, strong) TMSSoftH264Encoder *softH264Encoder;
@property (nonatomic, assign) TMSLiveRecordType recordType;
@property (nonatomic, strong) UIView *m_displayView;
@property (nonatomic, strong) AVCaptureVideoDataOutput *video_output;
@property (nonatomic, strong) AVCaptureSession *m_session;
@property (nonatomic, strong) UIButton *rightBtn;
@end

@implementation TMSLiveController

- (instancetype)initWithRecordType:(TMSLiveRecordType)recordType {
    
    if (self == [super init]) {
        self.recordType = recordType;
    }
    return self;
}

- (void)backAction {
    
    if (self.recordType == TMSLiveRecordVideoType) {
        [self stopPreview];
    } else {
        if (self.audioRecorder.recording) {
            [self.audioRecorder stop];
            [self.aacFileWriter close];
            [self.rightBtn setTitle:@"开始" forState:UIControlStateNormal];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)captureAction {
    
    if (self.recordType == TMSLiveRecordVideoType) {
        [self stopPreview];
    } else {
        if (self.audioRecorder.recording) {
            [self.audioRecorder stop];
            [self.aacFileWriter close];
            [self.rightBtn setTitle:@"开始" forState:UIControlStateNormal];
        }else{
            [self.audioRecorder start];
            [self.rightBtn setTitle:@"停止" forState:UIControlStateNormal];
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor orangeColor];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    [self.rightBtn setTitle:@"开始" forState:UIControlStateNormal];
    [self.rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.rightBtn addTarget:self action:@selector(captureAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBtn];
    
    if (self.recordType == TMSLiveRecordVideoType) {
        
        [self.rightBtn setTitle:@"停止" forState:UIControlStateNormal];
        
        self.m_displayView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height + 44, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - [UIApplication sharedApplication].statusBarFrame.size.height - 44)];
        [self.view addSubview:self.m_displayView];

        [self startCaptureSession];
        
    } else {
        
        [self setupAacAdtsPipline];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    if (self.recordType == TMSLiveRecordVideoType) {
        [self startPreview];
    }
}

- (void)startPreview {
    
    if (![_m_session isRunning]) {
        [_m_session startRunning];
    }
}

- (void)stopPreview {
    
    if ([_m_session isRunning]) {
        [_m_session stopRunning];
        
        [self.softH264Encoder freeH264Resource];
        
    }
}

- (int)startCaptureSession
{
    NSError *error = nil;
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    if([session canSetSessionPreset:AVCaptureSessionPreset1280x720])
    {
        session.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    else
    {
        session.sessionPreset = AVCaptureSessionPresetHigh;
    }
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    device.activeVideoMinFrameDuration = CMTimeMake(1, 30);
    
    // Create a device input with the device and add it to the session.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    if (!input) {
        return -1;
    }
    [session addInput:input];
    
    self.video_output = [[AVCaptureVideoDataOutput alloc] init];
    [session addOutput:self.video_output];
    
    
    // Specify the pixel format
    self.video_output.videoSettings =
    [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    self.video_output.alwaysDiscardsLateVideoFrames = NO;
    // Configure your output.
    dispatch_queue_t queue = dispatch_queue_create("videoQueue", NULL);
    [self.video_output setSampleBufferDelegate:self queue:queue];
    
    for (AVCaptureConnection *connection in [_video_output connections]) {
        
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            
            if([[port mediaType] isEqual:AVMediaTypeVideo]) {
                AVCaptureConnection * videoConnection = connection;
                videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
            }
        }
    }
    
    [self adjustVideoStabilization];
    
    _m_session = session;
    
    CALayer *previewViewLayer = [self.m_displayView layer];
    previewViewLayer.backgroundColor = [[UIColor blackColor] CGColor];
    
    AVCaptureVideoPreviewLayer *newPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_m_session];
    newPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    [newPreviewLayer setFrame:[UIApplication sharedApplication].keyWindow.bounds];
    
    [newPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [previewViewLayer insertSublayer:newPreviewLayer atIndex:0];
    return 0;
}

- (void)adjustVideoStabilization {
    
    NSArray *devices = [AVCaptureDevice devices];
    for(AVCaptureDevice *device in devices){
        if([device hasMediaType:AVMediaTypeVideo]){
            if([device.activeFormat isVideoStabilizationModeSupported:AVCaptureVideoStabilizationModeAuto]){
                for(AVCaptureConnection *connection in self.video_output.connections)
                {
                    for(AVCaptureInputPort *port in [connection inputPorts])
                    {
                        if([[port mediaType] isEqual:AVMediaTypeVideo])
                        {
                            if(connection.supportsVideoStabilization)
                            {
                                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeStandard;
                                NSLog(@"activeVideoStabilizationMode = %ld",(long)connection.activeVideoStabilizationMode);
                            }else{
                                NSLog(@"connection don't support video stabilization");
                            }
                        }
                    }
                }
            }else{
                NSLog(@"device don't support video stablization");
            }
        }
    }
}

#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if (sampleBuffer) {
        [self.softH264Encoder encoderToH264:sampleBuffer];
    }
   
}

- (TMSSoftH264Encoder *)softH264Encoder
{
    if (!_softH264Encoder) {
        _softH264Encoder = [TMSSoftH264Encoder getInstance];
        
        NSString *paths = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *videoDict = [paths stringByAppendingPathComponent:@"video"] ;
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"yyyy_MM_dd_HH_mm_ss";
        NSString *newString = [format stringFromDate:[NSDate date]];
        
        NSString *videoFile = [videoDict stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",newString,@"h264"]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:videoFile])
        {
            [fileManager createDirectoryAtPath:videoDict withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [_softH264Encoder setFileSavedPath:videoFile];
        [_softH264Encoder setEncoderVideoWidth:720 height:1280 bitrate:64000];
    }
    return _softH264Encoder;
}

-(void)setupAacAdtsPipline{
    
    self.audioRecorder = [[TMSAudioRecorder alloc] init];
    
    TMSAudioConvertor *converter = [[TMSAudioConvertor alloc] init];
    AudioStreamBasicDescription outputDesc = {
        0, kAudioFormatMPEG4AAC, 0, 0, kAudioAACFramesPerPacket,0,0,0,0
    };
    converter.outputDesc = outputDesc;
    [self.audioRecorder addTarget:converter];
    
    self.aacFileWriter = [[TMSAACFileWriter alloc] init];
    [converter addTarget:self.aacFileWriter];

}

- (void)dealloc {
    
    NSLog(@"%@--dealloc", NSStringFromClass([self class]));
}

@end
