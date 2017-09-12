//
//  Enumeration.h
//  WYPhotoSelectTest
//
//  Created by wangyang on 2017/8/2.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#ifndef Enumeration_h
#define Enumeration_h

/**
 选择的媒体类型
 OnlyPhotosType,图片
 OnlyVideosType,视频
 AllMediaType,图片和视频
 */
typedef enum : NSUInteger {
    OnlyPhotosType,
    OnlyVideosType,
    AllMediaType,
} SelectMediaType;

/**
 拍摄的媒体类型
 PhotoCameraType,拍摄图片
 VideoCameraType,拍摄视频
 AllMediaCameraType,拍摄图片和视频
 */
typedef enum : NSUInteger {
    PhotoCameraType,
    VideoCameraType,
    AllMediaCameraType,
} CameraType;
#endif /* Enumeration_h */
