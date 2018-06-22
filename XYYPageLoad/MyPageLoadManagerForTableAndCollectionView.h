//
//  MyPageLoadManagerForTableAndCollectionView.h
//  
//
//  Created by LeslieChen on 15/3/31.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>
#import "MyPageLoadControllerProtocol.h"
#import "XYYFoundation.h"

//----------------------------------------------------------

@class MyPageLoadManagerForTableAndCollectionView;

//----------------------------------------------------------

typedef NS_ENUM(NSInteger, MyPageLoadDataHandleType) {
    MyPageLoadDataHandleAnimationTypeLoadInsertSection,
    MyPageLoadDataHandleAnimationTypeLoadInsertRow,
    MyPageLoadDataHandleAnimationTypeInsertSection,
    MyPageLoadDataHandleAnimationTypeInsertRow,
    MyPageLoadDataHandleAnimationTypeRemoveSection,
    MyPageLoadDataHandleAnimationTypeRemoveRow,
    MyPageLoadDataHandleAnimationTypeReloadSection,
    MyPageLoadDataHandleAnimationTypeReloadRow
};

//----------------------------------------------------------

@protocol MyPageLoadManagerForTableAndCollectionViewDataSource <NSObject>

@optional

//page为0，则为更新
- (void)    pageLoadManager:(MyPageLoadManagerForTableAndCollectionView *)pageLoadManager
     wantToLoadDataWithPage:(NSUInteger)page
                andPageSize:(NSUInteger)pageSize;

//想要取消加载数据
- (void)pageLoadManagerWantCancleLoadData:(MyPageLoadManagerForTableAndCollectionView *)pageLoadManager;

//完成取消加载数据
- (void)pageLoadManager:(MyPageLoadManagerForTableAndCollectionView *)pageLoadManager didCancleLoadData:(BOOL)isUpdate;

//数据数目改变
- (void)pageLoadManagerCurrentDataCountDidChange:(MyPageLoadManagerForTableAndCollectionView *)pageLoadManager;

//返回数据操作的动画类型
- (UITableViewRowAnimation)pageLoadManager:(MyPageLoadManagerForTableAndCollectionView *)pageLoadManager tableViewRowAnimationForDataHandleType:(MyPageLoadDataHandleType)dataHandleType;


//筛选数据
- (NSArray *)   pageLoadManager:(MyPageLoadManagerForTableAndCollectionView *)pageLoadManager
                   willAddDatas:(NSArray *)datas
               withCurrentDatas:(NSArray *)currentDatas;

@end

//----------------------------------------------------------

//获取内容视图的block
typedef UIScrollView * (^GetContentScrollViewBlock)(void);

//----------------------------------------------------------

//分页加载配置
@interface MyPageLoadManagerConfigure : NSObject

//初始化
- (id)initWithContentScrollView:(UIScrollView *)scrollView pageLoadControllerClass:(Class)pageLoadControllerClass;
- (id)initWithContentScrollView:(UIScrollView *)scrollView
        pageLoadControllerClass:(Class)pageLoadControllerClass
                       pageSize:(NSUInteger)pageSize
                   startSection:(NSUInteger)startSection
                       startRow:(NSUInteger)startRow;
- (id)initWithGetContentScrollViewBlcok:(GetContentScrollViewBlock)getContentScrollViewBlock
                pageLoadControllerClass:(Class)pageLoadControllerClass;
- (id)initWithGetContentScrollViewBlcok:(GetContentScrollViewBlock)getContentScrollViewBlock
                pageLoadControllerClass:(Class)pageLoadControllerClass
                               pageSize:(NSUInteger)pageSize
                           startSection:(NSUInteger)startSection
                               startRow:(NSUInteger)startRow;


@property(nonatomic,readonly) NSUInteger pageSize;
@property(nonatomic,readonly) NSUInteger startSection;
@property(nonatomic,readonly) NSUInteger startRow;
@property(nonatomic,strong,readonly) Class pageLoadControllerClass;

@property(nonatomic,copy,readonly) GetContentScrollViewBlock getContentScrollViewBlock;
@property(nonatomic,strong,readonly) UIScrollView * contentScrollView;
@property(nonatomic,strong,readonly) UITableView * tableView;
@property(nonatomic,strong,readonly) UICollectionView * collectionView;

@end

//----------------------------------------------------------

@interface MyPageLoadManagerForTableAndCollectionView : NSObject <MyPageLoadControllerDelegate>

