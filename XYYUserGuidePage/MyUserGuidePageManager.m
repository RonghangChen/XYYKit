//
//  MyUserGuidePageManager.m
//  
//
//  Created by LeslieChen on 15/5/21.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyUserGuidePageManager.h"

//----------------------------------------------------------

@interface _MyUserGuidePageCell : UICollectionViewCell

@property(nonatomic,strong,readonly) MyUserGuideView * pageView;

@end

//----------------------------------------------------------

@implementation _MyUserGuidePageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)updateViewWithInfo:(NSDictionary *)info context:(id)context
{
    _pageView = [info userGuidePageView];
    
    if (_pageView) {
        _pageView.frame = self.contentView.bounds;
        _pageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_pageView];
        
        [_pageView updateViewWithPageInfo:info context:context];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [_pageView removeFromSuperview];
}

@end

//----------------------------------------------------------

@interface _MyUserGuidePageTransitionContext : NSObject

- (id)initWithCurrentPageView:(MyUserGuideView *)currentPageView andIndex:(NSUInteger)index;

- (void)startShowPageView:(MyUserGuideView *)pageView atIndex:(NSInteger)index bounces:(BOOL)bounces;
- (void)updateShowProgress:(CGFloat)progress;
- (void)completedShow;
- (void)cancleShow;

@property(nonatomic,strong,readonly) MyUserGuideView * currentPageView;
@property(nonatomic,strong,readonly) MyUserGuideView * targetShowPageView;

@property(nonatomic,readonly) NSInteger  currentPageIndex;
@property(nonatomic,readonly) NSInteger  targetShowPageIndex;

@property(nonatomic,readonly,getter=isTransiting) BOOL transiting;
@property(nonatomic,readonly,getter=isBouning) BOOL bouning;

@end

//----------------------------------------------------------

@implementation _MyUserGuidePageTransitionContext

- (id)initWithCurrentPageView:(MyUserGuideView *)currentPageView andIndex:(NSUInteger)index
{
    self = [super init];
    
    if (self) {
        _currentPageView = currentPageView;
        _currentPageIndex = index;
    }
    
    return self;
}


- (void)startShowPageView:(MyUserGuideView *)pageView atIndex:(NSInteger)index bounces:(BOOL)bounces
{
//    DefaultDebugLog(@"开始开始页面过渡");
    
    if (!self.isTransiting) {
        
        _transiting = YES;
        _bouning = bounces;
        
        _targetShowPageView = pageView;
        _targetShowPageIndex = index;
        
        MyUserGuideViewShowDirection direction = _targetShowPageIndex > _currentPageIndex ? MyUserGuideViewShowDirectionNext : MyUserGuideViewShowDirectionPrev;
        
        [_targetShowPageView startShow:YES bounces:bounces direction:direction];
        [_currentPageView startShow:NO bounces:bounces direction:direction];
        
//         NSLog(@"开始页面过渡 from %i to %i",_currentPageIndex,_targetShowPageIndex);
    }
}

- (void)updateShowProgress:(CGFloat)progress
{
    if (self.isTransiting) {
        
        progress = self.isBouning ? 2 * progress : progress;
        progress = ChangeInMinToMax(progress, 0.f, 1.f);
        
        [_targetShowPageView updateShow:YES withProgress:progress];
        [_currentPageView updateShow:NO withProgress:progress];
    }
}

- (void)completedShow
{
//    DefaultDebugLog(@"开始完成页面过渡");
    
    if (self.isTransiting) {
        
//        NSLog(@"完成页面过渡 from %i to %i",_currentPageIndex,_targetShowPageIndex);
        
        _transiting = NO;
        _bouning = NO;
        
        [_targetShowPageView completedShow:YES];
        [_currentPageView completedShow:NO];
        
        _currentPageView = _targetShowPageView;
        _currentPageIndex = _targetShowPageIndex;
        
        _targetShowPageView = nil;
        _targetShowPageIndex = NSNotFound;
    }
}

- (void)cancleShow
{
//    DefaultDebugLog(@"开始取消页面过渡");
    
    if (self.isTransiting) {
        
//        NSLog(@"取消页面过渡 from %i to %i",_currentPageIndex,_targetShowPageIndex);
        
        _transiting = NO;
        _bouning = NO;
        
        [_targetShowPageView cancledShow:YES];
        [_currentPageView cancledShow:NO];
        
        _targetShowPageView = nil;
        _targetShowPageIndex = NSNotFound;
        
    }
}

@end

//----------------------------------------------------------

@interface MyUserGuidePageManager () < UICollectionViewDataSource,
                                       UICollectionViewDelegateFlowLayout >

