//
//  MyContentViewCellController.m

//
//  Created by LeslieChen on 15/1/29.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyContentViewCellController.h"
#import "NSObject+ShowViewControllerDelegate.h"
#import "MyContentViewTableViewCell.h"
#import "MyContentViewCollectionViewCell.h"
#import "UICollectionView+register.h"
#import "UITableView+register.h"
#import "XYYCommonUtil.h"
#import "XYYBaseDef.h"
#import "MyPathManager.h"
#import "NSDictionary+MyCategory.h"
#import "UITableViewCell+ShowContent.h"

//----------------------------------------------------------

@interface MyContentViewCellController ()  < UITableViewDelegate,
                                             UITableViewDataSource,
                                             UICollectionViewDelegateFlowLayout,
                                             UICollectionViewDataSource,
                                             MyContentViewCellDelegate >

@end

//----------------------------------------------------------

@implementation MyContentViewCellController

//@synthesize cellOutletAllocator = _cellOutletAllocator;

#pragma mark -

#define defaultContentViewCellClass()  \
        ((self.tableView) ? [MyContentViewTableViewCell class] : [MyContentViewCollectionViewCell class])
#define sectionCells(sectionInfo)   \
        ((self.tableView) ? [sectionInfo rows] : [sectionInfo items])

#define contentViewCellClass(info)  \
        ((self.tableView) ? [info contentViewTableViewCellClass] : [info contentViewCollectionViewCellClass])
#define contentViewCellClassName(info)  \
        ((self.tableView) ? [info contentViewTableViewCellClassName] : [info contentViewCollectionViewCellClassName])

#pragma mark -

- (id)init {
    return [self initWithContentScrollView:nil cellResuseInfos:nil cellInfos:nil extraInfo:nil];
}


- (id)initWithContentScrollView:(UIScrollView *)contentScrollView
          configurationFileName:(NSString *)fileName
                         bundle:(NSBundle *)bundleOrNil
{
    NSDictionary * configurationInfo = [NSDictionary dictionaryWithContentsOfFile:PlistResourceFilePathInBundle(bundleOrNil,fileName)];
    
    return [self initWithContentScrollView:contentScrollView
                           cellResuseInfos:[configurationInfo cellResuseInfos]
                                 cellInfos:[configurationInfo cellInfos]
                                 extraInfo:[configurationInfo extraInfo]];
}

- (id)initWithContentScrollView:(UIScrollView *)contentScrollView
                cellResuseInfos:(NSArray *)cellResuseInfos
                      cellInfos:(NSArray *)cellInfos
                      extraInfo:(NSDictionary *)extraInfo
{
    self = [super init];
    
    if (self) {
        
        if (!contentScrollView) {
            _contentScrollView = _tableView =[[UITableView alloc] init];
        }else {
            _tableView = ConvertToClassPointer(UITableView, contentScrollView);
            _collectionView = ConvertToClassPointer(UICollectionView, contentScrollView);
            
            if (!_tableView && !_collectionView) {
                @throw [NSException exceptionWithName:NSInvalidArgumentException
                                               reason:@"contentScrollView必须为UITableView或UICollectionView及其子类的实例"
                                             userInfo:nil];
            }
            
            _contentScrollView = contentScrollView;
        }

        //设置代理和数据源
        [_contentScrollView performSelector:@selector(setDelegate:) withObject:self];
        [_contentScrollView performSelector:@selector(setDataSource:) withObject:self];
        
    
        //注册复用
        
        //默认复用cell
        if (_tableView) {
            [_tableView registerClass:[MyContentViewTableViewCell class] forCellReuseIdentifier:defaultReuseDef];
        }else {
            [_collectionView registerClass:[MyContentViewCollectionViewCell class] forCellWithReuseIdentifier:defaultReuseDef];
        }
        
        //用户自定义复用cell
        for (NSDictionary * info in cellResuseInfos) {
            
            NSString * reuseIdentifier = [info reuseIdentifier];
            Class cellClass = NSClassFromString([info cellClassName]);
            NSString * nibName = [info cellNibName];
            
            if (!cellClass && reuseIdentifier.length) {
                cellClass = defaultContentViewCellClass();
            }

            if (_tableView) {
                
                if ([cellClass isSubclassOfClass:[UITableViewCell class]]) {
                    [_tableView registerCellWithClass:cellClass nibNameOrNil:nibName bundleOrNil:nil andReuseIdentifier:reuseIdentifier];
                }
                
            }else {
                
                if ([cellClass isSubclassOfClass:[UICollectionViewCell class]]) {
                    [_collectionView registerCellWithClass:cellClass nibNameOrNil:nibName bundleOrNil:nil andReuseIdentifier:reuseIdentifier];
                }
            }
        }
        
        _cellInfos = cellInfos;
        _extraInfo = extraInfo;
        
    }
    
    return self;
}

