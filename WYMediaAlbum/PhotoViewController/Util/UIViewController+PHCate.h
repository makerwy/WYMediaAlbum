//
//  UIViewController+PHCate.h
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/15.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (PHCate)
- (void)changeNavAlpha:(float)alphaValue color:(UIColor *)color;
- (void)titleColor:(NSString *)titleColor font:(CGFloat)font;
- (void)barButtonItemImageName:(NSString *)imageName position:(NSString *)position;
- (void)barImageTap:(UITapGestureRecognizer *)tap;
- (void)barButtonItemTitle:(NSString *)itemTitle;
@end
