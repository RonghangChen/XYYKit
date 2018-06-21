//
//  MyBasicTextViewInfoCell.h
//  
//
//  Created by LeslieChen on 15/12/18.
//  Copyright © 2015年 ED. All rights reserved.
//

#import "MyBasicInfoCell.h"

@interface MyBasicTextViewInfoCell : MyBasicInfoCell <UITextViewDelegate>

//初始化textView
- (void)setupTextView:(UITextView *)textView;
@property(nonatomic,strong,readonly) UITextView * textView;

//文本的结束点(相对应cell)
@property(nonatomic,readonly) CGPoint textEndPointForTextView;


@end
