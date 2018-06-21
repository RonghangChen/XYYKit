//
//  MyInfoCellController.m
//  
//
//  Created by LeslieChen on 15/3/24.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyInfoCellController.h"
#import "MyContentViewCellController.h"
#import "NSDictionary+MyBasicInfoCell.h"
#import "MyPathManager.h"
#import "XYYBaseDef.h"
#import "XYYCommonUtil.h"
#import "NSDictionary+MyCategory.h"
#import "UIViewController+Instance.h"

//----------------------------------------------------------

@interface MyInfoCellEditContext ()

- (id)initWithEditer:(id<MyInfoCellEditerProtocol>)editer forCellAtIndexPath:(NSIndexPath *)indexPath key:(NSString *)key;
- (id)initWithCell:(MyBasicInfoCell *)editingCell atIndexPath:(NSIndexPath *)indexPath key:(NSString *)key;

@end

//----------------------------------------------------------

@implementation MyInfoCellEditContext

- (id)initWithEditer:(id<MyInfoCellEditerProtocol>)editer forCellAtIndexPath:(NSIndexPath *)indexPath key:(NSString *)key
{
    self = [super init];
    if (self) {
        _editer = editer;
        _indexPath = indexPath;
        _editType = MyInfoCellEditTypeEditer;
        _key = key;
    }
    
    return self;
}

- (id)initWithCell:(MyBasicInfoCell *)editingCell atIndexPath:(NSIndexPath *)indexPath key:(NSString *)key
{
    self = [super init];
    if (self) {
        _editingCell = editingCell;
        _indexPath = indexPath;
        _editType = MyInfoCellEditTypeCell;
        _key = key;
    }
    
    return self;
}

@end

//----------------------------------------------------------

@interface MyInfoCellController () < MyContentViewCellControllerDelegate,
                                     MyContentViewCellControllerDataSource,
                                     MyBasicInfoCellEditerDelegate,
                                     MyInfoCellEditerEditerDelegate >

@property(nonatomic,strong) MyContentViewCellController * contentViewCellController;

@property(nonatomic,strong,readonly) NSMutableDictionary * valuesDic;
@property(nonatomic,strong,readonly) NSMutableDictionary * keysToIndexPathsMap;

@end

//----------------------------------------------------------

@implementation MyInfoCellController

@synthesize valuesDic = _valuesDic;
@synthesize keysToIndexPathsMap = _keysToIndexPathsMap;

- (id)init
{
    @throw [[NSException alloc] initWithName:@"方法调用错误"
                                      reason:@"MyContentViewCellController不支持无参数初始化"
                                    userInfo:nil];
}

- (id)  initWithTableView:(UITableView *)tableView
    configurationFileName:(NSString *)fileName
                   bundle:(NSBundle *)bundleOrNil
       baseViewController:(UIViewController *)viewController
{
    NSDictionary * configurationInfo = [NSDictionary dictionaryWithContentsOfFile:PlistResourceFilePathInBundle(bundleOrNil,fileName)];
    
    return [self initWithTableView:tableView
                   cellResuseInfos:[configurationInfo cellResuseInfos]
                         cellInfos:[configurationInfo cellInfos]
                         extraInfo:[configurationInfo extraInfo]
                baseViewController:viewController];
}

- (id)initWithTableView:(UITableView *)tableView
        cellResuseInfos:(NSArray *)cellResuseInfos
              cellInfos:(NSArray *)cellInfos
              extraInfo:(NSDictionary *)extraInfo
     baseViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {

        _baseViewController = viewController;
        _editable = YES;
        
        _contentViewCellController = [[MyContentViewCellController alloc] initWithContentScrollView:tableView cellResuseInfos:cellResuseInfos cellInfos:cellInfos extraInfo:extraInfo];
        
        _contentViewCellController.delegate = self;
        _contentViewCellController.dataSource = self;
        
        typeof(self) __weak weak_self = self;
        _contentViewCellController.configurationBlock = ^(MyContentViewCellController * cellController, NSIndexPath * indexPath, id cell) {
            
            typeof(self) _self = weak_self;
            if (![cell isKindOfClass:[MyBasicInfoCell class]]) {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                               reason:@"非custom的cell必须为MyBasicInfoCell及其子类"
                                             userInfo:nil];
            }
            
            [_self _updateCell:cell atIndexPath:indexPath];
            if(_self.configurationBlock) {
                _self.configurationBlock(_self,indexPath,cell);
            }
        };
        
    }
    
    return self;
}

