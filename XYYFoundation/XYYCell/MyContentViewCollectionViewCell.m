//
//  MyContentViewCollectionViewCell.m

//
//  Created by LeslieChen on 15/1/25.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyContentViewCollectionViewCell.h"
#import "UIView+IntervalAnimation.h"
#import "UICollectionReusableView+ShowContent.h"
#import "NSDictionary+MyCategory.h"

//----------------------------------------------------------

@implementation MyContentViewCollectionViewCell

@synthesize delegate = _delegate;


+ (CGSize)sizeForCellWithInfo:(NSDictionary *)info
            containerViewSize:(CGSize)containerViewSize
                      context:(MyCellContext *)context
{
    return [self sizeForViewWithInfo:info containerViewSize:containerViewSize context:context];
}

- (void)updateCellWithInfo:(NSDictionary *)info context:(MyCellContext *)context
{
    [super updateViewWithInfo:info context:context];
}

@end


@implementation NSDictionary (MyContentViewCollectionViewCell)

- (NSString *)contentViewCollectionViewCellClassName
{
    NSString * className = [self valueForKey:@"collectionViewCellClass"
                                   withClass:[NSString class]];
    
    if ([NSClassFromString(className) isSubclassOfClass:[MyContentViewCollectionViewCell class]]) {
        return className;
    }else{
        return nil;
    }
}

- (Class)contentViewCollectionViewCellClass {
    return NSClassFromString([self contentViewCollectionViewCellClassName]);
}

@end

