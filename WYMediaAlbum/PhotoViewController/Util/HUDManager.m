//
//  HUDManager.m
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/16.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "HUDManager.h"
#import "PHHeader.h"
@interface HUDManager ()

@property (strong, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) NSTimer *timer;

@end
@implementation HUDManager

+ (HUDManager *)sharedManager {
    static HUDManager *sharedManager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManager = [[HUDManager alloc] init];
    });
    return sharedManager;
}

- (void)hud:(NSString *)string {
    [[HUDManager sharedManager].contentLabel removeFromSuperview];
    [HUDManager sharedManager].contentLabel = nil;
    [HUDManager sharedManager].contentLabel = [[UILabel alloc] init];
    [HUDManager sharedManager].contentLabel.bounds = CGRectMake(0, 0, SCREEN_WIDTH_PH - 60, 35);
    [HUDManager sharedManager].contentLabel.center = CGPointMake(SCREEN_WIDTH_PH / 2.0, SCREEN_HEIGHT_PH - 100);
    [HUDManager sharedManager].contentLabel.layer.cornerRadius = 5;
    [HUDManager sharedManager].contentLabel.clipsToBounds = YES;
    [HUDManager sharedManager].contentLabel.textAlignment = NSTextAlignmentCenter;
    [HUDManager sharedManager].contentLabel.font = [UIFont systemFontOfSize:14];
    [HUDManager sharedManager].contentLabel.text = string;
    [HUDManager sharedManager].contentLabel.textColor = [UIColor whiteColor];
    [HUDManager sharedManager].contentLabel.backgroundColor = [UIColor blackColor];
    
    [[HUDManager sharedManager].contentLabel sizeToFit];
    [HUDManager sharedManager].contentLabel.bounds = CGRectMake(0, 0, [HUDManager sharedManager].contentLabel.frame.size.width + 10, 35);
    [HUDManager sharedManager].contentLabel.center = CGPointMake(SCREEN_WIDTH_PH / 2.0, SCREEN_HEIGHT_PH - 100);
    
    [[UIApplication sharedApplication].delegate.window addSubview:[HUDManager sharedManager].contentLabel];
    [NSTimer scheduledTimerWithTimeInterval:1 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [UIView animateWithDuration:0.3 animations:^{
            [HUDManager sharedManager].contentLabel.alpha = 0;
        } completion:^(BOOL finished) {
            [[HUDManager sharedManager].contentLabel removeFromSuperview];
            [HUDManager sharedManager].contentLabel = nil;
        }];
    }];

}

@end
