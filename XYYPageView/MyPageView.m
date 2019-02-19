//
//  MyPageView.m
//  
//
//  Created by LeslieChen on 15/11/7.
//  Copyright © 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyPageView.h"
#import "XYYFoundation.h"
#import <objc/runtime.h>

//----------------------------------------------------------

static char PageContainerScrollViewKey;
static BOOL defaultGestureRecognizerSimultaneouslyHandle(id object, SEL sel, UIGestureRecognizer * gestureRecognizer, UIGestureRecognizer * otherGestureRecognizer) {
    return NO;
}

//----------------------------------------------------------

@interface UIScrollView(MyPageViewHook)<UIGestureRecognizerDelegate>

@property(nonatomic,weak) UIScrollView * pageContainerScrollView;

@end

//----------------------------------------------------------

@implementation UIScrollView(MyPageViewHook)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        SEL sel1 = @selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:);
        SEL sel2 = @selector(_MyPageView_gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:);
        
        Method method1 = class_getInstanceMethod(self, sel1);
        if (method1 == NULL) {
            class_addMethod([UIScrollView class], sel1, (IMP)defaultGestureRecognizerSimultaneouslyHandle, method_getTypeEncoding(class_getInstanceMethod(self, sel2)));
        }
        
        //交换
        [UIScrollView exchangeInstanceMethodIMPWithSel1:sel1 sel2:sel2];
    });
}

- (void)setPageContainerScrollView:(UIScrollView *)pageContainerScrollView {
    objc_setAssociatedObject(self, &PageContainerScrollViewKey, pageContainerScrollView, OBJC_ASSOCIATION_ASSIGN);
}

- (UIScrollView *)pageContainerScrollView {
    return objc_getAssociatedObject(self, &PageContainerScrollViewKey);
}

- (BOOL)_MyPageView_gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (self.pageContainerScrollView == otherGestureRecognizer.view) {
        return YES;
    }
    
    return [self _MyPageView_gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
}

@end

//----------------------------------------------------------

@interface MyPageView () < UICollectionViewDelegateFlowLayout,
                           UICollectionViewDataSource >

@property(nonatomic,strong) UICollectionView * collectionView;

@property(nonatomic) BOOL needScrollPageCell;
@property(nonatomic,strong,readonly) NSMutableArray<UIScrollView *> * pageContentScrollViews;

@end

//----------------------------------------------------------

@implementation MyPageView
{
    //数据是否有效
    BOOL _dataVaild;
    BOOL _ignoreScroll;
    
    UIScrollView * __unsafe_unretained  _containerScrollView;
}

@synthesize pagesCount = _pagesCount;
@synthesize dispalyPageIndex = _dispalyPageIndex;
@synthesize pageContentScrollViews = _pageContentScrollViews;

#pragma mark -

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _setup_MyPageView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame scrollDirection:MyPageViewScrollDirectionHorizontal];
}

- (id)initWithFrame:(CGRect)frame scrollDirection:(MyPageViewScrollDirection)scrollDirection {
    return [self initWithFrame:frame scrollDirection:scrollDirection containerScrollView:nil];
}

- (id)initWithFrame:(CGRect)frame scrollDirection:(MyPageViewScrollDirection)scrollDirection containerScrollView:(UIScrollView *)containerScrollView
{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollDirection = scrollDirection;
        
        if (containerScrollView) {
            __weak typeof(self) weak_self = self;
            containerScrollView.deallocBlock = ^{
                 __strong typeof(self) strong_self = weak_self;
                if (strong_self) {
                    [strong_self _containerScrollViewInvaild];
                }
            };
            _containerScrollView = containerScrollView;
            
            //注册观察
            [self addObserver:containerScrollView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
            
        }
        [self _setup_MyPageView];
    }
    
    return self;
}

