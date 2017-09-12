//
//  HUDManager.h
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/16.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HUDManager : NSObject
+ (HUDManager *)sharedManager;
- (void)hud:(NSString *)string;
@end
