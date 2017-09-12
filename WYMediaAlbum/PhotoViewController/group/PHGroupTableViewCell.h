//
//  PHGroupTableViewCell.h
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/9.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KJAssetCollection.h"

@interface PHGroupTableViewCell : UITableViewCell

@property (assign, nonatomic) SelectMediaType mediaType;

/**
 展示Cell

 @param assetCollection KJAssetCollection
 */
- (void)showCellWithKJAssetCollection:(KJAssetCollection *)assetCollection;

@end
