//
//  MyBasicTextFieldViewInfoCell.h
//  QingYang_iOS
//
//  Created by 陈荣航 on 2018/4/9.
//  Copyright © 2018年 leslie. All rights reserved.
//

#import "MyBasicInfoCell.h"

@interface MyBasicTextFieldViewInfoCell : MyBasicInfoCell <UITextFieldDelegate>

//初始化textField
- (void)setupTextField:(UITextField *)textField;
@property(nonatomic,strong,readonly) UITextField * textField;

@end