- (void)_setup_MyPageView
{
    self.clipsToBounds = YES;
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = (self.scrollDirection == MyPageViewScrollDirectionHorizontal) ? UICollectionViewScrollDirectionHorizontal : UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 0.f;
    self.collectionView = [[UICollectionView alloc] initWithFrame:[self _collectionViewFrame] collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.scrollsToTop = NO;
    if (self.scrollDirection == MyPageViewScrollDirectionHorizontal) {
        self.collectionView.alwaysBounceHorizontal = YES;
    }else {
        self.collectionView.alwaysBounceVertical = YES;
    }
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    configurationContentScrollViewForAdaptation(self.collectionView);
    
    [self addSubview:self.collectionView];
    
}

- (void)dealloc {
    [self _containerScrollViewInvaild];
}

#pragma mark-

- (UIScrollView *)containerScrollView {
    return _containerScrollView;
}

- (NSMutableArray<UIScrollView *> *)pageContentScrollViews
{
    if (!_pageContentScrollViews) {
        _pageContentScrollViews = [NSMutableArray array];
    }
    
    return _pageContentScrollViews;
}


- (void)_containerScrollViewInvaild
{
    if (_containerScrollView) {
        [self removeObserver:_containerScrollView forKeyPath:@"contentOffset"];
        _containerScrollView = nil;
    }
    
    [self _clearAllPageCells];
}

- (void)_clearAllPageCells
{
    if (_pageContentScrollViews.count) {
        for (UIScrollView * scrollView in _pageContentScrollViews) {
            scrollView.pageContainerScrollView = nil;
            [self removeObserver:scrollView forKeyPath:@"contentOffset"];
        }
        [_pageContentScrollViews removeAllObjects];
    }
}

- (void)_addPageCellIfNeed:(UICollectionViewCell *)pageCell
{
    UIScrollView * scrollView = [pageCell subPageContentScrollView];
    if (scrollView && [self.pageContentScrollViews indexOfObjectIdenticalTo:scrollView] == NSNotFound) {
        scrollView.pageContainerScrollView = _containerScrollView;
        [self addObserver:scrollView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:(void *)pageCell];
        [self.pageContentScrollViews addObject:scrollView];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        
        if (object == _containerScrollView) {
            
            if (_ignoreScroll) {
                return;
            }
            
            UIScrollView * scrollView = object;
            
            CGPoint contentOffset = [scrollView contentOffsetForScrollToBorder:self.scrollDirection == MyPageViewScrollDirectionHorizontal ? MyScrollBorderBottom : MyScrollBorderRight];
            
            _ignoreScroll = YES;
            if (self.needScrollPageCell) {
                scrollView.contentOffset = contentOffset;
            }else {
            
                if (self.scrollDirection == MyPageViewScrollDirectionHorizontal) {
                    if (scrollView.contentOffset.y >= contentOffset.y) {
                        scrollView.contentOffset = contentOffset;
                        self.needScrollPageCell = NO;
                    }
                }else {
                    if (scrollView.contentOffset.x >= contentOffset.x) {
                        scrollView.contentOffset = contentOffset;
                        self.needScrollPageCell = NO;
                    }
                }
                
            }
            _ignoreScroll = NO;
            
            return;
            
        }else if ([self.pageContentScrollViews indexOfObjectIdenticalTo:object] != NSNotFound) {
            
            if (_ignoreScroll) {
                return;
            }
            
            UIScrollView * scrollView = object;
            
            CGPoint contentOffset = [scrollView contentOffsetForScrollToBorder:self.scrollDirection == MyPageViewScrollDirectionHorizontal ? MyScrollBorderTop : MyScrollBorderLeft];
            
            _ignoreScroll = YES;
            if (!self.needScrollPageCell) {
                scrollView.contentOffset = contentOffset;
            }else {
                
                if (self.scrollDirection == MyPageViewScrollDirectionHorizontal) {
                    if (scrollView.contentOffset.y <= contentOffset.y) {
                        scrollView.contentOffset = contentOffset;
                        self.needScrollPageCell = YES;
                    }
                }else {
                    if (scrollView.contentOffset.x <= contentOffset.x) {
                        scrollView.contentOffset = contentOffset;
                        self.needScrollPageCell = YES;
                    }
                }
                
            }
            _ignoreScroll = NO;
            
            return;
        }
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark -

- (void)_loadDataIfNeed
{
    if (!_dataVaild) {
        _dataVaild = YES;
        self.needScrollPageCell = NO;
        
        id<MyPageViewDataSource> dataSource = self.dataSource;
        ifRespondsSelector(dataSource, @selector(numberOfPagesInPageView:)) {
            _pagesCount = [dataSource numberOfPagesInPageView:self];
        }else {
            _pagesCount = dataSource ? 1 : 0;
        }
        
        _dispalyPageIndex = _pagesCount ? 0 : NSNotFound;
    }
}

- (NSUInteger)pagesCount
{
    [self _loadDataIfNeed];
    return _pagesCount;
}

- (NSUInteger)dispalyPageIndex
{
    [self _loadDataIfNeed];
    return _dispalyPageIndex;
}

#define IndexPathForPageIndex(index) [NSIndexPath indexPathForItem:0 inSection:index]
#define PageIndexForIndexPath(indexPath) (indexPath.section)

- (void)setDispalyPageIndex:(NSUInteger)dispalyPageIndex
{
    //核对索引
    if (dispalyPageIndex >= self.pagesCount) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"dispalyPageIndex应小于页面总数"
                                     userInfo:nil];
    }
    
    //设置索引并移动到目标位置
    _dispalyPageIndex = dispalyPageIndex;
    
    //移动到显示
    _ignoreScroll = YES;
    BOOL scrollEnabled = self.collectionView.scrollEnabled;
    self.collectionView.scrollEnabled = NO;
    [self.collectionView scrollToItemAtIndexPath:IndexPathForPageIndex(dispalyPageIndex)
                                atScrollPosition:self.scrollDirection == MyPageViewScrollDirectionHorizontal ? UICollectionViewScrollPositionLeft : UICollectionViewScrollPositionTop
                                        animated:NO];
    self.collectionView.scrollEnabled = scrollEnabled;
    _ignoreScroll = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.pagesCount && !_ignoreScroll) {
        
        //计算目标page
        NSInteger desPageIndex = 0;
        if (self.scrollDirection == MyPageViewScrollDirectionHorizontal) {
            desPageIndex = roundf(scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame));
        }else {
            desPageIndex = roundf(scrollView.contentOffset.y / CGRectGetHeight(scrollView.frame));
        }
        
        desPageIndex = ChangeInMinToMax(desPageIndex, 0.f, self.pagesCount - 1);
        if (self.dispalyPageIndex != desPageIndex) {
            
            NSUInteger prevPageIndex = self.dispalyPageIndex;
            _dispalyPageIndex = desPageIndex;
            
            id<MyPageViewDelegate> delegate = self.delegate;
            ifRespondsSelector(delegate, @selector(pageView:didEndDisplayPageAtIndex:)) {
                [delegate pageView:self didEndDisplayPageAtIndex:prevPageIndex];
            }
            
            ifRespondsSelector(delegate, @selector(pageView:didDisplayPageAtIndex:)) {
                [delegate pageView:self didDisplayPageAtIndex:desPageIndex];
            }
        }
    }
    
    //代理消息转发
    id<MyPageViewDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(scrollViewDidScroll:)) {
        [delegate scrollViewDidScroll:scrollView];
    }
}


