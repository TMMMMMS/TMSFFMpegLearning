//
//  ViewController.m
//  FFMpegTest
//
//  Created by TmmmS on 2021/4/18.
//

#import "ViewController.h"
#import "SeparateViewController.h"
#import "TMSLiveController.h"
#import "TMSDecodeViewController.h"

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
    return 3;
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
    } else {
        cell.textLabel.text = @"视频实时录制";
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
            vc = [[TMSLiveController alloc] initWithRecordType:TMSLiveRecordAudioType];
            break;
        case 2:
            vc = [[TMSLiveController alloc] initWithRecordType:TMSLiveRecordVideoType];
            break;
            
        default:
            break;
    }
    
    [self.navigationController pushViewController:vc animated:YES];
    
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

@end