- (void)reloadWithCellInfos:(NSArray *)cellInfos extraInfo:(NSDictionary *)extraInfo
{
    //结束编辑
    [self endEditWithAnimated:NO completedBlock:nil];
    
    //更新数据
    [_keysToIndexPathsMap removeAllObjects];
//    [_valuesDic removeAllObjects];
    [self.contentViewCellController reloadWithCellInfos:cellInfos extraInfo:extraInfo];
}

#pragma mark -

- (void)_updateCell:(MyBasicInfoCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MyCellContext * context = [self.contentViewCellController contextForContentViewCellAtIndexPath:indexPath];
    NSDictionary * info = [self infoCellInfoAtIndexPath:indexPath];
    
    //记录key所在cell的索引信息
    NSString * cellKey = [info infoCellKey];
    if (cellKey) {
        self.keysToIndexPathsMap[cellKey] = indexPath;
    }
    
    cell.delegate = self.delegate;
    cell.editerDelegate = self;
    [cell updateWithInfoCellInfo:info value:cellKey ? self.valuesDic[cellKey] : nil editable:self.editable context:context];
}

#pragma mark -

- (UITableView *)tableView {
    return [self.contentViewCellController tableView];
}

- (NSArray *)cellInfos {
    return self.contentViewCellController.cellInfos;
}
- (NSDictionary *)sectionInfoAtSection:(NSUInteger)section {
    return [self.contentViewCellController sectionInfoAtSection:section];
}
- (NSDictionary *)cellInfoAtIndexPath:(NSIndexPath *)indexPath {
    return [self.contentViewCellController cellInfoAtIndexPath:indexPath];
}

- (BOOL)isCustomCellAtIndexPath:(NSIndexPath *)indexPath {
    return [self.contentViewCellController isCustomCellAtIndexPath:indexPath];
}
- (BOOL)isCustomSection:(NSUInteger)section {
    return [self.contentViewCellController isCustomSection:section];
}
- (NSArray *)customCellIndexPaths {
    return [self.contentViewCellController customCellIndexPaths];
}
- (NSIndexSet *)customSections {
    return [self.contentViewCellController customSections];
}

- (void)reloadCustomCells:(BOOL)animated {
    [self.contentViewCellController reloadCustomCells:animated];
}
- (void)reloadCustomSections:(BOOL)animated {
    [self.contentViewCellController reloadCustomSections:animated];
}
- (void)reloadAllCustomItems:(BOOL)animated {
    [self.contentViewCellController reloadAllCustomItems:animated];
}

#pragma mark -

- (NSInteger)contentViewCellController:(MyContentViewCellController *)contentViewCellController
           numberOfCellAtCustomSection:(NSInteger)section
{
    id<MyInfoCellControllerDataSource> dataSource = self.dataSource;
    ifRespondsSelector(dataSource, @selector(infoCellController:numberOfCellAtCustomSection:)){
        return [dataSource infoCellController:self numberOfCellAtCustomSection:section];
    }
    
    return 0;
}