@property(nonatomic,strong,readonly) NSArray * pageInfos;
@property(nonatomic,strong) NSString * pageInfosFileName;
@property(nonatomic,strong) NSBundle * pageInfosFileBundle;

@property(nonatomic,strong,readonly) UICollectionView * collectionView;
@property(nonatomic,strong,readonly) _MyUserGuidePageTransitionContext * transitionContext;

@end

//----------------------------------------------------------

@implementation MyUserGuidePageManager

@synthesize pageInfos = _pageInfos;
@synthesize contentView = _contentView;
@synthesize collectionView = _collectionView;
@synthesize transitionContext = _transitionContext;

#pragma mark -

- (id)initWithPageInfosFileName:(NSString *)infoFileName bundle:(NSBundle *)bundleOrNil
{
    self = [super init];
    
    if (self) {
        self.pageInfosFileName  = infoFileName;
        self.pageInfosFileBundle = bundleOrNil;
    }
    
    return self;
}

- (id)initWithPageInfos:(NSArray *)pageInfos
{
    self = [super init];
    
    if (self) {
        _pageInfos = [NSArray arrayWithArray:pageInfos];
    }
    
    return self;
}

#pragma mark - 

- (NSArray *)pageInfos
{
    if (!_pageInfos) {
        
        if (self.pageInfosFileName.length) {
            _pageInfos = [NSArray arrayWithContentsOfFile:[self.pageInfosFileBundle ?: [NSBundle mainBundle] pathForResource:self.pageInfosFileName ofType:@"plist"]];
        }
        
        if (_pageInfos == nil) {
            _pageInfos = [NSArray array];
        }
    }
    
    return _pageInfos;
}

- (NSUInteger)pageCount {
    return self.pageInfos.count;
}

- (NSDictionary *)pageInfoAtIndex:(NSUInteger)index {
    return self.pageInfos[index];
}

#pragma mark - 

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, screenSize().width, screenSize().height)];
        self.collectionView.frame = _contentView.bounds;
        self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_contentView addSubview:self.collectionView];
    }
    
    return _contentView;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumInteritemSpacing = 0.f;
        flowLayout.minimumLineSpacing = 0.f;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.bounces = self.bounces;
        
        //适配
        configurationContentScrollViewForAdaptation(_collectionView);
        
        [_collectionView registerClass:[_MyUserGuidePageCell class]
            forCellWithReuseIdentifier:defaultReuseDef];
    }
    
    return _collectionView;
}

- (void)setBounces:(BOOL)bounces
{
    if (_bounces != bounces) {
        _bounces = bounces;
        _collectionView.bounces = bounces;
    }
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pageInfos.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.frame.size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    _MyUserGuidePageCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:defaultReuseDef
                                                                            forIndexPath:indexPath];
    
    MyCellContext * context = [[MyCellContext alloc] initWithIndexPath:indexPath
                                                    totalInfoIndexPath:[NSIndexPath indexPathForItem:self.pageCount - 1 inSection:0]
                                                               context:nil];
    
    [cell updateViewWithInfo:[self pageInfoAtIndex:indexPath.item] context:context];
    cell.pageView.delegate = self.delegate;
    
    return cell;
}

#pragma mark -

- (MyUserGuideView *)_userGuideViewAtIndex:(NSUInteger)index
{
    _MyUserGuidePageCell * cell = (id)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    return cell.pageView;
}

- (_MyUserGuidePageTransitionContext *)transitionContext
{
    if (!_transitionContext) {
        
        if (self.pageCount) {
            _transitionContext = [[_MyUserGuidePageTransitionContext alloc] initWithCurrentPageView:[self _userGuideViewAtIndex:self.currentPageIndex] andIndex:self.currentPageIndex];
        }else {
            _transitionContext = [[_MyUserGuidePageTransitionContext alloc] initWithCurrentPageView:nil  andIndex:NSNotFound];
        }
    }
    
    return _transitionContext;
}

