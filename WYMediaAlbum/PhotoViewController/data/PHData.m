//
//  PHData.m
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/9.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "PHData.h"
#import <MediaPlayer/MediaPlayer.h>
@implementation PHData

/**
 根据mediaType获取相册资源
 mediaType = 0;                           图片和视频
 mediaType = PHAssetMediaTypeImage        图片
 mediaType = PHAssetMediaTypeVideo        视频
 
 @param mediaType mediaType description
 @param callback callback description
 */
+ (void)allMediaDataSourceWithMediaType:(PHAssetMediaType)mediaType callback:(void(^)(NSMutableArray<KJAssetCollection *>*array))callback {
    NSMutableArray *arrayResult = [NSMutableArray arrayWithCapacity:0];
    
    // 系统相册 相机拍摄的所有图片和视频
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    //最近添加的照片或视频
    PHFetchResult *recentAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded options:nil];
    //用户创建的相册
    PHFetchResult *userAlbums = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    for (NSInteger i = 0; i < smartAlbums.count; i++) {
        PHCollection *collection = smartAlbums[i];
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            KJAssetCollection *collection = [[KJAssetCollection alloc] initWithPHAssetCollection:assetCollection mediaType:mediaType];
            if (collection.count > 0) {
                [arrayResult addObject:collection];
            }
        }
    }
    for (NSInteger i = 0; i < recentAlbums.count; i++) {
        PHCollection *collection = recentAlbums[i];
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            KJAssetCollection *collection = [[KJAssetCollection alloc] initWithPHAssetCollection:assetCollection mediaType:mediaType];
            if (collection.count > 0) {
                [arrayResult addObject:collection];
            }
        }
    }
    for (int i = 0; i < userAlbums.count; i++) {
        PHCollection *collection = userAlbums[i];
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            KJAssetCollection *collection = [[KJAssetCollection alloc] initWithPHAssetCollection:assetCollection mediaType:mediaType];
            if (collection.count > 0) {
                [arrayResult addObject:collection];
            }
        }
    }
    callback(arrayResult);
}

/**
 根据mediaType获取每个assetCollection中的相片或视频
 mediaType = 0;                           图片和视频
 mediaType = PHAssetMediaTypeImage        图片
 mediaType = PHAssetMediaTypeVideo        视频
 
 @param assetCollection assetCollection description
 @param mediaType mediaType description
 @return return value description
 */
+ (NSMutableArray *)allAssetsInAssetCollection:(PHAssetCollection *)assetCollection mediaType:(PHAssetMediaType)mediaType {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    if (mediaType > 0) {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",mediaType];
    }
    PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
    [assetsFetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [array addObject:obj];
    }];
    return array;
}

/**
 根据size获取asset高清图
 如果要获取asset原图 imageSize = PHImageManagerMaximumSize
 1、PHImageRequestOptions类用于定制请求。
 
 　　上面的方法返回指定尺寸的图像，如果你仅仅指定必要的参数而没有对 options 进行配置的话，返回的图像尺寸将会是原始图像的尺寸。或者，你指定的尺寸很小，这时候会按照你的要求来返回接近该尺寸的图像。PHImageRequestOptions有以下几个重要的属性：
 
 　　　　synchronous：指定请求是否同步执行。 默认为 NO，如果 synchronous 为 YES，即同步请求时，deliveryMode 会被视为 PHImageRequestOptionsDeliveryModeHighQualityFormat，即自动返回高质量的图片，因此不建议使用同步请求，否则如果界面需要等待返回的图像才能进一步作出反应，则反应时长会很长。
 
 　　　　resizeMode：对请求的图像怎样缩放。有三种选择：None，不缩放；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。（resizeMode 默认是 None，这也造成了返回图像尺寸与要求尺寸不符。这点需要注意。要返回一个指定尺寸的图像需要避免两层陷阱：一定要指定 options 参数，resizeMode 不能为 None。）
 
 　　　　deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。这个属性只有在 synchronous 为 true 时有效。
 
 　　　　normalizedCropRect：用于对原始尺寸的图像进行裁剪，基于比例坐标。只在 resizeMode 为 Exact 时有效。
 
 　　　　networkAccessAllowed ：参数控制是否允许网络请求，默认为 NO，如果不允许网络请求，那么就没有然后了，当然也拉取不到 iCloud 的图像原件。（在 PhotoKit 中，对 iCloud 照片库有很好的支持，如果用户开启了 iCloud 照片库，并且选择了“优化 iPhone/iPad 储存空间”，或者选择了“下载并保留原件”但原件还没有加载好的时候，PhotoKit 也会预先拿到这些非本地图像的 PHAsset，但是由于本地并没有原图，所以如果产生了请求高清图的请求，PHotoKit 会尝试从 iCloud 下载图片，而这个行为最终的表现，会被 PHImageRequestOptions 中的值所影响。）
 
 　　　　versions：这个属性是指获取的图像是否需要包含系统相册“编辑”功能处理过的信息（如滤镜，旋转等）；
 
 　　　　　  　　　.Current 会递送包含所有调整和修改的图像；.Unadjusted 会递送未被施加任何修改的图像；.Original 会递送原始的、最高质量的格式的图像 (例如 RAW 格式的数据。而当将属性设置为 .Unadjusted 时，会递送一个 JPEG)。
 
 @param asset asset description
 @param imageSize 指定尺寸
 @param complete complete description
 */
+ (PHImageRequestID)imageHighQualityFormatFromPHAsset:(PHAsset *)asset imageSize:(CGSize)imageSize complete:(void (^)(UIImage *))complete {
    if (asset.mediaType == PHAssetMediaTypeImage || asset.mediaType == PHAssetMediaTypeVideo) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
//        options.version = PHImageRequestOptionsVersionCurrent;
//        options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
//        options.synchronous = YES;
        PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            //[[info objectForKey:PHImageResultIsDegradedKey] boolValue] yes 返回的是缩略图 No返回的是原图
            BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey];
            if (downloadFinined) {
                if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
                    if (complete) {
                        complete (result);
                    }
                }
            }
        }];
        return imageRequestID;
    }else {
        if (complete) {
            complete (nil);
        }
        return 0;
    }
}

/**
 根据asset获取视频data
 
 @param asset asset description
 @param complete complete description
 */
+ (void)dataInAsset:(PHAsset *)asset complete:(void(^)(NSData *data))complete {
    [PHData videoUrlWithAsset:asset complete:^(NSURL *url) {
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (complete) {
            complete(data);
        }
    }];
}

/**
 根据asset获取视频url
 
 @param asset asset description
 @param complete complete description
 */
+ (void)videoUrlWithAsset:(PHAsset *)asset complete:(void(^)(NSURL *url))complete {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        AVURLAsset *urlAsset = (AVURLAsset *)asset;
        
        NSURL *url = urlAsset.URL;
        if (complete) {
            complete(url);
        }
    }];
}

@end
