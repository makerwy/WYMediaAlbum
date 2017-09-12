//
//  PHGroupTableViewCell.m
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/9.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "PHGroupTableViewCell.h"
#import "PHData.h"
#import "PHHeader.h"
@implementation PHGroupTableViewCell
{
    UIImageView         *_headImageView;
    UILabel             *_titleLabel;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self addSubviews];
        
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 57.5, SCREEN_WIDTH_PH, 0.5);
        layer.backgroundColor = [UIColor colorWithHexString:@"e6e6e6"].CGColor;
        [self.layer addSublayer:layer];
    }
    return self;
}

#pragma mark -
#pragma mark - VIEWS

- (void)addSubviews {
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 58, 58)];
    _headImageView.contentMode = UIViewContentModeScaleAspectFill;
    _headImageView.clipsToBounds = YES;
    [self addSubview:_headImageView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, 200, 58)];
    _titleLabel.textColor = [UIColor colorWithHexString:@"333333"];
    _titleLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:_titleLabel];
}

#pragma mark -
#pragma mark - PRIVATE

/**
 展示Cell
 
 @param assetCollection KJAssetCollection
 */
- (void)showCellWithKJAssetCollection:(KJAssetCollection *)assetCollection {
    if (assetCollection.assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
        _titleLabel.text = [NSString stringWithFormat:@"相机胶卷（%ld）",assetCollection.count];
    }else {
        _titleLabel.text = [NSString stringWithFormat:@"%@（%ld）",assetCollection.assetCollection.localizedTitle,assetCollection.count];;
    }
    _headImageView.image = assetCollection.coverImage;
}
@end
