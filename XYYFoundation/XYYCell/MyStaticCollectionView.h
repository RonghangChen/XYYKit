//
//  MyCollectionView.h

//
//  Created by LeslieChen on 15/2/27.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "MyStaticCollectionViewCell.h"
#import "MyBorderView.h"

//----------------------------------------------------------

//布局方向
typedef NS_ENUM(NSInteger, MyStaticCollectionViewLayoutDirection) {
    MyStaticCollectionViewLayoutDirectionVertical,
    MyStaticCollectionViewLayoutDirectionHorizontal
};

//分割线风格
typedef NS_ENUM(NSInteger, MyStaticCollectionViewSeparatorLineStyle) {
    MyStaticCollectionViewSeparatorLineStyleNone,
    MyStaticCollectionViewSeparatorLineStyleLine,
    MyStaticCollectionViewSeparatorLineStyleGradient
};

//----------------------------------------------------------

@interface MyStaticCollectionViewSeparatorLineInfo : NSObject

+ (instancetype)defaultSeparatorLineInfo;
+ (instancetype)noSeparatorLineInfo;
+ (instancetype)singleSeparatorLineInfoWithColor:(UIColor *)separatorLineColor;

- (id)initWithSeparatorLineStyle:(MyStaticCollectionViewSeparatorLineStyle)separatorLineStyle
              separatorLineColor:(UIColor *)separatorLineColor
             separatorLineInsets:(UIEdgeInsets)separatorLineInsets;

- (id)initWithSeparatorLineStyle:(MyStaticCollectionViewSeparatorLineStyle)separatorLineStyle
              separatorLineColor:(UIColor *)separatorLineColor
              separatorLineWidth:(CGFloat)separatorLineWidth
             separatorLineInsets:(UIEdgeInsets)separatorLineInsets;

//分割线风格，默认为MyStaticCollectionViewSeparatorLineStyleNone，无分隔线
@property(nonatomic,readonly) MyStaticCollectionViewSeparatorLineStyle separatorLineStyle;
//分割线颜色,默认为灰色
@property(nonatomic,strong,readonly) UIColor * separatorLineColor;
//分割线宽度,默认0.f,即一个像素宽度
@property(nonatomic,readonly) CGFloat separatorLineWidth;
//分隔线inset,默认为UIEdgeInsetsZero
@property(nonatomic,readonly) UIEdgeInsets separatorLineInsets;

@end


//----------------------------------------------------------

@class MyStaticCollectionView;

//----------------------------------------------------------

@protocol MyStaticCollectionViewDelegate <NSObject>

@optional


//布局大小相关
//-----------------------------------

//返回section的占用空间的大小因素
- (NSUInteger)staticCollectionView:(MyStaticCollectionView *)collectionView
             spaceFactorForSection:(NSUInteger)section;

//返回单元的占用空间的大小因素
- (NSUInteger)staticCollectionView:(MyStaticCollectionView *)collectionView
     spaceFactorForItemAtIndexPath:(NSIndexPath *)indexPath;

//sectionInset
- (UIEdgeInsets)staticCollectionView:(MyStaticCollectionView *)collectionView
              sectionInsetForSection:(NSUInteger)section;

//单元的间隔
- (CGFloat)staticCollectionView:(MyStaticCollectionView *)collectionView
     interitemSpacingForSection:(NSUInteger)section;

//section的间隔
- (CGFloat)staticCollectionView:(MyStaticCollectionView *)collectionView
       sectionSpacingForSection:(NSUInteger)section1
                 betweenSection:(NSUInteger)section2;

//分割线相关
//-----------------------------------

- (MyStaticCollectionViewSeparatorLineInfo *)staticCollectionView:(MyStaticCollectionView *)collectionView
                                      separatorLineInfoForSection:(NSUInteger)section1
                                                   betweenSection:(NSUInteger)section2;

- (MyStaticCollectionViewSeparatorLineInfo *)staticCollectionView:(MyStaticCollectionView *)collectionView
                                         separatorLineInfoForItem:(NSUInteger)item1
                                                      betweenItem:(NSUInteger)item2
                                                        inSection:(NSUInteger)section;

//选择相关
//-----------------------------------

