//
//  MyPageLoadManagerForTableAndCollectionView.m
//  
//
//  Created by LeslieChen on 15/3/31.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyPageLoadManagerForTableAndCollectionView.h"
#import "MyPageLoadControllerProtocol.h"
#import "XYYFoundation.h"
#import "MyArrayPageLoadController.h"

//----------------------------------------------------------

@interface MyPageLoadManagerConfigure ()

//基于的分页管理器
@property(nonatomic,weak) MyPageLoadManagerForTableAndCollectionView * pageLoadManager;

//分页加载控制器
@property(nonatomic,strong,readonly) id<MyPageLoadControllerProtocol> pageLoadController;

@end

//----------------------------------------------------------

@implementation MyPageLoadManagerConfigure

@synthesize contentScrollView = _contentScrollView;
@synthesize pageLoadController = _pageLoadController;

- (id)init {
    return [self initWithContentScrollView:nil pageLoadControllerClass:nil];
}

- (id)initWithContentScrollView:(UIScrollView *)scrollView pageLoadControllerClass:(Class)pageLoadControllerClass
{
    return [self initWithContentScrollView:scrollView pageLoadControllerClass:pageLoadControllerClass
                                  pageSize:[MyPageLoadManagerForTableAndCollectionView defaultPageSize]
                              startSection:0
                                  startRow:0];
}

- (id)initWithContentScrollView:(UIScrollView *)scrollView
        pageLoadControllerClass:(Class)pageLoadControllerClass
                       pageSize:(NSUInteger)pageSize
                   startSection:(NSUInteger)startSection
                       startRow:(NSUInteger)startRow
{
    
    return [self initWithGetContentScrollViewBlcok:scrollView ? ^{ return scrollView; } : nil
                           pageLoadControllerClass:pageLoadControllerClass
                                          pageSize:pageSize
                                      startSection:startSection
                                          startRow:startRow];
}


- (id)initWithGetContentScrollViewBlcok:(GetContentScrollViewBlock)getContentScrollViewBlock
                pageLoadControllerClass:(Class)pageLoadControllerClass
{
    return [self initWithGetContentScrollViewBlcok:getContentScrollViewBlock
                           pageLoadControllerClass:pageLoadControllerClass
                                          pageSize:[MyPageLoadManagerForTableAndCollectionView defaultPageSize]
                                      startSection:0
                                          startRow:0];
}

- (id)initWithGetContentScrollViewBlcok:(GetContentScrollViewBlock)getContentScrollViewBlock
                pageLoadControllerClass:(Class)pageLoadControllerClass
                               pageSize:(NSUInteger)pageSize
                           startSection:(NSUInteger)startSection
                               startRow:(NSUInteger)startRow
{
    self = [super init];
    
    if (self) {
        
        _getContentScrollViewBlock = [getContentScrollViewBlock copy];
        _pageSize = pageSize;
        _startRow = startRow;
        _startSection = startSection;
        
        _pageLoadControllerClass  = pageLoadControllerClass ?: [MyArrayPageLoadController class];
        if (![_pageLoadControllerClass conformsToProtocol:@protocol(MyPageLoadControllerProtocol)]) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"pageLoadControllerClass必须遵循MyPageLoadControllerProtocol协议"
                                         userInfo:nil];
        }
    }
    
    return self;
}

- (id<MyPageLoadControllerProtocol>)pageLoadController
{
    if (!_pageLoadController) {
        _pageLoadController = [[_pageLoadControllerClass  alloc] initWithPageSize:_pageSize
                                                                     startSection:_startSection
                                                                         startRow:_startRow];
        [_pageLoadController setDelegate:self.pageLoadManager];
    }
    
    return _pageLoadController;
}

- (UIScrollView *)contentScrollView
{
    if (!_contentScrollView) {
        
        if (self.getContentScrollViewBlock) {
            _contentScrollView = self.getContentScrollViewBlock();
        }

        if (_contentScrollView &&
            ![_contentScrollView isKindOfClass:[UITableView class]] &&
            ![_contentScrollView isKindOfClass:[UICollectionView class]]) {
            
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"contentScrollView必须为UITableView或UICollectionView及其子类的实例"
                                         userInfo:nil];
        }
        
        _contentScrollView = _contentScrollView ?: [[UITableView alloc] init];
    }
    
    return _contentScrollView;
}

- (UITableView *)tableView {
    return ConvertToClassPointer(UITableView, self.contentScrollView);
}

