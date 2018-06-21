//
//  UILabel+CaculaterShowSize.h
//  
//
//  Created by 钱伟龙 on 16/8/18.
//  Copyright © 2016年 ED. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (CaculaterShowSize)

+ (CGSize)showSizeWithText:(NSString *)text
                      font:(UIFont *)font
                     width:(CGFloat)width;

+ (CGSize)showSizeWithText:(NSString *)text
                      font:(UIFont *)font
                     width:(CGFloat)width
             numberOfLines:(NSUInteger)numberOfLines;


+ (CGSize)showSizeWithAttributedText:(NSAttributedString *)attributedText
                         defaultFont:(UIFont *)font
                               width:(CGFloat)width;

+ (CGSize)showSizeWithAttributedText:(NSAttributedString *)attributedText
                         defaultFont:(UIFont *)font
                         constraints:(CGSize)size
                       numberOfLines:(NSUInteger)numberOfLines;


@end