- (CGSize)contentViewCellController:(MyContentViewCellController *)contentViewCellController sizeForCellAtIndexPath:(NSIndexPath *)indexPath
{
    if ([contentViewCellController isCustomCellAtIndexPath:indexPath]) {
        
        CGFloat height = self.tableView.rowHeight;
        id<MyInfoCellControllerDelegate> delegate = self.delegate;
        ifRespondsSelector(delegate, @selector(infoCellController:heightForCustomCellAtIndexPath:)){
            height = [delegate infoCellController:self heightForCustomCellAtIndexPath:indexPath];
        }
        
        return CGSizeMake(0, height);
        
    }else {
        
        Class cellClass = [contentViewCellController contentViewCellClassAtIndexPath:indexPath];
        if (![cellClass isSubclassOfClass:[MyBasicInfoCell class]]) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"非custom的cell必须为MyBasicInfoCell及其子类"
                                         userInfo:nil];
        }
        
        NSString * infoKey = [self infoCellKeyAtIndexPath:indexPath];
        
        return CGSizeMake(0.f, [cellClass heightForCellWithInfo:[contentViewCellController contentViewCellInfoAtIndexPath:indexPath]
                                             infoCellController:self
                                                          value:infoKey ? self.valuesDic[infoKey] : nil
                                                        context:[contentViewCellController contextForContentViewCellAtIndexPath:indexPath]]);
        
    }
}


- (id)contentViewCellController:(MyContentViewCellController *)contentViewCellController
          customCellAtIndexPath:(NSIndexPath *)indexPath
{
    id<MyInfoCellControllerDataSource> dataSource = self.dataSource;
    ifRespondsSelector(dataSource, @selector(infoCellController:customCellAtIndexPath:)){
        return [dataSource infoCellController:self customCellAtIndexPath:indexPath];
    }
    
    return nil;
}

