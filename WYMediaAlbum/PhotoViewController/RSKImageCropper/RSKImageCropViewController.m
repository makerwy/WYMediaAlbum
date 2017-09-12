//
// RSKImageCropViewController.m
//
// Copyright (c) 2014 Ruslan Skorb, http://ruslanskorb.com/
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "RSKImageCropViewController.h"
#import "RSKTouchView.h"
#import "RSKImageScrollView.h"
#import "UIImage+FixOrientation.h"

static const CGFloat kPortraitCircleMaskRectInnerEdgeInset = 50.0f;     // 圆形时边距
static const CGFloat kPortraitSquareMaskRectInnerEdgeInset = 20.0f;     // 正方形时边距

static const CGFloat kLandscapeCircleMaskRectInnerEdgeInset = 45.0f;
static const CGFloat kLandscapeSquareMaskRectInnerEdgeInset = 45.0f;

@interface RSKImageCropViewController ()

@property (strong, nonatomic) RSKImageScrollView *imageScrollView;
@property (strong, nonatomic) RSKTouchView *overlayView;
@property (strong, nonatomic) CAShapeLayer *maskLayer;
@property (assign, nonatomic) CGRect maskRect;
@property (strong, nonatomic) UIBezierPath *maskPath;


@property (strong, nonatomic) UITapGestureRecognizer *doubleTapGestureRecognizer;

@property (assign, nonatomic) BOOL didSetupConstraints;

@end

@implementation RSKImageCropViewController

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _avoidEmptySpaceAroundImage = YES;
        _applyMaskToCroppedImage = NO;
        _cropMode = RSKImageCropModeCircle;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)originalImage {
    self = [self init];
    if (self) {
        _originalImage = originalImage;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)originalImage cropMode:(RSKImageCropMode)cropMode {
    self = [self initWithImage:originalImage];
    if (self) {
        _cropMode = cropMode;
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 设置页面偏移
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.view.backgroundColor = [UIColor blackColor];
    self.view.clipsToBounds = YES;
    
    [self.view addSubview:self.imageScrollView];
    [self.view addSubview:self.overlayView];
    
    [self.view addGestureRecognizer:self.doubleTapGestureRecognizer];
    
    // 添加其他自定义视图
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    UIView *statsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 20)];
    [self.view addSubview:statsView];
    statsView.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1];
    
    UIView *btmView = [[UIView alloc] initWithFrame:CGRectMake(0, height-45, width, 45)];
    [self.view addSubview:btmView];
    btmView.backgroundColor = statsView.backgroundColor;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, 1)];
    imageView.image = [UIImage imageNamed:@"line_320x1_1.png"];
    [btmView addSubview:imageView];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [btmView addSubview:leftButton];
    
    leftButton.frame = CGRectMake(0, 1, 52, 44);
    [leftButton addTarget:self action:@selector(onCancelButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setTitle:@"取消" forState:normal];
    [leftButton setTitleColor:[UIColor colorWithRed:27/255.0 green:158/255.0 blue:1 alpha:1] forState:normal];
    [leftButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [btmView addSubview:rightButton];
    
    rightButton.frame = CGRectMake(width-52, 1, 52, 44);
    [rightButton addTarget:self action:@selector(onChooseButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setTitle:@"保存" forState:normal];
    [rightButton setTitleColor:[UIColor colorWithRed:27/255.0 green:158/255.0 blue:1 alpha:1] forState:normal];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
}

// 将要布局子视图
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    [self updateMaskRect];          // 获取中间部分区域
    [self layoutImageScrollView];   // 设置滚动视图区域
    [self layoutOverlayView];       // 设置覆盖层范围
    [self updateMaskPath];          // 更新的遮罩路径
//    [self.view setNeedsUpdateConstraints];      // 需要更新内容
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (!self.imageScrollView.zoomView) {
        [self displayImage];
    }
}

#pragma mark - Custom Accessors

- (RSKImageScrollView *)imageScrollView {       // 图片滚动视图
    if (!_imageScrollView) {
        _imageScrollView = [[RSKImageScrollView alloc] init];
        _imageScrollView.clipsToBounds = NO;
        _imageScrollView.aspectFill = self.avoidEmptySpaceAroundImage;
    }
    return _imageScrollView;
}

- (RSKTouchView *)overlayView {                 // 遮盖层
    if (!_overlayView) {
        _overlayView = [[RSKTouchView alloc] init];
        _overlayView.receiver = self.imageScrollView;
        [_overlayView.layer addSublayer:self.maskLayer];
    }
    return _overlayView;
}

- (CAShapeLayer *)maskLayer {
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.fillRule = kCAFillRuleEvenOdd;
        _maskLayer.fillColor = self.maskLayerColor.CGColor;
    }
    return _maskLayer;
}

