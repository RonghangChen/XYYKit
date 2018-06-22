//
//  MyScrollContentPageCell.h
//  
//
//  Created by 陈荣航 on 16/3/16.
//  Copyright © 2016年 ED. All rights reserved.
//

//-------------------------------------------------

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "MyRefreshControl.h"
#import "XYYCommonUtil.h"
#import "MyNetReachability.h"

//-------------------------------------------------

/**
 * 数据仓库类型，自定义的类型大于0
 */
typedef NS_ENUM(NSInteger, MyDataStoreType) {
    MyDataStoreTypeNone      =  0,  //无
    MyDataStoreTypeTemp      = -1,  //临时文件
    MyDataStoreTypeDocuments = -2,  //文档
};

//-------------------------------------------------

//分页视图的上下文
@protocol MyScrollContentPageCellContext <NSObject>

//是否需要更新数据
@property(nonatomic,readonly) BOOL needUpdateData;
//内容的偏移量
@property(nonatomic,readonly) CGPoint contentOffset;

//扩展的上下文
@property(nonatomic,strong) id extendContext;

@end

//-------------------------------------------------

//分页视图默认的上下文
@interface MyScrollContentPageCellDefaultContxt : NSObject <MyScrollContentPageCellContext>

- (id)initWithNeedUpdateData:(BOOL)needUpdateData
               contentOffset:(CGPoint)contentOffset
               extendContext:(id)extendContext;


@end

//-------------------------------------------------

@interface MyScrollContentPageCell : UICollectionViewCell < UITableViewDataSource,
                                                            UITableViewDelegate,
                                                            UICollectionViewDelegateFlowLayout,
                                                            UICollectionViewDataSource >

#pragma mark -
//-------------------------------------------------

//内容视图
@property(nonatomic,strong,readonly) UIView * myContentView;

//顶端附加视图的高度，改变该值后需要调用reloadViews来使该值生效
- (CGFloat)topExtentViewHeight;
//顶端的附加视图，在上面添加附加视图`
@property(nonatomic,strong,readonly) UIView * topExtentView;

//重新加载view，当topExtentViewHeight
- (void)reloadViews;

//返回contentScorllView的初始化contentInset,从子类重载改变其值
- (UIEdgeInsets)contentScorllViewInitContentInset;
- (UIEdgeInsets)contentScorllViewContentInset;

//返回contentScorllView的初始化scorllInitIndicatorInsets,默认返回contentScorllViewInitContentInset,从子类重载改变其值
- (UIEdgeInsets)contentScorllViewInitScorllIndicatorInsets;
- (UIEdgeInsets)contentScorllViewScorllIndicatorInsets;

//内容滑动视图
@property(nonatomic,weak) UIScrollView * contentScrollView;

//更新视图
- (void)updateViewForSafeAreaInsetsDidChange;

#pragma mark -
//-------------------------------------------------

//内容视图
@property(nonatomic,strong) UITableView * contentTableView;
@property(nonatomic,strong) UICollectionView * contentCollectionView;

/**
 * 刷新控件的引用，请将其加入UIScrollView或者其子类视图中使用
 */
@property(nonatomic,strong,readonly) MyRefreshControl *refreshControl;

/*
 *刷新处理函数，不要手动调用，请从子类覆盖该函数以完成所需操作
 */
- (void)refreshHandle;

/**
 * 加载控件的引用，请将其加入UIScrollView或者其子类视图中使用
 */
@property(nonatomic,strong,readonly) MyRefreshControl *loadControl;

/**
 * 加载处理函数，不要手动调用，请从子类覆盖该函数以完成所需操作
 */
- (void)loadHandle;

#pragma mark -
//-------------------------------------------------

//活动指示器视图
@property(nonatomic,readonly,strong) MBProgressHUD * progressIndicatorView;

//显示进度指示视图
- (void)showProgressIndicatorViewWithAnimated:(BOOL)animated title:(NSString *)title;

//隐藏进度指示视图
- (void)hideProgressIndicatorViewWithAnimated:(BOOL)animated completedBlock:(void(^)(void))completedBlock;

#pragma mark -
//-------------------------------------------------

//是否监听网络改变,默认为NO
@property(nonatomic) BOOL needObserveNetworkStatusChange;

//获取当前网络状况
- (NetworkStatus)currentNetworkStatus;
//当前网络是否可用
- (BOOL)currentNetworkAvailable:(BOOL)showMSgWhenNoNetwork;

//网络状况改变通知
- (void)networkStatusChangeHandle;

#pragma mark - 数据储存
//-------------------------------------------------

//设置某一key标识的数据需要被储存
- (void)setNeedSavaDataForKey:(NSString *)key;

//立即缓存数据如果需要
- (void)saveDatasIfNeeded;

//储存某一key的数据，调用了setNeedSavaDataForKey方法后，默认实现是通过needSaveDataForKey方法返回需要储存的数据并储存到默认的仓库,不要手动调用该方法
- (void)saveDataForKey:(NSString *)key;

//返回标识为key的需要储存的数据,默认返回nil
- (id)needSaveDataForKey:(NSString *)key;
//返回存储数据默认的仓库类型
- (MyDataStoreType)dataStoreTypeForSavaDateWithKey:(NSString *)key;

//返回存储的数据
- (id)getDataSavedInStore:(MyDataStoreType)dataStoreType withKey:(NSString *)key;

//自定义类型储存，重载实现
- (void)saveData:(id)data toCustomDataStore:(MyDataStoreType)dataStoreType withKey:(NSString *)key;
//获取自定义类型储存，重载实现
- (id)getDataSavedInCustomStore:(MyDataStoreType)dataStoreType withKey:(NSString *)key;


#pragma mark - 上下文
//-------------------------------------------------

//通过上下文进行更新
- (void)updateWithContext:(id<MyScrollContentPageCellContext>)context;
//更新视图（重载）
- (void)updateViewWithContext:(id<MyScrollContentPageCellContext>)context;

//是否需要更新数据
- (BOOL)needUpdateDataForContext:(id<MyScrollContentPageCellContext>)context;

//返回通过上下文生成的内容偏移，重载进行自定义
- (CGPoint)contentOffsetForContext:(id<MyScrollContentPageCellContext>)context;

//获取初当前页面的上下文
- (id<MyScrollContentPageCellContext>)currentPageContext;

//自定义的上下文
@property(nonatomic,strong) id extendContext;

#pragma mark - 其他
//-------------------------------------------------

//尝试更新数据
- (void)tryRefreshData;

//开始更新数据
- (void)startUpdateData;

//是否正在更新数据
@property(nonatomic,readonly,getter=isUpdatingData) BOOL updatingData;

#pragma mark - 消息转发
//-------------------------------------------------

//返回消息aSelector转发的对象
- (id)myForwardingTargetForSelector:(SEL)aSelector;

@end