- (BOOL)contentViewCellController:(MyContentViewCellController *)contentViewCellController
         didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL bRet = NO;
    if ([contentViewCellController isCustomCellAtIndexPath:indexPath]) {
        
        id<MyInfoCellControllerDelegate> delegate = self.delegate;
        ifRespondsSelector(delegate, @selector(infoCellController:didSelectCustomCellAtIndexPath:)){
            bRet = [delegate infoCellController:self didSelectCustomCellAtIndexPath:indexPath];
        }
        
    }else{
        
        NSDictionary * cellInfo = [self infoCellInfoAtIndexPath:indexPath];
        
        switch ([cellInfo infoCellType]) {
            case MyBasicInfoCellTypeEdit:
                if (self.editable) {
                    MyBasicInfoCell * cell = [self.tableView  cellForRowAtIndexPath:indexPath];
                    if ([cell canBeginEditForDidSelected]) {
                        [self infoCellWantToBeginEdit:cell];
                    }
                }
                
            break;
            
            case MyBasicInfoCellTypeNext:
            {
                NSString * targetKey = [cellInfo targetKey];
                Class viewControllerClass = NSClassFromString(targetKey);
                if ([viewControllerClass isSubclassOfClass:[UIViewController class]]) {
                    
                    //显示视图
                    id<MyInfoCellControllerDelegate> delegate = self.delegate;
                    ifRespondsSelector(delegate, @selector(infoCellController:shouldShowViewControllerForClass:)) {
                        [delegate infoCellController:self shouldShowViewControllerForClass:viewControllerClass];
                    }else {
                       [self object:self wantToShowViewController:[viewControllerClass viewController] animated:YES completedBlock:nil];
                    }
                    
                }else{
                    
                     //打开URL
                    NSURL * url = [NSURL URLWithString:[targetKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    if (url) {
                        id<MyInfoCellControllerDelegate> delegate = self.delegate;
                        ifRespondsSelector(delegate, @selector(infoCellController:shouldOpenURL:)) {
                            [delegate infoCellController:self shouldOpenURL:url];
                        }else {
                            openURL(url);
                        }
                    }
                }
            }
            
            break;
                
            default:
            {
                id<MyInfoCellControllerDelegate> delegate = self.delegate;
                ifRespondsSelector(delegate, @selector(infoCellController:didSelectCellAtIndexPath:)){
                    bRet = [delegate infoCellController:self didSelectCellAtIndexPath:indexPath];
                }
            }
                
            break;
        }
    }
    
    return bRet;
}

#pragma mark -

- (BOOL)infoCellWantToBeginEdit:(MyBasicInfoCell *)cell
{
    BOOL bRet = NO;
    
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath) {
        NSDictionary * cellInfo = [self infoCellInfoAtIndexPath:indexPath];
        if ([cellInfo infoCellType] == MyBasicInfoCellTypeEdit) {
            
            id<MyInfoCellEditerProtocol> editer = [cellInfo infoCellEditer];
            if (editer) {
                
                //生成上下文
                NSString * key = [cellInfo infoCellKey];
                MyInfoCellEditContext * context = [[MyInfoCellEditContext alloc] initWithEditer:editer forCellAtIndexPath:indexPath key:key];
                
                //尝试开始编辑
                if ([self _tryStartEditWithContext:context]) {
                    
                    //更新编辑器信息
                    if ([editer respondsToSelector:@selector(updateWithInfo:value:context:)]) {
                        [editer updateWithInfo:cellInfo value:key ? self.valuesDic[key] : nil context:[self _contextForCellAtIndexPath:indexPath]];
                    }else if([editer respondsToSelector:@selector(updateWithInfo:value:)]) {
                        [editer updateWithInfo:cellInfo value:key ? self.valuesDic[key] : nil];
                    }
                    
                    //设置代理
                    editer.delegate = self.delegate;
                    editer.editerDelegate = self;
                    
                    //开始编辑
                    [editer startEditForInfoCellAtIndexPath:indexPath
                                          baseTableViewView:self.tableView
                                           inViewController:self.baseViewController
                                                   animated:YES
                                             completedBlock:nil];
                    
                    [self _didStartEditWithContext:context];
                    
                    bRet = YES;
                    
                }else if ([cell canBeginEdit]) {
                        
                    //生成上下文
                    NSString * key = [cellInfo infoCellKey];
                    MyInfoCellEditContext * context = [[MyInfoCellEditContext alloc] initWithCell:cell atIndexPath:indexPath key:key];
                    
                    //尝试开始编辑
                    if ([self _tryStartEditWithContext:context]) {
                        
                        //开始编辑
                        [cell beginEdit:YES completedBlock:nil];
                        [self _didStartEditWithContext:context];
                        
                        bRet = YES;
                    }
                }
            }
        }
    }
    
    return bRet;
}

#pragma mark -

- (MyInfoCellEditContext *)_editContextForCell:(MyBasicInfoCell *)cell
{
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    return [[MyInfoCellEditContext alloc] initWithCell:cell atIndexPath:indexPath key:[self infoCellKeyAtIndexPath:indexPath]];
}

- (BOOL)infoCellWillBeginEdit:(MyBasicInfoCell *)cell
{
    if (self.editable) {
        return [self _tryStartEditWithContext:[self _editContextForCell:cell]];
    }
    
    return NO;
}

- (void)infoCellDidBeginEdit:(MyBasicInfoCell *)cell {
    [self _didStartEditWithContext:[self _editContextForCell:cell]];
}

- (void)infoCellDidEndEdit:(MyBasicInfoCell *)cell {
    [self _didEndEditWithContext:[self _editContextForCell:cell]];
}

#pragma mark -

- (void)setEditable:(BOOL)editable
{
    if (_editable != editable) {
        _editable = editable;
        
        //重新加载数据
        [self reloadData];
    }
}

- (BOOL)_tryStartEditWithContext:(MyInfoCellEditContext *)context
{
    id<MyInfoCellControllerDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(infoCellController:willBeginEditWithContext:)){
        if (![delegate infoCellController:self willBeginEditWithContext:context]) {
            return NO;
        }
    }
    
    if (self.isEditting) {
        if (self.editerContext.editType == MyInfoCellEditTypeCell &&
            context.editType == MyInfoCellEditTypeCell &&
            [self.editerContext.editingCell isTextEdit] &&
            [context.editingCell isTextEdit]) { //如果全部都是cell编辑文本则无需结束编辑(系统会自动结束)
            //do nothing
        }else {
           [self endEditWithAnimated:YES completedBlock:nil];
        }
    }
    
    return YES;
}

