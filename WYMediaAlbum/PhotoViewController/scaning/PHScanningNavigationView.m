//
//  PHScanningNavigationView.m
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/16.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "PHScanningNavigationView.h"
#import "PHHeader.h"

@interface PHScanningNavigationView ()

{
    UIView          *_shadowView;
}

@end

@implementation PHScanningNavigationView

- (id)init {
    self = [super init];
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH_PH, 64);
    if (self) {
        _shadowView = [[UIView alloc] init];
        _shadowView.backgroundColor = [UIColor blackColor];
        _shadowView.alpha = 0.7;
        _shadowView.frame = CGRectMake(0, 0, SCREEN_WIDTH_PH, 64);
        [self addSubview:_shadowView];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
        button.tag = 101;
        [button setImage:[UIImage imageNamed:@"ic_login_back"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        UIButton *selectButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH_PH - 40, 0, 20, 20)];
        selectButton.tag = 102;
        [selectButton setImage:[UIImage imageNamed:CELL_UNSELECTED_IMAGE] forState:UIControlStateNormal];
        [selectButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:selectButton];
        selectButton.center = CGPointMake(selectButton.center.x, button.center.y);
        self.selectButton = selectButton;
    }
    return self;
}

- (void)showSelectedButton:(BOOL)isSelect {
    if (isSelect) {
        [self.selectButton setImage:[UIImage imageNamed:CELL_SELECTED_IMAGE] forState:UIControlStateNormal];
    }else {
        [self.selectButton setImage:[UIImage imageNamed:CELL_UNSELECTED_IMAGE] forState:UIControlStateNormal];
    }
}

#pragma mark -
#pragma mark - INTERFACE

- (void)back:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(scanningNavigationView:clickAtIndex:)]) {
        [self.delegate scanningNavigationView:self clickAtIndex:button.tag - 100];
    }
}
@end