#pragma mark -

- (void)reloadPages:(BOOL)keepDispalyPage
{
    if (_dataVaild) {
        _dataVaild = NO;
        
        _ignoreScroll = YES;
        
        //记录当前的索引
        NSUInteger dispalyPageIndex = _dispalyPageIndex;
        
        //重新加载数据
        [self _clearAllPageCells];
        [self.collectionView reloadData];
        
        //移动到目标位置
        BOOL scrollEnabled = self.collectionView.scrollEnabled;
        self.collectionView.scrollEnabled = NO;
        if (keepDispalyPage && dispalyPageIndex < self.pagesCount) {
            _dispalyPageIndex = dispalyPageIndex;
            self.collectionView.contentOffset = [self _contentOffsetForPageAtIndex:dispalyPageIndex];
        }else {
            _dispalyPageIndex = self.pagesCount == 0 ? NSNotFound : 0;
            self.collectionView.contentOffset = CGPointZero;
        }
        self.collectionView.scrollEnabled = scrollEnabled;
        
        
        _ignoreScroll = NO;
    }
}

#pragma mark -

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //frame大小改变重新加载页面的尺寸
    [self _reoladPageSize:NO];
}

- (CGRect)_collectionViewFrame
{
    CGRect collectionViewFrame = self.bounds;
    if (self.scrollDirection == MyPageViewScrollDirectionHorizontal) {
        collectionViewFrame.size.width += self.pageMargin;
    }else {
        collectionViewFrame.size.height += self.pageMargin;
    }
    
    return collectionViewFrame;
}

