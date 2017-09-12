//
//  CameraCollectionViewCell.m
//  KJPhotoManager
//
//  Created by 二师兄 on 2017/3/16.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "CameraCollectionViewCell.h"

@implementation CameraCollectionViewCell
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self controlView];
    }
    return self;
}
-(void)controlView{
    UIImageView * camera = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_camera"]];
    [self addSubview:camera];
    camera.frame = CGRectMake(2, 2, self.frame.size.width-4, self.frame.size.height-4);
}
@end
