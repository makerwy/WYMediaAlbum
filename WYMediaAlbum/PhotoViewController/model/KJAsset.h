//
//  KJAsset.h
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/16.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface KJAsset : NSObject

/**
 初始化方法

 @param asset asset
 @return KJAsset
 */
- (KJAsset *)initWithPHAsset:(PHAsset *)asset;
/**
 Asset对象
 */
@property (strong, nonatomic) PHAsset *asset;

/**
 是否被选中
 */
@property (assign, nonatomic) BOOL selected;

/**
 是否是相机位
 */
@property (assign, nonatomic) BOOL isCamera;

/**
 相机照片
 */
@property (strong, nonatomic) UIImage * cameraImage;

/**
 视频本地url
 */
@property (strong, nonatomic) NSURL *videoUrl;

/**
 视频时长
 */
@property (copy, nonatomic) NSString * timeLength;

/**
 视频是否在播放
 */
@property (assign, nonatomic) BOOL isPlaying;

@end
