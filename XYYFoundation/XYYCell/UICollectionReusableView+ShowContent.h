//
//  UICollectionReusableView+ShowContent.h
//  
//
//  Created by LeslieChen on 15/10/24.
//  Copyright © 2015年 ED. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionReusableView (ShowContent)


+ (CGSize)sizeForViewWithInfo:(NSDictionary *)info
            containerViewSize:(CGSize)containerViewSize
                      context:(id)context;

- (void)updateViewWithInfo:(NSDictionary *)info context:(id)context;


@end
