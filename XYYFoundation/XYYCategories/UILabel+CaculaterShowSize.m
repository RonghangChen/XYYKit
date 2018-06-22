//
//  UILabel+CaculaterShowSize.m
//  
//
//  Created by 钱伟龙 on 16/8/18.
//  Copyright © 2016年 ED. All rights reserved.
//

#import "UILabel+CaculaterShowSize.h"
#import "TTTAttributedLabel.h"

@implementation UILabel (CaculaterShowSize)

+ (CGSize)showSizeWithText:(NSString *)text font:(UIFont *)font width:(CGFloat)width {
    return [self showSizeWithText:text font:font width:width numberOfLines:0];

}

+ (CGSize)showSizeWithText:(NSString *)text
                      font:(UIFont *)font
                     width:(CGFloat)width
             numberOfLines:(NSUInteger)numberOfLines
{
    if (text.length == 0) {
        return CGSizeZero;
    }
    
    return [self showSizeWithAttributedText:[[NSAttributedString alloc] initWithString:text]
                                defaultFont:font
                                constraints:CGSizeMake(width, CGFLOAT_MAX)
                              numberOfLines:numberOfLines];
    
}


+ (CGSize)showSizeWithAttributedText:(NSAttributedString *)attributedText
                         defaultFont:(UIFont *)defaultFont
                               width:(CGFloat)width
{
    return [self showSizeWithAttributedText:attributedText
                                defaultFont:defaultFont
                                constraints:CGSizeMake(width, CGFLOAT_MAX)
                              numberOfLines:0];
}

+ (CGSize)showSizeWithAttributedText:(NSAttributedString *)attributedText
                         defaultFont:(UIFont *)defaultFont
                         constraints:(CGSize)size
                       numberOfLines:(NSUInteger)numberOfLines
{
    if (attributedText.length == 0) {
        return CGSizeZero;
    }
    
    UILabel * label = [[self alloc] initWithFrame:CGRectZero];
    label.numberOfLines = numberOfLines;
    label.preferredMaxLayoutWidth = size.width;
    label.font = defaultFont;
    
    if ([label isKindOfClass:[TTTAttributedLabel class]]) {
        
        [(TTTAttributedLabel *)label setText:attributedText afterInheritingLabelAttributesAndConfiguringWithBlock:nil];
        
    }else {
        
        label.attributedText = attributedText;
    }
    
    CGSize intrinsicContentSize = [label intrinsicContentSize];
    return CGSizeMake(ceilf(MIN(intrinsicContentSize.width, size.width)),
                      ceilf(MIN(intrinsicContentSize.height, size.height)));
}

@end
