//
//  MyScrollContentPageCell.m
//  
//
//  Created by 陈荣航 on 16/3/16.
//  Copyright © 2016年 ED. All rights reserved.
//

//-------------------------------------------------

#import "MyScrollContentPageCell.h"
#import "XYYCache.h"
#import "MBProgressHUD.h"
#import "MyPageView.h"

//-------------------------------------------------

@implementation MyScrollContentPageCellDefaultContxt

@synthesize needUpdateData = _needUpdateData;
@synthesize contentOffset = _contentOffset;
@synthesize extendContext = _extendContext;

- (id)initWithNeedUpdateData:(BOOL)needUpdateData contentOffset:(CGPoint)contentOffset extendContext:(id)extendContext
{
    self = [super init];
    if (self) {
        _needUpdateData = needUpdateData;
        _contentOffset = contentOffset;
        _extendContext = extendContext;
    }
    
    return self;
}

@end


//-------------------------------------------------


@implementation MyScrollContentPageCell
{
    CGFloat _topExtentViewHeight;
    NSMutableSet *  _needSavaDataKeys;
}

@synthesize myContentView = _myContentView;
@synthesize topExtentView = _topExtentView;
@synthesize refreshControl = _refreshControl;
@synthesize loadControl = _loadControl;
@synthesize progressIndicatorView = _progressIndicatorView;

#pragma mark -

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self reloadViews];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self reloadViews];
    }
    
    return self;
}

- (void)dealloc
{
    //停止刷新和加载
    [_refreshControl endRefreshing];
    [_loadControl endRefreshing];
    
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (UIView *)myContentView
{
    if (!_myContentView) {
        _myContentView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView insertSubview:_myContentView atIndex:0];
    }
    
    return _myContentView;
}


- (CGFloat)topExtentViewHeight {
    return 0.f;
}

- (void)reloadViews
{
    if (_topExtentViewHeight != [self topExtentViewHeight]) {
        _topExtentViewHeight = MAX(0, [self topExtentViewHeight]);
        
        [self _updateContentScrollViewInset];
        [self setNeedsLayout];
    }
}

- (UIView *)topExtentView
{
    if (!_topExtentView && [self topExtentViewHeight] >= 0) {
        _topExtentView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.contentView.width, _topExtentViewHeight)];
        [self.contentView addSubview:_topExtentView];
    }
    
    return _topExtentView;
}

#pragma mark -

- (UIEdgeInsets)contentScorllViewInitContentInset
{
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeAreaInsets = self.safeAreaInsets;
        return UIEdgeInsetsMake(safeAreaInsets.top, 0.f, safeAreaInsets.bottom, 0.f);
    }else {
        return UIEdgeInsetsZero;
    }
}

- (void)safeAreaInsetsDidChange
{
    if (@available(iOS 11.0, *)) {
        [super safeAreaInsetsDidChange];
    }
    
    [self updateViewForSafeAreaInsetsDidChange];
}

- (void)updateViewForSafeAreaInsetsDidChange
{
    [self _updateContentScrollViewInset];
}

- (UIEdgeInsets)contentScorllViewContentInset
{
    UIEdgeInsets contentInset = [self contentScorllViewInitContentInset];
    contentInset.top += _topExtentViewHeight;
    return contentInset;
}

- (UIEdgeInsets)contentScorllViewInitScorllIndicatorInsets {
    return [self contentScorllViewInitContentInset];
}

- (UIEdgeInsets)contentScorllViewScorllIndicatorInsets
{
    UIEdgeInsets scrollIndicatorInsets = [self contentScorllViewInitScorllIndicatorInsets];
    scrollIndicatorInsets.top += _topExtentViewHeight;
    return scrollIndicatorInsets;
}

- (void)setContentScrollView:(UIScrollView *)contentScrollView
{
    if (_contentScrollView != contentScrollView) {
        _contentScrollView = contentScrollView;
        
        if (contentScrollView) {
            
            //适配iOS11
            configurationContentScrollViewForAdaptation(contentScrollView);
            
            if (contentScrollView.superview == nil) {
                contentScrollView.frame = self.myContentView.bounds;
                contentScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
                [self.myContentView addSubview:contentScrollView];
            }
            
            //更新inset
            [self _updateContentScrollViewInset];
        }
    }
}

- (UIScrollView *)subPageContentScrollView {
    return _contentScrollView;
}

- (void)_updateContentScrollViewInset
{
    if (!self.contentScrollView) {
        return;
    }
    
    self.contentScrollView.contentInset = [self contentScorllViewContentInset];
    self.contentScrollView.scrollIndicatorInsets = [self contentScorllViewScorllIndicatorInsets];
}

#pragma mark -

- (Class)defaultRefreshControlClass {
    return nil;
}

