//
//  KJAssetCollection.h
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/15.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface KJAssetCollection : NSObject

/**
 根据mediaType获取分组的资源
 PHAssetMediaTypeImage ：图片
 PHAssetMediaTypeVideo ：视频

 @param assetCollection assetCollection description
 @param mediaType mediaType description
 @return return value description
 */
- (KJAssetCollection *)initWithPHAssetCollection:(PHAssetCollection *)assetCollection mediaType:(PHAssetMediaType)mediaType;

@property (strong, nonatomic) PHAssetCollection *assetCollection;
/**
 对象数量
 */
@property (assign, nonatomic) NSInteger count;

/**
 将最后一个对象获取
 */
@property (strong, nonatomic) PHAsset *lastAsset;

/**
 封面
 */
@property (strong, nonatomic) UIImage *coverImage;
@end