- (CGPoint)_contentOffsetForPageAtIndex:(NSUInteger)index
{
    if (self.pagesCount == 0) {
        return CGPointZero;
    }else if (self.scrollDirection == MyPageViewScrollDirectionHorizontal) {
        return CGPointMake(CGRectGetWidth(self.collectionView.frame) * index, 0.f);
    }else {
        return CGPointMake(0.f, CGRectGetHeight(self.collectionView.frame) * index);
    }
}

- (void)_reoladPageSize:(BOOL)force
{
    CGRect collectionViewFrame = [self _collectionViewFrame];
    if (force || !CGRectEqualToRect(collectionViewFrame, self.collectionView.frame)) {
        
        //将要重新加载页面
        id<MyPageViewDelegate> delegate = self.delegate;
        ifRespondsSelector(delegate, @selector(pageViewWillReloadPages:)) {
            [delegate pageViewWillReloadPages:self];
        }
        
        _ignoreScroll = YES;
        
        //重新加载数据并移动到目标位置
        self.needScrollPageCell = NO;
        [self.collectionView reloadData];
        self.collectionView.frame = collectionViewFrame;
        BOOL scrollEnabled = self.collectionView.scrollEnabled;
        self.collectionView.scrollEnabled = NO;
        self.collectionView.contentOffset = [self _contentOffsetForPageAtIndex:self.dispalyPageIndex];
        self.collectionView.scrollEnabled = scrollEnabled;
        
        _ignoreScroll = NO;
    }
}

- (void)setPageMargin:(CGFloat)pageMargin
{
    pageMargin = MAX(0, pageMargin);
    if (_pageMargin != pageMargin) {
        _pageMargin = pageMargin;
        
        if (_dataVaild) { //如果数据有效，重新加载页面尺寸
            [self _reoladPageSize:YES];
        }else {
            self.collectionView.frame = [self _collectionViewFrame];
        }
    }
}

#pragma mark -

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.bounds.size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets sectionInset = UIEdgeInsetsZero;
    if (self.scrollDirection == MyPageViewScrollDirectionHorizontal) {
        sectionInset.right += self.pageMargin;
    }else {
        sectionInset.bottom += self.pageMargin;
    }
    
    return sectionInset;
}

#pragma mark -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.pagesCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = nil;
    id<MyPageViewDataSource> dataSource = self.dataSource;
    ifRespondsSelector(dataSource, @selector(pageView:cellForPageAtIndex:)) {
        cell = [dataSource pageView:self cellForPageAtIndex:PageIndexForIndexPath(indexPath)];
    }
    
    if (cell == nil) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"pageView:cellForPageAtIndex:必须返回非nil的cell"
                                     userInfo:nil];
    }
    
    if (_containerScrollView) {
        
        UIScrollView * contentScrollView = [cell subPageContentScrollView];
        if (contentScrollView) {
            if (!self.needScrollPageCell) {
                if (self.scrollDirection == MyPageViewScrollDirectionHorizontal) {
                    [contentScrollView scrollToBoder:MyScrollBorderTop];
                }else {
                    [contentScrollView scrollToBoder:MyScrollBorderLeft];
                }
            }
        }else {
            self.needScrollPageCell = NO;
        }
        
        [self _addPageCellIfNeed:cell];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<MyPageViewDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(pageView:willDisplayPageCell:atIndex:)) {
        [delegate pageView:self willDisplayPageCell:cell atIndex:PageIndexForIndexPath(indexPath)];
    }
}

