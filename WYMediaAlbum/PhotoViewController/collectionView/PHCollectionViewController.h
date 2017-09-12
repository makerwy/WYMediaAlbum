//
//  PHCollectionViewController.h
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/9.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
typedef void(^PHGroupViewControllerBlock)(id result);

@interface PHCollectionViewController : UIViewController
@property (copy, nonatomic) PHGroupViewControllerBlock block;
/**
 可以选取图片的数量
 */
@property (assign, nonatomic) NSInteger count;

/**
 是否有照相功能
 */
@property (assign, nonatomic) BOOL isCamera;

@property (copy, nonatomic) NSString *titleString;

/**
 是否需要裁剪 （单选有效）
 */
@property (assign, nonatomic) BOOL isCropping;
/**
 集合对象
 */
@property (strong, nonatomic) PHAssetCollection *assetCollection;

/**
 选择的媒体类型
 */
@property (assign, nonatomic) SelectMediaType mediaType;

@end
