//
//  TMSAACFileWriter.h
//  FFMpegTest
//
//  Created by santian_mac on 2021/7/23.
//

#import <Foundation/Foundation.h>
#import "TMSAudioInput.h"

NS_ASSUME_NONNULL_BEGIN

@interface TMSAACFileWriter : NSObject<TMSAudioInput>

@property (nonatomic, copy) NSString *filePath;

- (void)close;

@end

NS_ASSUME_NONNULL_END
