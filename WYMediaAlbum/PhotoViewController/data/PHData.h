//
//  PHData.h
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/9.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "KJAssetCollection.h"

@interface PHData : NSObject

/**
 根据mediaType获取相册资源
 mediaType = 0;                           图片和视频
 mediaType = PHAssetMediaTypeImage        图片
 mediaType = PHAssetMediaTypeVideo        视频
 
 @param mediaType mediaType description
 @param callback callback description
 */
+ (void)allMediaDataSourceWithMediaType:(PHAssetMediaType)mediaType callback:(void(^)(NSMutableArray<KJAssetCollection *>*array))callback;

/**
 根据mediaType获取每个assetCollection中的相片或视频
 mediaType = 0;                           图片和视频
 mediaType = PHAssetMediaTypeImage        图片
 mediaType = PHAssetMediaTypeVideo        视频
 
 @param assetCollection assetCollection description
 @param mediaType mediaType description
 @return return value description
 */
+ (NSMutableArray *)allAssetsInAssetCollection:(PHAssetCollection *)assetCollection mediaType:(PHAssetMediaType)mediaType;

/**
 根据size获取asset高清图
 如果要获取asset原图 imageSize = PHImageManagerMaximumSize
 
 @param asset asset description
 @param imageSize 指定尺寸
 @param complete complete description
 */
+ (PHImageRequestID)imageHighQualityFormatFromPHAsset:(PHAsset *)asset imageSize:(CGSize)imageSize complete:(void (^)(UIImage *image))complete;

/**
 根据asset获取视频data

 @param asset asset description
 @param complete complete description
 */
+ (void)dataInAsset:(PHAsset *)asset complete:(void(^)(NSData *data))complete;

/**
 根据asset获取视频url

 @param asset asset description
 @param complete complete description
 */
+ (void)videoUrlWithAsset:(PHAsset *)asset complete:(void(^)(NSURL *url))complete;

@end
