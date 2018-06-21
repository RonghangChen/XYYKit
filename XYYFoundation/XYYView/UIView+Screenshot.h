//
//  UIView+Screenshot.h
//
//
//  Created by LeslieChen on 14/12/15.
//  Copyright (c) 2014年 YB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Screenshot)

- (UIImage *)convertViewToImage;
- (UIImage *)convertViewToImageWithRetina:(BOOL)retina;

@end
