 //
//  MyScrollTriggerView.m
//
//
//  Created by LeslieChen on 14/11/11.
//  Copyright (c) 2014年 YB. All rights reserved.
//

//----------------------------------------------------------

#import "MyScrollTriggerView.h"
#import "XYYConst.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NSObject+runtime.h"

//----------------------------------------------------------

#define defaultMinTriggerDistance 50.f

//----------------------------------------------------------

@interface UIScrollView (_MyScrollTriggerView)


//滑动触发视图集合
@property(nonatomic,strong,readonly) NSMutableDictionary * scrollTriggerViews;

//返回滑动触发视图，没有返回nil
- (MyScrollTriggerView *)scrollTriggerViewForLocation:(MyScrollTriggerViewLocation)location;
//添加滑动触发视图，每个位置有且只能有一个，否则会抛出异常
- (void)addScrollTriggerView:(MyScrollTriggerView *)scrollTriggerView forLocation:(MyScrollTriggerViewLocation)location;
//移除滑动触发视图
- (void)removeScrollTriggerViewForLocation:(MyScrollTriggerViewLocation)location;

//原始contentInset,即不附加scrollTriggerViewContentInset，contentInset = originalContentInset + scrollTriggerViewContentInset
@property(nonatomic) UIEdgeInsets originalContentInset;
//定位所用的原始contentInset，考虑adjustContentInset;
@property(nonatomic,readonly) UIEdgeInsets originalLocationContentInset;

//滑动触发视图附加的contentInset
@property(nonatomic,readonly) UIEdgeInsets scrollTriggerViewContentInset;
//更新contentInset
- (void)updateContentInsetForScrollTriggerView;

@end

//----------------------------------------------------------

@interface MyScrollTriggerView()

//扩展的contentInset
@property(nonatomic,readonly) UIEdgeInsets appendContentInset;

@end

//----------------------------------------------------------

@implementation MyScrollTriggerView
{
    BOOL _ignoreChange;
}

#pragma mark - life circle

- (id)initWithCoder:(NSCoder *)aDecoder
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"MyScrollTriggerView不能通过initWithCoder:方法进行初始化"
                                 userInfo:nil];
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithLocation:MyScrollTriggerViewLocationTop minTriggerDistance:defaultMinTriggerDistance];
}

- (id)initWithLocation:(MyScrollTriggerViewLocation)location {
    return [self initWithLocation:location minTriggerDistance:defaultMinTriggerDistance];
}

- (id)initWithLocation:(MyScrollTriggerViewLocation)location minTriggerDistance:(CGFloat)minTriggerDistance
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _location = location;
        _minTriggerDistance = minTriggerDistance;
        _animationrDuration = 0.4;
        _alphaChangeWithScroll = YES;
        _invalidate = YES;
    }
    
    return self;
}

#pragma mark -

- (void)setFrame:(CGRect)frame {
    [self _updateFrame];
}

- (void)setBounds:(CGRect)bounds {
    [self _updateFrame];
}

- (void)setCenter:(CGPoint)center {
    [self _updateFrame];
}

- (void)setMinTriggerDistanceOffset:(CGFloat)minTriggerDistanceOffset
{
    if (_minTriggerDistanceOffset != minTriggerDistanceOffset) {
        _minTriggerDistanceOffset = minTriggerDistanceOffset;
        [self invalidate];
    }
}

- (void)setLocationOffset:(CGPoint)locationOffset
{
    if (!CGPointEqualToPoint(locationOffset, _locationOffset)) {
        _locationOffset = locationOffset;
        [self invalidate];
        
        //更新位置
        [self _updateFrame];
    }
}

- (void)setMode:(MyScrollTriggerViewTriggerMode)mode
{
    if (_mode != mode) {
        _mode = mode;
        [self invalidate];
    }
}

- (void)setEnabled:(BOOL)enabled
{
    if (self.isEnabled != enabled) {
        
        if (!enabled) {
            [self invalidate];
        }
        
        [super setEnabled:enabled];
    }
}

