//
//  MyContentViewCellController.h

//
//  Created by LeslieChen on 15/1/29.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "NSObject+ShowViewControllerDelegate.h"
#import "MyContentViewCellProtocol.h"

//----------------------------------------------------------

@class MyContentViewCellController;

//----------------------------------------------------------

@protocol MyContentViewCellControllerDelegate < UIScrollViewDelegate,
                                                MyContentViewCellDelegate >

@optional

//是否需要自定义尺寸，不实现或者返回YES则会通过sizeForCellAtIndexPath返回尺寸
- (BOOL)contentViewCellController:(MyContentViewCellController *)contentViewCellController
       needSizeForCellAtIndexPath:(NSIndexPath *)indexPath;

//cell尺寸，如果实现该方法其他返回尺寸方法将失效，以该方法值为准
- (CGSize)contentViewCellController:(MyContentViewCellController *)contentViewCellController
             sizeForCellAtIndexPath:(NSIndexPath *)indexPath;

//自定义cell尺寸
- (CGSize)contentViewCellController:(MyContentViewCellController *)contentViewCellController
        sizeForCustomCellAtIndexPath:(NSIndexPath *)indexPath;

//返回上下文
- (id)contentViewCellController:(MyContentViewCellController *)contentViewCellController
      contextForCellAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)contentViewCellController:(MyContentViewCellController *)contentViewCellController
         didSelectCellAtIndexPath:(NSIndexPath *)indexPath;


//是否可以删除自定义cell，cell一定要在自定义section里面
- (BOOL)contentViewCellController:(MyContentViewCellController *)contentViewCellController canDeleteCustomCellAtIndexPath:(NSIndexPath *)indexPath;

//删除按钮的标题
- (NSString *)contentViewCellController:(MyContentViewCellController *)contentViewCellController titleForDeleteConfirmationButtonForCustomRowAtIndexPath:(NSIndexPath *)indexPath;


@end

//----------------------------------------------------------

@protocol MyContentViewCellControllerDataSource <NSObject>

@optional

- (NSInteger)contentViewCellController:(MyContentViewCellController *)contentViewCellController
                 numberOfCellAtCustomSection:(NSInteger)section;

- (id)contentViewCellController:(MyContentViewCellController *)contentViewCellController
          customCellAtIndexPath:(NSIndexPath *)indexPath;

//点击了删除自定义cell
- (void)contentViewCellController:(MyContentViewCellController *)contentViewCellController commitDeleteCustomCellAtIndexPath:(NSIndexPath *)indexPath;

@end


//----------------------------------------------------------

typedef void (^ConfigurationContentViewCellBlock)(MyContentViewCellController * cellController,
                                                  NSIndexPath * indexPath,
                                                  id cell);

//----------------------------------------------------------

@interface MyContentViewCellController : NSObject 

- (id)initWithContentScrollView:(UIScrollView *)contentScrollView
          configurationFileName:(NSString *)fileName
                         bundle:(NSBundle *)bundleOrNil;

- (id)initWithContentScrollView:(UIScrollView *)contentScrollView
                cellResuseInfos:(NSArray *)cellResuseInfos
                      cellInfos:(NSArray *)cellInfos
                      extraInfo:(NSDictionary *)extraInfo;

@property(nonatomic,strong,readonly) UIScrollView * contentScrollView;
@property(nonatomic,strong,readonly) UITableView * tableView;
@property(nonatomic,strong,readonly) UICollectionView * collectionView;

//重新加载数据
- (void)reloadWithCellInfos:(NSArray *)cellInfos extraInfo:(NSDictionary *)extraInfo;

@property(nonatomic,strong,readonly) NSArray * cellInfos;
@property(nonatomic,strong,readonly) NSDictionary * extraInfo;

- (NSDictionary *)sectionInfoAtSection:(NSUInteger)section;
- (NSDictionary *)cellInfoAtIndexPath:(NSIndexPath *)indexPath;

//内容cell信息（加入扩展信息）
- (NSDictionary *)contentViewCellInfoAtIndexPath:(NSIndexPath *)indexPath;
//内容cell的类型
- (Class)contentViewCellClassAtIndexPath:(NSIndexPath *)indexPath;
//内容cell的上下文
- (MyCellContext *)contextForContentViewCellAtIndexPath:(NSIndexPath *)indexPath;


- (BOOL)isCustomCellAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isCustomSection:(NSUInteger)section;
- (NSArray *)customCellIndexPaths;
- (NSIndexSet *)customSections;

- (void)reloadData;
- (void)reloadCustomCells:(BOOL)animated;
- (void)reloadCustomSections:(BOOL)animated;
- (void)reloadAllCustomItems:(BOOL)animated;

//配置用的block
@property(nonatomic,copy) ConfigurationContentViewCellBlock configurationBlock;

//代理和数据源
@property(nonatomic,weak) id<MyContentViewCellControllerDelegate> delegate;
@property(nonatomic,weak) id<MyContentViewCellControllerDataSource> dataSource;

@end

//----------------------------------------------------------


@interface NSDictionary (MyContentViewCellController)

//cell的信息
- (NSArray *)cellInfos;
//cell的复用信息
- (NSArray *)cellResuseInfos;
//额外扩展信息
- (NSDictionary *)extraInfo;

//cell的类名
- (NSString *)cellClassName;
//复用定义
- (NSString *)reuseIdentifier;
//nib文件名字
- (NSString *)cellNibName;

//是否是自定义的
- (BOOL)isCustom;

@end