- (UICollectionView *)collectionView {
    return ConvertToClassPointer(UICollectionView, self.contentScrollView);
}

@end


//----------------------------------------------------------

@interface MyPageLoadManagerForTableAndCollectionView ()

@property(nonatomic,strong,readonly) id<MyPageLoadControllerProtocol> pageLoadController;

//分页加载配置
@property(nonatomic,strong) NSArray<MyPageLoadManagerConfigure *> * pageLoadManagerConfigures;

//是否正在加载数据
@property(nonatomic) BOOL isLoadData;

@end

//----------------------------------------------------------

@implementation MyPageLoadManagerForTableAndCollectionView

@synthesize topRefreshControl = _topRefreshControl;
@synthesize bottomLoadControl = _bottomLoadControl;


+ (NSUInteger)defaultPageSize {
    return 10;
}

- (id)init {
    return [self initWithConfigures:@[[[MyPageLoadManagerConfigure alloc] init]]];
}


- (id)  initWithScrollView:(UIScrollView *)scrollView
   pageLoadControllerClass:(Class)pageLoadControllerClass
                  pageSize:(NSUInteger)pageSize
              startSection:(NSUInteger)startSection
                  startRow:(NSUInteger)startRow
            segmentedCount:(NSUInteger)segmentedCount
{
    if (segmentedCount == 0) {
        segmentedCount = 1;
        NSLog(@"segmentedCount等于0，已被设置为1");
    }
    
    NSMutableArray * pageLoadManagerConfigures = [NSMutableArray arrayWithCapacity:segmentedCount];
    for (NSInteger i = 0; i < segmentedCount; ++ i) {
        [pageLoadManagerConfigures addObject:[[MyPageLoadManagerConfigure alloc] initWithContentScrollView:scrollView pageLoadControllerClass:pageLoadControllerClass pageSize:pageSize startSection:startSection startRow:startRow]];
    }
    
    return [self initWithConfigures:pageLoadManagerConfigures];
}

- (id)initWithConfigures:(NSArray<MyPageLoadManagerConfigure *> *)configures
{
    if (configures.count == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"分页配置不能为空"
                                     userInfo:nil];
    }
    
    self = [super init];
    
    if (self) {
        _segmentedCount = configures.count;
        _currentSegmentedIndex = 0;
        
        _pageLoadManagerConfigures = [NSArray arrayWithArray:configures];
        [_pageLoadManagerConfigures makeObjectsPerformSelector:@selector(setPageLoadManager:) withObject:self];
    }
    
    return self;
}

#pragma mark -

- (NSUInteger)pageSize {
    return [self.currentConfigure pageSize];
}

- (UITableView *)tableView {
    return self.currentConfigure.tableView;
}

- (UICollectionView *)collectionView {
    return self.currentConfigure.collectionView;
}

- (UIScrollView *)contentScrollView {
    return self.currentConfigure.contentScrollView;
}

- (void)reloadContentViewData {
    [self.currentConfigure.contentScrollView performSelector:@selector(reloadData) withObject:nil];
}

#pragma mark -

- (id<MyPageLoadControllerProtocol>)pageLoadController {
    return self.currentConfigure.pageLoadController;
}

- (MyPageLoadManagerConfigure *)currentConfigure {
    return self.pageLoadManagerConfigures[self.currentSegmentedIndex];
}

- (MyPageLoadManagerConfigure *)configureAtSegmentedIndex:(NSUInteger)segmentedIndex {
    return self.pageLoadManagerConfigures[segmentedIndex];
}

- (void)setCurrentSegmentedIndex:(NSUInteger)currentSegmentedIndex
{
    if (_currentSegmentedIndex != currentSegmentedIndex) {
        checkIndexAtRange(currentSegmentedIndex, NSMakeRange(0, self.segmentedCount));
        
//        UIScrollView * contentScrollView = self.contentScrollView;
        
        //取消加载
        [self cancleLoadData];
        
        _currentSegmentedIndex = currentSegmentedIndex;
        
        //更新刷新和加载控件
        [self _updateRefreshControl];
        [self _updateLoadControl];
        
//        //刷新内容(改变前后为同一个)
//        if (self.contentScrollView == contentScrollView) {
//            [self reloadContentViewData];
//        }
        //刷新内容
        [self reloadContentViewData];
        
        //发送消息
        [self _sendCurrentDataCountDidChangeMsg];
    }
}