- (void)setHidden:(BOOL)hidden
{
    if (self.isHidden != hidden) {
        
        if (hidden) {
            [self invalidate];
        }
        
        [super setHidden:hidden];
    }
}

- (void)setAlphaChangeWithScroll:(BOOL)alphaChangeWithScroll
{
    if (_alphaChangeWithScroll != alphaChangeWithScroll) {
        _alphaChangeWithScroll = alphaChangeWithScroll;
        
        if (self.state != MyScrollTriggerViewStatusTriggering) {
            [self invalidate];
        }
    }
}

#pragma mark -

- (UIScrollView *)scrollView {
    return (UIScrollView *)self.superview;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview) {
        if (![newSuperview isKindOfClass:[UIScrollView class]]) {
            @throw  [[NSException alloc] initWithName:NSInternalInconsistencyException
                                               reason:@"必须为UIScrollView的子视图"
                                             userInfo:nil];
        }
    }
    
    if (self.superview) {
        
        //状态失效
        [self invalidate];
        //取消观察
        [self _unregisterKVO];
        
        //移除视图
        [self.scrollView removeScrollTriggerViewForLocation:self.location];
    }
}

- (void)didMoveToSuperview
{
    if (self.superview) {
        
        //添加关联
        [self.scrollView addScrollTriggerView:self forLocation:self.location];
        
        //设置失效进行初始化更新
        [self invalidate];
        _ignoreChange = NO;
        _invalidate = NO;
        _appendContentInset = UIEdgeInsetsZero;
        
        //注册观察
        [self _registerKVO];
        
        //更新位置
        [self _updateFrame];
    }
}

#pragma mark - KVO

- (NSArray *)_observableKeypaths
{
    switch (self.location) {
        case MyScrollTriggerViewLocationTop:
        case MyScrollTriggerViewLocationLeft:
            return @[@"contentInset",
                     @"contentOffset",
                     @"adjustedContentInset",
                     @"bounds"];
            break;
            
        default:
            return @[@"contentInset",
                     @"adjustedContentInset",
                     @"contentOffset",
                     @"contentSize",
                     @"bounds"];
            break;
    }
    
}

- (void)_registerKVO
{
    for (NSString * keyPath in [self _observableKeypaths]) {
        [self.scrollView addObserver:self
                          forKeyPath:keyPath
                             options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                             context:nil];
    }
}

- (void)_unregisterKVO
{
    for (NSString * keyPath in [self _observableKeypaths]) {
        [self.scrollView removeObserver:self forKeyPath:keyPath];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    UIScrollView * scrollView = self.scrollView;
    
    id oldValue = [change objectForKey:@"old"];
    id newValue = [change objectForKey:@"new"];
    
    //非滑动视图或者值未改变直接忽略
    if (scrollView != object || [oldValue isEqualToValue:newValue]) {
        return;
    }
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        
        if (_ignoreChange || !self.enabled || self.isHidden) {
            return;
        }
        
        //如果非触发状态下contentInset和开始的不同则忽略（即设置contentInset过程中引起的contentOffset改变）
        if (self.status != MyScrollTriggerViewStatusTriggering &&
            !UIEdgeInsetsEqualToEdgeInsets(self.scrollView.originalContentInset, self.scrollView.contentInset)) {
            return;
        }
        
        [self _contentOffsetDidChange];
        
    }else if([keyPath isEqualToString:@"bounds"] &&
             CGSizeEqualToSize([oldValue CGRectValue].size, [newValue CGRectValue].size)) {
                  
        //bounds改变而且size没变则忽略
        return;
        
    }else if([keyPath isEqualToString:@"contentInset"] && _ignoreChange) {
        
        //contentInset改变且忽略改变
        return;
        
    }else {
        
        //更新位置
        [self _updateFrame];
        
        //如果不是正在触发则状态失效
        if (self.status != MyScrollTriggerViewStatusTriggering) {
            [self invalidate];
        }
    }
}

