//
//  PHScanningCollectionViewCell.m
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/16.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "PHScanningCollectionViewCell.h"
#import "PHData.h"

@interface PHScanningCollectionViewCell ()<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImageView *playView;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) KJAsset *asset;
@end

@implementation PHScanningCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.scrollView.backgroundColor = [UIColor blackColor];
        self.scrollView.delegate = self;
        self.scrollView.maximumZoomScale = 1.5;
        self.scrollView.minimumZoomScale = 1;
        [self addSubview:self.scrollView];
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.scrollView.frame];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.scrollView addSubview:self.imageView];
        
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap1:)];
        [self.scrollView addGestureRecognizer:tap1];
        
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap2:)];
        tap2.numberOfTapsRequired = 2;
        [self.scrollView addGestureRecognizer:tap2];
        
        self.playView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:self.playView];
        
        self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.playButton.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self.playButton setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
        [self.playButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.playButton];
    }
    return self;
}

#pragma mark -
#pragma mark - PRIVATE

/**
 展示图片
 
 @param asset KJAsset
 */
- (void)showWithKJAsset:(KJAsset *)asset {
    self.asset = asset;
    if (asset.asset.mediaType == PHAssetMediaTypeImage) {
        self.scrollView.hidden = NO;
        self.playView.hidden = YES;
        self.playButton.hidden = YES;
        [PHData imageHighQualityFormatFromPHAsset:asset.asset imageSize:PHImageManagerMaximumSize complete:^(UIImage *image) {
            if (image.size.width > image.size.height) {
                CGRect imageRect = self.imageView.frame;
                imageRect.size = CGSizeMake(SCREEN_WIDTH_PH , SCREEN_WIDTH_PH * image.size.height / image.size.width);
                self.imageView.frame = imageRect;
            }
            self.imageView.image = image;
            
        }];
    }else {
        self.scrollView.hidden = YES;
        self.playView.hidden = NO;
        self.playButton.hidden = NO;
        [PHData imageHighQualityFormatFromPHAsset:asset.asset imageSize:PHImageManagerMaximumSize complete:^(UIImage *image) {
            if (image.size.width > image.size.height) {
                CGRect imageRect = self.playView.frame;
                imageRect.size = CGSizeMake(SCREEN_WIDTH_PH , SCREEN_WIDTH_PH * image.size.height / image.size.width);
                self.playView.frame = imageRect;
                self.playView.center = CGPointMake(SCREEN_WIDTH_PH / 2.0, SCREEN_HEIGHT_PH / 2.0);
            }else {
                CGRect imageRect = self.playView.frame;
                imageRect.size = CGSizeMake(SCREEN_WIDTH_PH , SCREEN_HEIGHT_PH);
                self.playView.frame = imageRect;
                self.playView.center = CGPointMake(SCREEN_WIDTH_PH / 2.0, SCREEN_HEIGHT_PH / 2.0);
            }
            self.playView.image = image;
        }];
    }
}

#pragma mark -
#pragma mark - <UIScrollViewDelegate>

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        return self.imageView;
    }else {
        return nil;
    }
}

#pragma mark -
#pragma mark - INTERFACE

- (void)tap2:(UIGestureRecognizer *)tap2 {
    if (self.scrollView.zoomScale != 1) {
        [self.scrollView setZoomScale:1 animated:YES];
    }else {
        [self.scrollView setZoomScale:1.5 animated:YES];
    }
}
- (void)tap1:(UIGestureRecognizer *)tap {
    if (self.block) {
        self.block ();
    }
}

- (void)playVideo:(UIButton *)button {
    if (self.block) {
        self.block ();
    }
}
@end
