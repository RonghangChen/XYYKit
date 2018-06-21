//
//  UIActionSheet+Block.h
//  
//
//  Created by LeslieChen on 15/10/29.
//  Copyright © 2015年 ED. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UIActionSheetCallBackBlock)(UIActionSheet * actionSheet,NSInteger buttonIndex);

@interface UIActionSheet (Block) <UIActionSheetDelegate>

@property(nonatomic,copy) UIActionSheetCallBackBlock actionSheetCallBackBlock;

+ (instancetype)actionViewWithCallBackBlock:(UIActionSheetCallBackBlock)alertViewCallBackBlock
                                      title:(NSString *)title
                          cancelButtonTitle:(NSString *)cancelButtonTitle
                     destructiveButtonTitle:(NSString *)destructiveButtonTitle
                          otherButtonTitles:( NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

@end