#pragma mark -

- (void)beginTrigger {
    [self beginTrigger_e:YES];
}

- (void)beginTrigger_e:(BOOL)scrollToShow
{
    //是否可用和显示了
    if (self.scrollView == nil || !self.isEnabled || self.isHidden) {
        return;
    }
    
    //状态和模式支持
    if (self.status != MyScrollTriggerViewStatusTriggering &&
        !(self.mode & MyScrollTriggerViewTriggerModeMomentary)) {
        
        //更新inset和状态
        _invalidate = NO;
        [self _tryChangeStatus:MyScrollTriggerViewStatusTriggering];
        [self _updateContentInsetForTriggering];
        
        //不需要滑动到显示则更新一下contentOffset防止inset的导致的tableview的头视图混乱问题
        if (!scrollToShow) {
            [self _contentOffsetDidChange];
        }else {
            [self _updateContentOffsetForTriggering];
        }
    }
}

- (void)endTrigger {
    [self _endTrigger:YES];
}

- (void)_endTrigger:(BOOL)animated
{
    if (self.status == MyScrollTriggerViewStatusTriggering) {
        
        //更新状态
        [self _tryChangeStatus:MyScrollTriggerViewStatusNormal];
        
        if (animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:self.animationrDuration];
        }
        
        //更新inset
        [self _updateAppendContentInset:UIEdgeInsetsZero];
        
        if (self.alphaChangeWithScroll) {
            super.alpha = 0.f;
        }
        
        if (animated) {
            [UIView commitAnimations];
        }
    }
}

#pragma mark -

- (void)invalidate
{
    if (self.status == MyScrollTriggerViewStatusBeginReadyTrigger ||
        self.status == MyScrollTriggerViewStatusReadyToTrigger) {
        
        //改变到正常状态，并标记为失效
        _invalidate = YES;
        [self _tryChangeStatus:MyScrollTriggerViewStatusNormal];
        
    }else if(self.state == MyScrollTriggerViewStatusTriggering) {
        
        //结束刷新
        [self _endTrigger:NO];
        
    }else {
        
        [self updateViewForReset];
    }
}

#pragma mark -

- (void)_updateFrame
{
    UIScrollView * scrollView = self.scrollView;
    if (scrollView == nil) {
        return;
    }
    
    CGSize scrollViewSize = scrollView.bounds.size;
    CGRect frame = CGRectZero;
    
    switch (self.location) {
        case MyScrollTriggerViewLocationTop:
            
            frame = CGRectMake(0.f, - self.minTriggerDistance, scrollViewSize.width, self.minTriggerDistance);
            
            break;
            
        case MyScrollTriggerViewLocationLeft:
            
            frame = CGRectMake(- self.minTriggerDistance, 0, self.minTriggerDistance, scrollViewSize.height);
            
            break;
            
        case MyScrollTriggerViewLocationBottom:
        {
            CGSize contentSize = scrollView.contentSize;
            
            //计算最小显示内容高度
            UIEdgeInsets originalLocationContentInset = scrollView.originalLocationContentInset;
            CGFloat minShowHeight = scrollViewSize.height - originalLocationContentInset.top - originalLocationContentInset.bottom;
            
            //如果内容高度小于最小显示内容高度则以最小显示内容高度定位
            frame = CGRectMake(0.f, MAX(minShowHeight, contentSize.height), scrollViewSize.width, self.minTriggerDistance);
        }
            break;
         
        case MyScrollTriggerViewLocationRight:
        {
            CGSize contentSize = scrollView.contentSize;
            
            //计算最小显示内容宽度
            UIEdgeInsets originalLocationContentInset = scrollView.originalLocationContentInset;
            CGFloat minShowWidth = scrollViewSize.width - originalLocationContentInset.left - originalLocationContentInset.right;
            
            //如果内容高度小于最小显示内容宽度则以最小显示内容宽度定位
            frame = CGRectMake(MAX(minShowWidth, contentSize.width), 0.f, self.minTriggerDistance, scrollViewSize.height);
        }
    }
    
    //设置位置
    super.frame = CGRectOffset(frame, self.locationOffset.x, self.locationOffset.y);
    
    //如果正在触发则需要更新inset
    if (self.status == MyScrollTriggerViewStatusTriggering) {
        [self _updateContentInsetForTriggering];
    }
}