#pragma mark -

- (void)reloadWithCellInfos:(NSArray *)cellInfos extraInfo:(NSDictionary *)extraInfo
{
    _cellInfos = cellInfos;
    _extraInfo = extraInfo;
    
    [self reloadData];
}

- (NSDictionary *)sectionInfoAtSection:(NSUInteger)section {
    return self.cellInfos[section];
}

- (NSDictionary *)cellInfoAtIndexPath:(NSIndexPath *)indexPath {
    return [sectionCells([self sectionInfoAtSection:indexPath.section]) objectAtIndex:indexPath.row];
}

#pragma mark -

- (BOOL)isCustomCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * sectionInfo = [self sectionInfoAtSection:indexPath.section];
    
    if ([sectionInfo isCustom]) {
        return YES;
    }else{
        
        NSDictionary * cellInfo = [self cellInfoAtIndexPath:indexPath];
        if ([cellInfo isCustom]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isCustomSection:(NSUInteger)section {
    return [[self sectionInfoAtSection:section] isCustom];
}

- (NSArray *)customCellIndexPaths
{
    NSMutableArray *  customCellIndexPaths = [NSMutableArray array];
    
    NSInteger section = 0;
    for (NSDictionary * sectionInfo in self.cellInfos) {
    
        if (![sectionInfo isCustom]) {
    
            //获取该section所有cell单元信息
            NSArray * cells = sectionCells(sectionInfo);
            
            NSInteger row = 0;
            for (NSDictionary * cellInfo in cells) {
                if ([cellInfo isCustom]) {
                    [customCellIndexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
                }
                ++ row;
            }
        }
        ++ section;
    }
    
    return customCellIndexPaths;
}

- (NSIndexSet *)customSections
{
    NSMutableIndexSet * customSections = [NSMutableIndexSet indexSet];
    
    NSInteger section = 0;
    for (NSDictionary * sectionInfo in self.cellInfos) {
        
        if ([sectionInfo isCustom]) {
            [customSections addIndex:section];
        }
        ++ section;
    }
    
    return customSections;
}

#pragma mark -

- (void)reloadData {
    [self.contentScrollView performSelector:@selector(reloadData)];
}

- (void)reloadCustomCells:(BOOL)animated
{
    if (self.tableView) {
        [self.tableView reloadRowsAtIndexPaths:[self customCellIndexPaths]
                              withRowAnimation:animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone];
    }else {
        [self.collectionView reloadItemsAtIndexPaths:[self customCellIndexPaths]];
    }
}

- (void)reloadCustomSections:(BOOL)animated
{
    if (self.tableView) {
        [self.tableView reloadSections:[self customSections]
                      withRowAnimation:animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone];
    }else {
        [self.collectionView reloadSections:[self customSections]];
    }
}

- (void)reloadAllCustomItems:(BOOL)animated
{
    if (self.tableView) {
        
        [self.tableView beginUpdates];
        [self reloadCustomSections:animated];
        [self reloadCustomCells:animated];
        [self.tableView endUpdates];
        
    }else{
        
        [self.collectionView performBatchUpdates:^{
            [self reloadCustomSections:animated];
            [self reloadCustomCells:animated];
        } completion:nil];
    }
}

#pragma mark - 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cellInfos.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.cellInfos.count;
}

- (NSInteger)_numberOfCellAtSection:(NSInteger)section
{
    NSInteger cellCount = 0;
    
    NSDictionary * sectionInfo = [self sectionInfoAtSection:section];
    
    //自定义单元
    if ([sectionInfo isCustom]) {
        
        id<MyContentViewCellControllerDataSource> dataSource = self.dataSource;
        ifRespondsSelector(dataSource, @selector(contentViewCellController:numberOfCellAtCustomSection:)){
            cellCount = [dataSource contentViewCellController:self numberOfCellAtCustomSection:section];
        }
        
    }else {
        cellCount = [sectionCells(sectionInfo) count];
    }
    
    return cellCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self _numberOfCellAtSection:section];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self _numberOfCellAtSection:section];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return [[self sectionInfoAtSection:section] minimumInteritemSpacing:[(UICollectionViewFlowLayout *)collectionViewLayout minimumInteritemSpacing]];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return [[self sectionInfoAtSection:section] minimumLineSpacing:[(UICollectionViewFlowLayout *)collectionViewLayout minimumLineSpacing]];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return [[self sectionInfoAtSection:section] sectionInset:[(UICollectionViewFlowLayout *)collectionViewLayout sectionInset]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.style == UITableViewStylePlain) {
        return 0.f;
    }else {
        return [[self sectionInfoAtSection:section] sectionHeaderHeight:tableView.sectionHeaderHeight];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (tableView.style == UITableViewStylePlain) {
        return 0.f;
    }else {
        return [[self sectionInfoAtSection:section] sectionFooterHeight:tableView.sectionFooterHeight];
    }
}

- (CGSize)_sizeForCustomCellAtIndexPath:(NSIndexPath *)indexPath
{
    MyAssert([self isCustomCellAtIndexPath:indexPath]);
    
    id<MyContentViewCellControllerDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(contentViewCellController:sizeForCustomCellAtIndexPath:)){
        return [delegate contentViewCellController:self sizeForCustomCellAtIndexPath:indexPath];
    }else{
        return self.tableView ? CGSizeMake(0.f, self.tableView.rowHeight) : [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout itemSize];
    }
}

