//
//  MyBasicTextFieldViewInfoCell.m
//  QingYang_iOS
//
//  Created by 陈荣航 on 2018/4/9.
//  Copyright © 2018年 leslie. All rights reserved.
//

#import "MyBasicTextFieldViewInfoCell.h"

@implementation MyBasicTextFieldViewInfoCell

- (void)setupTextField:(UITextField *)textField
{
    if (_textField == nil && textField != nil) {
        _textField = textField;
        _textField.delegate = self;
        
        [_textField addTarget:self
                       action:@selector(_textDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    }
}

#pragma mark -

- (void)updateWithInfoCellInfo:(NSDictionary *)infoCellInfo value:(id)value editable:(BOOL)editable context:(MyCellContext *)context
{
    [super updateWithInfoCellInfo:infoCellInfo value:value editable:editable context:context];
    
    if ([infoCellInfo infoCellType] != MyBasicInfoCellTypeCustomEdit) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"MyBasicTextFieldViewInfoCell的编辑类型必须为MyBasicInfoCellTypeCustomEdit"
                                     userInfo:nil];
    }
    
    if (_textField) {
        _textField.enabled = editable;
        _textField.text = [self valueTitle];
        _textField.placeholder = self.infoCellInfo.infoCellPlaceholderText;
    }
}

#pragma mark -

- (BOOL)canBeginEdit {
    return _textField != nil;
}

- (BOOL)canBeginEditForDidSelected {
    return NO;
}

- (BOOL)isTextEdit {
    return YES;
}

- (void)beginEdit:(BOOL)animated completedBlock:(void (^)(void))completedBlock {
    [_textField becomeFirstResponder];
}

- (void)endEdit:(BOOL)animated completedBlock:(void(^)(void))completedBlock {
    [_textField resignFirstResponder];
}

- (BOOL)isInfoEditting {
    return [_textField isFirstResponder];
}

#pragma mark -

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (_textField == textField) {
        return [self willBeginEdit];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (_textField == textField) {
        [self didBeginEdit];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (_textField == textField) {
        [self didEndEdit];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (_textField == textField) {
        return [self willEditToNewValue:[textField.text stringByReplacingCharactersInRange:range withString:string]];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (_textField == textField && textField.text.length) {
        return [self willEditToNewValue:@""];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_textField == textField) {
        [textField resignFirstResponder];
        [self didEndEdit];
        
        return NO;
    }
    
    return YES;
}

- (void)_textDidChange:(UITextField *)textField
{
    if (_textField == textField) {
        [self didEditToNewValue:textField.text];
    }
}

@end