- (void)_updateContentInsetForTriggering
{
    MyAssert(self.status == MyScrollTriggerViewStatusTriggering);
    
    UIScrollView * scrollView = self.scrollView;
    UIEdgeInsets appendContentInset = UIEdgeInsetsZero;
    
    switch (self.location) {
        case MyScrollTriggerViewLocationTop:
            
            appendContentInset.top = (self.minTriggerDistance + self.minTriggerDistanceOffset);
            
            break;
            
        case MyScrollTriggerViewLocationLeft:
            
            appendContentInset.left = (self.minTriggerDistance + self.minTriggerDistanceOffset);
            
            break;
            
        case MyScrollTriggerViewLocationBottom:
        {
            //计算最小显示内容高度
            UIEdgeInsets originalLocationContentInset = scrollView.originalLocationContentInset;
            CGFloat minShowHeight = CGRectGetHeight(scrollView.bounds) - originalLocationContentInset.top - originalLocationContentInset.bottom;

            //计算附加的偏移，如果内容高度小于最小显示内容高度则需要附加偏移
            CGFloat appendOffset = MAX(0.f, minShowHeight - scrollView.contentSize.height);
            
            appendContentInset.bottom = (self.minTriggerDistance + self.minTriggerDistanceOffset + appendOffset);
        }
            break;
            
        case MyScrollTriggerViewLocationRight:
        {
            //计算最小显示内容宽度
            UIEdgeInsets originalLocationContentInset = scrollView.originalLocationContentInset;
            CGFloat minShowWidth = CGRectGetWidth(scrollView.bounds) - originalLocationContentInset.left - originalLocationContentInset.right;
            
            //计算附加的偏移，如果内容宽度小于最小显示内容宽度则需要附加偏移
            CGFloat appendOffset = MAX(0.f, minShowWidth - scrollView.contentSize.width);
            
            appendContentInset.right = (self.minTriggerDistance + self.minTriggerDistanceOffset + appendOffset);
        }
            break;
    }
    
    //更新contentInset
    [self _updateAppendContentInset:appendContentInset];
}

- (void)_updateAppendContentInset:(UIEdgeInsets)appendContentInset
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_appendContentInset, appendContentInset)) {
        _appendContentInset = appendContentInset;
        
        _ignoreChange = YES;
        [self.scrollView updateContentInsetForScrollTriggerView];
        _ignoreChange = NO;
    }
}

- (void)_updateContentOffsetForTriggering
{
    MyAssert(self.status == MyScrollTriggerViewStatusTriggering);
    
    UIScrollView * scrollView = self.scrollView;
    UIEdgeInsets originalLocationContentInset = scrollView.originalLocationContentInset;
    CGPoint contentOffset = scrollView.contentOffset;
    
    switch (self.location) {
        case MyScrollTriggerViewLocationTop:
            
            contentOffset.y = - originalLocationContentInset.top - self.minTriggerDistance -  self.minTriggerDistanceOffset;
            
            break;
            
        case MyScrollTriggerViewLocationLeft:
            
            contentOffset.x = - originalLocationContentInset.left - self.minTriggerDistance -  self.minTriggerDistanceOffset;
            
            break;
            
        case MyScrollTriggerViewLocationBottom:
            
            contentOffset.y = CGRectGetMaxY(self.frame) - self.locationOffset.y + self.minTriggerDistanceOffset + originalLocationContentInset.bottom - CGRectGetHeight(scrollView.bounds);
            
            break;
            
        case MyScrollTriggerViewLocationRight:
            
            contentOffset.x = CGRectGetMaxX(self.frame) - self.locationOffset.x + self.minTriggerDistanceOffset + originalLocationContentInset.right - CGRectGetWidth(scrollView.bounds) ;
            
            break;
    }
    
    [scrollView setContentOffset:contentOffset animated:YES];
}

