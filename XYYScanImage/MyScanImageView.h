//
//  MyScanImageView.h
//  
//
//  Created by LeslieChen on 15/11/6.
//  Copyright © 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "XYYFoundation.h"
#import "MyScanImageData.h"

//----------------------------------------------------------

@class MyScanImageView;

//----------------------------------------------------------

//图片的的显示状态
typedef NS_OPTIONS(NSInteger,MyScanImageDisplayState) {
    MyScanImageDisplayStateNone    = 0,        //没有显示任何图片
    MyScanImageDisplayStateThumb   = 1 << 0,   //缩略图
    MyScanImageDisplayStateLoading = 1 << 1,   //正在加载
    MyScanImageDisplayStateSource  = 1 << 2    //显示原图
};


//----------------------------------------------------------

@protocol MyScanImageViewDelegate <NSObject>

@optional

//完成显示了图片
- (void)scanImageView:(MyScanImageView *)scanImageView didDisplayImageAtIndex:(NSInteger)index;
////结束显示了图片
//- (void)scanImageView:(MyScanImageView *)scanImageView didEndDisplayImageAtIndex:(NSInteger)index;

//改变了完成加载原图的状态（当改变了显示的图片和显示的图片完成了加载原图时会改变当前原图完成加载的状态）
- (void)scanImageView:(MyScanImageView *)scanImageView imageDisplayStateDidChangeFromState:(MyScanImageDisplayState)state;

//将要旋转
- (BOOL)scanImageView:(MyScanImageView *)scanImageView shouldRotateToOrientation:(UIInterfaceOrientation)orientation;
//已经旋转
- (void)scanImageView:(MyScanImageView *)scanImageView didRotateToOrientation:(UIInterfaceOrientation)orientation;

//已经开始浏览
- (void)scanImageViewDidStartScan:(MyScanImageView *)scanImageView;
//将要结束浏览（返回NO阻止）
- (BOOL)scanImageViewShouldEndScan:(MyScanImageView *)scanImageView;
//已经结束浏览
- (void)scanImageViewDidEndScan:(MyScanImageView *)scanImageView;

@end

//----------------------------------------------------------

//数据源
@protocol MyScanImageViewDataSource <NSObject>

@optional

//返回图片总数(默认为1)
- (NSUInteger)scanImageView:(MyScanImageView *)scanImageView numberOfImagesForScanWithContext:(id)context;

@required

//返回用于浏览的图片
- (MyScanImageData *)scanImageView:(MyScanImageView *)scanImageView imageForScanAtIndex:(NSUInteger)index withContext:(id)context;

@end


//----------------------------------------------------------

@interface MyScanImageView : UIView <MyBlurredBackgroundProtocol>

@property(nonatomic,strong) UIView * overlayView;

//浏览的背景颜色，默认为黑色（无毛玻璃效果时有效）
@property(nonatomic) UIColor * scanBackgroundColor;

//开始浏览图片

//数据源返回
- (void)startScanImageAtIndex:(NSUInteger)index
               withDataSource:(id<MyScanImageViewDataSource>)dataSource
                      context:(id)context
                   baseWindow:(UIWindow *)baseWindow
                     animated:(BOOL)animated
               completedBlock:(void(^)(void))completedBlock;

//固定数目的
- (void)startScanImageAtIndex:(NSUInteger)index
                   withImages:(NSArray<MyScanImageData *> *)images
                   baseWindow:(UIWindow *)baseWindow
                     animated:(BOOL)animated
               completedBlock:(void(^)(void))completedBlock;

- (void)startScanImage:(MyScanImageData *)image
            baseWindow:(UIWindow *)baseWindow
              animated:(BOOL)animated
        completedBlock:(void(^)(void))completedBlock;

//重新加载图片，当数据源的图片数据改变时，调用该方法重新载入数据
- (void)reloadImages:(BOOL)keepDispalyImage;


//是否正在浏览
@property(nonatomic,readonly,getter=isScanning) BOOL scanning;

//结束浏览
- (void)endScanImageWithAnimated:(BOOL)animated completedBlock:(void(^)(void))completedBlock;

//代理和数据源
@property(nonatomic,weak) id<MyScanImageViewDelegate> delegate;
@property(nonatomic,weak,readonly) id<MyScanImageViewDataSource> dataSource;

//浏览图片的上下文，用于数据源区分
@property(nonatomic,strong,readonly) id scanContext;

//当前显示的图片索引
@property(nonatomic,readonly) NSUInteger currentDispalyImageIndex;
//图片总数
@property(nonatomic,readonly) NSUInteger numberOfImages;
//返回特定索引的图片
- (MyScanImageData *)imageAtIndex:(NSUInteger)index;


//图片的显示状态
@property(nonatomic,readonly) MyScanImageDisplayState imageDisplayState;

//是否可以长按将图片保存到相册，默认为YES
@property(nonatomic) BOOL canLongPerssSaveImageToPhotosAlbum;
//保存图片到相册
- (BOOL)saveImageToPhotosAlbum;


//是否显示索引指示，默认为YES
@property(nonatomic) BOOL displayIndexIndicater;
//显示索引指示最少需要的图片数目，（默认为2）
@property(nonatomic) NSUInteger indexIndicaterMinimumDisplayImageCount;

//显示的方向
@property(nonatomic,readonly) UIInterfaceOrientation orientation;

@end


//----------------------------------------------------------

//图片浏览的Overlay视图
@interface UIView (MyScanImageOverlayView)

@property(nonatomic,readonly) MyScanImageView * scanImageView;

//获取显示的位置
- (CGRect)frameThatFitForScanImageOverlayView:(CGRect)bounds safeAreaInsets:(UIEdgeInsets)safeAreaInsets;
//frame无效
- (void)overlayViewFrameInvalidate;

//改变了显示的图片
- (void)didChangeDisplayImage;

@end

//----------------------------------------------------------

//浏览图片的代理
@protocol MyScanImageDelegate <NSObject>

@optional

- (BOOL)object:(id)object wantToScanImage:(MyScanImageData *)image;
- (BOOL)object:(id)object wantToScanImage:(MyScanImageData *)image configureBlock:(void(^)(MyScanImageView * scanImageView))configureBlock;
- (BOOL)object:(id)object wantToScanImages:(NSArray<MyScanImageData *> * )images atIndex:(NSUInteger)index configureBlock:(void(^)(MyScanImageView * scanImageView))configureBlock;
- (BOOL)object:(id<MyScanImageViewDataSource>)object wantToScanImageAtIndex:(NSUInteger)index withContext:(id)context;
- (BOOL)object:(id<MyScanImageViewDataSource>)object wantToScanImageAtIndex:(NSUInteger)index withContext:(id)context configureBlock:(void(^)(MyScanImageView * scanImageView))configureBlock;
//
//@required

//结束浏览图片
- (BOOL)object:(id<MyScanImageViewDataSource>)object wantToEndScanImageWithContex:(id)context;

//重新加载浏览图片
- (BOOL)object:(id<MyScanImageViewDataSource>)object wantToReloadScanImagesWithContex:(id)context;


@end



