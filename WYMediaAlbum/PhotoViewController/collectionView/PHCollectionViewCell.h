//
//  PHCollectionViewCell.h
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/9.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KJAsset.h"

typedef void (^PHCollectionViewCellTapBlock)(BOOL isSelected);
@interface PHCollectionViewCell : UICollectionViewCell

@property (copy, nonatomic) PHCollectionViewCellTapBlock block;

@property (assign, nonatomic) PHImageRequestID imageRequestID;

@property (strong, nonatomic) KJAsset *asset;

@property (strong, nonatomic) UIButton     *selectedButton;

/**
 被选中时 图片动画显示
 */
- (void)imageViewAnimation;

- (void)showSelectImage:(BOOL)isSelected;

@end