#pragma mark -

- (void)_contentOffsetDidChange
{
    //计算偏移量
    CGFloat offset = 0.f;
    UIScrollView * scrollView = self.scrollView;
    UIEdgeInsets originalLocationContentInset = scrollView.originalLocationContentInset;
    
    switch (self.location) {
        case MyScrollTriggerViewLocationTop:
            
            offset = - scrollView.contentOffset.y - originalLocationContentInset.top;
            
            break;
            
        case MyScrollTriggerViewLocationLeft:
            
            offset = - scrollView.contentOffset.x - originalLocationContentInset.left;
            
            break;
            
        case MyScrollTriggerViewLocationBottom:
        {
            float minYInFrame = CGRectGetMinY(self.frame) - scrollView.contentOffset.y - self.locationOffset.y;
            offset = CGRectGetHeight(scrollView.bounds) - originalLocationContentInset.bottom - minYInFrame;
        }
            break;
            
        case MyScrollTriggerViewLocationRight:
        {
            float minXInFrame = CGRectGetMinX(self.frame) - scrollView.contentOffset.x - self.locationOffset.x;
            offset = CGRectGetWidth(scrollView.bounds) - originalLocationContentInset.right - minXInFrame;
        }
            break;
    }
    
    //减去偏移
    offset -= self.minTriggerDistanceOffset;
    
    if (self.status == MyScrollTriggerViewStatusNormal) {
        
        if (self.invalidate) {
            
            //移出响应区域则变得有效
            if (offset <= 0.f) {
                _invalidate = NO;
            }
            
        }else if (offset > 0.f) { //开始准备响应
            
            [self _tryChangeStatus:MyScrollTriggerViewStatusBeginReadyTrigger];
        }
        
    }else if (self.status == MyScrollTriggerViewStatusTriggering) {
        
        if (self.location == MyScrollTriggerViewLocationTop &&
            [scrollView isKindOfClass:[UITableView class]] &&
            [(UITableView *)scrollView style] == UITableViewStylePlain) {
            
            UIEdgeInsets appendContentInset = UIEdgeInsetsZero;
            if (offset >= self.minTriggerDistance) {
                appendContentInset.top = (self.minTriggerDistance + self.minTriggerDistanceOffset);
            }else if (offset >= - self.minTriggerDistanceOffset) {
                appendContentInset.top = (offset + self.minTriggerDistanceOffset);
            }
            
            //更新contentInset
            [self _updateAppendContentInset:appendContentInset];
            
        }
        
    }else if (self.status == MyScrollTriggerViewStatusReadyToTrigger && !scrollView.isTracking) {
        
        //开始触发
        [self _beginTriggerWithScrollView:scrollView];
        
    }else {

        if (self.status == MyScrollTriggerViewStatusBeginReadyTrigger) {
            
            if (offset > self.minTriggerDistance) {
                
                if (scrollView.isTracking) {
                    
//                    //如果是立即模式则直接开始触发，否则进入准备触发状态
//                    if (self.mode & MyScrollTriggerViewTriggerModeImmediately) {
//                        [self _beginTriggerWithScrollView:scrollView];
//                    }else {
//                        [self _tryChangeStatus:MyScrollTriggerViewStatusReadyToTrigger];
////                        [self updateViewForReadyToTrigger:YES];
//                    }
//                    
                    [self _tryChangeStatus:MyScrollTriggerViewStatusReadyToTrigger];
                    
                    return;
                }
                
            }else if(offset < 0) {
                
                [self _tryChangeStatus:MyScrollTriggerViewStatusNormal];
            }
            
        }else if (offset < self.minTriggerDistance) {
                
            [self _tryChangeStatus:MyScrollTriggerViewStatusBeginReadyTrigger];
//            [self updateViewForReadyToTrigger:NO];
            
        }else {
            return;
        }
        
        //更新进度
        [self updateViewForTriggerProgress:ChangeInMinToMax(offset / self.minTriggerDistance, 0.f, 1.f)];
    }
}

