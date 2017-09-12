//
//  PHTabbarView.h
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/16.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHTabbarView;

@protocol PHTabbarViewDelegate <NSObject>

@required

/**
 点击预览或者完成的代理方法

 @param tabbarView <#tabbarView description#>
 @param index 1.预览 2.完成
 */
- (void)tabbarView:(PHTabbarView *)tabbarView didSelectAtIndex:(NSInteger)index;

@end

@interface PHTabbarView : UIView
@property (assign, nonatomic) BOOL isSingle;
@property (assign, nonatomic) id <PHTabbarViewDelegate> delegate;

- (void)count:(NSInteger)count;

@end
