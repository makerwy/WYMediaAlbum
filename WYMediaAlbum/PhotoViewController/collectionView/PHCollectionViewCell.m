//
//  PHCollectionViewCell.m
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/9.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "PHCollectionViewCell.h"
#import <MediaPlayer/MediaPlayer.h>

@interface PHCollectionViewCell ()
@property (strong, nonatomic) UIImageView  *imageView;
@property (strong, nonatomic) UIImageView  *selectedImageView;
@property (strong, nonatomic) UIView       *shadowView;
@property (strong, nonatomic) UILabel      *timeLabel;

@end

@implementation PHCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        // 主图
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (UIView *)shadowView {
    if (!_shadowView) {
        // 选择区域 灰色背景
        _shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 ,self.frame.size.width, self.frame.size.height)];
        _shadowView.alpha = 0.6;
//        _shadowView.layer.cornerRadius = 20 / 2.0;
//        _shadowView.clipsToBounds = YES;
        _shadowView.backgroundColor = [UIColor blackColor];
        [self addSubview:_shadowView];
        _shadowView.hidden = YES;
    }
    return _shadowView;
}

- (UIImageView *)selectedImageView {
    if (!_selectedImageView) {
        // 选择区域图标
        _selectedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 23, 3 ,20, 20)];
        _selectedButton.userInteractionEnabled = YES;
        [self addSubview:_selectedImageView];
    }
    return _selectedImageView;
}

- (UIButton *)selectedButton {
    if (!_selectedButton) {
        _selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectedButton.frame = CGRectMake(self.frame.size.width - 44, 0, 44, 44);
        [_selectedButton addTarget:self action:@selector(selectCell:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_selectedButton];
    }
    return _selectedButton;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 12, self.frame.size.width, 12)];
        _timeLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        _timeLabel.font = [UIFont systemFontOfSize:10];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [UIColor colorWithHexString:@"ffffff"];
        [self addSubview:_timeLabel];
    }
    return _timeLabel;
}

#pragma mark -
#pragma mark - PRIVATE

- (void)setAsset:(KJAsset *)asset {
    _asset = asset;
    PHImageRequestID imageRequestID = [PHData imageHighQualityFormatFromPHAsset:asset.asset imageSize:CGSizeMake(200, 200) complete:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = image;
            self.timeLabel.text = asset.timeLength;
            if (asset.asset.mediaType == PHAssetMediaTypeImage) {
                self.timeLabel.hidden = YES;
            }else if (asset.asset.mediaType == PHAssetMediaTypeVideo) {
                self.timeLabel.hidden = NO;
            }
            self.shadowView.hidden = !asset.selected;
            self.selectedButton.selected = asset.selected;
            self.selectedImageView.image = asset.selected ? [UIImage imageNamed:CELL_SELECTED_IMAGE]:[UIImage imageNamed:CELL_UNSELECTED_IMAGE];
        });
    }];
    
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    self.imageRequestID = imageRequestID;
}

- (void)imageViewAnimation {
    [UIView animateWithDuration:0.3 animations:^{
        self.selectedImageView.bounds = CGRectMake(0, 0, 23, 23);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            self.selectedImageView.bounds = CGRectMake(0, 0, 20, 20);
        }];
    }];
}

- (void)showSelectImage:(BOOL)isSelected {
    self.asset.selected = isSelected;
    self.shadowView.hidden = !isSelected;
    self.selectedButton.selected = isSelected;
    self.selectedImageView.image = isSelected ? [UIImage imageNamed:CELL_SELECTED_IMAGE]:[UIImage imageNamed:CELL_UNSELECTED_IMAGE];
}

#pragma mark -
#pragma mark - INTERFACE

- (void)selectCell:(UIButton *)button {
    [self imageViewAnimation];
    self.shadowView.hidden = button.selected;
    self.selectedImageView.image = !button.selected ? [UIImage imageNamed:CELL_SELECTED_IMAGE]:[UIImage imageNamed:CELL_UNSELECTED_IMAGE];
    if (_block) {
        _block(button.selected);
    }
}

- (void)tap:(UIGestureRecognizer *)tap {
    
}
@end