- (void)_beginTriggerWithScrollView:(UIScrollView *)scrollView
{
    if (self.mode & MyScrollTriggerViewTriggerModeMomentary) {
        [self invalidate];
    }else{
        
        //记录当前偏移量
        CGPoint contentOffset = scrollView.contentOffset;
        
        //更新视图和状态
        [self _tryChangeStatus:MyScrollTriggerViewStatusTriggering];
        [self _updateContentInsetForTriggering];
        
        //恢复到之前偏移量
        _ignoreChange = YES;
        
//        if (scrollView.isTracking &&
//            self.mode & MyScrollTriggerViewTriggerModeImmediately) {
//            scrollView.scrollEnabled = NO;
//        }
        
        scrollView.contentOffset = contentOffset;
        
//        scrollView.scrollEnabled = YES;
        
        _ignoreChange = NO;
    }
    
    //发送消息
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}


#pragma mark -

- (void)setAlpha:(CGFloat)alpha {
    //do nothing
}

- (void)_tryChangeStatus:(MyScrollTriggerViewStatus)status
{
    if (_status != status) {
        
        MyScrollTriggerViewStatus oldStatus = self.status;
        _status = status;
        [self statusDidChangeFromStatus:oldStatus];
    }
}

- (void)statusDidChangeFromStatus:(MyScrollTriggerViewStatus)fromStatus
{
    if (!self.alphaChangeWithScroll ||
        (self.status == MyScrollTriggerViewStatusReadyToTrigger ||
         self.status == MyScrollTriggerViewStatusTriggering)) {
            super.alpha = 1.f;
    }
}

- (void)updateViewForReset {
    super.alpha = self.alphaChangeWithScroll ? 0.f : 1.f;
}

- (void)updateViewForTriggerProgress:(float)progress
{
    if (self.alphaChangeWithScroll) {
        super.alpha = progress;
    }
}

//- (void)updateViewForReadyToTrigger:(BOOL)ready {
//    // do nothing
//}


@end

//----------------------------------------------------------

@implementation UIScrollView(_MyScrollTriggerView)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        //交换方法实现
        [UIScrollView exchangeInstanceMethodIMPWithSel1:@selector(setContentInset:) sel2:@selector(_setContentInsetIgnoreScrollTriggerView:)];

//        //交换方法实现
//        Class class = [UIScrollView class];
//        Method oldMethod = class_getInstanceMethod(class, @selector(setContentInset:));
//        Method newMethod = class_getInstanceMethod(class, @selector(_setContentInsetIgnoreScrollTriggerView:));
//
//        method_exchangeImplementations(oldMethod, newMethod);
    });
}

- (NSMutableDictionary *)scrollTriggerViews
{
    static char scrollViewScrollTriggerViewsKey;
    
    //运行时方法获取属性
    NSMutableDictionary * scrollTriggerViews = objc_getAssociatedObject(self, &scrollViewScrollTriggerViewsKey);
    
    //不存在则初始化并存储
    if (scrollTriggerViews == nil) {
        scrollTriggerViews = [NSMutableDictionary dictionaryWithCapacity:4];
        objc_setAssociatedObject(self, &scrollViewScrollTriggerViewsKey, scrollTriggerViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return scrollTriggerViews;
}

- (MyScrollTriggerView *)scrollTriggerViewForLocation:(MyScrollTriggerViewLocation)location {
    return self.scrollTriggerViews[@(location)];
}

- (void)addScrollTriggerView:(MyScrollTriggerView *)scrollTriggerView forLocation:(MyScrollTriggerViewLocation)location
{
    if ([self scrollTriggerViewForLocation:location] != nil) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"UIScrollView同一个方向的MyScrollTriggerView只能添加一个" userInfo:nil];
    }
    
    [self.scrollTriggerViews setObject:scrollTriggerView forKey:@(location)];
}

