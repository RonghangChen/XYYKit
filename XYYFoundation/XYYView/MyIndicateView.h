//
//  MyLoadingIndicateView.h
//  5idj_ios
//
//  Created by LeslieChen on 14-7-27.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import "MyActivityIndicatorView.h"
#import "XYYSizeUtil.h"

//----------------------------------------------------------

typedef NS_ENUM(int, MyIndicateViewStyle){
    MyIndicateViewStyleNoneView,
    MyIndicateViewStyleActivityView,
    MyIndicateViewStyleImageView,
    MyIndicateViewStyleCustomView
    
};

//----------------------------------------------------------

@interface MyIndicateView : UIView

@property(nonatomic) MyIndicateViewStyle style;


//--------layout----------


//缩进的比例
@property(nonatomic) UIEdgeInsets marginScale;
//缩进的值
@property(nonatomic) UIEdgeInsets marginValue;

//偏移值
@property(nonatomic) CGPoint contentOffset;

//内容布局方式
@property(nonatomic) MyContentLayout contentLayout;

//default is 10.f
@property(nonatomic) float   topMargin;
//default is 5.f
@property(nonatomic) float   bottomMargin;


//--------content----------

@property(nonatomic,strong,readonly) MyActivityIndicatorView * activityIndicatorView;

@property(nonatomic,strong) UIImage  * image;

@property(nonatomic,strong) UIView   * customView;

@property (copy) NSString *titleLabelText;

@property (copy) NSString *detailLabelText;

//--------UI----------

@property(nonatomic,strong) UIFont* titleLabelFont;

@property(nonatomic,strong) UIColor* titleLabelColor;

@property(nonatomic,strong) UIFont* detailLabelFont;

@property(nonatomic,strong) UIColor* detailLabelColor;

@property (assign) float progress;

//-------------------

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

@end