- (UIColor *)maskLayerColor {
    if (!_maskLayerColor) {
        _maskLayerColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f];
    }
    return _maskLayerColor;
}

- (UITapGestureRecognizer *)doubleTapGestureRecognizer {
    if (!_doubleTapGestureRecognizer) {
        _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        _doubleTapGestureRecognizer.delaysTouchesEnded = NO;
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    }
    return _doubleTapGestureRecognizer;
}

- (void)setAvoidEmptySpaceAroundImage:(BOOL)avoidEmptySpaceAroundImage {
    if (_avoidEmptySpaceAroundImage != avoidEmptySpaceAroundImage) {
        _avoidEmptySpaceAroundImage = avoidEmptySpaceAroundImage;
        
        self.imageScrollView.aspectFill = avoidEmptySpaceAroundImage;
    }
}

- (void)setOriginalImage:(UIImage *)originalImage {
    if (![_originalImage isEqual:originalImage]) {
        _originalImage = originalImage;
        if (self.isViewLoaded) {
            [self displayImage];
        }
    }
}

- (void)setMaskPath:(UIBezierPath *)maskPath {
    if (![_maskPath isEqual:maskPath]) {
        _maskPath = maskPath;
        
        UIBezierPath *clipPath = [UIBezierPath bezierPathWithRect:self.overlayView.frame];
        [clipPath appendPath:maskPath];
        clipPath.usesEvenOddFillRule = YES;
        
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnimation.duration = [CATransaction animationDuration];
        pathAnimation.timingFunction = [CATransaction animationTimingFunction];
        [self.maskLayer addAnimation:pathAnimation forKey:@"path"];
        
        self.maskLayer.path = [clipPath CGPath];
    }
}

#pragma mark - Action handling

- (void)onCancelButtonTouch:(UIBarButtonItem *)sender {
    [self cancelCrop];
}

- (void)onChooseButtonTouch:(UIBarButtonItem *)sender{
    [self cropImage];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    [self resetZoomScale:YES];
    [self resetContentOffset:YES];
}

#pragma mark - Private

// 状态栏方向
- (BOOL)isPortraitInterfaceOrientation {
    return UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
}

- (void)resetZoomScale:(BOOL)animated {
    CGFloat zoomScale;
    if (CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds)) {
        zoomScale = CGRectGetHeight(self.view.bounds) / self.originalImage.size.height;
    } else {
        zoomScale = CGRectGetWidth(self.view.bounds) / self.originalImage.size.width;
    }
    [self.imageScrollView setZoomScale:zoomScale animated:animated];
}

// 重定义滚动范围
- (void)resetContentOffset:(BOOL)animated {
    CGSize boundsSize = self.imageScrollView.bounds.size;
    CGRect frameToCenter = self.imageScrollView.zoomView.frame;
    
    CGPoint contentOffset;
    if (CGRectGetWidth(frameToCenter) > boundsSize.width) {
        contentOffset.x = (CGRectGetWidth(frameToCenter) - boundsSize.width) * 0.5f;
    } else {
        contentOffset.x = 0;
    }
    if (CGRectGetHeight(frameToCenter) > boundsSize.height) {
        contentOffset.y = (CGRectGetHeight(frameToCenter) - boundsSize.height) * 0.5f;
    } else {
        contentOffset.y = 0;
    }
    
    [self.imageScrollView setContentOffset:contentOffset animated:animated];
}

- (void)displayImage {
    if (self.originalImage) {
        [self.imageScrollView displayImage:self.originalImage];
        [self resetZoomScale:NO];
        [self resetContentOffset:NO];
    }
}

