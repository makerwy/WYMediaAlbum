//
//  PHScanningViewController.h
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/16.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KJAsset.h"

@interface PHScanningViewController : UIViewController

/**
 数据源数组
 */
@property (strong, nonatomic) NSArray <KJAsset *>*array;

/**
 当前默认页面
 */
@property (assign, nonatomic) NSInteger index;

/**
 可以选取图片的数量
 */
@property (assign, nonatomic) NSInteger count;


@end
