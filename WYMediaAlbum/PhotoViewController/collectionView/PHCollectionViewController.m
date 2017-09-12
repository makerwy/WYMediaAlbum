//
//  PHCollectionViewController.m
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/9.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "PHCollectionViewController.h"
#import "PHCollectionViewCell.h"
#import "PHHeader.h"
#import "PHTabbarView.h"
#import "PHScanningViewController.h"
#import "CameraCollectionViewCell.h"

@interface PHCollectionViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate,PHTabbarViewDelegate,RSKImageCropViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray <KJAsset *>*array;
@property (strong, nonatomic) NSMutableArray <KJAsset *>*selectedArray;
@property (strong, nonatomic) PHTabbarView *tabView;
@property (strong, nonatomic) KJAsset *cameraAsset;
@property (strong, nonatomic) KJAsset *publicAsset;
@end

@implementation PHCollectionViewController
{
    UICollectionView            *_collectionView;
}
- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    if (self.navigationController.viewControllers.count == 1) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }else{
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if (_collectionView) {
        [_collectionView reloadData];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.array = [NSMutableArray arrayWithCapacity:0];
    self.selectedArray = [NSMutableArray arrayWithCapacity:0];
    [self navigation];
    [self collectionView];
    [self dataSource];
    [self tabBarView];
}

#pragma mark -
#pragma mark - DATA SOURCE

- (void)dataSource {
    if (self.isCamera) {
        self.cameraAsset = [[KJAsset alloc] init];
        self.cameraAsset.isCamera = YES;
        [self.array addObject:self.cameraAsset];
    }
    if (self.mediaType == OnlyPhotosType) {
        [self dataSource:PHAssetMediaTypeImage];
    }else if (self.mediaType == OnlyVideosType) {
        [self dataSource:PHAssetMediaTypeVideo];
    }else {
        [self dataSource:0];
    }
}

#pragma mark -
#pragma mark - PRIVATE

- (void)navigation {
    self.navigationItem.title = self.titleString;
    [self barButtonItemImageName:@"ic_login_back" position:@"left"];
    [self barButtonItemTitle:@"  取消"];
}

- (void)barImageTap:(UITapGestureRecognizer *)tap {
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 根据mediaType获取资源

 @param mediaType mediaType description
 */
- (void)dataSource:(PHAssetMediaType)mediaType {
    NSMutableArray *array = [PHData allAssetsInAssetCollection:self.assetCollection mediaType:mediaType];
    __block NSMutableArray <PHAsset *>*assets = [NSMutableArray arrayWithCapacity:0];
    [array enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __block KJAsset *asset = [[KJAsset alloc] initWithPHAsset:obj];
        asset.selected = NO;
        //如果是视频 获取视频时长
        if (asset.asset.mediaType == PHAssetMediaTypeVideo) {
            NSString *timeLength = [NSString stringWithFormat:@"%0.0f",obj.duration];
            timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
            asset.timeLength = timeLength;
        }
        [assets addObject:asset.asset];
        [self.array addObject:asset];
    }];
    [_collectionView reloadData];
}

/**
 图片预览

 @param array array description
 @param index index description
 */
- (void)scanningViewControllerWithArray:(NSMutableArray *)array index:(NSInteger)index {
    PHScanningViewController *vc = [[PHScanningViewController alloc] init];
    vc.array = array;
    vc.index = index;
    vc.count = self.count;
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 获取视频时间

 @param duration duration description
 @return return value description
 */
- (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration {
    NSString *newTime;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"0:0%zd",duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"0:%zd",duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd",min,sec];
        }
    }
    return newTime;
}

- (void)selectCell:(PHCollectionViewCell *)cell asset:(KJAsset *)asset isSelected:(BOOL)isSelected {
    [cell imageViewAnimation];
    if (self.count == 1) {
        //单选
        if (self.mediaType == AllMediaType) {
            //视频和图片混合的情况
            if (self.selectedArray.count > 0) {
                KJAsset  *selectAsset = self.selectedArray[0];
                if (asset.asset.mediaType != selectAsset.asset.mediaType) {
                    [[HUDManager sharedManager] hud:@"视频和照片只可以选一种"];
                    [cell showSelectImage:NO];
                    return;
                }
            }
        }
        if (self.selectedArray.count > 0) {
            ///单选时，如果数据源数组中已经有被选中的asset，先取消选中
            [self.array enumerateObjectsUsingBlock:^(KJAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.selected) {
                    //更改选中状态
                    obj.selected = NO;
                    PHCollectionViewCell *cell = (PHCollectionViewCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:idx inSection:0]];
                    //更换选中图片
                    [cell showSelectImage:NO];
                    //将asset从选中的数组中删去
                    [self.selectedArray removeObject:obj];
                }
            }];
            if (isSelected) {
                //
                asset.selected = NO;
                cell.selectedButton.selected = NO;
                NSMutableArray *array = self.selectedArray;
                [array enumerateObjectsUsingBlock:^(KJAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([asset.asset.localIdentifier isEqualToString:obj.asset.localIdentifier]) {
                        [self.selectedArray removeObject:asset];
                    }
                }];
            }else {
                asset.selected = YES;
                cell.selectedButton.selected = YES;
                [self.selectedArray addObject:asset];
            }
        }else {
            asset.selected = YES;
            cell.selectedButton.selected = YES;
            [self.selectedArray addObject:asset];
        }
    }else {
        //多选
        if (self.mediaType == AllMediaType) {
            if (self.selectedArray.count > 0) {
                KJAsset  *asset1 = self.selectedArray[0];
                if (asset.asset.mediaType != asset1.asset.mediaType) {
                    [[HUDManager sharedManager] hud:@"视频和照片只可以选一种"];
                    [cell showSelectImage:NO];
                    return;
                }
            }
        }
        if (asset.selected == YES) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                __block NSUInteger index;
                [self.array enumerateObjectsUsingBlock:^(KJAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([asset.asset.localIdentifier isEqualToString:obj.asset.localIdentifier]) {
                        index = idx;
                        *stop = YES;
                    }
                }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    PHCollectionViewCell *cell = (PHCollectionViewCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
                    //更换选中图片
                    [cell showSelectImage:NO];
                    //将asset从选中的数组中删去
                    asset.selected = NO;
                    [self.selectedArray removeObject:asset];
                    [self.tabView count:self.selectedArray.count];
                });
            });
        }else {
            if (self.selectedArray.count >= self.count) {
                [[HUDManager sharedManager] hud:@"超出最大限制"];
                [cell showSelectImage:NO];
                return ;
            }
            asset.selected = YES;
            [self.selectedArray addObject:asset];
            [self.tabView count:self.selectedArray.count];
        }
        
    }
}