//
- (void)layoutImageScrollView {
    self.imageScrollView.frame = self.maskRect;
}

//
- (void)layoutOverlayView {
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds) * 2, CGRectGetHeight(self.view.bounds) * 2);
    self.overlayView.frame = frame;
}

// 中间显示部分区域
- (void)updateMaskRect
{
    switch (self.cropMode) {
        case RSKImageCropModeCircle: {
            CGFloat viewWidth = CGRectGetWidth(self.view.frame);
            CGFloat viewHeight = CGRectGetHeight(self.view.frame);
            
            CGFloat diameter;
            if ([self isPortraitInterfaceOrientation]) {
                diameter = MIN(viewWidth, viewHeight) - kPortraitCircleMaskRectInnerEdgeInset * 2;
            } else {
                diameter = MIN(viewWidth, viewHeight) - kLandscapeCircleMaskRectInnerEdgeInset * 2;
            }
            
            CGSize maskSize = CGSizeMake(diameter, diameter);
            
            self.maskRect = CGRectMake((viewWidth - maskSize.width) * 0.5f,
                                       (viewHeight - maskSize.height) * 0.5f,
                                       maskSize.width,
                                       maskSize.height);
            break;
        }
        case RSKImageCropModeSquare: {
            CGFloat viewWidth = CGRectGetWidth(self.view.frame);
            CGFloat viewHeight = CGRectGetHeight(self.view.frame);
            
            CGFloat length;
            if ([self isPortraitInterfaceOrientation]) {
                length = MIN(viewWidth, viewHeight) - kPortraitSquareMaskRectInnerEdgeInset * 2;
            } else {
                length = MIN(viewWidth, viewHeight) - kLandscapeSquareMaskRectInnerEdgeInset * 2;
            }
            
            CGSize maskSize = CGSizeMake(length, length);
            
            self.maskRect = CGRectMake((viewWidth - maskSize.width) * 0.5f,
                                       (viewHeight - maskSize.height) * 0.5f,
                                       maskSize.width,
                                       maskSize.height);
            break;
        }
        case RSKImageCropModeCustom: {
                self.maskRect = CGRectMake(0, [UIScreen mainScreen].bounds.size.height / 2.0 -  [UIScreen mainScreen].bounds.size.width * self.ratio / 2.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * self.ratio);
            break;
        }
    }
}

- (void)updateMaskPath
{
    switch (self.cropMode) {
        case RSKImageCropModeCircle: {
            self.maskPath = [UIBezierPath bezierPathWithOvalInRect:self.maskRect];    
            break;
        }
        case RSKImageCropModeSquare: {
            self.maskPath = [UIBezierPath bezierPathWithRect:self.maskRect];
            break;
        }
        case RSKImageCropModeCustom: {
            CGRect rect = CGRectMake(0, [UIScreen mainScreen].bounds.size.height / 2.0 -  [UIScreen mainScreen].bounds.size.width * self.ratio / 2.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * self.ratio);
            self.maskPath = [UIBezierPath bezierPathWithRect:rect];
            break;
        }
    }
}

- (CGRect)cropRect
{
    CGRect cropRect = CGRectZero;
    float zoomScale = 1.0 / self.imageScrollView.zoomScale;
    
    cropRect.origin.x = round(self.imageScrollView.contentOffset.x * zoomScale);
    cropRect.origin.y = round(self.imageScrollView.contentOffset.y * zoomScale);
    cropRect.size.width = CGRectGetWidth(self.imageScrollView.bounds) * zoomScale;
    cropRect.size.height = CGRectGetHeight(self.imageScrollView.bounds) * zoomScale;
    
    cropRect = CGRectIntegral(cropRect);
    
    return cropRect;
}

