//
//  MyBasicInfoCellEditView.m
//  
//
//  Created by LeslieChen on 15/3/23.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import "MyBasicInfoCellEditerView.h"
#import "NSDictionary+MyCategory.h"
#import "XYYBaseDef.h"


@implementation MyBasicInfoCellEditerView

@synthesize info = _info;
@synthesize value = _value;
@synthesize cellIndexPath = _cellIndexPath;
@synthesize delegate = _delegate;
@synthesize editerDelegate = _editerDelegate;

- (Class)valueExpectedClass {
    return nil;
}

- (void)updateWithInfo:(NSDictionary *)info value:(id)value context:(id)context {
    [self updateWithInfo:info value:value];
}

- (void)updateWithInfo:(NSDictionary *)info value:(id)value
{
    _info = info;
    
    Class valueExpectedClass = [self valueExpectedClass];
    _value = !valueExpectedClass || [value isKindOfClass:valueExpectedClass] ? value : nil;
    
    self.title = [info myTitle];
}

- (id)newValue {
    return  self.value;
}

- (BOOL)didChangeValue:(id)newValue {
    return newValue != self.value && ![newValue isEqual:self.value];
}

- (BOOL)tryEditToNewValue
{
    BOOL bRet = YES;
    
    id newValue = self.newValue;
    if ([self didChangeValue:newValue]) {
        
        id<MyInfoCellEditerEditerDelegate> delegate = self.editerDelegate;
        ifRespondsSelector(delegate, @selector(infoCellEditer:willEditToValue:)){
            bRet = [delegate infoCellEditer:self willEditToValue:newValue];
        }
        
        if (bRet) {
            [self didEditToNewValue:newValue];
            ifRespondsSelector(delegate, @selector(infoCellEditer:didEditToValue:)){
                [delegate infoCellEditer:self didEditToValue:newValue];
            }else {
                [self endEditWithAnimated:YES completedBlock:nil];
            }
        }
        
    }else {
        [self didEndEditByCancle];
    }
    
    return bRet;
}

- (void)didEditToNewValue:(id)newValue {
    _value = self.newValue;
}

- (BOOL)isEditting {
    return NO;
}

- (void)startEditForInfoCellAtIndexPath:(NSIndexPath *)indexPath
                      baseTableViewView:(UITableView *)tableView
                       inViewController:(UIViewController *)viewController
                               animated:(BOOL)animated
                         completedBlock:(void(^)(void))completedBlock
{
    _cellIndexPath = indexPath;
}


- (void)endEditWithAnimated:(BOOL)animated completedBlock:(void (^)(void))completedBlock {
    
}

- (void)didEndEditByCancle
{
    id<MyInfoCellEditerEditerDelegate> delegate = self.editerDelegate;
    ifRespondsSelector(delegate, @selector(infoCellEditerDidEditByCancel:)){
        [delegate infoCellEditerDidEditByCancel:self];
    }else {
        [self endEditWithAnimated:YES completedBlock:nil];
    }
}

@end
