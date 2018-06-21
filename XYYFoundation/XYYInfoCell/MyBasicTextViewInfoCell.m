//
//  MyBasicTextViewInfoCell.m
//  
//
//  Created by LeslieChen on 15/12/18.
//  Copyright © 2015年 ED. All rights reserved.
//

#import "MyBasicTextViewInfoCell.h"

@implementation MyBasicTextViewInfoCell

- (void)setupTextView:(UITextView *)textView
{
    if (_textView == nil && textView != nil) {
        _textView = textView;
        _textView.delegate = self;
    }
}

#pragma mark -

- (void)updateWithInfoCellInfo:(NSDictionary *)infoCellInfo value:(id)value editable:(BOOL)editable context:(MyCellContext *)context
{
    [super updateWithInfoCellInfo:infoCellInfo value:value editable:editable context:context];
 
    if ([infoCellInfo infoCellType] != MyBasicInfoCellTypeCustomEdit) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"MyBasicTextViewInfoCell的编辑类型必须为MyBasicInfoCellTypeCustomEdit"
                                     userInfo:nil];
    }
    
    if (_textView) {
        _textView.editable = editable;
        _textView.text = [self valueTitle];
    }
}

#pragma mark -

- (BOOL)canBeginEdit {
    return _textView != nil;
}

- (BOOL)canBeginEditForDidSelected {
    return NO;
}

- (BOOL)isTextEdit {
    return YES;
}

- (void)beginEdit:(BOOL)animated completedBlock:(void (^)(void))completedBlock {
    [_textView becomeFirstResponder];
}

- (void)endEdit:(BOOL)animated completedBlock:(void(^)(void))completedBlock {
    [_textView resignFirstResponder];
}

- (BOOL)isInfoEditting {
    return [_textView isFirstResponder];
}

#pragma mark -

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (_textView == textView) {
        return [self willBeginEdit];
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (_textView == textView) {
        [self didBeginEdit];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (_textView == textView) {
        [self didEndEdit];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (_textView == textView) {
        return [self willEditToNewValue:[_textView.text stringByReplacingCharactersInRange:range withString:text]];
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (_textView == textView) {
        [self didEditToNewValue:_textView.text];
    }
}

- (CGPoint)textEndPointForTextView
{
    if (_textView && [_textView isDescendantOfView:self]) {
        CGRect caretRect = [_textView caretRectForPosition:_textView.endOfDocument];
        return [self convertPoint:CGPointMake(CGRectGetMaxX(caretRect), CGRectGetMaxY(caretRect)) fromView:_textView];
    }
    
    return CGPointZero;
}

@end