- (void)_didStartEditWithContext:(MyInfoCellEditContext *)context
{
    _editerContext = context;
    
    id<MyInfoCellControllerDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(infoCellController:didBeginEditWithContext:)){
        [delegate infoCellController:self didBeginEditWithContext:context];
    }
}

- (void)_didEndEditWithContext:(MyInfoCellEditContext *)context
{
    if ([self.editerContext.indexPath isEqual:context.indexPath]) {
        _editerContext = nil;
    }
}

- (BOOL)isEditting
{
    BOOL bRet = NO;
    
    if (self.editerContext) {
        
        if (self.editerContext.editType == MyInfoCellEditTypeEditer) {
            bRet = [self.editerContext.editer isEditting];
        }else {
            bRet = [self.editerContext.editingCell isInfoEditting];
        }
        
        if (!bRet) {
            _editerContext = nil;
        }
    }
    
    return bRet;
}

- (void)endEditWithAnimated:(BOOL)animated completedBlock:(void (^)(void))completedBlock
{
    if (self.isEditting) {
        
        if (self.editerContext.editType == MyInfoCellEditTypeEditer) {
            [self.editerContext.editer endEditWithAnimated:animated completedBlock:completedBlock];
        }else {
            [self.editerContext.editingCell endEdit:animated completedBlock:completedBlock];
        }
        
        _editerContext = nil;
    }
}

- (void)infoCellEditerDidEditByCancel:(id<MyInfoCellEditerProtocol>)infoCellEditer {
    [self _endShowEditer:infoCellEditer];
}

- (void)_endShowEditer:(id<MyInfoCellEditerProtocol>)infoCellEditer
{
    [infoCellEditer endEditWithAnimated:YES completedBlock:nil];
    [self _didEndEditWithContext:[[MyInfoCellEditContext alloc] initWithEditer:infoCellEditer forCellAtIndexPath:infoCellEditer.cellIndexPath key:[infoCellEditer.info infoCellKey]]];
}


#pragma mark -

- (BOOL)infoCell:(MyBasicInfoCell *)cell willEditToValue:(id)value {
    return [self _willEditToValue:value forKey:cell.key];
}

- (void)infoCell:(MyBasicInfoCell *)cell didEditToValue:(id)value {
    [self _didEditToValue:value forKey:cell.key updateCell:NO];
}

- (BOOL)infoCellEditer:(id<MyInfoCellEditerProtocol>)infoCellEditer willEditToValue:(id)value {
    return [self _willEditToValue:value forKey:[infoCellEditer.info infoCellKey]];
}

- (void)infoCellEditer:(id<MyInfoCellEditerProtocol>)infoCellEditer didEditToValue:(id)value
{
    //结束编辑
    [self _endShowEditer:infoCellEditer];
    
    //改变值
    [self _didEditToValue:value forKey:[infoCellEditer.info infoCellKey] updateCell:YES];
}

#pragma mark -

//- (void)setConfigurationBlock:(ConfigurationInfoCellBlock)configurationBlock
//{
//    if (_configurationBlock != configurationBlock) {
//        _configurationBlock = configurationBlock;
//        [self.contentViewCellController reloadData:YES];
//    }
//}