- (void)removeScrollTriggerViewForLocation:(MyScrollTriggerViewLocation)location {
    [self.scrollTriggerViews removeObjectForKey:@(location)];
}

#pragma mark -

static char originalContentInsetKey;
- (UIEdgeInsets)originalContentInset
{
    NSValue * value = objc_getAssociatedObject(self, &originalContentInsetKey);
    if (value == nil) {
        return self.contentInset;
    }
    
    return [value UIEdgeInsetsValue];
}

- (void)setOriginalContentInset:(UIEdgeInsets)originalContentInset
{
    objc_setAssociatedObject(self, &originalContentInsetKey, [NSValue valueWithUIEdgeInsets:originalContentInset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)originalLocationContentInset
{
    UIEdgeInsets originalLocationContentInset = self.originalContentInset;
    
    if (@available(iOS 11.0, *)) {
        
        UIEdgeInsets adjustedContentInset = self.adjustedContentInset;
        UIEdgeInsets contentInset = self.contentInset;
        
        originalLocationContentInset.top += (adjustedContentInset.top - contentInset.top);
        originalLocationContentInset.left += (adjustedContentInset.left - contentInset.left);
        originalLocationContentInset.bottom += (adjustedContentInset.bottom - contentInset.bottom);
        originalLocationContentInset.right += (adjustedContentInset.right - contentInset.right);
    }
    
    return originalLocationContentInset;
}

- (void)_setContentInsetIgnoreScrollTriggerView:(UIEdgeInsets)contentInset
{
    //更新初始的inset
    self.originalContentInset = contentInset;

    //更新contentInset
    [self updateContentInsetForScrollTriggerView];
}

- (UIEdgeInsets)scrollTriggerViewContentInset
{
    UIEdgeInsets scrollTriggerViewContentInset = UIEdgeInsetsZero;
    for (MyScrollTriggerView * scrollTriggerView  in self.scrollTriggerViews.allValues) {
        
        //附加每一个扩展的ContentInset
        UIEdgeInsets appendContentInset = scrollTriggerView.appendContentInset;
        scrollTriggerViewContentInset.top += appendContentInset.top;
        scrollTriggerViewContentInset.left += appendContentInset.left;
        scrollTriggerViewContentInset.bottom += appendContentInset.bottom;
        scrollTriggerViewContentInset.right += appendContentInset.right;
    }
    
    return scrollTriggerViewContentInset;
}

- (void)updateContentInsetForScrollTriggerView
{
    UIEdgeInsets contentInset = self.originalContentInset;
    UIEdgeInsets scrollTriggerViewContentInset = self.scrollTriggerViewContentInset;
    
    contentInset.top += scrollTriggerViewContentInset.top;
    contentInset.left += scrollTriggerViewContentInset.left;
    contentInset.bottom += scrollTriggerViewContentInset.bottom;
    contentInset.right += scrollTriggerViewContentInset.right;
    
    //由于交换了方法实现，调用_setContentInsetNoneScrollTriggerView:等同于调用setContentInset:
    [self _setContentInsetIgnoreScrollTriggerView:contentInset];
}

//- (void)_setContentInsetIgnoreScrollTriggerView:(UIEdgeInsets)contentInset
//{
//    static Method oldMethod = NULL;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        oldMethod = [UIScrollView getCatrgoryOverInstanceMethodWithSel:@selector(setContentInset:)];
//    });
//
//    MyAssert(oldMethod != NULL);
//
//    //调用
//    ((void(*)(id,Method,UIEdgeInsets))method_invoke)(self,oldMethod,contentInset);
//}

@end

