//
//  MyInfoCellController.h
//  
//
//  Created by LeslieChen on 15/3/24.
//  Copyright (c) 2015年 ED. All rights reserved.
//
//----------------------------------------------------------

#import "MyBasicInfoCell.h"
#import "MyInfoCellEditerProtocol.h"

//----------------------------------------------------------

@class MyInfoCellController;

//----------------------------------------------------------

//编辑的类型
typedef NS_ENUM(NSInteger,MyInfoCellEditType) {
    MyInfoCellEditTypeEditer,
    MyInfoCellEditTypeCell
};

//----------------------------------------------------------

//编辑的上下文
@interface MyInfoCellEditContext : NSObject

//编辑的类型
@property(nonatomic,readonly) MyInfoCellEditType editType;

@property(nonatomic,weak,readonly) id<MyInfoCellEditerProtocol> editer;
@property(nonatomic,strong,readonly) NSIndexPath * indexPath;
@property(nonatomic,strong,readonly) NSString * key;

//正在编辑的cell
@property(nonatomic,strong,readonly) MyBasicInfoCell * editingCell;

@end

//----------------------------------------------------------

@protocol MyInfoCellControllerDelegate < MyBasicInfoCellDelegate,
                                         MyInfoCellEditerDelegate,
                                         UIScrollViewDelegate >

@optional

- (CGFloat)infoCellController:(MyInfoCellController *)infoCellController heightForCustomCellAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)infoCellController:(MyInfoCellController *)infoCellController didSelectCustomCellAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)infoCellController:(MyInfoCellController *)infoCellController didSelectCellAtIndexPath:(NSIndexPath *)indexPath;


//显示viewController
- (void)infoCellController:(MyInfoCellController *)infoCellController shouldShowViewControllerForClass:(Class)viewControllerClass;
//打开URL
- (void)infoCellController:(MyInfoCellController *)infoCellController shouldOpenURL:(NSURL *)url;
//是否可以删除自定义cell，cell一定要在自定义section里面
- (BOOL)infoCellController:(MyInfoCellController *)infoCellController canDeleteCustomCellAtIndexPath:(NSIndexPath *)indexPath;

//删除按钮的标题
- (NSString *)infoCellController:(MyInfoCellController *)infoCellController titleForDeleteConfirmationButtonForCustomRowAtIndexPath:(NSIndexPath *)indexPath;


//将要开始编辑
- (BOOL)infoCellController:(MyInfoCellController *)infoCellController willBeginEditWithContext:(MyInfoCellEditContext *)editContext;
//已经开始编辑
- (void)infoCellController:(MyInfoCellController *)infoCellController didBeginEditWithContext:(MyInfoCellEditContext *)editContext;
////已经结束编辑
//- (void)infoCellController:(MyInfoCellController *)infoCellController didEndEditWithContext:(MyInfoCellEditContext *)editContext;


//将要改变值
- (BOOL)infoCellController:(MyInfoCellController *)infoCellController willEditToValue:(id)value forKey:(NSString *)key;
//已经改变值
- (void)infoCellController:(MyInfoCellController *)infoCellController didEditToValue:(id)value forKey:(NSString *)key;


@end

//----------------------------------------------------------

@protocol MyInfoCellControllerDataSource <NSObject>

@optional

- (NSInteger)infoCellController:(MyInfoCellController *)infoCellController numberOfCellAtCustomSection:(NSInteger)section;
- (UITableViewCell *)infoCellController:(MyInfoCellController *)infoCellController customCellAtIndexPath:(NSIndexPath *)indexPath;

- (NSDictionary *)infoCellController:(MyInfoCellController *)infoCellController infoCellInfoAtIndexPath:(NSIndexPath *)indexPath;

//点击了删除自定义cell
- (void)infoCellController:(MyInfoCellController *)infoCellController commitDeleteCustomCellAtIndexPath:(NSIndexPath *)indexPath;

//上下文
- (id)infoCellController:(MyInfoCellController *)infoCellController contextForCellAtIndexPath:(NSIndexPath *)indexPath;

@end

//----------------------------------------------------------

typedef void (^ConfigurationInfoCellBlock)(MyInfoCellController * cellController,NSIndexPath * indexPath,MyBasicInfoCell * cell);


//----------------------------------------------------------

@interface MyInfoCellController : NSObject

- (id)  initWithTableView:(UITableView *)tableView
    configurationFileName:(NSString *)fileName
                   bundle:(NSBundle *)bundleOrNil
       baseViewController:(UIViewController *)viewController;

- (id)initWithTableView:(UITableView *)tableView
        cellResuseInfos:(NSArray *)cellResuseInfos
              cellInfos:(NSArray *)cellInfos
              extraInfo:(NSDictionary *)extraInfo
     baseViewController:(UIViewController *)viewController;

//重新加载数据
- (void)reloadWithCellInfos:(NSArray *)cellInfos extraInfo:(NSDictionary *)extraInfo;

@property(nonatomic,weak,readonly) UIViewController * baseViewController;
@property(nonatomic,strong,readonly) UITableView * tableView;

@property(nonatomic,weak) id<MyInfoCellControllerDelegate> delegate;
@property(nonatomic,weak) id<MyInfoCellControllerDataSource> dataSource;


@property(nonatomic,strong,readonly) NSArray * cellInfos;
- (NSDictionary *)sectionInfoAtSection:(NSUInteger)section;
- (NSDictionary *)cellInfoAtIndexPath:(NSIndexPath *)indexPath;

//infoCell的内容
- (NSDictionary *)infoCellInfoAtIndexPath:(NSIndexPath *)indexPath;
//infoCell对应的key
- (NSString *)infoCellKeyAtIndexPath:(NSIndexPath *)indexPath;
//获取特定key的cell索引视图显示后才有效
- (NSIndexPath *)indexPathForCellWithKey:(NSString *)infoCellKey;


- (BOOL)isCustomCellAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isCustomSection:(NSUInteger)section;
- (NSArray *)customCellIndexPaths;
- (NSIndexSet *)customSections;

- (void)reloadCustomCells:(BOOL)animated;
- (void)reloadCustomSections:(BOOL)animated;
- (void)reloadAllCustomItems:(BOOL)animated;

//配置用的block
@property(nonatomic,copy) ConfigurationInfoCellBlock configurationBlock;

//更新值
- (void)setInfoValue:(id)value forKey:(NSString *)key;
- (void)setValuesForKeys:(NSDictionary *)valuesDic;
- (void)setValuesForKeys:(NSDictionary *)valuesDic reloadAllData:(BOOL)reloadAllData;

//删除值
- (void)removeValuesForKeys:(NSArray *)keys reloadAllData:(BOOL)reloadAllData;
- (void)removeAllValues;

//获取值
- (NSDictionary *)vaulesForKeys:(NSArray *)keys;
- (NSDictionary *)allVaules;
- (id)infoValueForKey:(NSString *)key;

//重新加载
- (void)reloadData;
//清空值
- (void)clearAllVaules;

//是否允许编辑，默认为YES
@property(nonatomic,getter=isEditabled) BOOL editable;

//编辑的上下文，没有编辑该值为nil
@property(nonatomic,strong,readonly) MyInfoCellEditContext * editerContext;
@property(nonatomic,readonly,getter=isEditting) BOOL editting;

//结束编辑
- (void)endEditWithAnimated:(BOOL)animated completedBlock:(void(^)(void))completedBlock;

@end
