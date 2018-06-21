//
//  UICollectionReusableView+ShowContent.m
//  
//
//  Created by LeslieChen on 15/10/24.
//  Copyright © 2015年 ED. All rights reserved.
//

#import "UICollectionReusableView+ShowContent.h"
#import "NSDictionary+MyCategory.h"

@implementation UICollectionReusableView (ShowContent)

+ (CGSize)sizeForViewWithInfo:(NSDictionary *)info
            containerViewSize:(CGSize)containerViewSize
                      context:(id)context
{
    CGSize cellSize = CGSizeZero;
    
    NSString * cellSizeValue = [info sizeValue];
    if (!cellSizeValue) {
        
        id heightValue = [info heightValue];
        id widthValue = [info widthValue];
        
        if (heightValue || widthValue) {
            cellSize = CGSizeMake(widthValue ? [widthValue floatValue] : containerViewSize.width, heightValue ? [heightValue floatValue] : containerViewSize.height);
        }
    }else {
        cellSize = CGSizeFromString(cellSizeValue);
    }
    
    cellSize.width  = MAX(0.f, cellSize.width);
    cellSize.height = MAX(0.f, cellSize.height);
    
    return cellSize;
}

- (void)updateViewWithInfo:(NSDictionary *)info context:(id)context {
    
}


@end
