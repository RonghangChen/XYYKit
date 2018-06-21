//
//  UIView+IntervalAnimation.m
//  
//
//  Created by LeslieChen on 15/3/10.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import "UIView+IntervalAnimation.h"
#import  <objc/runtime.h>

static char intervalAnimationOnlyAnimatedSelfKey;

@implementation UIView (IntervalAnimation)

- (void)setOnlyAnimatedSelf:(BOOL)onlyAnimatedSelf
{
    objc_setAssociatedObject(self, &intervalAnimationOnlyAnimatedSelfKey, onlyAnimatedSelf ? @(YES) : nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)onlyAnimatedSelf {
    return [objc_getAssociatedObject(self, &intervalAnimationOnlyAnimatedSelfKey) boolValue];
}

- (NSArray *)needAnimatedViewsForShow:(BOOL)show context:(id)context
{
    if (self.onlyAnimatedSelf) {
        return @[self];
    }else if ([self isKindOfClass:[UITableView class]]) {
        return [(UITableView *)self visibleCells];
    }else if ([self isKindOfClass:[UICollectionView class]]){
        return [[(UICollectionView *)self visibleCells] sortedArrayUsingComparator:^(id obj1  ,id obj2){
            NSIndexPath * indexPath1 = [(UICollectionView *)self indexPathForCell:obj1];
            NSIndexPath * indexPath2 = [(UICollectionView *)self indexPathForCell:obj2];
            
            if (indexPath1.section > indexPath2.section) {
                return NSOrderedDescending;
            }else if (indexPath1.section == indexPath2.section) {
                return indexPath1.item > indexPath2.item ? NSOrderedDescending : NSOrderedAscending;
            }else {
                return NSOrderedAscending;
            }
        }];
    }else if (self.subviews.count == 0 || ![self isMemberOfClass:[UIView class]]){
        return @[self];
    }
    
    return self.subviews;
}

- (NSArray *)needAnimatedViewsWithDirection:(MyMoveAnimatedDirection)moveAnimtedDirection
                                    forShow:(BOOL)show
                                    context:(id)context
{
    return [self needAnimatedViewsForShow:show context:context];
}

@end
