//
//  ViewController.m
//  FFMpegTest
//
//  Created by TmmmS on 2021/4/18.
//

#import "ViewController.h"
#import "TMSLiveController.h"
#import "TMSDecodeViewController.h"
#import "TMSLiveStreamingViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class)];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"FFMpeg解码";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"音频实时录制";
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"视频实时录制";
    } else {
        cell.textLabel.text = @"直播推流";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *vc;
    
    switch (indexPath.row) {
        case 0:
            vc = [[TMSDecodeViewController alloc] init];
            break;
        case 1:
            vc = [self requestAuthorizationWithMediaType:AVMediaTypeAudio indexPath:indexPath];
            break;
        case 2:
            vc = [self requestAuthorizationWithMediaType:AVMediaTypeVideo indexPath:indexPath];
            break;
        case 3:
            vc = [self requestAuthorizationWithMediaType:AVMediaTypeAudio indexPath:indexPath];
            break;

        default:
            break;
    }
    
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, CGFLOAT_MIN)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, CGFLOAT_MIN)];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableView *)tableView {
    
    if (_tableView == nil) {
        
        CGFloat tableY = [UIApplication sharedApplication].statusBarFrame.size.height + 44;
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tableY, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - tableY) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, CGFLOAT_MIN)];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, CGFLOAT_MIN)];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    }
    return _tableView;
}

- (UIViewController *)requestAuthorizationWithMediaType:(AVMediaType)mediaType indexPath:(NSIndexPath *)indexPath {
    
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (videoAuthStatus == AVAuthorizationStatusNotDetermined) {// 未询问用户是否授权
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        }];
        return nil;
    } else if(videoAuthStatus == AVAuthorizationStatusRestricted || videoAuthStatus == AVAuthorizationStatusDenied) {// 未授权
        [self showSetAlertViewWithMediaType:mediaType];
        return nil;
    } else{// 已授权
        
        if (indexPath.row == 2) {
            return [[TMSLiveController alloc] initWithRecordType:mediaType == AVMediaTypeAudio ? TMSLiveRecordAudioType : TMSLiveRecordVideoType];
        } else {
            if (mediaType == AVMediaTypeAudio) {
                return [self requestAuthorizationWithMediaType:AVMediaTypeVideo indexPath:indexPath];
            } else {
                return [[TMSLiveStreamingViewController alloc] init];
            }
        }
    }
}

//提示用户进行麦克风使用授权
- (void)showSetAlertViewWithMediaType:(AVMediaType)mediaType {
    
    NSString *mediaStr = mediaType == AVMediaTypeAudio ? @"麦克风" : @"摄像头";
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@权限未开启", mediaStr] message:[NSString stringWithFormat:@"%@权限未开启，请进入系统【设置】>【隐私】>【%@】中打开开关,开启%@功能", mediaStr, mediaStr, mediaStr] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *setAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //跳入当前App设置界面
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alertVC addAction:cancelAction];
    [alertVC addAction:setAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

@end