+ (NSUInteger)defaultPageSize;

- (id)  initWithScrollView:(UIScrollView *)scrollView
   pageLoadControllerClass:(Class)pageLoadControllerClass
                  pageSize:(NSUInteger)pageSize
              startSection:(NSUInteger)startSection
                  startRow:(NSUInteger)startRow
            segmentedCount:(NSUInteger)segmentedCount;

- (id)initWithConfigures:(NSArray<MyPageLoadManagerConfigure *> *)configures;

@property(nonatomic,readonly) NSUInteger pageSize;
@property(nonatomic,strong,readonly) UIScrollView * contentScrollView;
@property(nonatomic,strong,readonly) UITableView * tableView;
@property(nonatomic,strong,readonly) UICollectionView * collectionView;

//当前分页加载的配置
@property(nonatomic,strong,readonly) MyPageLoadManagerConfigure * currentConfigure;
- (MyPageLoadManagerConfigure *)configureAtSegmentedIndex:(NSUInteger)segmentedIndex;


//当前segmented
@property(nonatomic) NSUInteger currentSegmentedIndex;
@property(nonatomic,readonly) NSUInteger segmentedCount;

//加载控件
@property(nonatomic,strong) MyRefreshControl * topRefreshControl;
@property(nonatomic,strong) MyRefreshControl * bottomLoadControl;


//自动添加刷新控件
@property(nonatomic) BOOL autoAddRefreshControl;
//自动添加加载控件
@property(nonatomic) BOOL autoAddLoadControl;


//重新加载数据
- (void)reloadContentViewData;

//初始化更新数据
- (void)updateWithInitDatas:(NSArray *)datas;
- (void)updateWithInitDatas:(NSArray *)datas totalDataCount:(NSUInteger)totalDataCount;
- (void)updateWithInitDatas:(NSArray *)datas totalDataCount:(NSUInteger)totalDataCount nextPage:(NSInteger)nextPage;

//开始更新数据
- (void)startUpdateData:(BOOL)showRefreshControl;
//开始更新数据
- (void)startUpdateData:(BOOL)showRefreshControl scrollToTop:(BOOL)scrollToTop;

//开始加载数据
- (void)startLoadData:(BOOL)showLoadControl;
- (void)startLoadData:(BOOL)showLoadControl scrollToBottom:(BOOL)scrollToBottom;

//取消加载数据
- (void)cancleLoadData;

//加载的类型
@property(nonatomic,readonly) MyDataLoadType dataLoadType;

//回调
//加载数据成功
- (void)loadDataSuccessWithDatas:(NSArray *)datas totalCount:(NSUInteger)totalCount;
//加载数据错误
- (void)loadDataFail;

//总数据量
- (NSUInteger)totalDataCount;
//当前数据数量
- (NSUInteger)currentDataCount;
//开始的section
- (NSUInteger)startSection;
//开始的section
- (NSUInteger)startRow;

//是否完成加载
- (BOOL)hadCompletedLoad;

- (BOOL)containDataAtIndexPath:(NSIndexPath *)indexPath;

//获取数据
- (id)firstData;
- (id)lastData;
- (id)dataAtIndex:(NSUInteger)index;
- (id)dataAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForDataAtIndex:(NSUInteger)index;
- (NSUInteger)indexForDataAtIndexPath:(NSIndexPath *)indexPath;

- (NSArray *)allDatas;
- (NSArray *)allDatasAtSegmentedIndex:(NSUInteger)segmentedIndex;
- (NSIndexPath *)indexPathForData:(id)data;

- (NSUInteger)sectionCount;
- (NSUInteger)dataCountAtSection:(NSUInteger)section;

//插入数据
- (void)insertDatas:(NSArray *)datas atIndexPaths:(NSArray *)indexPaths;
- (void)insertDatas:(NSArray *)datas atSections:(NSIndexSet *)sections;

//替换数据
- (void)replaceDatas:(NSArray *)datas atIndexPaths:(NSArray *)indexPaths;
- (void)replaceDatas:(NSArray *)datas atSections:(NSIndexSet *)sections;

//删除数据
- (void)removeDataAtIndexPaths:(NSArray *)indexPaths;
- (void)removeDataAtSections:(NSIndexSet *)sections;
- (void)removeDatas:(NSArray *)datas;

//数据源
@property(nonatomic,weak) id<MyPageLoadManagerForTableAndCollectionViewDataSource> dataSource;

@end