- (NSDictionary *)infoCellInfoAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.contentViewCellController isCustomCellAtIndexPath:indexPath]) {
        return nil;
    }
    
    NSMutableDictionary * infoCellInfo = [NSMutableDictionary dictionaryWithDictionary:[[self.contentViewCellController contentViewCellInfoAtIndexPath:indexPath] infoCellInfo]];
    
    //扩展代理返回的数据
    id<MyInfoCellControllerDataSource> dataSource = self.dataSource;
    ifRespondsSelector(dataSource, @selector(infoCellController:infoCellInfoAtIndexPath:)) {
        [infoCellInfo addEntriesFromDictionary:[dataSource infoCellController:self infoCellInfoAtIndexPath:indexPath]];
    }
    
    return infoCellInfo;
}

- (NSString *)infoCellKeyAtIndexPath:(NSIndexPath *)indexPath {
    return [[self infoCellInfoAtIndexPath:indexPath] infoCellKey];
}

- (NSIndexPath *)indexPathForCellWithKey:(NSString *)infoCellKey {
    return infoCellKey ? self.keysToIndexPathsMap[infoCellKey] : nil;
}

#pragma mark - 

- (NSMutableDictionary *)valuesDic {
    return _valuesDic ?: (_valuesDic = [[NSMutableDictionary alloc] init]);
}

- (NSMutableDictionary *)keysToIndexPathsMap {
    return _keysToIndexPathsMap ?: (_keysToIndexPathsMap = [[NSMutableDictionary alloc] init]);
}

- (void)setInfoValue:(id)value forKey:(NSString *)key
{
    if (value) {
        [self setValuesForKeys:@{key : value} reloadAllData:NO];
    }else {
        [self removeValuesForKeys:@[key] reloadAllData:NO];
    }
}

- (void)setValuesForKeys:(NSDictionary *)valuesDic {
    [self setValuesForKeys:valuesDic reloadAllData:NO];
}