#pragma mark -

- (void)setAutoAddRefreshControl:(BOOL)autoAddRefreshControl
{
    if (_autoAddRefreshControl != autoAddRefreshControl) {
        _autoAddRefreshControl = autoAddRefreshControl;
        
        [self cancleLoadData];
        [self _updateRefreshControl];
    }
}

- (MyRefreshControl *)topRefreshControl
{
    if (!_topRefreshControl) {
        _topRefreshControl = [[MyRefreshControl alloc] initWithType:MyRefreshControlTypeTop];
        [_topRefreshControl addTarget:self
                               action:@selector(_topRefreshControlHandle:)
                     forControlEvents:UIControlEventValueChanged];
    }
    
    return _topRefreshControl;
}

- (void)setTopRefreshControl:(MyRefreshControl *)topRefreshControl
{
    if (topRefreshControl && topRefreshControl.type != MyRefreshControlTypeTop) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"topRefreshControl需要是MyRefreshControlTypeTop类型"
                                     userInfo:nil];
    }
    
    if (_topRefreshControl != topRefreshControl) {
        
        if (_topRefreshControl) {
            [_topRefreshControl removeFromSuperview];
            [_topRefreshControl removeTarget:self
                                      action:@selector(_topRefreshControlHandle:)
                            forControlEvents:UIControlEventValueChanged];
        }
        
        _topRefreshControl = topRefreshControl;
        [_topRefreshControl addTarget:self
                               action:@selector(_topRefreshControlHandle:)
                     forControlEvents:UIControlEventValueChanged];
        
        [self cancleLoadData];
        [self _updateRefreshControl];
    }
}

- (void)_updateRefreshControl
{
    [self _completeLoad];
    
    if (self.autoAddRefreshControl) {
        [[self contentScrollView] addSubview:self.topRefreshControl];
    }else{
        [_topRefreshControl removeFromSuperview];
    }
}

- (void)_topRefreshControlHandle:(id)sender
{
    if (sender == _topRefreshControl) {
        
        //没有更新则开始更新
        if (self.dataLoadType != MyDataLoadTypeUpdate) {
            [self startUpdateData:NO];
        }
    }
}


#pragma mark -

- (void)setAutoAddLoadControl:(BOOL)autoAddLoadControl
{
    if (_autoAddLoadControl != autoAddLoadControl) {
        _autoAddLoadControl = autoAddLoadControl;
        
        [self cancleLoadData];
        [self _updateRefreshControl];
    }
}

- (MyRefreshControl *)bottomLoadControl
{
    if (!_bottomLoadControl) {
        _bottomLoadControl = [[MyRefreshControl alloc] initWithType:MyRefreshControlTypeBottom];
        [_bottomLoadControl addTarget:self
                               action:@selector(_bottomLoadControlHandle:)
                     forControlEvents:UIControlEventValueChanged];
    }
    
    return _bottomLoadControl;
}

- (void)setBottomLoadControl:(MyRefreshControl *)bottomLoadControl
{
    if (bottomLoadControl && bottomLoadControl.type != MyRefreshControlTypeBottom) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"bottomLoadControl需要是MyRefreshControlTypeBottom类型"
                                     userInfo:nil];
    }
    
    if (_bottomLoadControl != bottomLoadControl) {
        
        if (_bottomLoadControl) {
            [_bottomLoadControl removeFromSuperview];
            [_bottomLoadControl removeTarget:self
                                      action:@selector(_bottomLoadControlHandle:)
                            forControlEvents:UIControlEventValueChanged];
        }
        
        _bottomLoadControl = bottomLoadControl;
        [_bottomLoadControl addTarget:self
                               action:@selector(_bottomLoadControlHandle:)
                     forControlEvents:UIControlEventValueChanged];
        
        [self cancleLoadData];
        [self _updateLoadControl];
    }
}

- (void)_updateLoadControl
{
    if (self.autoAddLoadControl) {
        
        if (![self.pageLoadController hadCompletedLoad]) {
            [[self contentScrollView] addSubview:self.bottomLoadControl];
        }else{
            [_bottomLoadControl removeFromSuperview];
        }
        
    }else {
        [_bottomLoadControl removeFromSuperview];
    }
}

- (void)_bottomLoadControlHandle:(id)sender
{
    if (sender == _bottomLoadControl) {
        
        //没有加载则开始加载
        if (self.dataLoadType == MyDataLoadTypeNone) {
            [self startLoadData:NO];
        }else if (self.dataLoadType == MyDataLoadTypeUpdate) {
            [_bottomLoadControl endRefreshing];
            _bottomLoadControl.hidden = YES;
        }
    }
}


