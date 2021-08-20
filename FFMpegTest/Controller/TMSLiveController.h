//
//  TMSLiveController.h
//  FFMpegTest
//
//  Created by santian_mac on 2021/7/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TMSLiveRecordType)
{
    TMSLiveRecordVideoType,
    TMSLiveRecordAudioType,
};

@interface TMSLiveController : UIViewController
- (instancetype)initWithRecordType:(TMSLiveRecordType)recordType;
@end

NS_ASSUME_NONNULL_END
