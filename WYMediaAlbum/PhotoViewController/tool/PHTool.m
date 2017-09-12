//
//  PHTool.m
//  KJPhotoManager
//
//  Created by wangyang on 2017/3/9.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "PHTool.h"
#import "PHGroupViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

typedef void(^PHToolCameraSureBlock)(id result);
typedef void(^PHToolCancelBlock)(void);
typedef void(^PHToolDismissBlock)(void);

static PHTool *manager;

@interface PHTool()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
/**
 照相机 单选
 */
@property (strong, nonatomic) UIImagePickerController *pickerViewController;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (copy, nonatomic)  PHToolCameraSureBlock cameraSureBlock;
@property (copy, nonatomic)  PHToolCancelBlock cancelBlock;
@property (copy, nonatomic)  PHToolDismissBlock dismissBlock;
@end

@implementation PHTool

+ (PHTool *)shareManager {
    if (!manager) {
        manager = [[PHTool alloc] init];
    }
    return manager;
}

/**
 调取照相机和摄像机 单张
 
 @param viewController 试图控制器
 @param sure 确定
 @param cancel 取消
 */
+ (void)showCameraInViewController:(UIViewController *)viewController cameraType:(CameraType)cameraType sure:(void(^)(id result))sure cancel:(void(^)(void))cancel dismiss:(void(^)())dismiss {
    // 判断是否有相机
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if (cameraType == PhotoCameraType) {
            picker.mediaTypes = @[(NSString *)kUTTypeImage];
        }else if (cameraType == VideoCameraType) {
            picker.mediaTypes = @[(NSString *)kUTTypeMovie];
        }else {
            picker.mediaTypes = @[(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage];
        }
        picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;//设置相机后摄像头
        picker.videoMaximumDuration = 10;//最长拍摄时间
        picker.videoQuality = UIImagePickerControllerQualityTypeHigh;//拍摄质量
        
        picker.allowsEditing = NO;//是否可编辑
        picker.delegate = [PHTool shareManager];
        [viewController presentViewController:picker animated:YES completion:nil];
        [PHTool shareManager].pickerViewController = picker;
    }else {
        NSLog(@"该设备无摄像头");
    }
    [PHTool shareManager].cameraSureBlock = sure;
    [PHTool shareManager].cancelBlock = cancel;
    [PHTool shareManager].dismissBlock = dismiss;
}

/**
 调取照相机
 
 @param viewController 视图控制器
 @param sure 确定
 @param cancel 取消
 */
+ (void)showPhotoCameraInViewController:(UIViewController *)viewController sure:(void(^)(UIImage *image))sure cancel:(void(^)(void))cancel dismiss:(void(^)())dismiss {
    [PHTool showCameraInViewController:viewController cameraType:PhotoCameraType sure:sure cancel:cancel dismiss:dismiss];
}

/**
 调取摄像机拍摄视频
 
 @param viewController 视图控制器
 @param sure 确定
 @param cancel 取消
 */
+ (void)showVideoCameraInViewController:(UIViewController *)viewController sure:(void(^)(NSURL *videoUrl))sure cancel:(void(^)(void))cancel dismiss:(void(^)())dismiss {
    [PHTool showCameraInViewController:viewController cameraType:VideoCameraType sure:sure cancel:cancel dismiss:dismiss];
}

