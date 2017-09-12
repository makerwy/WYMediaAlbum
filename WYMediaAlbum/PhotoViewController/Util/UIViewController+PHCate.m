//
//  UIViewController+PHCate.m
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/15.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "UIViewController+PHCate.h"
#import "UIColor+PHCate.h"

@implementation UIViewController (PHCate)
- (void)changeNavAlpha:(float)alphaValue color:(UIColor *)color {
    if (alphaValue < 0.99) {
        UINavigationBar * bar = self.navigationController.navigationBar;
        UIImage *bgImage = [self imageWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64) alpha:alphaValue color:color];
        [bar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.translucent = YES;
    }else {
        UINavigationBar * bar = self.navigationController.navigationBar;
        UIImage *bgImage = [self imageWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64) alpha:alphaValue color:color];
        [bar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.translucent = NO;
    }
}
- (UIImage *)imageWithFrame:(CGRect)frame alpha:(CGFloat)alpha color:(UIColor *)color {
    frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    UIGraphicsBeginImageContext(frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, frame);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
- (void)titleColor:(NSString *)titleColor font:(CGFloat)font {
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:titleColor],NSFontAttributeName:[UIFont systemFontOfSize:font]};
}
- (void)barButtonItemImageName:(NSString *)imageName position:(NSString *)position {
    UIImageView *button = [[UIImageView alloc] init];
    button.frame = CGRectMake(0, 0, 40, 40);
    button.image = [UIImage imageNamed:imageName];
    if ([position isEqualToString:@"left"]) {
        button.contentMode = UIViewContentModeLeft;
    }else if ([position isEqualToString:@"right"]) {
        button.contentMode = UIViewContentModeRight;
    }
    button.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(barImageTap:)];
    [button addGestureRecognizer:tap];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    if ([position isEqualToString:@"left"]) {
        self.navigationItem.leftBarButtonItem = item;
        button.tag = 1;
    }else if ([position isEqualToString:@"right"]) {
        self.navigationItem.rightBarButtonItem = item;
        button.tag = 2;
    }
}
- (void)barImageTap:(UITapGestureRecognizer *)tap {
    if (tap.view.tag == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)barButtonItemTitle:(NSString *)itemTitle {
    UIButton *button = [[UIButton alloc] init];
    button.frame = CGRectMake(0, 0, 44, 44);
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitle:itemTitle forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:@"ffffff"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnClickBar:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = item;
    button.tag = 2;
}
- (void)btnClickBar:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