- (BOOL)_isVaildTargetPageIndex:(NSInteger)targetPageIndex {
    return targetPageIndex >= 0.f && targetPageIndex < self.pageCount;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint contentOffset = scrollView.contentOffset;
    CGFloat pageWidth = CGRectGetWidth(scrollView.bounds);
    
    BOOL isNext = contentOffset.x > pageWidth * self.currentPageIndex;
    
    if (self.transitionContext.isTransiting) {
        
        //上一次滑动取消
        if((self.transitionContext.targetShowPageIndex > (NSInteger)self.currentPageIndex &&
            self.currentPageIndex * pageWidth >= contentOffset.x) ||
           (self.transitionContext.targetShowPageIndex < (NSInteger)self.currentPageIndex &&
            self.currentPageIndex * pageWidth <= contentOffset.x)) {
               
            NSInteger targetPageIndex = self.transitionContext.targetShowPageIndex;
            [self.transitionContext cancleShow];
            
            if ([self _isVaildTargetPageIndex:targetPageIndex]) {
               [self _sendCancleShowPageMsgWithPageIndex:targetPageIndex];
            }
               
            return;
        }
        
        CGFloat pageProgress = contentOffset.x / pageWidth;
        
        //改变页面
        if (!self.transitionContext.isBouning && (isNext ? floorf(pageProgress) : ceilf(pageProgress)) != self.currentPageIndex) {
            
            NSUInteger fromPageIndex = self.currentPageIndex;
            [self.transitionContext completedShow];
            _currentPageIndex = self.transitionContext.currentPageIndex;
            
            [self _sendCompletedShowPageMsgFromPageIndex:fromPageIndex];
            
        }else { //更新进度
            
            CGFloat progress = fabs(self.currentPageIndex - pageProgress);
            [self.transitionContext updateShowProgress:progress];
            
            if (!self.transitionContext.isBouning) {
                [self _sendUpdateShowingPageMsgWithProgress:pageProgress];
            }
        }
        
    }else if(self.collectionView.isDragging){ //开始过渡
        
        NSInteger desPageIndex = self.currentPageIndex + (isNext ? 1 : -1);
        if ([self _isVaildTargetPageIndex:desPageIndex]) {
            
            MyUserGuideView * userGuideView = [self _userGuideViewAtIndex:desPageIndex];
            
            if (userGuideView) {
                [self.transitionContext startShowPageView:userGuideView atIndex:desPageIndex bounces:NO];
                [self _sendStartShowPageMsg];
            }
        }else {
            [self.transitionContext startShowPageView:nil atIndex:desPageIndex bounces:YES];
        }
        
        //0.5f后尝试取消过渡，防止错误情况发生
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_timeToTryCancleTransition) object:nil];
        [self performSelector:@selector(_timeToTryCancleTransition) withObject:self afterDelay:0.5f];        
    }
    
//    else {
//        NSLog(@"开始过渡失败");
//    }
}

- (void)_timeToTryCancleTransition
{
    if (self.transitionContext.isTransiting &&
        !self.collectionView.isTracking &&
        !self.collectionView.isDecelerating) { //发生错误情况,手动取消
        
//        NSLog(@"发生错误情况，手动取消过渡");
        
        NSInteger targetPageIndex = self.transitionContext.targetShowPageIndex;
        [self.transitionContext cancleShow];
        
        if ([self _isVaildTargetPageIndex:targetPageIndex]) {
            [self _sendCancleShowPageMsgWithPageIndex:targetPageIndex];
        }
    }
}

- (void)_sendStartShowPageMsg;
{
    id<MyUserGuidePageManagerDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(userGuidePageManager:startShowPageAtIndex:fromPageAtIndex:)) {
        [delegate userGuidePageManager:self
                  startShowPageAtIndex:self.transitionContext.targetShowPageIndex
                       fromPageAtIndex:self.currentPageIndex];
    }
}

- (void)_sendUpdateShowingPageMsgWithProgress:(CGFloat)progress
{
    id<MyUserGuidePageManagerDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(userGuidePageManager:showingPageAtIndex:fromPageAtIndex:withProgress:)) {
        [delegate userGuidePageManager:self
                    showingPageAtIndex:self.transitionContext.targetShowPageIndex
                       fromPageAtIndex:self.currentPageIndex
                          withProgress:progress];
    }
}

- (void)_sendCompletedShowPageMsgFromPageIndex:(NSUInteger)fromPageIndex
{
    id<MyUserGuidePageManagerDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(userGuidePageManager:didShowPageAtIndex:fromPageAtIndex:)) {
        [delegate userGuidePageManager:self
                    didShowPageAtIndex:self.currentPageIndex
                       fromPageAtIndex:fromPageIndex];
    }
}

- (void)_sendCancleShowPageMsgWithPageIndex:(NSUInteger)pageIndex
{
    id<MyUserGuidePageManagerDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(userGuidePageManager:cancleShowPageAtIndex:fromPageAtIndex:)) {
        [delegate userGuidePageManager:self
                 cancleShowPageAtIndex:pageIndex
                       fromPageAtIndex:self.currentPageIndex];
    }
}


@end

//----------------------------------------------------------

@implementation NSDictionary (MyUserGuidePage)

- (MyUserGuideView *)userGuidePageView
{
    Class userGuidePageViewClass = NSClassFromString([self stringValueForKey:@"pageViewClass"]);
    if ([userGuidePageViewClass isSubclassOfClass:[MyUserGuideView class]]) {
        return [userGuidePageViewClass xyy_createInstance];
    }
    
    return nil;
}

@end