#pragma mark -

- (void)updateWithInitDatas:(NSArray *)datas  {
    [self updateWithInitDatas:datas totalDataCount:datas.count];
}

- (void)updateWithInitDatas:(NSArray *)datas totalDataCount:(NSUInteger)totalDataCount
{
    [self cancleLoadData];
    [self.pageLoadController updateWithInitDatas:datas totalDataCount:MAX(datas.count, totalDataCount)];
}

- (void)updateWithInitDatas:(NSArray *)datas totalDataCount:(NSUInteger)totalDataCount nextPage:(NSInteger)nextPage
{
    [self cancleLoadData];
    [self.pageLoadController updateWithInitDatas:datas totalDataCount:MAX(datas.count, totalDataCount) nextPage:nextPage];
}

- (void)startUpdateData:(BOOL)showRefreshControl {
    [self startUpdateData:showRefreshControl scrollToTop:YES];
}

- (void)startUpdateData:(BOOL)showRefreshControl scrollToTop:(BOOL)scrollToTop
{
    [self cancleLoadData];
    
    if (self.autoAddRefreshControl && showRefreshControl) {
        [self.topRefreshControl beginRefreshing_e:scrollToTop];
    }
    _bottomLoadControl.hidden = YES;
    
    [self.pageLoadController startLoadDataForUpdate];
}

- (void)startLoadData:(BOOL)showLoadControl {
    [self startLoadData:showLoadControl scrollToBottom:YES];
}

- (void)startLoadData:(BOOL)showLoadControl scrollToBottom:(BOOL)scrollToBottom
{
    [self cancleLoadData];
    
    if (self.autoAddLoadControl && showLoadControl) {
        [self.bottomLoadControl beginRefreshing_e:scrollToBottom];
    }
    _topRefreshControl.hidden = YES;
    
    [self.pageLoadController startLoadData];
}

- (MyDataLoadType)dataLoadType {
    return [self.pageLoadController dataLoadType];
}

- (void)cancleLoadData
{
    if ([self.pageLoadController dataLoadType] != MyDataLoadTypeNone) {
        
        BOOL isUpdate = [self.pageLoadController dataLoadType] == MyDataLoadTypeUpdate;
        id<MyPageLoadManagerForTableAndCollectionViewDataSource> dataSource = self.dataSource;
        ifRespondsSelector(dataSource, @selector(pageLoadManagerWantCancleLoadData:)){
            [dataSource pageLoadManagerWantCancleLoadData:self];
        }
        
        [self loadDataFail];
        
        ifRespondsSelector(dataSource, @selector(pageLoadManager:didCancleLoadData:)){
            [dataSource pageLoadManager:self didCancleLoadData:isUpdate];
        }
    }
}

- (void)loadDataSuccessWithDatas:(NSArray *)datas totalCount:(NSUInteger)totalCount
{
    self.isLoadData = YES;
    
    [self _completeLoad];
    [self.pageLoadController endLoadDataWithDatas:datas totalDataCount:totalCount];
    
    self.isLoadData = NO;
}

- (void)loadDataFail
{
    [self _completeLoad];
    [self.pageLoadController loadDataFail];
}

- (void)_completeLoad
{
    [_topRefreshControl endRefreshing];
    [_bottomLoadControl endRefreshing];
    
    _topRefreshControl.hidden = NO;
    _bottomLoadControl.hidden = NO;
}

#pragma mark -

//是否完成加载
- (BOOL)hadCompletedLoad {
    return self.pageLoadController.hadCompletedLoad;
}

- (NSUInteger)startSection {
    return [self.pageLoadController startSection];
}

- (NSUInteger)startRow {
    return [self.pageLoadController startRow];
}

- (NSUInteger)totalDataCount {
    return [self.pageLoadController totalDataCount];
}

- (NSUInteger)currentDataCount {
    return [self.pageLoadController currentDataCount];
}

- (NSUInteger)sectionCount {
    return [self.pageLoadController sectionCount];
}

- (NSUInteger)dataCountAtSection:(NSUInteger)section {
    return [self.pageLoadController dataCountAtSection:section];
}


- (BOOL)containDataAtIndexPath:(NSIndexPath *)indexPath {
    return [self.pageLoadController containDataAtIndexPath:indexPath];
}


