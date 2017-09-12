//
//  PHTabbarView.m
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/16.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "PHTabbarView.h"
#import "UIColor+PHCate.h"

@interface PHTabbarView ()

@property (strong, nonatomic) UIButton *scanButton;
@property (strong, nonatomic) UIButton *sureButton;
@property (strong, nonatomic) UILabel *countLabel;

@end

@implementation PHTabbarView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, frame.size.width, 0.5);
        layer.backgroundColor = [UIColor colorWithHexString:@"999999"].CGColor;
        [self.layer addSublayer:layer];
        
        self.scanButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 40, frame.size.height)];
        [self.scanButton setTitle:@"预览" forState:UIControlStateNormal];
        [self.scanButton setTitleColor:[UIColor colorWithHexString:@"333333"] forState:UIControlStateNormal];
        [self.scanButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        self.scanButton.tag = 1;
        [self addSubview:self.scanButton];
        
        self.sureButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 5 - 40, 0, 40, frame.size.height)];
        [self.sureButton setTitle:@"完成" forState:UIControlStateNormal];
        [self.sureButton setTitleColor:[UIColor colorWithHexString:@"1afa29"] forState:UIControlStateNormal];
        [self.sureButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        self.sureButton.tag = 2;
        [self addSubview:self.sureButton];
        
        self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, frame.size.width - 100, frame.size.height)];
        self.countLabel.text = @"已选 0";
        self.countLabel.textAlignment = NSTextAlignmentCenter;
        self.countLabel.textColor = [UIColor colorWithHexString:@"333333"];
        [self addSubview:self.countLabel];
    }
    return self;
}

#pragma mark -
#pragma mark - PRIVATE

- (void)setIsSingle:(BOOL)isSingle {
    if (isSingle) {
        self.countLabel.hidden = YES;
    }else {
        self.countLabel.hidden = NO;
    }
}

- (void)count:(NSInteger)count {
    self.countLabel.text = [NSString stringWithFormat:@"已选 %ld",count];
}

#pragma mark -
#pragma mark - INTERFACE

- (void)buttonClick:(UIButton *)button {
    if (button.tag == 1) {
        // 预览
        
    }else if (button.tag == 2) {
        // 完成
        
    }
    if ([self.delegate respondsToSelector:@selector(tabbarView:didSelectAtIndex:)]) {
        [self.delegate tabbarView:self didSelectAtIndex:button.tag];
    }
}

@end
