# WYMediaAlbum
封装系统相册，单选多选以及预览
/**
 调取照相机和摄像机 单张
 
 @param viewController 试图控制器
 @param cameraType
        PhotoCameraType,拍摄图片
        VideoCameraType,拍摄视频
        AllMediaCameraType,拍摄图片和视频
 @param sure 确定
 @param cancel 取消
 */
+ (void)showCameraInViewController:(UIViewController *)viewController cameraType:(CameraType)cameraType sure:(void(^)(id result))sure cancel:(void(^)(void))cancel dismiss:(void(^)())dismiss;
该方法可以调用系统相机，传入cameraType设置调用的相机类型。

/**
 弹出相册 （默认到第一个分组）
 mediaType:
 1.OnlyPhotosType 图片
 2.OnlyVideosType 视频
 3.AllMediaType   图片和视频
 
 @param count 选择数量
 @param mediaType mediaType description
 @param isCropping 是否裁剪（mediaType = OnlyPhotoType 有效）
 @param isCamera 是否有拍照功能
 @param complete complete description
 */
+ (void)showAssetWithCount:(NSInteger)count
                 mediaType:(SelectMediaType)mediaType
                  isCamera:(BOOL)isCamera
                isCropping:(BOOL)isCropping
                  complete:(void(^)(id result))complete;
该方法可以调取系统的资源：图片和视频.

/**
 根据mediaType获取相册资源
 mediaType = 0;                           图片和视频
 mediaType = PHAssetMediaTypeImage        图片
 mediaType = PHAssetMediaTypeVideo        视频
 
 @param mediaType mediaType description
 @param callback callback description
 */
+ (void)allMediaDataSourceWithMediaType:(PHAssetMediaType)mediaType callback:(void(^)(NSMutableArray<KJAssetCollection *>*array))callback;


/**
 根据mediaType获取每个assetCollection中的相片或视频
 mediaType = 0;                           图片和视频
 mediaType = PHAssetMediaTypeImage        图片
 mediaType = PHAssetMediaTypeVideo        视频
 
 @param assetCollection assetCollection description
 @param mediaType mediaType description
 @return return value description
 */
+ (NSMutableArray *)allAssetsInAssetCollection:(PHAssetCollection *)assetCollection mediaType:(PHAssetMediaType)mediaType;

以上几个方法是该demo的核心方法
