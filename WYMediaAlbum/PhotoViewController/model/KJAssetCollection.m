//
//  KJAssetCollection.m
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/15.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "KJAssetCollection.h"
#import "PHData.h"
@implementation KJAssetCollection

/**
 根据mediaType获取分组的资源
 PHAssetMediaTypeImage ：图片
 PHAssetMediaTypeVideo ：视频
 
 @param assetCollection assetCollection description
 @param mediaType mediaType description
 @return return value description
 */
- (KJAssetCollection *)initWithPHAssetCollection:(PHAssetCollection *)assetCollection mediaType:(PHAssetMediaType)mediaType {
    self = [super init];
    if (self) {
        self.assetCollection = assetCollection;
        // 获取分组内对象数量
        
        // 创建过滤器
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        //根据mediaType筛选
        if (mediaType > 0) {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",mediaType];
        }
        
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
        self.count = assetsFetchResult.count;
        PHAsset *asset = [assetsFetchResult lastObject];
        self.lastAsset = asset;
        
        [PHData imageHighQualityFormatFromPHAsset:asset imageSize:CGSizeMake(200, 200) complete:^(UIImage *image) {
            if (image) {
                self.coverImage = image;
            }else {
                self.coverImage = [UIImage imageNamed:@"ic_PH_default"];
            }
        }];
    }
    return self;
}

@end
