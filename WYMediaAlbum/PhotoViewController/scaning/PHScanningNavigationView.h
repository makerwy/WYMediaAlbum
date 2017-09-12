//
//  PHScanningNavigationView.h
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/16.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHScanningNavigationView;

@protocol PHScanningNavigationViewDelegate <NSObject>

@optional

/**
 点击按钮的事件回调

 @param scanningNavigationView 当前视图
 @param index 1.返回
 */
- (void)scanningNavigationView:(PHScanningNavigationView *)scanningNavigationView clickAtIndex:(NSInteger)index;

@end

@interface PHScanningNavigationView : UIView

@property (assign, nonatomic) id <PHScanningNavigationViewDelegate> delegate;

@property (strong, nonatomic) UIButton *selectButton;

- (void)showSelectedButton:(BOOL)isSelect;

@end
