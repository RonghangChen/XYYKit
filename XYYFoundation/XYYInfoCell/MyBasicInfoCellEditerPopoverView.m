//
//  MyBasicInfoCellEditerPopoverView.m
//  
//
//  Created by LeslieChen on 15/3/23.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyBasicInfoCellEditerPopoverView.h"
#import "NSDictionary+MyBasicInfoCell.h"
#import "MyPopoverView.h"

//----------------------------------------------------------

@implementation MyBasicInfoCellEditerPopoverView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self _setup_MyBasicInfoCellEditerPopoverView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self _setup_MyBasicInfoCellEditerPopoverView];
    }
    
    return self;
}

- (void)_setup_MyBasicInfoCellEditerPopoverView
{
    self.contentAnchorPoint = CGPointMake(0.5f,0.5f);
    self.locationAnchorPoint = CGPointMake(0.5f, 0.5f);
}

#pragma mark -

- (void)updateWithInfo:(NSDictionary *)info value:(id)value
{
    [super updateWithInfo:info value:value];
    _values = [info infoValues];
}

#pragma mark -

- (BOOL)isEditting {
    return [self.popoverView isShowing] || [[MyAlertViewManager sharedManager] isShowAlertView:self];
}

- (void)startEditForInfoCellAtIndexPath:(NSIndexPath *)indexPath
                      baseTableViewView:(UITableView *)tableView
                       inViewController:(UIViewController *)viewController
                               animated:(BOOL)animated
                         completedBlock:(void (^)(void))completedBlock
{
    [super startEditForInfoCellAtIndexPath:indexPath
                         baseTableViewView:tableView
                          inViewController:viewController
                                  animated:animated
                            completedBlock:completedBlock];
    
    [self endEditWithAnimated:NO completedBlock:nil];
    
    MyPopoverView * popoverView = [self popoverView] ? : [[MyPopoverView alloc] initWithContentView:self];
    popoverView.adjustContentViewFrameWhenNoContain = YES;
    popoverView.contentViewAnchorPoint = self.contentAnchorPoint;
    popoverView.locationAnchorPoint = self.locationAnchorPoint;
    
    [[MyAlertViewManager sharedManager] showAlertView:self withBlock:^{
        [popoverView showInView:nil animated:animated completedBlock:completedBlock];
    }];
}

- (void)endEditWithAnimated:(BOOL)animated completedBlock:(void (^)(void))completedBlock
{
    if ([[MyAlertViewManager sharedManager] isShowAlertView:self]) {
        [[MyAlertViewManager sharedManager] hideAlertView:self withAnimated:animated completedBlock:completedBlock];
    }else {
        [self hideAlertViewWithAnimated:animated completedBlock:completedBlock];
    }
}

- (void)hideAlertViewWithAnimated:(BOOL)animated completedBlock:(void (^)(void))completedBlock {
    [self.popoverView hide:animated completedBlock:completedBlock];
} 

#pragma mark -

- (UIWindowLevel)showPopoverWindowLevel {
    return MAX(UIWindowLevelStatusBar, [super showPopoverWindowLevel]);
}

//- (BOOL)popoverViewWillTapHiddenAtPoint:(CGPoint)point
//{
//    [self tryEditToNewValue];
//    return NO;
//}

- (void)popoverViewDidTapHidden {
    [self didEndEditByCancle];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width * 0.5f, size.width * 0.5f);
}


@end
