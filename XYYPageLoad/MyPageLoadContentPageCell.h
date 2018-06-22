//
//  MyPageLoadContentPageCell.h
//  
//
//  Created by 陈荣航 on 16/3/17.
//  Copyright © 2016年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyScrollContentPageCell.h"
#import "MyPageLoadManagerForTableAndCollectionView.h"

//----------------------------------------------------------

//数据筛选类型
typedef NS_ENUM(NSInteger, MyDatasFilterType) {
    MyDatasFilterTypeNone,      //无筛选
    MyDatasFilterTypeEqual,     //通过是否相等筛选，如果存在相等数据则筛选掉，保证数据唯一性
    MyDatasFilterTypeCustom     //自定义筛选方式
};


/**
 * 指示视图的状态
 */
typedef NS_ENUM(NSInteger, MyIndicaterViewStatus) {
    MyIndicaterViewStatusHidden,   //隐藏
    MyIndicaterViewStatusLoading,  //加载
    MyIndicaterViewStatusNoNet,    //无网络
    MyIndicaterViewStatusError,    //错误
    MyIndicaterViewStatusNothing   //无内容
};

//----------------------------------------------------------

@interface MyPageLoadDatasContext : NSObject <MyScrollContentPageCellContext>

- (id)initWithDatas:(NSArray *)datas context:(id)context;
- (id)initWithDatas:(NSArray *)datas
         totalCount:(NSUInteger)totalCount
      contentOffset:(CGPoint)contentOffset
            context:(id)context;

- (id)initWithPageLoadManager:(MyPageLoadManagerForTableAndCollectionView *)pageLoadManager context:(id)context;

- (id)initWithDatas:(NSArray *)datas
         totalCount:(NSUInteger)totalCount
     needUpdateData:(BOOL)needUpdateData
      contentOffset:(CGPoint)contentOffset
            context:(id)context;

//数据
@property(nonatomic,strong,readonly) NSArray * datas;

//数据总数
@property(nonatomic,readonly) NSUInteger totalCount;

@end


//----------------------------------------------------------

@interface MyPageLoadContentPageCell : MyScrollContentPageCell <MyPageLoadManagerForTableAndCollectionViewDataSource >


#pragma mark - 管理器初始化
//-------------------------------------------------

//默认一页数据的大小
- (NSUInteger)defaultPageSize;

//初始化分页加载管理器
- (void)setupPageLoadManagerWithdatasContext:(MyPageLoadDatasContext *)datasContext;

//创建分页加载管理器，子类重载该方法创建
- (MyPageLoadManagerForTableAndCollectionView *)createPageLoadManager;
//配置加载管理器，子类重载进行特殊配置
- (void)configPageLoadManager:(MyPageLoadManagerForTableAndCollectionView *)pageLoadManager;

//管理器的引用初始化后才有效
@property(nonatomic,strong,readonly) MyPageLoadManagerForTableAndCollectionView * pageLoadManager;


#pragma mark - 标签切换
//-------------------------------------------------

//当前segmented的index
@property(nonatomic) NSUInteger currentSegmentedIndex;

- (BOOL)willChangeSegmentedIndexToIndex:(NSUInteger)toIndex;
- (void)didChangeSegmentedIndexFromIndex:(NSUInteger)fromIndex;

//是否需要更新视图当改变了segmented的index
- (BOOL)needUpdateDataWhenChangeSegmentedIndexFromIndex:(NSUInteger)fromIndex;
//开始切换标签的显示动画
- (void)startShowContentAnimationWhenDidChangeSegmentedIndexFromIndex:(NSUInteger)fromIndex;

//改变index初始化的offset
- (CGPoint)contentOffsetWhenDidChangeSegmentedIndexToIndex:(NSUInteger)toIndex;
//是否需要改变offset，默认为YES
- (BOOL)needChangeContentOffsetWhenDidChangeSegmentedIndexFromIndex:(NSUInteger)fromIndex;


#pragma mark - 加载数据操作和回调方法
//-------------------------------------------------

//开始更新数据
- (void)startUpdateData:(BOOL)scrollToTop;

//开始加载数据
- (void)loadDataHandleWithPage:(NSUInteger)page andPageSize:(NSUInteger)pageSize;
//取消加载
- (void)cancelLoadDataHandle;

/**
 * 数据加载成功后的回调
 * 完成加载数据后可能需要在后台进行数据的筛选，completedBlock会在数据筛选完毕后进行回调
 */
- (void)loadDataSuccessWithDatas:(NSArray *)datas
                      totalCount:(NSUInteger)totalCount
                  completedBlock:(void(^)(NSArray * filtedDatas))completedBlock;
- (void)loadDataSuccessWithDatas:(NSArray *)datas
                      totalCount:(NSUInteger)totalCount
           beginUpdateDatasBlock:(void(^)(NSArray * filtedDatas))beginUpdateDatasBlock
                  completedBlock:(void(^)(NSArray * filtedDatas))completedBlock;
//加载数据错误
- (void)loadDataFailWithError:(NSError *)error;

//完成加载数据的动画
- (void)startShowContentAnimationWhenLoadDataSuccessWithDatas:(NSArray *)datas totalCount:(NSUInteger)totalCount;

//返回所有分页加载的可见的cell
- (NSArray *)visiblePageLoadCells;

#pragma mark - 加载过程的通知，子类重载进行特定操作
//-------------------------------------------------

//将要开始加载数据
- (BOOL)willStartLoadData:(BOOL)isUpdateData;
//开始加载数据失败（网络原因）
- (void)didStartLoadDataFail:(BOOL)isUpdateData;
//开始加载数据
- (void)didStartLoadData:(BOOL)isUpdateData;
//取消加载数据
- (void)willCancleLoadData:(BOOL)isUpdateData;
//结束加载数据
- (void)didEndLoadData:(BOOL)isUpdateData success:(BOOL)success;


#pragma mark - 加载指示视图
//-------------------------------------------------

//是否显示指示视图，默认为YES
- (BOOL)showIndicaterView;

//指示视图的状态
@property(nonatomic,readonly) MyIndicaterViewStatus indicaterViewStatus;

//更新指示视图
- (void)setNeedUpdateIndicaterView;
//更新指示视图，重载进行特定的显示
- (void)updateIndicaterViewWithStatus:(MyIndicaterViewStatus)status context:(id)context;

//更新视图当数据数目改变
- (void)updateViewWhenDatasCountDidChange;

#pragma mark - 数据筛选
//-------------------------------------------------

//数据筛选方式
@property(nonatomic) MyDatasFilterType datasFilterType;
//自定义筛选数据，当datasFilterType为ED_DatasFilterTypeCustom时会调用该方法进行数据筛选，默认不筛选
- (NSArray *)customFilterDatas:(NSArray *)datas baseCurrentDatas:(NSArray *)currentDatas;

//需要筛选的数据类别，返回nil则都需要筛选
- (Class)needFilterDataClass;

@end
