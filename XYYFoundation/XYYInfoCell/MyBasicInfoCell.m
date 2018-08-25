//
//  MyBasciInfoCell.m
//  
//
//  Created by LeslieChen on 15/3/22.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import "MyBasicInfoCell.h"
#import "NSDictionary+MyCategory.h"
#import "NSDictionary+MyBasicInfoCell.h"
#import "MyInfoCellController.h"
#import "UITableViewCell+ShowContent.h"
#import "XYYBaseDef.h"

@implementation MyBasicInfoCell

@dynamic delegate;

+ (CGFloat)heightForCellWithInfo:(NSDictionary *)info
              infoCellController:(MyInfoCellController *)infoCellController
                           value:(id)value
                         context:(MyCellContext *)context
{
    return [self heightForCellWithInfo:info tableView:infoCellController.tableView context:context];
}

- (void)updateWithInfoCellInfo:(NSDictionary *)infoCellInfo value:(id)value editable:(BOOL)editable context:(MyCellContext *)context
{
    _editable = editable;
    _infoCellInfo = infoCellInfo;
    _value = value;
    
    [self updateWithInfoCellInfo:infoCellInfo value:value context:context];
    
}

- (void)updateWithInfoCellInfo:(NSDictionary *)infoCellInfo value:(id)value context:(MyCellContext *)context
{
    //do nothing
}

- (MyBasicInfoCellType)cellType {
    return [self.infoCellInfo infoCellType];
}

- (MyBasicInfoCellEditType)editType {
    return [self.infoCellInfo infoCellEditType];
}

- (NSString *)key {
    return [self.infoCellInfo infoCellKey];
}

#pragma amrk -

- (BOOL)isInfoEditting {
    return NO;
}

//是否可以开始编辑
- (BOOL)canBeginEdit {
    return NO;
}

- (BOOL)canBeginEditForDidSelected {
    return YES;
}

- (BOOL)isTextEdit {
    return NO;
}

//开始编辑（没有编辑视图会使用该方法开始进行编辑）
- (void)beginEdit:(BOOL)animated completedBlock:(void(^)(void))completedBlock {
    //do nothing
}

//结束编辑
- (void)endEdit:(BOOL)animated completedBlock:(void(^)(void))completedBlock {
    //do nothing
}

- (BOOL)tryBeginEdit
{
    if ([self willBeginEdit]) {
        [self didBeginEdit];
        return YES;
    }
    
    return NO;
}

- (BOOL)willBeginEdit
{
    if ([self canBeginEdit] && self.cellType == MyBasicInfoCellTypeCustomEdit) {
        
        BOOL bRet = YES;
        id<MyBasicInfoCellEditerDelegate> editerDelegate = self.editerDelegate;
        ifRespondsSelector(editerDelegate, @selector(infoCellWillBeginEdit:)) {
            bRet = [editerDelegate infoCellWillBeginEdit:self];
        }
        
        return bRet;
    }
    
    return NO;
}

- (void)didBeginEdit
{
    id<MyBasicInfoCellEditerDelegate> editerDelegate = self.editerDelegate;
    ifRespondsSelector(editerDelegate, @selector(infoCellDidBeginEdit:)) {
        [editerDelegate infoCellDidBeginEdit:self];
    }
}

- (void)didEndEdit
{
    id<MyBasicInfoCellEditerDelegate> editerDelegate = self.editerDelegate;
    ifRespondsSelector(editerDelegate, @selector(infoCellDidEndEdit:)) {
        [editerDelegate infoCellDidEndEdit:self];
    }
}

- (BOOL)wantToBeginEdit
{
    BOOL bRet = NO;
    id<MyBasicInfoCellEditerDelegate> editerDelegate = self.editerDelegate;
    ifRespondsSelector(editerDelegate, @selector(infoCellWantToBeginEdit:)) {
        bRet = [editerDelegate infoCellWantToBeginEdit:self];
    }
    
    return bRet;
}



- (BOOL)tryEditToNewValue:(id)newValue
{
    if ([self willEditToNewValue:newValue]) {
        [self didEditToNewValue:newValue];
        return YES;
    }
    
    return NO;
}

- (BOOL)willEditToNewValue:(id)newValue
{
    BOOL bRet= YES;
    id<MyBasicInfoCellEditerDelegate> editerDelegate = self.editerDelegate;
    ifRespondsSelector(editerDelegate, @selector(infoCell:willEditToValue:)){
        bRet = [editerDelegate infoCell:self willEditToValue:newValue];
    }
    
    return bRet;
}

- (void)didEditToNewValue:(id)newValue
{
    _value = [newValue isKindOfClass:[NSString class]] && [newValue length] == 0 ? nil : newValue;
    
    id<MyBasicInfoCellEditerDelegate> editerDelegate = self.editerDelegate;
    ifRespondsSelector(editerDelegate, @selector(infoCell:didEditToValue:)){
        [editerDelegate infoCell:self didEditToValue:_value];
    }
}

- (NSString *)valueTitle
{
    if (self.value == nil || self.value == [NSNull null]) {
        return [self.infoCellInfo valuePlaceholder];
    }
    
    if (self.cellType == MyBasicInfoCellTypeEdit) {
        
        switch (self.editType) {
            case MyBasicInfoCellEditTypePicker:
            {
                NSDictionary * valueInfo = [self.infoCellInfo infoValueForValue:self.value];
                return [valueInfo myTitle] ?: [[valueInfo value] description];
            }
            break;
            
            case MyBasicInfoCellEditTypePickerDate:
                return [self.infoCellInfo infoDateStrForValue:self.value];
            break;
            
            default:
            break;
        }
    }
    
    return [self.value description];
}

@end

