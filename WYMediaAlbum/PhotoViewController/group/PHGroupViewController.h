//
//  PHGroupViewController.h
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/9.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PHGroupViewControllerBlock)(id result);

@interface PHGroupViewController : UIViewController
@property (copy, nonatomic) PHGroupViewControllerBlock block;
/**
 可以选取图片的数量
 */
@property (assign, nonatomic) NSInteger count;

/**
 是否有照相功能
 */
@property (assign, nonatomic) BOOL isCamera;

/**
 是否需要裁剪 （单选有效）
 */
@property (assign, nonatomic) BOOL isCropping;

/**
 选择的媒体类型
 */
@property (assign, nonatomic) SelectMediaType mediaType;

@end