- (UIControl<MyRefreshControlProtocol> *)refreshControl
{
    if (!_refreshControl) {
        
        //初始化
        _refreshControl = (id)[[self defaultRefreshControlClass] ?: [MyRefreshControlManager defaultRefreshControlClass] createWithRefreshType:MyRefreshControlTypeTop];
        [_refreshControl addTarget:self
                            action:@selector(refreshHandle)
                  forControlEvents:UIControlEventValueChanged];
//        _refreshControl.textColor = defaultTitleTextColor();
//        _refreshControl.locationOffset = CGPointMake(0.f, - self.contentScorllViewInitContentInset.top);
    }
    
    return _refreshControl;
}

- (void)refreshHandle {
}

- (UIControl<MyRefreshControlProtocol> *)loadControl
{
    if (!_loadControl) {
        _loadControl = [[self defaultRefreshControlClass] ?: [MyRefreshControlManager defaultRefreshControlClass] createWithRefreshType:MyRefreshControlTypeBottom];
        [_loadControl addTarget:self
                         action:@selector(loadHandle)
               forControlEvents:UIControlEventValueChanged];
//        _loadControl.textColor = defaultTitleTextColor();
//        _loadControl.locationOffset = CGPointMake(0.f, self.contentScorllViewInitContentInset.bottom);
    }
    
    return _loadControl;
}

- (void)loadHandle {
}

#pragma mark -

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.myContentView.frame = self.contentView.bounds;
    
    if ([self topExtentViewHeight]) {
        self.topExtentView.frame = CGRectMake(0.f, self.contentScorllViewInitContentInset.top, self.contentView.width, _topExtentViewHeight);
    }
}

#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark -

- (UIView *)showProgressIndicatorViewBaseView {
    return self;
}

- (void)showProgressIndicatorViewWithAnimated:(BOOL)animated title:(NSString *)title
{
    [self hideProgressIndicatorViewWithAnimated:NO completedBlock:nil];
    
    _progressIndicatorView = [[XYYMessageUtil shareMessageUtil] showProgressViewInView:[self showProgressIndicatorViewBaseView] withTitle:title animated:animated];
}

- (void)hideProgressIndicatorViewWithAnimated:(BOOL)animated completedBlock:(void(^)(void))completedBlock
{
    if (_progressIndicatorView) {
        [_progressIndicatorView hideWithAnimated:animated completedBlock:completedBlock];
        _progressIndicatorView = nil;
    }
}

#pragma mark -

- (BOOL)currentNetworkAvailable:(BOOL)showMSgWhenNoNetwork
{
    if ([self currentNetworkStatus] == NotReachable) {
        if (showMSgWhenNoNetwork) {
             [[XYYMessageUtil shareMessageUtil] showErrorMessageInView:self.window withTitle:@"网络似乎断开了连接" detail:nil duration:0.0 completedBlock:nil];
        }
        return NO;
    }
    
    return YES;
}

- (NetworkStatus)currentNetworkStatus {
    return [MyNetReachability currentNetReachabilityStatus];
}

- (void)setNeedObserveNetworkStatusChange:(BOOL)needObserveNetworkStatusChange
{
    if (_needObserveNetworkStatusChange != needObserveNetworkStatusChange) {
        
        if (_needObserveNetworkStatusChange) {
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:NetReachabilityChangedNotification
                                                          object:nil];
        }
        
        _needObserveNetworkStatusChange = needObserveNetworkStatusChange;
        
        //添加通知
        if (_needObserveNetworkStatusChange) {
            
            //开始监听
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(_networkStatusChangeNotification:)
                                                         name:NetReachabilityChangedNotification
                                                       object:nil];
        }
    }
}

- (void)_networkStatusChangeNotification:(NSNotification *)notification
{
    if ([NSThread isMainThread]) {
        [self networkStatusChangeHandle];
    }else{
        [self performSelectorOnMainThread:@selector(networkStatusChangeHandle)
                               withObject:nil
                            waitUntilDone:NO];
    }
}

- (void)networkStatusChangeHandle {
    //do noting
}


#pragma mark -

//设置某一key标识的数据需要被储存
- (void)setNeedSavaDataForKey:(NSString *)key
{
    if (!_needSavaDataKeys) {
        _needSavaDataKeys = [NSMutableSet set];
    }
    
    if (key.length) {
        [_needSavaDataKeys addObject:key];
    }else {
        DefaultDebugLog(@"标识需要储存数据的key不能为nil");
    }
}

- (void)saveDatasIfNeeded
{
    //储存数据
    for (NSString * key in _needSavaDataKeys) {
        [self saveDataForKey:key];
    }
    
    [_needSavaDataKeys removeAllObjects];
}

