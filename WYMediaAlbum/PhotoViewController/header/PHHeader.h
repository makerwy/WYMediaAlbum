//
//  PHHeader.h
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/9.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#ifndef PHHeader_h
#define PHHeader_h

#define SCREEN_WIDTH_PH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT_PH [UIScreen mainScreen].bounds.size.height

#define MAX_ALERT_STRING @"超出最大数量"
#define SELECTED_NONE    @"尚未选择任何图片或视频"
#define CELL_SELECTED_IMAGE @"ic_selected"
#define CELL_UNSELECTED_IMAGE @"ic_unselected"

#import "PHData.h"
#import "KJAssetCollection.h"
#import "UIColor+PHCate.h"
#import "UIViewController+PHCate.h"
#import "KJAsset.h"
#import "HUDManager.h"
#import "PHTool.h"
#import "RSKImageCropper.h"
#import "Enumeration.h"

#endif /* PHHeader_h */
