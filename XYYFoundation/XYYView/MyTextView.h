//
//  MyTextView.h
//  
//
//  Created by LeslieChen on 15/4/15.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import <UIKit/UIKit.h>

//只支持left对齐
@interface MyTextView : UITextView

@property(nonatomic,strong) NSString * placeholderText;
// font & color
@property(nonatomic,strong) NSDictionary * placeholderAttributed;


- (CGSize)sizeForFullShowWithWidth:(CGFloat)width;

@end