- (void)saveDataForKey:(NSString *)key
{
    MyAssert(key.length);
    
    //获取需要缓存的数据
    id data = [self needSaveDataForKey:key];
    
    //仓库类型
    MyDataStoreType dataStoreType = [self dataStoreTypeForSavaDateWithKey:key];
    
    //自定义储存
    if (dataStoreType > MyDataStoreTypeNone) {
        [self saveData:data toCustomDataStore:dataStoreType withKey:key];
    }else if (dataStoreType != MyDataStoreTypeNone) {
        
        MyDocumentCachePool * cachePool = dataStoreType == MyDataStoreTypeTemp ? [MyDocumentCachePool shareTempCachePool] : [MyDocumentCachePool sharePool];
        
        if ([data conformsToProtocol:@protocol(NSCoding)]) {
            [cachePool cacheKeyedArchiverDataWithRootObject:data forKey:key async:YES];
        }else {
            [cachePool removeCacheFileForKey:key async:YES];
        }
    }
}

- (id)needSaveDataForKey:(NSString *)key {
    return nil;
}

- (MyDataStoreType)dataStoreTypeForSavaDateWithKey:(NSString *)key {
    return MyDataStoreTypeTemp;
}

- (id)getDataSavedInStore:(MyDataStoreType)dataStoreType withKey:(NSString *)key
{
    if (key.length == 0) {
        return nil;
    }
    
    if (dataStoreType > MyDataStoreTypeNone) {
        return [self getDataSavedInCustomStore:dataStoreType withKey:key];
    }else if (dataStoreType != MyDataStoreTypeNone) {
        
        MyDocumentCachePool * cachePool = dataStoreType == MyDataStoreTypeTemp ? [MyDocumentCachePool shareTempCachePool] : [MyDocumentCachePool sharePool];
        
        return [cachePool cacheKeyedUnArchiverRootObjectForKey:key];
    }
    
    return nil;
}

- (void)saveData:(id)data toCustomDataStore:(MyDataStoreType)dataStoreType withKey:(NSString *)key {
    //do nothing
}

- (id)getDataSavedInCustomStore:(MyDataStoreType)dataStoreType withKey:(NSString *)key {
    return nil;
}


#pragma mark -

- (void)updateWithContext:(id<MyScrollContentPageCellContext>)context
{
    _extendContext = [context extendContext];
    
    //更新视图
    [self updateViewWithContext:context];
    
    //更新内容偏移
    if (self.contentScrollView != nil) {
        
        UIEdgeInsets contentInset = self.contentScrollView.contentInset;
        CGPoint contentOffset = [self contentOffsetForContext:context];
        contentOffset.x = MAX(contentOffset.x, - contentInset.left);
        contentOffset.y = MAX(contentOffset.y, - contentInset.top);
        self.contentScrollView.contentOffset = contentOffset;
    }
    
    //更新数据
    if ([self needUpdateDataForContext:context]) {
        [self startUpdateData];
    }
}

- (void)updateViewWithContext:(id<MyScrollContentPageCellContext>)context {
    //do nothing
}

- (BOOL)needUpdateDataForContext:(id<MyScrollContentPageCellContext>)context {
    return context == nil || [context needUpdateData];
}

- (CGPoint)contentOffsetForContext:(id<MyScrollContentPageCellContext>)context
{
    if (context == nil || [context needUpdateData]) {
        UIEdgeInsets contentInset = self.contentScrollView.contentInset;
        return CGPointMake(- contentInset.left, - contentInset.top);
    }else {
        return [context contentOffset];
    }
}

- (void)startUpdateData {
    //do nothing
}

- (id<MyScrollContentPageCellContext>)currentPageContext
{
    return [[MyScrollContentPageCellDefaultContxt alloc] initWithNeedUpdateData:[self isUpdatingData] contentOffset:self.contentScrollView.contentOffset extendContext:self.extendContext];
}

- (void)tryRefreshData
{
    //没有在刷新数据则开始刷新数据，否则移动到最顶端
    if (![self isUpdatingData]) {
        [self startUpdateData];
    }else {
        [self.contentScrollView scrollToBoder:MyScrollBorderTop animated:YES];
    }
}

- (BOOL)isUpdatingData {
    return NO;
}

#pragma mark -

- (id)myForwardingTargetForSelector:(SEL)aSelector {
    return nil;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if (![super respondsToSelector:aSelector]) {
        id object = [self myForwardingTargetForSelector:aSelector];
        return [object respondsToSelector:aSelector];
    }
    
    return YES;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    id object = [self myForwardingTargetForSelector:aSelector];
    if ([object respondsToSelector:aSelector]) {
        return object;
    }
    
    return [super forwardingTargetForSelector:aSelector];
}

@end
