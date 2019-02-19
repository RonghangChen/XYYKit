//
//  UIScrollView+ScrollToBorder.m
//  
//
//  Created by LeslieChen on 15/6/16.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import "UIScrollView+ScrollToBorder.h"

@implementation UIScrollView (ScrollToBorder)

- (void)scrollToBoder:(MyScrollBorder)border {
    [self scrollToBoder:border offset:CGPointZero animated:NO];
}

- (void)scrollToBoder:(MyScrollBorder)border animated:(BOOL)animated {
    [self scrollToBoder:border offset:CGPointZero animated:animated];
}

- (void)scrollToBoder:(MyScrollBorder)border offset:(CGPoint)offset animated:(BOOL)animated
{
    CGPoint contentOffset = [self contentOffsetForScrollToBorder:border];
    
    contentOffset.x += offset.x;
    contentOffset.y += offset.y;
    
    [self setContentOffset:contentOffset animated:animated];
}

- (CGPoint)contentOffsetForScrollToBorder:(MyScrollBorder)border
{
    CGPoint contentOffset = self.contentOffset;
    
    if (border) {
        
        UIEdgeInsets contentInset;
        if (@available(iOS 11.0, *)) {
            contentInset = self.adjustedContentInset;
        }else {
            contentInset = self.contentInset;
        }
        
        if (border & MyScrollBorderTop) {
            contentOffset.y = - contentInset.top;
        }else if (border & MyScrollBorderBottom) {
            
            CGSize contentSize = self.contentSize;
            CGSize size = self.bounds.size;
            
            if (contentSize.height + contentInset.top + contentInset.bottom < size.height) {
                contentOffset.y = - contentInset.top;
            }else {
                contentOffset.y = contentSize.height + contentInset.bottom - size.height;
            }
        }
        
        if (border & MyScrollBorderLeft) {
            contentOffset.x = - contentInset.left;
        }else if (border & MyScrollBorderRight) {
            
            CGSize contentSize = self.contentSize;
            CGSize size = self.bounds.size;
            
            if (contentSize.width + contentInset.left + contentInset.right < size.width) {
                contentOffset.x = - contentInset.left;
            }else {
                contentOffset.x = contentSize.width + contentInset.right - size.width;
            }
        }
    }
    
    return contentOffset;
}

@end