- (void)setValuesForKeys:(NSDictionary *)valuesDic reloadAllData:(BOOL)reloadAllData
{
    if (valuesDic.count == 0) {
        return;
    }
    
    NSMutableArray * indexPathsWillReload = [NSMutableArray arrayWithCapacity:valuesDic.count];
    for (NSString * key in valuesDic.keyEnumerator) {
        
        if([key isKindOfClass:[NSString class]]){
            
            id newValue = valuesDic[key];
            if (![self.valuesDic[key] isEqual:newValue]) {
                self.valuesDic[key] = newValue;
                
                if (!reloadAllData) {
                    NSIndexPath * indexPath = self.keysToIndexPathsMap[key];
                    if (indexPath) {
                        [indexPathsWillReload addObject:indexPath];
                    }
                }
            }
        }
    }
    
    //更新cell
    if (reloadAllData) {
        [self.tableView reloadData];
    }else if (indexPathsWillReload.count) {
        [self.tableView reloadRowsAtIndexPaths:indexPathsWillReload
                              withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)removeValuesForKeys:(NSArray *)keys reloadAllData:(BOOL)reloadAllData
{
    if (keys.count == 0) {
        return;
    }
    
    NSMutableArray * indexPathsWillReload = [NSMutableArray arrayWithCapacity:keys.count];
    for (NSString * key in keys) {

        if([key isKindOfClass:[NSString class]]){
            
            if ([self.valuesDic objectForKey:key]) {
                [self.valuesDic removeObjectForKey:key];
                
                if (!reloadAllData) {
                    NSIndexPath * indexPath = self.keysToIndexPathsMap[key];
                    if (indexPath) {
                        [indexPathsWillReload addObject:indexPath];
                    }
                }
            }
        }
    }
    
    //更新cell
    if (reloadAllData) {
        [self.tableView reloadData];
    }else if (indexPathsWillReload.count) {
        [self.tableView reloadRowsAtIndexPaths:indexPathsWillReload
                              withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)removeAllValues
{
    if (self.valuesDic.count == 0) {
        return;
    }
    
    [self.valuesDic removeAllObjects];
    [self.tableView reloadData];
}

- (NSDictionary *)allVaules {
    return [NSDictionary dictionaryWithDictionary:self.valuesDic];
}

- (NSDictionary *)vaulesForKeys:(NSArray *)keys {
    return [self.valuesDic objectsForKeys:keys];
}

- (id)infoValueForKey:(NSString *)key {
    return key ? [self.valuesDic objectForKey:key] : nil;
}


- (void)reloadData
{
    [self endEditWithAnimated:NO completedBlock:nil];
    [self.tableView reloadData];
}

- (void)clearAllVaules
{
    if (self.valuesDic.count) {
        [self.valuesDic removeAllObjects];
        [self reloadData];
    }
}

- (BOOL)_willEditToValue:(id)value forKey:(NSString *)key
{
    BOOL bRet = YES;
    if (key) {
        id<MyInfoCellControllerDelegate> delegate = self.delegate;
        ifRespondsSelector(delegate, @selector(infoCellController:willEditToValue:forKey:)){
            bRet = [delegate infoCellController:self willEditToValue:value forKey:key];
        }
    }
    
    return bRet;
}

- (void)_didEditToValue:(id)value forKey:(NSString *)key updateCell:(BOOL)updateCell
{
    if (key) {
        
        if (value) {
            self.valuesDic[key] = value;
        }else{
            [self.valuesDic removeObjectForKey:key];
        }
        
        id<MyInfoCellControllerDelegate> delegate = self.delegate;
        ifRespondsSelector(delegate, @selector(infoCellController:didEditToValue:forKey:)){
            [delegate infoCellController:self didEditToValue:value forKey:key];
        }
        
        if (updateCell) {
            NSIndexPath * indexPath = self.keysToIndexPathsMap[key];
            if(indexPath){
                [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    }
}

#pragma mark -

- (id)contentViewCellController:(MyContentViewCellController *)contentViewCellController contextForCellAtIndexPath:(NSIndexPath *)indexPath
{
    return [self _contextForCellAtIndexPath:indexPath];
}

- (id)_contextForCellAtIndexPath:(NSIndexPath *)indexPath
{
    id<MyInfoCellControllerDataSource> dataSource = self.dataSource;
    ifRespondsSelector(dataSource, @selector(infoCellController:contextForCellAtIndexPath:)) {
        return [dataSource infoCellController:self contextForCellAtIndexPath:indexPath];
    }
    
    return nil;
}

#pragma mark -

- (BOOL)contentViewCellController:(MyContentViewCellController *)contentViewCellController canDeleteCustomCellAtIndexPath:(NSIndexPath *)indexPath
{
    id<MyInfoCellControllerDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(infoCellController:canDeleteCustomCellAtIndexPath:)) {
        return [delegate infoCellController:self canDeleteCustomCellAtIndexPath:indexPath];
    }
    
    return NO;
}

- (NSString *)contentViewCellController:(MyContentViewCellController *)contentViewCellController titleForDeleteConfirmationButtonForCustomRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MyInfoCellControllerDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(infoCellController:titleForDeleteConfirmationButtonForCustomRowAtIndexPath:)) {
        return [delegate infoCellController:self titleForDeleteConfirmationButtonForCustomRowAtIndexPath:indexPath];
    }
    
    return @"删除";
}

- (void)contentViewCellController:(MyContentViewCellController *)contentViewCellController commitDeleteCustomCellAtIndexPath:(NSIndexPath *)indexPath
{
    id<MyInfoCellControllerDataSource> dataSource = self.dataSource;
    ifRespondsSelector(dataSource, @selector(infoCellController:commitDeleteCustomCellAtIndexPath:)) {
        [dataSource infoCellController:self commitDeleteCustomCellAtIndexPath:indexPath];
    }
}

#pragma mark - 滑动视图相关方法的转发

- (void)setDelegate:(id<MyInfoCellControllerDelegate>)delegate
{
    if (_delegate != delegate) {
        _delegate = delegate;
        
        //更新代理
        self.contentViewCellController.delegate = nil;
        self.contentViewCellController.delegate = self;
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
