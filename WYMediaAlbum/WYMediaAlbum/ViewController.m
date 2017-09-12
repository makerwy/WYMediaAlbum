//
//  ViewController.m
//  WYPhotoSelectTest
//
//  Created by wangyang on 2017/8/1.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "ViewController.h"
#import "firstViewController.h"
@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *array;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    NSArray *array = @[@"照片单选(无摄像头)",@"照片多选(无摄像头)",@"照片单选(有摄像头)",@"照片多选(有摄像头)",@"视频单选(无摄像头)",@"视频多选(无摄像头)",@"视频单选(有摄像头)",@"视频多选(有摄像头)",@"照片和视频单选(无摄像头)",@"照片和视频多选(无摄像头)",@"照片和视频单选(有摄像头)",@"照片和视频多选(有摄像头)"];
    self.array = array;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = NO;
    cell.textLabel.text = self.array[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [PHTool showAssetWithCount:1 mediaType:OnlyPhotosType isCamera:NO isCropping:YES complete:^(id result) {
                //
                NSLog(@"%@",[NSString stringWithFormat:@"%@",result]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[HUDManager sharedManager] hud:[NSString stringWithFormat:@"%@",result]];
                });
            }];
            break;
        case 1:
            [PHTool showAssetWithCount:9 mediaType:OnlyPhotosType isCamera:NO isCropping:YES complete:^(id result) {
                //
                NSLog(@"%@",[NSString stringWithFormat:@"%@",result]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[HUDManager sharedManager] hud:[NSString stringWithFormat:@"%@",result]];
                });
            }];
            break;
        case 2:
            
            [PHTool showAssetWithCount:1 mediaType:OnlyPhotosType isCamera:YES isCropping:NO complete:^(id result) {
                NSLog(@"%@",[NSString stringWithFormat:@"%@",result]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[HUDManager sharedManager] hud:[NSString stringWithFormat:@"%@",result]];
                });
            }];
            break;
        case 3:
            [PHTool showAssetWithCount:9 mediaType:OnlyPhotosType isCamera:YES isCropping:NO complete:^(id result) {
                NSLog(@"%@",[NSString stringWithFormat:@"%@",result]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[HUDManager sharedManager] hud:[NSString stringWithFormat:@"%@",result]];
                });
            }];
            break;
        case 4:
            
            [PHTool showAssetWithCount:1 mediaType:OnlyVideosType isCamera:NO isCropping:YES complete:^(id result) {
                NSLog(@"%@",[NSString stringWithFormat:@"%@",result]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[HUDManager sharedManager] hud:[NSString stringWithFormat:@"%@",result]];
                });
            }];
            break;
        case 5:
            [PHTool showAssetWithCount:9 mediaType:OnlyVideosType isCamera:NO isCropping:YES complete:^(id result) {
                NSLog(@"%@",[NSString stringWithFormat:@"%@",result]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[HUDManager sharedManager] hud:[NSString stringWithFormat:@"%@",result]];
                });
            }];
            break;
        case 6:
            [PHTool showAssetWithCount:9 mediaType:OnlyVideosType isCamera:YES isCropping:YES complete:^(id result) {
                NSLog(@"%@",[NSString stringWithFormat:@"%@",result]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[HUDManager sharedManager] hud:[NSString stringWithFormat:@"%@",result]];
                });
            }];
            break;
        case 7:
            [PHTool showAssetWithCount:9 mediaType:OnlyVideosType isCamera:YES isCropping:YES complete:^(id result) {
                NSLog(@"%@",[NSString stringWithFormat:@"%@",result]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[HUDManager sharedManager] hud:[NSString stringWithFormat:@"%@",result]];
                });
            }];
            break;
        case 8:
            [PHTool showAssetWithCount:1 mediaType:AllMediaType isCamera:NO isCropping:YES complete:^(id result) {
                NSLog(@"%@",[NSString stringWithFormat:@"%@",result]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[HUDManager sharedManager] hud:[NSString stringWithFormat:@"%@",result]];
                });
            }];
            break;
        case 9:
            [PHTool showAssetWithCount:9 mediaType:AllMediaType isCamera:NO isCropping:YES complete:^(id result) {
                NSLog(@"%@",[NSString stringWithFormat:@"%@",result]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[HUDManager sharedManager] hud:[NSString stringWithFormat:@"%@",result]];
                });
            }];
            break;
        case 10:
            [PHTool showAssetWithCount:1 mediaType:AllMediaType isCamera:YES isCropping:YES complete:^(id result) {
                NSLog(@"%@",[NSString stringWithFormat:@"%@",result]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[HUDManager sharedManager] hud:[NSString stringWithFormat:@"%@",result]];
                });
            }];
            break;
        case 11:
            [PHTool showAssetWithCount:9 mediaType:AllMediaType isCamera:YES isCropping:YES complete:^(id result) {
                NSLog(@"%@",[NSString stringWithFormat:@"%@",result]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[HUDManager sharedManager] hud:[NSString stringWithFormat:@"%@",result]];
                });
            }];
            break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