#pragma mark -
#pragma mark - PRIVATE METHOD <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([PHTool shareManager].cancelBlock) {
        [PHTool shareManager].cancelBlock ();
    }
    [[PHTool shareManager].pickerViewController dismissViewControllerAnimated:YES completion:^{
        if ([PHTool shareManager].dismissBlock) {
            [PHTool shareManager].dismissBlock();
        }
    }];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {//如果是拍照
        UIImage *image;
        //如果允许编辑则获得编辑后的照片，否则获取原始照片
        if (picker.allowsEditing) {
            image=[info objectForKey:UIImagePickerControllerEditedImage];//获取编辑后的照片
        }else{
            image=[info objectForKey:UIImagePickerControllerOriginalImage];//获取原始照片
        }
        if ([PHTool shareManager].cameraSureBlock) {
            [PHTool shareManager].cameraSureBlock (image);
            [[PHTool shareManager].pickerViewController dismissViewControllerAnimated:YES completion:^{
                if ([PHTool shareManager].dismissBlock) {
                    [PHTool shareManager].dismissBlock();
                }
            }];
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);//保存到相簿
    }else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){//如果是录制视频
        NSLog(@"video...");
        NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
        NSString *urlStr=[url path];
        if ([PHTool shareManager].cameraSureBlock) {
            [PHTool shareManager].cameraSureBlock (url);
            [[PHTool shareManager].pickerViewController dismissViewControllerAnimated:YES completion:^{
                if ([PHTool shareManager].dismissBlock) {
                    [PHTool shareManager].dismissBlock();
                }
            }];
        }
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
            //保存视频到相簿，注意也可以使用ALAssetsLibrary来保存
            UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);//保存视频到相簿
        }
        
    }
}

//视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功.");
    }
}

#pragma mark --
#pragma mark -- 弹出相册

/**
 弹出自定义相册 默认到所有照片中 (无视频)
 不裁剪
 @param count 选择数量
 */
+ (void)showImagesWithCount:(NSInteger)count complete:(void(^)(id result))complete {
    [PHTool showImagesWithCount:count isCropping:NO complete:^(id result) {
        if (complete) {
            complete(result);
        }
    }];
}

/**
 弹出自定义相册 默认到所有照片中 (无视频，默认可以拍照)
 @param count 选择数量
 @param isCropping 是否裁剪（count == 1有效）
 */
+ (void)showImagesWithCount:(NSInteger)count isCropping:(BOOL)isCropping complete:(void(^)(id result))complete {
    [PHTool showAssetWithCount:count mediaType:OnlyPhotosType isCamera:YES isCropping:isCropping complete:^(id result) {
        if (complete) {
            complete(result);
        }
    }];
}

/**
 弹出自定义相册 默认到所有视频中
 
 @param complete complete
 */
+ (void)showVideosWithCount:(NSInteger)count complete:(void(^)(id result))complete {
    [PHTool showAssetWithCount:count mediaType:OnlyVideosType isCamera:NO isCropping:NO complete:^(id result) {
        if (complete) {
            complete(result);
        }
    }];
}

/**
 弹出自定义相册 包含视频和图片
 
 @param count count description
 @param complete complete description
 */
+ (void)showAllAssetWithCount:(NSInteger)count complete:(void(^)(id result))complete {
    [PHTool showAssetWithCount:count mediaType:AllMediaType isCamera:NO isCropping:NO complete:^(id result) {
        if (complete) {
            complete(result);
        }
    }];
}

/**
 弹出相册 （默认到第一个分组）
 
 @param count 选择数量
 @param mediaType mediaType description
 @param isCropping 是否裁剪（mediaType = OnlyPhotoType count = 1有效）
 @param complete complete description
 */
+ (void)showAssetWithCount:(NSInteger)count
                 mediaType:(SelectMediaType)mediaType
                  isCamera:(BOOL)isCamera
                isCropping:(BOOL)isCropping
                  complete:(void(^)(id result))complete {
    PHGroupViewController *vc = [[PHGroupViewController alloc] init];
    vc.count = count;
    vc.isCropping = isCropping;
    vc.mediaType = mediaType;
    vc.isCamera = isCamera;
    vc.block = ^(id asset) {
        if (complete) {
            complete (asset);
        }
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [window.rootViewController presentViewController:nav animated:YES completion:nil];
}

+ (void)release {
    manager = nil;
    [PHTool shareManager].cancelBlock = nil;
    [PHTool shareManager].navigationController = nil;
    [PHTool shareManager].cameraSureBlock = nil;
}

@end