// Methods for notification of selection/deselection and highlight/unhighlight events.
// The sequence of calls leading to selection from a user touch is:
//
// (when the touch begins)
// 1. -staticCollectionView:shouldHighlightItemAtIndexPath:
// 2. -staticCollectionView:didHighlightItemAtIndexPath:
//
// (when the touch lifts)
// 3. -staticCollectionView:shouldSelectItemAtIndexPath: or -staticCollectionView:shouldDeselectItemAtIndexPath:
// 4. -staticCollectionView:didSelectItemAtIndexPath: or -staticCollectionView:didDeselectItemAtIndexPath:
// 5. -staticCollectionView:didUnhighlightItemAtIndexPath:

- (BOOL)staticCollectionView:(MyStaticCollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)staticCollectionView:(MyStaticCollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)staticCollectionView:(MyStaticCollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)staticCollectionView:(MyStaticCollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)staticCollectionView:(MyStaticCollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath; // called when the user taps on an already-selected item in multi-select mode
- (void)staticCollectionView:(MyStaticCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)staticCollectionView:(MyStaticCollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

//----------------------------------------------------------

@protocol MyStaticCollectionViewDataSource <NSObject>

- (NSUInteger)staticCollectionView:(MyStaticCollectionView *)collectionView
            numberOfItemsInSection:(NSUInteger)section;

@optional

//返回cell方法，两个至少需要实现一个
- (MyStaticCollectionViewCell *)staticCollectionView:(MyStaticCollectionView *)collectionView
                              cellForItemAtIndexPath:(NSIndexPath *)indexPath;
- (MyStaticCollectionViewCell *)staticCollectionView:(MyStaticCollectionView *)collectionView
                              cellForItemAtIndexPath:(NSIndexPath *)indexPath
                                           itemIndex:(NSUInteger)index;

- (NSUInteger)numberOfSectionInStaticCollectionView:(MyStaticCollectionView *)collectionView;

@end

//----------------------------------------------------------

@interface MyStaticCollectionView : MyBorderView

//布局方向，默认为MyStaticCollectionViewLayoutDirectionVertical
@property(nonatomic) MyStaticCollectionViewLayoutDirection layoutDirection;
//内容的缩进量，默认为UIEdgeInsetsZero
@property(nonatomic) UIEdgeInsets contentInset;


/*重要*/
//下面四个变量设置后（除初始化）需手动调用reloadData才生效

//section的缩进量，默认为UIEdgeInsetsZero
@property(nonatomic) UIEdgeInsets sectionInset;
//section中项目的间隔，默认为0.f
@property(nonatomic) CGFloat interitemSpacing;
//section间距，默认为0.f
@property(nonatomic) CGFloat sectionSpacing;
//分割线信息,默认为defaultSeparatorLineInfo
@property(nonatomic,strong) MyStaticCollectionViewSeparatorLineInfo * separatorLineInfo;

//显示所有的分割线，默认为NO，即当两个item都存在才会显示
@property(nonatomic) BOOL  showAllSeparatorLine;

// default is YES
@property (nonatomic) BOOL allowsSelection;
// default is NO
@property (nonatomic) BOOL allowsMultipleSelection;

//选择
- (NSIndexPath *)indexPathForSelectedItem; // returns nil or an anyone selected index path
- (NSArray *)indexPathsForSelectedItems; // returns nil or an array of selected index paths
- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)deselectAllItem:(BOOL)animated;


//重新加载数据
- (void)reloadData;

//当前数据信息
- (NSUInteger)numberOfSections;
- (NSUInteger)numberOfItemsInSection:(NSInteger)section;

- (__kindof MyStaticCollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)cellsAtSections:(NSIndexSet *)section;
- (NSArray *)allCells;

- (NSIndexPath *)indexPathForCell:(MyStaticCollectionViewCell *)cell;

- (CGRect)itemFrameAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForItemAtPoint:(CGPoint)point;

//代理和数据源
@property(nonatomic,weak) IBOutlet id<MyStaticCollectionViewDelegate> delegate;
@property(nonatomic,weak) IBOutlet id<MyStaticCollectionViewDataSource> dataSource;

//获取可复用的cell，当集合重新加载，所有带有identifier的cell都会放入复用池，可通过该方法使用identifier获取到它们，避免重复加载，cell返回后会立即从复用池移除
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;


@end
