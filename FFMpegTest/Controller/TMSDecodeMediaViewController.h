//
//  TMSDecodeMediaViewController.h
//  FFMpegTest
//
//  Created by santian_mac on 2021/8/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TMSDecodeMediaType)
{
    TMSDecodeVideoMediaType,
    TMSDecodeAudioMediaType,
};

@interface TMSDecodeMediaViewController : UIViewController
- (instancetype)initWithDecodeMediaType:(TMSDecodeMediaType)decodeType;
@end

NS_ASSUME_NONNULL_END
