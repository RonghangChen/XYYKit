//
//  ED_FilterContentView.m

//
//  Created by LeslieChen on 15/3/2.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyBasicDeclineMenuContentView.h"
#import "MyDeclineMenuContainerView.h"

//----------------------------------------------------------

NSString * const MyDeclineMenuContentViewSizeInvalidateNotification = @"MyDeclineMenuContentViewSizeInvalidateNotification";

//----------------------------------------------------------

@implementation MyBasicDeclineMenuContentView

#pragma mark -

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self _setup_MyBasicDeclineMenuContentView];
//    }
//    
//    return self;
//}
//
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        [self _setup_MyBasicDeclineMenuContentView];
//    }
//    
//    return self;
//}
//
//- (void)_setup_MyBasicDeclineMenuContentView
//{
////    self.needAnimatedWhenShow = YES;
////    self.showAnimtedMoveDirection = MyMoveAnimatedDirectionLeft;
//}

#pragma mark -

- (CGFloat)heightForViewWithContainerSize:(CGSize)containerSize {
    return containerSize.height * 0.6f;
}

- (void)sizeInvalidate
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MyDeclineMenuContentViewSizeInvalidateNotification
                                                        object:self];
}

#pragma mark -

- (void)viewWillShow:(BOOL)animated duration:(NSTimeInterval)duration
{
    if (self.needAnimatedWhenShow) {
        [self startShowAnimatedWithDelay:animated ? duration * 0.6f : 0.f];
    }
}

- (void)startShowAnimatedWithDelay:(NSTimeInterval)delay
{
    [self startCommitIntervalAnimatedWithDirection:self.showAnimtedMoveDirection
                                          duration:1.3f
                                             delay:delay
                                           forShow:YES
                                           context:nil
                                    completedBlock:nil];
}


- (void)viewDidShow:(BOOL)animated {
    //do nothing
}

- (void)viewWillHide:(BOOL)animated duration:(NSTimeInterval)duration {
    //do nothing
}

-(void)viewDidHide:(BOOL)animated {
    //do nothing
}

#pragma mark -

- (BOOL)shouldTapHiddenInContainerView:(MyDeclineMenuContainerView *)containerView {
    return YES;
}

- (BOOL)shouldBeginSwipeHiddenInContainerView:(MyDeclineMenuContainerView *)containerView {
    return YES;
}

- (BOOL)shouldSwipeHiddenInContainerView:(MyDeclineMenuContainerView *)containerView {
    return YES;
}


@end
