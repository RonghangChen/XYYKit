//
//  MyUserGuideCell.h
//  
//
//  Created by LeslieChen on 15/5/21.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "XYYFoundation.h"

//----------------------------------------------------------

typedef NS_ENUM(NSInteger, MyUserGuideViewStatus) {
    MyUserGuideViewStatusNone,
    MyUserGuideViewStatusShowing,   //正在显示
    MyUserGuideViewStatusShowed,    //已经显示
    MyUserGuideViewStatusHiding,    //正在隐藏
    MyUserGuideViewStatusHidden     //隐藏
};

typedef NS_ENUM(NSInteger, MyUserGuideViewShowDirection) {
    MyUserGuideViewShowDirectionNext,  //下一个方向
    MyUserGuideViewShowDirectionPrev   //上一个方向
};


//----------------------------------------------------------

@class MyUserGuideView;

//----------------------------------------------------------

@protocol MyUserGuideViewDelegate <NSObject>

@optional

- (void)userGuideViewWantToCompletedGuide:(MyUserGuideView *)userGuideView;

@end

//----------------------------------------------------------

@interface MyUserGuideView: UIView


//开始显示或隐藏
- (void)startShow:(BOOL)show bounces:(BOOL)bounces direction:(MyUserGuideViewShowDirection)direction;
- (void)updateShow:(BOOL)show  withProgress:(CGFloat)progress;
- (void)completedShow:(BOOL)show;
- (void)cancledShow:(BOOL)show;

//动画
- (NSTimeInterval)animationDurationForShow:(BOOL)show
                                   bounces:(BOOL)bounces
                                 direction:(MyUserGuideViewShowDirection)direction;
- (void)animationForShow:(BOOL)show
                 bounces:(BOOL)bounces
                duration:(NSTimeInterval)duration
               direction:(MyUserGuideViewShowDirection)direction;

//子类覆盖
- (void)didStartShow:(BOOL)show
         withBounces:(BOOL)bounces
        andDirection:(MyUserGuideViewShowDirection)direction;

- (void)didCompletedShow:(BOOL)show
           withDirection:(MyUserGuideViewShowDirection)direction;

- (void)didCancledShow:(BOOL)show
           withBounces:(BOOL)bounces
          andDirection:(MyUserGuideViewShowDirection)direction;


@property(nonatomic,readonly) MyUserGuideViewStatus status;
@property(nonatomic,weak) id<MyUserGuideViewDelegate> delegate;

- (void)updateViewWithPageInfo:(NSDictionary *)pageInfo context:(MyCellContext *)context;
- (void)tryCompletedGuide;

@end