- (NSDictionary *)contentViewCellInfoAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isCustomCellAtIndexPath:indexPath]) {
        return nil;
    }else {
        return [self _contentViewCellInfoAtIndexPath:indexPath];
    }
}

- (NSDictionary *)_contentViewCellInfoAtIndexPath:(NSIndexPath *)indexPath
{
    //添加扩展消息
    NSMutableDictionary * cellInfo = [NSMutableDictionary dictionaryWithDictionary:self.extraInfo];
    [cellInfo addEntriesFromDictionary:[self.cellInfos[indexPath.section] extraInfo]];
    
    //添加cellInfo
    [cellInfo addEntriesFromDictionary:[self cellInfoAtIndexPath:indexPath]];
    
    return cellInfo;
}

- (MyCellContext *)contextForContentViewCellAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isCustomCellAtIndexPath:indexPath]) {
        return nil;
    }else {
        return [self _contextForContentViewCellAtIndexPath:indexPath];
    }
}

- (MyCellContext *)_contextForContentViewCellAtIndexPath:(NSIndexPath *)indexPath
{
    id context = nil;
    id<MyContentViewCellControllerDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(contentViewCellController:contextForCellAtIndexPath:)){
        context = [delegate contentViewCellController:self contextForCellAtIndexPath:indexPath];
    }
    
    return [[MyCellContext alloc] initWithIndexPath:indexPath
                                 totalInfoIndexPath:[NSIndexPath indexPathForItem:[self _numberOfCellAtSection:indexPath.section] - 1 inSection:self.cellInfos.count - 1]
                                            context:context];
}

- (Class)contentViewCellClassAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isCustomCellAtIndexPath:indexPath]) {
        return nil;
    }else {
        return [self _contentViewCellClassAtIndexPath:indexPath];
    }
}

- (Class)_contentViewCellClassAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * cellInfo = [self _contentViewCellInfoAtIndexPath:indexPath];
    Class cellClass = contentViewCellClass(cellInfo);
    
    return cellClass ?: defaultContentViewCellClass();
}