#pragma mark -
#pragma mark - VIEWS

- (void)collectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((SCREEN_WIDTH_PH - 25) / 4.0, (SCREEN_WIDTH_PH - 25) / 4.0);
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_PH, SCREEN_HEIGHT_PH - 64 - 49) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
    [_collectionView registerClass:[PHCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [_collectionView registerClass:[CameraCollectionViewCell class] forCellWithReuseIdentifier:@"cameracell"];
    [self.view addSubview:_collectionView];
}

- (void)tabBarView {
    self.tabView = [[PHTabbarView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT_PH - 49 - 64, SCREEN_WIDTH_PH, 49)];
    self.tabView.delegate = self;
    [self.view addSubview:self.tabView];
    if (self.count == 1) {
        self.tabView.isSingle = YES;
    }else {
        self.tabView.isSingle = NO;
    }
}

#pragma mark -
#pragma mark - <<UICollectionViewDelegate,UICollectionViewDataSource>>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.array.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    __block KJAsset *asset = self.array[indexPath.row];
    if (asset.isCamera) {
        //照相机
        CameraCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cameracell" forIndexPath:indexPath];
        return cell;
    } else {
        PHCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        __block PHCollectionViewCell *cellWeak = cell;
        cell.asset = asset;
        cellWeak.block = ^(BOOL isSelected){
            //选择图片点击事件
            [self selectCell:cell asset:asset isSelected:isSelected];
        };
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    KJAsset *asset = self.array[indexPath.row];
    if (asset.isCamera) {
        //呼出照相
        if (self.mediaType == OnlyVideosType) {
            //拍摄视频
            [PHTool showVideoCameraInViewController:self sure:^(NSURL *videoUrl) {
                //
                if (self.publicAsset) {
                    self.publicAsset.videoUrl = videoUrl;
                } else {
                    self.publicAsset  = [[KJAsset alloc] init];
                    self.publicAsset.videoUrl = videoUrl;
                }
            } cancel:^{
                //
            } dismiss:^{
                //
                [self backAndGiveValue];
            }];
        }else if (self.mediaType == OnlyPhotosType) {
            //拍摄照片
            [PHTool showPhotoCameraInViewController:self sure:^(UIImage *image) {
                if (self.publicAsset) {
                    self.publicAsset.cameraImage = image;
                } else {
                    self.publicAsset  = [[KJAsset alloc] init];
                    self.publicAsset.cameraImage = image;
                }
            } cancel:^{
                //
            } dismiss:^{
                [self backAndGiveValue];
            }];
        }else {
            //拍摄视频和照片
            [PHTool showCameraInViewController:self cameraType:AllMediaCameraType sure:^(id result) {
                if ([result isKindOfClass:[UIImage class]]) {
                    //照片
                    UIImage *image = (UIImage *)result;
                    if (self.publicAsset) {
                        self.publicAsset.cameraImage = image;
                    } else {
                        self.publicAsset  = [[KJAsset alloc] init];
                        self.publicAsset.cameraImage = image;
                    }
                }else if ([result isKindOfClass:[NSURL class]]) {
                    //视频
                    NSURL *videoUrl = (NSURL *)result;
                    if (self.publicAsset) {
                        self.publicAsset.videoUrl = videoUrl;
                    } else {
                        self.publicAsset  = [[KJAsset alloc] init];
                        self.publicAsset.videoUrl = videoUrl;
                    }
                }else{
                    
                }
            } cancel:^{
                //
            } dismiss:^{
                [self backAndGiveValue];
            }];
        }
        
    } else {
        PHScanningViewController *vc = [[PHScanningViewController alloc] init];
        __block NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
        
        if (self.isCamera) {
            vc.index = indexPath.item - 1;
            [self.array enumerateObjectsUsingBlock:^(KJAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (idx != 0) {
                    [array addObject:obj];
                }
            }];
            vc.array = array;
        }else {
            vc.index = indexPath.item;
            vc.array = self.array;
        }
        vc.count = self.count;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark -
#pragma mark - <PHTabbarViewDelegate>

- (void)tabbarView:(PHTabbarView *)tabbarView didSelectAtIndex:(NSInteger)index {
    if (index == 1) {
        // 预览
        [self.selectedArray removeAllObjects];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if (self.array.count == 0) {
                return ;
            }
            [self.array enumerateObjectsUsingBlock:^(KJAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.selected) {
                    [self.selectedArray addObject:obj];
                }
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.selectedArray.count > 0) {
                    [self scanningViewControllerWithArray:self.selectedArray index:0];
                }else {
                    [[HUDManager sharedManager] hud:SELECTED_NONE];
                }
            });
        });
    }else if (index == 2) {
        // 完成
        [self backAndGiveValue];
    }
}
//本页面消失且传值
- (void)backAndGiveValue {
    if (self.count == 1) {
        if (!self.publicAsset) {
            self.publicAsset = self.selectedArray[0];
        }
        if ([self.publicAsset isKindOfClass:[KJAsset class]]) {
            //
            KJAsset * asset = (KJAsset*)self.publicAsset;
            
            if (self.mediaType == OnlyPhotosType) {
                if (self.isCropping) {
                    if (asset.cameraImage) {
                        [self cutImageWithImage:asset.cameraImage WithStartOrEnd:nil];
                    } else {
                        [PHData imageHighQualityFormatFromPHAsset:asset.asset imageSize:PHImageManagerMaximumSize complete:^(UIImage *image) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self cutImageWithImage:image WithStartOrEnd:nil];
                            });
                        }];
                    }
                }else {
                    if (asset.cameraImage) {
                        if (self.block) {
                            self.block (asset.cameraImage);
                        }
                    }else {
                        [PHData imageHighQualityFormatFromPHAsset:asset.asset imageSize:PHImageManagerMaximumSize complete:^(UIImage *image) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (self.block) {
                                    self.block (image);
                                }
                            });
                        }];
                    }
                    [self.navigationController dismissViewControllerAnimated:YES completion:^{
                        //判断如果是相机页面dismiss  就再dismiss一次
                        if (self.publicAsset.cameraImage || self.publicAsset.videoUrl) {
                            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                        }
                    }];
                }
            }else if (self.mediaType == OnlyVideosType) {
                if (self.block) {
                    self.block (asset);
                }
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    //判断如果是相机页面dismiss  就再dismiss一次
                    if (self.publicAsset.cameraImage || self.publicAsset.videoUrl) {
                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                    }
                }];
            }else {
                if (asset.asset.mediaType == PHAssetMediaTypeImage) {
                    if (self.isCropping) {
                        if (asset.cameraImage) {
                            [self cutImageWithImage:asset.cameraImage WithStartOrEnd:nil];
                        } else {
                            [PHData imageHighQualityFormatFromPHAsset:asset.asset imageSize:PHImageManagerMaximumSize complete:^(UIImage *image) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self cutImageWithImage:image WithStartOrEnd:nil];
                                });
                            }];
                        }
                    }else {
                        if (asset.cameraImage) {
                            if (self.block) {
                                self.block (asset.cameraImage);
                            }
                        }else {
                            [PHData imageHighQualityFormatFromPHAsset:asset.asset imageSize:PHImageManagerMaximumSize complete:^(UIImage *image) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (self.block) {
                                        self.block (image);
                                    }
                                });
                            }];
                        }
                        [self.navigationController dismissViewControllerAnimated:YES completion:^{
                            //判断如果是相机页面dismiss  就再dismiss一次
                            if (self.publicAsset.cameraImage || self.publicAsset.videoUrl) {
                                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                            }
                        }];
                    }
                }else if (asset.asset.mediaType == PHAssetMediaTypeVideo) {
                    if (self.block) {
                        self.block (asset);
                    }
                    [self.navigationController dismissViewControllerAnimated:YES completion:^{
                        //判断如果是相机页面dismiss  就再dismiss一次
                        if (self.publicAsset.cameraImage || self.publicAsset.videoUrl) {
                            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                        }
                    }];
                }else {
                    if (self.block) {
                        self.block (asset);
                    }
                    [self.navigationController dismissViewControllerAnimated:YES completion:^{
                        //判断如果是相机页面dismiss  就再dismiss一次
                        if (self.publicAsset.cameraImage || self.publicAsset.videoUrl) {
                            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                        }
                    }];
                }
            }
        }
    } else {
        if (self.mediaType == OnlyPhotosType) {
            //照片
            if (self.publicAsset.cameraImage) {
                if (self.block) {
                    self.block (self.publicAsset);
                }
            }else {
                if (self.block) {
                    self.block (self.selectedArray);
                }
            }
        }else if (self.mediaType == OnlyVideosType) {
            //视频
            if (self.publicAsset.videoUrl) {
                if (self.block) {
                    self.block (self.publicAsset);
                }
            }else {
                if (self.block) {
                    self.block (self.selectedArray);
                }
            }
        }else {
            //照片和视频
            if (self.publicAsset) {
                if (self.block) {
                    self.block (self.publicAsset);
                }
            }else {
                if (self.block) {
                    self.block (self.selectedArray);
                }
            }
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            //判断如果是相机页面dismiss  就再dismiss一次
            if (self.publicAsset.cameraImage || self.publicAsset.videoUrl) {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}

//将图片裁剪
-(void)cutImageWithImage:(UIImage *)image WithStartOrEnd:(NSString *)location{
    RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:image cropMode:RSKImageCropModeSquare];
    imageCropVC.delegate = self;
    imageCropVC.ratio = 5.0f;
    [self presentViewController:imageCropVC animated:YES completion:nil];
}

#pragma mark - Delegate Method: RSKImageCropViewControllerDelegate

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect {
    [controller dismissViewControllerAnimated:YES completion:nil];
    if (_block) {
        _block(croppedImage);
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        //判断如果是相机页面dismiss  就再dismiss一次
        if (self.publicAsset.cameraImage || self.publicAsset.videoUrl) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"用户放弃裁剪图片");
}

- (void)dealloc {
    NSLog(@"PHCollectionViewController被释放了");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
