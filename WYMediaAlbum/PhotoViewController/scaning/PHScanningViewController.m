//
//  PHScanningViewController.m
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/16.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "PHScanningViewController.h"
#import "UIViewController+PHCate.h"
#import "PHHeader.h"
#import "PHScanningCollectionViewCell.h"
#import "PHScanningNavigationView.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PHScanningViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate,PHScanningNavigationViewDelegate>
@property (assign, nonatomic) PHAssetMediaType mediaType;
@end

@implementation PHScanningViewController
{
    UICollectionView            *_collectionView;
    PHScanningNavigationView    *_navigationView;
    NSMutableArray              *_dataArray;
    KJAsset                     *_currentAsset;
    KJAsset                     *_lastAsset;
    
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    self.navigationController.navigationBar.hidden = NO;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    if (self.navigationController.viewControllers.count == 1) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }else{
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self navigation];
    [self collectionView];
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    [self addNavView];
    [self.array enumerateObjectsUsingBlock:^(KJAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.selected) {
            _lastAsset = obj;
            self.mediaType = obj.asset.mediaType;
        }
    }];
}

#pragma mark -
#pragma mark - PRIVATE

- (void)navigation {
    [self barButtonItemImageName:@"ic_login_back" position:@"left"];
    [self barButtonItemTitle:@"  取消"];
    _dataArray = [NSMutableArray arrayWithCapacity:0];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)barImageTap:(UITapGestureRecognizer *)tap {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark - VIEWS

- (void)collectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = [UIScreen mainScreen].bounds.size;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_PH, SCREEN_HEIGHT_PH) collectionViewLayout:layout];
    _collectionView.pagingEnabled = YES;
    _collectionView.backgroundColor = [UIColor blackColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [_collectionView registerClass:[PHScanningCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.view addSubview:_collectionView];
}

- (void)addNavView {
    _navigationView = [[PHScanningNavigationView alloc] init];
    _navigationView.delegate = self;
    [self.view addSubview:_navigationView];
}

#pragma mark -
#pragma mark - <<UICollectionViewDelegate,UICollectionViewDataSource>>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.array.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KJAsset *asset = self.array [indexPath.item];
    PHScanningCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    __block PHScanningCollectionViewCell *cellWeak = cell;
    NSLog(@"%@ ==== %d === %ld",asset,asset.selected,(long)indexPath.item);
    cellWeak.block = ^{
        if (asset.asset.mediaType == PHAssetMediaTypeVideo) {
            [PHData videoUrlWithAsset:asset.asset complete:^(NSURL *url) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
                    playerViewController.player = [AVPlayer playerWithURL:url];
                    // 弹出播放页面
                    [self presentViewController:playerViewController animated:YES completion:^{
                        // 开始播放
                        [playerViewController.player play];
                    }];
                });
            }];
        }else {
            _navigationView.hidden = !_navigationView.hidden;
        }
    };
    [cell showWithKJAsset:asset];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    KJAsset *asset = self.array [indexPath.item];
    _currentAsset = asset;
    NSLog(@"willcell ---- %@ ==== %d === %ld",asset,asset.selected,(long)indexPath.item);
    [_navigationView showSelectedButton:asset.selected];
}

#pragma mark -
#pragma mark - <PHScanningNavigationView>

- (void)scanningNavigationView:(PHScanningNavigationView *)scanningNavigationView clickAtIndex:(NSInteger)index {
    if (index == 1) {
        // 返回
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        //选中
        
        __block NSInteger selectCount = 0;
        [self.array enumerateObjectsUsingBlock:^(KJAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.selected) {
                selectCount ++;
            }
        }];
        if (selectCount == 0) {
            self.mediaType = _currentAsset.asset.mediaType;
        }
        
        if (self.count == 1) {
            if (_lastAsset == _currentAsset) {
                //
            }else {
                _lastAsset.selected = !_lastAsset.selected;
            }
            self.mediaType = _currentAsset.asset.mediaType;
        }else {
            if (self.mediaType) {
                if (_currentAsset.asset.mediaType != self.mediaType) {
                    [[HUDManager sharedManager] hud:@"视频和照片只可以选一种"];
                    return ;
                }
            }
            if (self.count <= selectCount) {
                [[HUDManager sharedManager] hud:@"超出最大限制"];
                return;
            }
        }
        
        _currentAsset.selected = !_currentAsset.selected;
        [_navigationView showSelectedButton:_currentAsset.selected];
        _lastAsset = _currentAsset;
    }
}

- (void)dealloc {
    NSLog(@"PHScanningViewController被释放了");
}
@end