- (NSString *)_reuseIdentifierForCellAtIndexPath:(NSIndexPath *)indexPath
{
    MyAssert(![self isCustomCellAtIndexPath:indexPath]);
    
    NSDictionary * cellInfo = [self _contentViewCellInfoAtIndexPath:indexPath];
    NSString * reuseIdentifier = [cellInfo reuseIdentifier];
    
    //使用默认的复用定义
    if (!reuseIdentifier.length) {
        Class cellClass = contentViewCellClass(cellInfo);
        reuseIdentifier = cellClass ? [cellClass defaultReuseIdentifier] : defaultReuseDef;
    }
    
    return reuseIdentifier;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MyContentViewCellControllerDelegate> delegate = self.delegate;
    
    //首先判断是否需要返回自定义尺寸
    BOOL bRet = YES;
    ifRespondsSelector(delegate, @selector(contentViewCellController:needSizeForCellAtIndexPath:)) {
        bRet = [delegate contentViewCellController:self needSizeForCellAtIndexPath:indexPath];
    }
    
    //返回自定义尺寸
    if (bRet &&
        [delegate respondsToSelector:@selector(contentViewCellController:sizeForCellAtIndexPath:)]) {
        
        return [delegate contentViewCellController:self sizeForCellAtIndexPath:indexPath].height;
        
    }else if (![self isCustomCellAtIndexPath:indexPath]) {
        
        Class cellClass = [self _contentViewCellClassAtIndexPath:indexPath];
        return  [cellClass heightForCellWithInfo:[self _contentViewCellInfoAtIndexPath:indexPath]
                                       tableView:tableView
                                         context:[self _contextForContentViewCellAtIndexPath:indexPath]];
        
    }else {
        return [self _sizeForCustomCellAtIndexPath:indexPath].height;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<MyContentViewCellControllerDelegate> delegate = self.delegate;
    
    //首先判断是否需要返回自定义尺寸
    BOOL bRet = YES;
    ifRespondsSelector(delegate, @selector(contentViewCellController:needSizeForCellAtIndexPath:)) {
        bRet = [delegate contentViewCellController:self needSizeForCellAtIndexPath:indexPath];
    }
    
    //返回自定义尺寸
    if (bRet &&
        [delegate respondsToSelector:@selector(contentViewCellController:sizeForCellAtIndexPath:)]) {
        
        return [delegate contentViewCellController:self sizeForCellAtIndexPath:indexPath];
        
    }else if (![self isCustomCellAtIndexPath:indexPath]) {
        
        Class cellClass = [self _contentViewCellClassAtIndexPath:indexPath];
        return  [cellClass sizeForCellWithInfo:[self _contentViewCellInfoAtIndexPath:indexPath]
                             containerViewSize:collectionView.bounds.size
                                       context:[self _contextForContentViewCellAtIndexPath:indexPath]];
        
    }else {
        return [self _sizeForCustomCellAtIndexPath:indexPath];
    }
}

- (id)_customCellAtIndexPath:(NSIndexPath *)indexPath
{
     MyAssert([self isCustomCellAtIndexPath:indexPath]);
    
    id<MyContentViewCellControllerDataSource> dataSource = self.dataSource;
    ifRespondsSelector(dataSource, @selector(contentViewCellController:customCellAtIndexPath:)){
        return [dataSource contentViewCellController:self customCellAtIndexPath:indexPath];
    }else{
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self isCustomCellAtIndexPath:indexPath]) {
        
        //复用定义
        NSString * reuseIdentifier = [self _reuseIdentifierForCellAtIndexPath:indexPath];
        MyAssert(reuseIdentifier.length != 0);
        
        //获取实例
        MyContentViewTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier
                                                                            forIndexPath:indexPath];

        //核对cell
        if (![cell isMemberOfClass:[self _contentViewCellClassAtIndexPath:indexPath]]) {
            @throw [[NSException alloc] initWithName:NSInternalInconsistencyException
                                              reason:@"UITableViewCell类与reuseIdentifier匹配有误,请检查配置文件"
                                            userInfo:nil];
        }
        
        //设置代理
        cell.delegate = self.delegate ?: (id<MyContentViewCellDelegate>)self;
        
        //更新消息
        [cell updateCellWithInfo:[self _contentViewCellInfoAtIndexPath:indexPath] context:[self _contextForContentViewCellAtIndexPath:indexPath]];
        
        //配置block
        if (self.configurationBlock) {
            self.configurationBlock(self,indexPath,cell);
        }
        
        return cell;
        
    }else{
       return [self _customCellAtIndexPath:indexPath];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self isCustomCellAtIndexPath:indexPath]) {
        
        //复用定义
        NSString * reuseIdentifier = [self _reuseIdentifierForCellAtIndexPath:indexPath];
        MyAssert(reuseIdentifier.length != 0);
        
        //获取实例
        MyContentViewCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        
        //核对信息
        if (![cell isMemberOfClass:[self _contentViewCellClassAtIndexPath:indexPath]]) {
            @throw [[NSException alloc] initWithName:NSInternalInconsistencyException
                                              reason:@"UICollectionViewCell类与reuseIdentifier匹配有误,请检查配置文件"
                                            userInfo:nil];
        }
        
        //代理
        cell.delegate = self.delegate ?: (id<MyContentViewCellDelegate>)self;
        
        //更新
        [cell updateCellWithInfo:[self _contentViewCellInfoAtIndexPath:indexPath] context:[self _contextForContentViewCellAtIndexPath:indexPath]];
        
        //配置block
        if (self.configurationBlock) {
            self.configurationBlock(self,indexPath,cell);
        }
        
        return cell;
    }else{
        
        //自定义
        return [self _customCellAtIndexPath:indexPath];
    }
}

