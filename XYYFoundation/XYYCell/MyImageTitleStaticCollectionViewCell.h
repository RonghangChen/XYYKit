//
//  MyImageTitleStaticCollectionViewCell.h
//  
//
//  Created by LeslieChen on 15/4/4.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyStaticCollectionViewCell.h"
#import "XYYSizeUtil.h"

//----------------------------------------------------------

//cell的状态
typedef NS_OPTIONS(NSUInteger, MyImageTitleStaticCollectionViewCellState) {
    MyImageTitleStaticCollectionViewCellStateNormal      = 0,
    MyImageTitleStaticCollectionViewCellStateHighlighted = 1 << 0,
    MyImageTitleStaticCollectionViewCellStateSelected    = 1 << 1
};


//cell的布局
typedef NS_ENUM(NSInteger,MyImageTitleStaticCollectionViewCellLayout) {
    MyImageTitleStaticCollectionViewCellLayoutImageLeft,    //图左文右
    MyImageTitleStaticCollectionViewCellLayoutImageRight,   //图右文左
    MyImageTitleStaticCollectionViewCellLayoutImageTop,     //图上文下
    MyImageTitleStaticCollectionViewCellLayoutImageBottom   //图下文上
};


//对其方式
typedef NS_ENUM(NSInteger,MyImageTitleStaticCollectionViewCellContentAlign) {
    MyImageTitleStaticCollectionViewCellContentAlignCenter,    //中心对齐
    MyImageTitleStaticCollectionViewCellContentAlignTop,       //上端对齐
    MyImageTitleStaticCollectionViewCellContentAlignBottom,    //下端对齐
    MyImageTitleStaticCollectionViewCellContentAlignLeft =
    MyImageTitleStaticCollectionViewCellContentAlignTop,       //左对齐
    MyImageTitleStaticCollectionViewCellContentAlignRight =
    MyImageTitleStaticCollectionViewCellContentAlignBottom     //右对齐
};

//----------------------------------------------------------

@interface MyImageTitleStaticCollectionViewCell : MyStaticCollectionViewCell

//cell的状态
@property(nonatomic,readonly) MyImageTitleStaticCollectionViewCellState state;

//布局
@property(nonatomic) MyImageTitleStaticCollectionViewCellLayout layout;
//内容布局
@property(nonatomic) MyContentLayout contentLayout;
//对齐方式
@property(nonatomic) MyImageTitleStaticCollectionViewCellContentAlign contentAlign;


//内容布局block,设置该值，可进行完全自定义布局
@property(nonatomic,copy) void(^contentLayoutBlock)(CGRect containerRect,    //容器rect
                                                    CGSize contentSize,      //内容大小
                                                    CGSize imageSize,        //图像大小
                                                    CGSize titleSize,        //文本大小
                                                    CGRect * contentRect,    //返回内容布局的外部变量，基于sectionRect
                                                    CGRect * imageRect,      //返回图像布局的外部变量，基于sectionRect
                                                    CGRect * titleRect);     //返回文本布局的外部变量，基于sectionRect



//设置属性文本，设置后会忽略文本和颜色信息的设置
- (void)setAttributedText:(NSAttributedString *)attributedText forState:(MyImageTitleStaticCollectionViewCellState)state;
- (NSAttributedString *)attributedTextForState:(MyImageTitleStaticCollectionViewCellState)state;
- (NSAttributedString *)showingAttributedTextForState:(MyImageTitleStaticCollectionViewCellState)state;


//字体，默认为17号system字体
@property(nonatomic,strong) UIFont  * textFont;

//设置文本
- (void)setText:(NSString *)text forState:(MyImageTitleStaticCollectionViewCellState)state;

- (NSString *)textForState:(MyImageTitleStaticCollectionViewCellState)state;
- (NSString *)showingTextForState:(MyImageTitleStaticCollectionViewCellState)state;


/**
 * 设置文本颜色
 * @param textColor textColor未文本颜色
 * @param state     state为状态
 */
- (void)setTextColor:(UIColor *)textColor forState:(MyImageTitleStaticCollectionViewCellState)state;

//返回state状态的文本颜色
- (UIColor *)textColorForState:(MyImageTitleStaticCollectionViewCellState)state;

//是否自动调整文本颜色，如果为YES，则当状态改变时，如无颜色则按照一定规律调整显示，默认为YES
@property(nonatomic) BOOL autoAdjustTextColor;

//返回state状态显示的文本颜色，原则是如果state状态无自定义颜色则使用Normal状态下的颜色，Normal无则用默认黑色
- (UIColor *)showingTextColorForState:(MyImageTitleStaticCollectionViewCellState)state;


//设置图片
- (void)setImage:(UIImage *)image forState:(MyImageTitleStaticCollectionViewCellState)state;
- (UIImage *)imageForState:(MyImageTitleStaticCollectionViewCellState)state;


////是否自动调整图片，如果为YES，则当状态改变时，如无自定义图片则通过文字颜色自动改变Normal状态下的图片，默认为YES
//@property(nonatomic) BOOL autoAdjustImage;

//是否调整图片和文本颜色一致，默认为YES
@property(nonatomic) BOOL adjustImageWithTextColor;


//获取索引的index的section在state状态下显示的图片,包含自动调整的结果
- (UIImage *)showingImageForState:(MyImageTitleStaticCollectionViewCellState)state;

//内容缩进量
@property(nonatomic) UIEdgeInsets contentInset;
//内容偏移
@property(nonatomic) CGPoint contentOffset;
//图片间隔，默认为0
@property(nonatomic) CGFloat titleImageMargin;


//文本和图片显示的View
@property(nonatomic,strong,readonly) UILabel * textLabel;
@property(nonatomic,strong,readonly) UIImageView * imageView;


- (void)cellStateDidChangeFromState:(MyImageTitleStaticCollectionViewCellState)fromState;

@end
