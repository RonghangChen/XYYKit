//
//  MyPageView.h
//
//
//  Created by LeslieChen on 15/11/7.
//  Copyright © 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

//滑动的方向
typedef NS_ENUM(NSInteger,MyPageViewScrollDirection) {
    MyPageViewScrollDirectionHorizontal,
    MyPageViewScrollDirectionVertical
};

//----------------------------------------------------------

@class MyPageView;
@protocol MyPageViewDelegate <UIScrollViewDelegate>

@optional

//将要显示page
- (void)pageView:(MyPageView *)pageView willDisplayPageCell:(UICollectionViewCell *)pageCell atIndex:(NSUInteger)pageIndex;

//显示了page(手动更改显示的page和重新加载数据时不会有该代理消息)
- (void)pageView:(MyPageView *)pageView didDisplayPageAtIndex:(NSUInteger)pageIndex;
//隐藏了page
- (void)pageView:(MyPageView *)pageView didEndDisplayPageAtIndex:(NSUInteger)pageIndex;

//选中了page
- (void)pageView:(MyPageView *)pageView didSelectedPageAtIndex:(NSUInteger)pageIndex;

//将要重新加载页面，主要的页面大小改变需要重新加载页面时才会调用，手动重新加载页面不会调动
- (void)pageViewWillReloadPages:(MyPageView *)pageView;

@end

//----------------------------------------------------------

@protocol MyPageViewDataSource <NSObject>

@optional
//page数，默认为1
- (NSUInteger)numberOfPagesInPageView:(MyPageView *)pageView;

@required
- (UICollectionViewCell *)pageView:(MyPageView *)pageView cellForPageAtIndex:(NSUInteger)pageIndex;

@end

//----------------------------------------------------------

NS_CLASS_AVAILABLE_IOS(8_0)
@interface MyPageView : UIView

- (id)initWithFrame:(CGRect)frame scrollDirection:(MyPageViewScrollDirection)scrollDirection;
- (id)initWithFrame:(CGRect)frame scrollDirection:(MyPageViewScrollDirection)scrollDirection containerScrollView:(UIScrollView *)containerScrollView;

//滑动的方向，默认为水平方向
@property(nonatomic,readonly) MyPageViewScrollDirection scrollDirection;

//容器滑动视图
@property(nonatomic,weak,readonly) UIScrollView * containerScrollView;

//页面间距（默认为0），设置小于0的值会以0处理
@property(nonatomic) CGFloat pageMargin;

//是否允许滑动
@property(nonatomic,getter=isScrollEnabled) BOOL scrollEnabled;
//是否允许选择
@property (nonatomic) BOOL allowsSelection;

//页面数目,由数据源决定
@property(nonatomic,readonly) NSUInteger pagesCount;

//返回特定索引上的页面cell，如果索引越界或者页面没有显示将返回nil
- (id)cellForPageAtIndex:(NSUInteger)pageIndex;
//返回page的index
- (NSUInteger)indexForPageCell:(UICollectionViewCell *)cell;
//可见的cell
- (NSArray *)visiblePageCells;

//当前显示的page索引,无页面时改值为NSNotFound
@property(nonatomic) NSUInteger dispalyPageIndex;
//- (void)setDispalyPageIndex:(NSUInteger)dispalyPageIndex animated:(BOOL)animated;

//重新加载page，keepDispalyPage决定重新加载后是否保持当前页面
- (void)reloadPages:(BOOL)keepDispalyPage;

////过渡到新的页面尺寸
//- (void)transitionToPageFrame:(CGRect)pageFrame animated:(BOOL)animated;

//注册复用
- (void)registerCellForPage:(Class)cellClass;
- (void)registerCellForPage:(Class)cellClass andReuseIdentifier:(NSString *)identifier;
- (void)registerCellForPage:(Class)cellClass
               nibNameOrNil:(NSString *)nibNameOrNil
                bundleOrNil:(NSBundle *)bundleOrNil
         andReuseIdentifier:(NSString *)reuseIdentifier;

//返回复用的cell(pageView:cellForPageAtIndex:里调用)
- (id)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forPageIndex:(NSUInteger)pageIndex;

@property(nonatomic,weak) id<MyPageViewDataSource> dataSource;
@property(nonatomic,weak) id<MyPageViewDelegate> delegate;

@end

//----------------------------------------------------------


@interface UICollectionViewCell (MyPageView)

- (UIScrollView *)subPageContentScrollView;

@end