- (BOOL)_didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL selected = NO;
    id<MyContentViewCellControllerDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(contentViewCellController:didSelectCellAtIndexPath:)){
        selected = [delegate contentViewCellController:self didSelectCellAtIndexPath:indexPath];
    }

    return selected;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self _didSelectCellAtIndexPath:indexPath]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self _didSelectCellAtIndexPath:indexPath]) {
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark -

- (void)setDelegate:(id<MyContentViewCellControllerDelegate>)delegate
{
    if (_delegate != delegate) {
        _delegate = delegate;
        
        //更新代理（contentScrollView内部实现上会在设置代理时通过判断代理是否实现某些方法来设置某些方法是否回调）
        [self.contentScrollView performSelector:@selector(setDelegate:) withObject:nil];
        [self.contentScrollView performSelector:@selector(setDelegate:) withObject:self];
    }
}

#pragma mark - 滑动视图代理消息转发

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

#pragma mark -

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isCustomSection:indexPath.section]) {
        id<MyContentViewCellControllerDelegate> delegate = self.delegate;
        ifRespondsSelector(delegate, @selector(contentViewCellController:canDeleteCustomCellAtIndexPath:)) {
            if ([delegate contentViewCellController:self canDeleteCustomCellAtIndexPath:indexPath]) {
                return UITableViewCellEditingStyleDelete;
            }
        }
    }
    
    return UITableViewCellEditingStyleNone;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isCustomSection:indexPath.section]) {
        id<MyContentViewCellControllerDelegate> delegate = self.delegate;
        ifRespondsSelector(delegate, @selector(contentViewCellController:titleForDeleteConfirmationButtonForCustomRowAtIndexPath:)) {
            return [delegate contentViewCellController:self titleForDeleteConfirmationButtonForCustomRowAtIndexPath:indexPath];
        }
    }
    
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([self isCustomSection:indexPath.section]) {
            
            id<MyContentViewCellControllerDataSource> dataSource = self.dataSource;
            ifRespondsSelector(dataSource, @selector(contentViewCellController:commitDeleteCustomCellAtIndexPath:)) {
                return [dataSource contentViewCellController:self commitDeleteCustomCellAtIndexPath:indexPath];
            }
        }
    }
}

@end

//----------------------------------------------------------

@implementation NSDictionary (MyContentViewCellController)

- (NSArray *)cellInfos {
    return [self valueForKey:@"cellInfos" withClass:[NSArray class]];
}
- (NSArray *)cellResuseInfos {
    return [self valueForKey:@"cellResuseInfos" withClass:[NSArray class]];
}
- (NSDictionary *)extraInfo {
    return [self valueForKey:@"extraInfo" withClass:[NSDictionary class]];
}


- (NSString *)cellClassName {
    return [self stringValueForKey:@"cellClass"];
}
- (NSString *)reuseIdentifier {
    return [self stringValueForKey:@"reuseIdentifier"];
}
- (NSString *)cellNibName {
    return [self stringValueForKey:@"nibName"];
}

- (BOOL)isCustom {
    return [self boolValueForKey:@"isCustom" defaultValue:NO];
}

@end

