//
//  UIScrollView+ScrollToBorder.h
//  
//
//  Created by LeslieChen on 15/6/16.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, MyScrollBorder) {
    MyScrollBorderTop    = 1 << 0,
    MyScrollBorderBottom = 1 << 1,
    MyScrollBorderLeft   = 1 << 2,
    MyScrollBorderRight  = 1 << 3
};

@interface UIScrollView (ScrollToBorder)

- (void)scrollToBoder:(MyScrollBorder)border;
- (void)scrollToBoder:(MyScrollBorder)border animated:(BOOL)animated;

@end