#pragma mark -

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<MyPageViewDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(pageView:didSelectedPageAtIndex:)) {
        [delegate pageView:self didSelectedPageAtIndex:PageIndexForIndexPath(indexPath)];
    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
}

#pragma mark -

- (id)cellForPageAtIndex:(NSUInteger)pageIndex {
    return [self.collectionView cellForItemAtIndexPath:IndexPathForPageIndex(pageIndex)];
}

- (NSUInteger)indexForPageCell:(UICollectionViewCell *)cell
{
    NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
    if (indexPath) {
        return PageIndexForIndexPath(indexPath);
    }else {
        return NSNotFound;
    }
}

- (NSArray *)visiblePageCells {
    return self.collectionView.visibleCells;
}

- (BOOL)isScrollEnabled {
    return self.collectionView.scrollEnabled;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    self.collectionView.scrollEnabled = scrollEnabled;
}

- (BOOL)allowsSelection {
    return self.collectionView.allowsSelection;
}

- (void)setAllowsSelection:(BOOL)allowsSelection {
    self.collectionView.allowsSelection = allowsSelection;
}

#pragma mark -

- (void)registerCellForPage:(Class)cellClass {
    [self registerCellForPage:cellClass andReuseIdentifier:nil];
}

- (void)registerCellForPage:(Class)cellClass andReuseIdentifier:(NSString *)identifier {
    [self registerCellForPage:cellClass nibNameOrNil:nil bundleOrNil:nil andReuseIdentifier:identifier];
}

- (void)registerCellForPage:(Class)cellClass
               nibNameOrNil:(NSString *)nibNameOrNil
                bundleOrNil:(NSBundle *)bundleOrNil
         andReuseIdentifier:(NSString *)reuseIdentifier
{
    [self.collectionView registerCellWithClass:cellClass
                                  nibNameOrNil:nibNameOrNil
                                   bundleOrNil:bundleOrNil
                            andReuseIdentifier:reuseIdentifier];
}

- (id)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forPageIndex:(NSUInteger)pageIndex {
    return [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:IndexPathForPageIndex(pageIndex)];
}

#pragma mark - 代理消息转发

- (void)setDelegate:(id<MyPageViewDelegate>)delegate
{
    if (_delegate != delegate) {
        _delegate = delegate;
        
        //更新代理（contentScrollView内部实现上会在设置代理时通过判断代理是否实现某些方法来设置某些方法是否回调）
        self.collectionView.delegate = nil;
        self.collectionView.delegate = self;
    }
}

- (BOOL)_isScorllViewDelegateContainSelector:(SEL)aSelector {
    return NSProtocolContainSelector(@protocol(UIScrollViewDelegate), aSelector, NO, YES);
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if (![super respondsToSelector:aSelector]) {
        if ([self _isScorllViewDelegateContainSelector:aSelector]) {
            return [self.delegate respondsToSelector:aSelector];
        }
        return NO;
    }
    return YES;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    id delegate = self.delegate;
    if ([self _isScorllViewDelegateContainSelector:aSelector] &&
        [delegate respondsToSelector:aSelector]) {
        return delegate;
    }else {
        return [super forwardingTargetForSelector:aSelector];
    }
}

@end


@implementation UICollectionViewCell (MyPageView)

- (UIScrollView *)subPageContentScrollView {
    return nil;
}

@end