- (NSIndexPath *)indexPathForDataAtIndex:(NSUInteger)index {
    return [self.pageLoadController indexPathForDataAtIndex:index];
}

- (NSUInteger)indexForDataAtIndexPath:(NSIndexPath *)indexPath {
    return [self.pageLoadController indexForDataAtIndexPath:indexPath];
}

- (id)firstData
{
    NSUInteger currentDataCount = self.currentDataCount;
    return currentDataCount ? [self dataAtIndex:0] : nil;
}

- (id)lastData
{
    NSUInteger currentDataCount = self.currentDataCount;
    return currentDataCount ? [self dataAtIndex:currentDataCount - 1] : nil;
}

- (id)dataAtIndexPath:(NSIndexPath *)indexPath {
    return [self.pageLoadController dataAtIndexPath:indexPath];
}

- (id)dataAtIndex:(NSUInteger)index {
    return  [self.pageLoadController dataAtIndex:index];
}

- (NSArray *)allDatas {
    return [self allDatasAtSegmentedIndex:self.currentSegmentedIndex];
}

- (NSArray *)allDatasAtSegmentedIndex:(NSUInteger)segmentedIndex {
    return [NSArray arrayWithArray:[[self.pageLoadManagerConfigures[segmentedIndex] pageLoadController] allDatas]];
}

- (NSIndexPath *)indexPathForData:(id)data {
    return [self.pageLoadController indexPathForData:data];
}


//插入数据
- (void)insertDatas:(NSArray *)datas atIndexPaths:(NSArray *)indexPaths {
    [self.pageLoadController insertDatas:datas atIndexPaths:indexPaths];
}
- (void)insertDatas:(NSArray *)datas atSections:(NSIndexSet *)sections {
    [self.pageLoadController insertDatas:datas atSections:sections];
}

//替换数据
- (void)replaceDatas:(NSArray *)datas atIndexPaths:(NSArray *)indexPaths {
    [self.pageLoadController replaceDatas:datas atIndexPaths:indexPaths];
}
- (void)replaceDatas:(NSArray *)datas atSections:(NSIndexSet *)sections {
    [self.pageLoadController replaceDatas:datas atSections:sections];
}

//移除数据
- (void)removeDataAtIndexPaths:(NSArray *)indexPaths {
    [self.pageLoadController removeDataAtIndexPaths:indexPaths];
}
- (void)removeDataAtSections:(NSIndexSet *)sections {
    [self.pageLoadController removeDataAtSections:sections];
}
- (void)removeDatas:(NSArray *)datas {
    [self.pageLoadController removeDatas:datas];
}


#pragma mark -

- (void)pageLoadController:(id<MyPageLoadControllerProtocol>)pageLoadController completedLoadStatusDidChange:(BOOL)completedLoad
{
    //更新加载控件
    [self _updateLoadControl];
    
    //发送数据数目改变通知
    [self _sendCurrentDataCountDidChangeMsg];
}

- (void)_sendCurrentDataCountDidChangeMsg
{
    id<MyPageLoadManagerForTableAndCollectionViewDataSource> dataSource = self.dataSource;
    ifRespondsSelector(dataSource, @selector(pageLoadManagerCurrentDataCountDidChange:)){
        [dataSource pageLoadManagerCurrentDataCountDidChange:self];
    }
}

- (void)pageLoadController:(id<MyPageLoadControllerProtocol>)pageLoadController wantToAddDataForViewAtIndexPaths:(NSArray *)indexPaths
{
    if (self.tableView) {
     
        UITableViewRowAnimation tableViewRowAnimation = [self _tableViewRowAnimationForDataHandleType:self.isLoadData ? MyPageLoadDataHandleAnimationTypeLoadInsertRow : MyPageLoadDataHandleAnimationTypeInsertRow];
        
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:tableViewRowAnimation];
        
    }else {
        [self.collectionView insertItemsAtIndexPaths:indexPaths];
    }
}

- (void)pageLoadController:(id<MyPageLoadControllerProtocol>)pageLoadController wantToRemoveDataForViewAtIndexPaths:(NSArray *)indexPaths
{
    if (self.tableView) {
        [self.tableView deleteRowsAtIndexPaths:indexPaths
                              withRowAnimation:[self _tableViewRowAnimationForDataHandleType:MyPageLoadDataHandleAnimationTypeRemoveRow]];
    }else {
        [self.collectionView deleteItemsAtIndexPaths:indexPaths];
    }
}

