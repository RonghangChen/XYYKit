//
//  UIActionSheet+Block.m
//  
//
//  Created by LeslieChen on 15/10/29.
//  Copyright © 2015年 ED. All rights reserved.
//

#import "UIActionSheet+Block.h"
#import <objc/runtime.h>

static char UIActionSheetCallBackBlockKey;

@implementation UIActionSheet (Block)

+ (instancetype)actionViewWithCallBackBlock:(UIActionSheetCallBackBlock)actionSheetCallBackBlock
                                      title:(NSString *)title
                          cancelButtonTitle:(NSString *)cancelButtonTitle
                     destructiveButtonTitle:(NSString *)destructiveButtonTitle
                          otherButtonTitles:( NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                             delegate:nil
                                                    cancelButtonTitle:cancelButtonTitle
                                               destructiveButtonTitle:destructiveButtonTitle
                                                    otherButtonTitles:otherButtonTitles, nil];
    
    NSString *other = nil;
    va_list args;
    if (otherButtonTitles) {
        va_start(args, otherButtonTitles);
        while ((other = va_arg(args, NSString*))) {
            [actionSheet addButtonWithTitle:other];
        }
        va_end(args);
    }
    
    actionSheet.delegate = actionSheet;
    actionSheet.actionSheetCallBackBlock = actionSheetCallBackBlock;
    
    return actionSheet;
}

- (void)setActionSheetCallBackBlock:(UIActionSheetCallBackBlock)actionSheetCallBackBlock
{
//    [self willChangeValueForKey:@"actionSheetCallBackBlock"];
    objc_setAssociatedObject(self, &UIActionSheetCallBackBlockKey, actionSheetCallBackBlock, OBJC_ASSOCIATION_COPY);
//    [self didChangeValueForKey:@"actionSheetCallBackBlock"];
}

- (UIActionSheetCallBackBlock)actionSheetCallBackBlock {
    return objc_getAssociatedObject(self, &UIActionSheetCallBackBlockKey);
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet == self) {
        UIActionSheetCallBackBlock actionSheetCallBackBlock = self.actionSheetCallBackBlock;
        if (actionSheetCallBackBlock) {
            actionSheetCallBackBlock(self,buttonIndex);
        }
    }
}

@end
