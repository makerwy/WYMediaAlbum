//
//  PHScanningCollectionViewCell.h
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/16.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KJAsset.h"

typedef void (^PHScanningCollectionViewCellTap)();

@interface PHScanningCollectionViewCell : UICollectionViewCell
@property (copy, nonatomic) PHScanningCollectionViewCellTap block;

/**
 展示图片

 @param asset KJAsset
 */
- (void)showWithKJAsset:(KJAsset *)asset;

@end