- (void)pageLoadController:(id<MyPageLoadControllerProtocol>)pageLoadController wantToReloadDataForViewAtIndexPaths:(NSArray *)indexPaths
{
    if (self.tableView) {
        [self.tableView reloadRowsAtIndexPaths:indexPaths
                              withRowAnimation:[self _tableViewRowAnimationForDataHandleType:MyPageLoadDataHandleAnimationTypeReloadRow]];
    }else {
        [self.collectionView reloadItemsAtIndexPaths:indexPaths];
    }
}

- (void)pageLoadControllerWantToReloadDataForView:(id<MyPageLoadControllerProtocol>)pageLoadController {
    [self reloadContentViewData];
}

- (void)    pageLoadController:(id<MyPageLoadControllerProtocol>)pageLoadController
        wantToLoadDataWithPage:(NSUInteger)page
                   andPageSize:(NSUInteger)pageSize
{
    id<MyPageLoadManagerForTableAndCollectionViewDataSource> dataSource = self.dataSource;
    ifRespondsSelector(dataSource, @selector(pageLoadManager:wantToLoadDataWithPage:andPageSize:)){
        [dataSource pageLoadManager:self wantToLoadDataWithPage:page andPageSize:pageSize];
    }
}

//添加section
- (void)pageLoadController:(id<MyPageLoadControllerProtocol>)pageLoadController wantToAddDataForViewAtSections:(NSIndexSet *)sections
{
    if (self.tableView) {
        
        UITableViewRowAnimation tableViewRowAnimation = [self _tableViewRowAnimationForDataHandleType:self.isLoadData ? MyPageLoadDataHandleAnimationTypeLoadInsertSection : MyPageLoadDataHandleAnimationTypeInsertSection];
        
        [self.tableView insertSections:sections withRowAnimation:tableViewRowAnimation];
    }else {
        [self.collectionView reloadSections:sections];
    }
}

//删除section
- (void)pageLoadController:(id<MyPageLoadControllerProtocol>)pageLoadController wantToRemoveDataForViewAtSections:(NSIndexSet *)sections
{
    if (self.tableView) {
        [self.tableView deleteSections:sections
                      withRowAnimation:[self _tableViewRowAnimationForDataHandleType:MyPageLoadDataHandleAnimationTypeRemoveSection]];
    }else {
        [self.collectionView deleteSections:sections];
    }
}

//重新加载section
- (void)pageLoadController:(id<MyPageLoadControllerProtocol>)pageLoadController wantToReloadDataForViewAtSections:(NSIndexSet *)sections
{
    if (self.tableView) {
        [self.tableView reloadSections:sections
                      withRowAnimation:[self _tableViewRowAnimationForDataHandleType:MyPageLoadDataHandleAnimationTypeReloadSection]];
    }else {
        [self.collectionView reloadSections:sections];
    }
}

- (UITableViewRowAnimation)_tableViewRowAnimationForDataHandleType:(MyPageLoadDataHandleType)dataHandleType
{
    UITableViewRowAnimation tableViewRowAnimation = UITableViewRowAnimationAutomatic;
    
    id<MyPageLoadManagerForTableAndCollectionViewDataSource> dataSource = self.dataSource;
    ifRespondsSelector(dataSource, @selector(pageLoadManager:tableViewRowAnimationForDataHandleType:)) {
        tableViewRowAnimation = [dataSource pageLoadManager:self tableViewRowAnimationForDataHandleType:dataHandleType];
    }else if(dataHandleType == MyPageLoadDataHandleAnimationTypeLoadInsertSection ||
             dataHandleType == MyPageLoadDataHandleAnimationTypeLoadInsertRow){
        tableViewRowAnimation = UITableViewRowAnimationNone;
    }
    
    return tableViewRowAnimation;
}

- (NSArray *)pageLoadController:(id<MyPageLoadControllerProtocol>)pageLoadController
                   willAddDatas:(NSArray *)datas
               withCurrentDatas:(NSArray *)currentDatas
{
    id<MyPageLoadManagerForTableAndCollectionViewDataSource> dataSource = self.dataSource;
    ifRespondsSelector(dataSource, @selector(pageLoadManager:willAddDatas:withCurrentDatas:)){
        return [dataSource pageLoadManager:self willAddDatas:datas withCurrentDatas:currentDatas];
    }
    
    return datas;
}

@end
