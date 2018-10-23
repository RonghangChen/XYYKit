//
//  ED_SharePopoverView.h
//  
//
//  Created by LeslieChen on 15/3/11.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "XYYFoundation.h"

//----------------------------------------------------------

@class MySocialShareTargetItem;
@class MySocialShareTargetItemsPopoverView;

//----------------------------------------------------------

@protocol MySocialShareTargetItemsPopoverViewDelegate <NSObject>

@optional

- (void)sharePopoverView:(MySocialShareTargetItemsPopoverView *)sharePopoverView willShow:(BOOL)show;
- (void)sharePopoverView:(MySocialShareTargetItemsPopoverView *)sharePopoverView didShow:(BOOL)show;

//点击了取消
- (BOOL)sharePopoverViewWillCancleShare:(MySocialShareTargetItemsPopoverView *)sharePopoverView;
//点击了分享项目
- (void)    sharePopoverView:(MySocialShareTargetItemsPopoverView *)sharePopoverView
       didTapShareTargetItem:(MySocialShareTargetItem *)targetItem;

@end

//----------------------------------------------------------

@interface MySocialShareTargetItemsPopoverView : UIView <MyBlurredBackgroundProtocol,MyAlertViewProtocol>

//自定义的分享项目
- (id)initWithShareTargetItems:(NSArray *)shareTargetItems;

//分享的目标项目
@property(nonatomic,copy) NSArray * shareTargetItems;

//显示
- (void)show:(void (^)(void))completedBlock;
//是否在显示
@property(nonatomic,readonly,getter = isShowing) BOOL showing;
//隐藏
- (void)hide:(void (^)(void))completedBlock;

//代理和上下文
@property(nonatomic,weak) id<MySocialShareTargetItemsPopoverViewDelegate> delegate;
@property(nonatomic,strong) id context;

@end

//----------------------------------------------------------

@protocol MyShowSocialShareTargetItemsPopoverViewDelegate  <NSObject>

@optional

- (void)object:(id)object wantToShowShareTargetItemsPopoverViewWithContext:(id)context;

@end