- (UIImage *)croppedImage:(UIImage *)image cropRect:(CGRect)cropRect
{
    // Step 1: check and correct the crop rect.
    CGSize imageSize = image.size;
    CGFloat x = CGRectGetMinX(cropRect);
    CGFloat y = CGRectGetMinY(cropRect);
    CGFloat width = CGRectGetWidth(cropRect);
    CGFloat height = CGRectGetHeight(cropRect);
    
    UIImageOrientation imageOrientation = image.imageOrientation;
    if (imageOrientation == UIImageOrientationRight || imageOrientation == UIImageOrientationRightMirrored) {
        cropRect.origin.x = y;
        cropRect.origin.y = round(imageSize.width - CGRectGetWidth(cropRect) - x);
        cropRect.size.width = height;
        cropRect.size.height = width;
    } else if (imageOrientation == UIImageOrientationLeft || imageOrientation == UIImageOrientationLeftMirrored) {
        cropRect.origin.x = round(imageSize.height - CGRectGetHeight(cropRect) - y);
        cropRect.origin.y = x;
        cropRect.size.width = height;
        cropRect.size.height = width;
    } else if (imageOrientation == UIImageOrientationDown || imageOrientation == UIImageOrientationDownMirrored) {
        cropRect.origin.x = round(imageSize.width - CGRectGetWidth(cropRect) - x);
        cropRect.origin.y = round(imageSize.height - CGRectGetHeight(cropRect) - y);
    }
    
    // Step 2: create an image using the data contained within the specified rect.
    CGImageRef croppedCGImage = CGImageCreateWithImageInRect(image.CGImage, cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedCGImage scale:1.0f orientation:image.imageOrientation];
    CGImageRelease(croppedCGImage);
    
    // Step 3: fix orientation of the cropped image.
    croppedImage = [croppedImage fixOrientation];
    
    // Step 4: If current mode is `RSKImageCropModeSquare` or mask should not be applied to the image after cropping,
    // we can return the cropped image immediately.
    // Otherwise, we need to apply the mask to the image.
    if (self.cropMode == RSKImageCropModeSquare || !self.applyMaskToCroppedImage) {
        // Step 5: return the cropped image
        return croppedImage;
    } else {
        UIBezierPath *maskPath = [self.maskPath copy];
        
        // Step 5: scale the mask to the size of the cropped image.
        CGFloat scale;
        if (croppedImage.size.height > croppedImage.size.width) {
            scale = croppedImage.size.height / CGRectGetHeight(maskPath.bounds);
        } else {
            scale = croppedImage.size.width / CGRectGetWidth(maskPath.bounds);
        }
        [maskPath applyTransform:CGAffineTransformMakeScale(scale, scale)];
        
        // Step 6: move the mask to the top-left.
        CGPoint translation = CGPointMake(-CGRectGetMinX(maskPath.bounds), -CGRectGetMinY(maskPath.bounds));
        [maskPath applyTransform:CGAffineTransformMakeTranslation(translation.x, translation.y)];
        
        // Step 7: apply the mask on the cropped image.
        UIGraphicsBeginImageContext(maskPath.bounds.size);
        
        // 7a: apply the mask.
        [maskPath addClip];
        
        // 7b: draw the cropped image.
        CGPoint point = CGPointMake(round((CGRectGetWidth(maskPath.bounds) - croppedImage.size.width) * 0.5f),
                                    round((CGRectGetHeight(maskPath.bounds) - croppedImage.size.height) * 0.5f));
        [croppedImage drawAtPoint:point];
        
        // 7c: get the cropped image to which the mask is applied.
        croppedImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        croppedImage = [UIImage imageWithCGImage:croppedImage.CGImage];
        
        // Step 8: return the cropped image
        return croppedImage;
    }
}

- (void)cropImage
{
    if ([self.delegate respondsToSelector:@selector(imageCropViewController:willCropImage:)]) {
        [self.delegate imageCropViewController:self willCropImage:self.originalImage];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGRect cropRect = [self cropRect];
        UIImage *croppedImage = [self croppedImage:self.originalImage cropRect:cropRect];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(imageCropViewController:didCropImage:usingCropRect:)]) {
                [self.delegate imageCropViewController:self didCropImage:croppedImage usingCropRect:cropRect];
            }
        });
    });
}

- (void)cancelCrop
{
    if ([self.delegate respondsToSelector:@selector(imageCropViewControllerDidCancelCrop:)]) {
        [self.delegate imageCropViewControllerDidCancelCrop:self];
    }
}

@end
