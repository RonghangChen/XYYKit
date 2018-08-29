//
//  MyInfoCellTextEditerPopoverView.m
//  
//
//  Created by LeslieChen on 15/3/24.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyInfoCellTextEditerPopoverView.h"
#import "MySegmentedControl.h"
#import "NSString+Predicate.h"
#import "XYYConst.h"
#import "NSDictionary+MyBasicInfoCell.h"
#import "MyPopoverView.h"
#import "XYYMessageUtil.h"

//----------------------------------------------------------

@interface MyInfoCellTextEditerPopoverView () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITextField *textFileld;
@property (strong, nonatomic) IBOutlet MySegmentedControl *buttonSegmentedControl;
@property (strong, nonatomic) IBOutlet UILabel *textLenghtIndicaterLabel;

@property(nonatomic) NSInteger minTextLenght;
@property(nonatomic) NSInteger maxTextLenght;

//文本是否可以为空
@property(nonatomic) BOOL textCanNull;

@end

//----------------------------------------------------------

@implementation MyInfoCellTextEditerPopoverView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    super.contentAnchorPoint = CGPointMake(0.5f, 0.f);
    super.locationAnchorPoint = CGPointMake(0.5f, 0.2f);
    
    self.layer.cornerRadius = 5.f;
    self.clipsToBounds = YES;
    
    self.buttonSegmentedControl.drawGradientSeparatorLine = NO;
    [self.buttonSegmentedControl addSectionsWithTitles:@[@"取消",@"确定"]];
    self.buttonSegmentedControl.borderMask = MySegmentedControlBorderTop;
    self.buttonSegmentedControl.borderColor = ColorWithNumberRGB(0xC3C3C3);
    self.buttonSegmentedControl.separatorLineColor = ColorWithNumberRGB(0xC3C3C3);
    [self.buttonSegmentedControl setTextFont:[UIFont systemFontOfSize:14.F]];
    [self.buttonSegmentedControl setTextColor:[UIColor grayColor] forState:MySegmentedControlSectionStateNormal];
    [self.buttonSegmentedControl setTextColor:ColorWithNumberRGB(0xD3D3D3) forState:MySegmentedControlSectionStateDisabled];
    self.buttonSegmentedControl.autoAdjustTextColor = NO;
    [self.buttonSegmentedControl setSectionBackgroundColor:ColorWithNumberRGB(0xEEEEEE)
                                                  forState:MySegmentedControlSectionStateHighlighted];
    self.buttonSegmentedControl.momentary = YES;
}

- (void)setContentAnchorPoint:(CGPoint)contentAnchorPoint {
}

- (void)setLocationAnchorPoint:(CGPoint)locationAnchorPoint {
}

#pragma mark -

- (Class)valueExpectedClass {
    return [NSString class];
}

- (void)updateWithInfo:(NSDictionary *)info value:(id)value
{
    [super updateWithInfo:info value:value];
    
    //设置文本
    self.textFileld.text = self.value;
    self.textFileld.placeholder = [self.info infoCellPlaceholderText];
    
    MyInfoCellValueTextType valueTextType = [self.info infoCellValueTextType];
    if (valueTextType == MyInfoCellValueTextTypePhoneNumber) {

        self.textFileld.keyboardType = UIKeyboardTypePhonePad;
        self.minTextLenght = self.maxTextLenght = 11;
        
    }else if (valueTextType == MyInfoCellValueTextTypeEmail) {
        
        self.textFileld.keyboardType = UIKeyboardTypeEmailAddress;
        self.minTextLenght = 5;
        self.maxTextLenght = NSIntegerMax;
        
    }else if (valueTextType == MyInfoCellValueTextTypeQQ) {
        
        self.textFileld.keyboardType = UIKeyboardTypeNumberPad;
        self.minTextLenght = 5;
        self.maxTextLenght = 11;
        
    }else {
        
        if (valueTextType == MyInfoCellValueTextTypeNumber) {  //数字
            self.textFileld.keyboardType = UIKeyboardTypeNumberPad;
        }else if (valueTextType == MyInfoCellValueTextTypeInteger) { //整形
            MyInfoCellValueSignType signType = [self.info infoCellValueSignType];
            if (signType == MyInfoCellValueSignTypePositive ||
                signType == MyInfoCellValueSignTypeUnNegative) { //只能输入正数
                self.textFileld.keyboardType = UIKeyboardTypeNumberPad;
            }else {
                self.textFileld.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            }
        }else if (valueTextType == MyInfoCellValueTextTypeDouble ||
                  valueTextType == MyInfoCellValueTextTypeMoney) { //浮点
            MyInfoCellValueSignType signType = [self.info infoCellValueSignType];
            if (signType == MyInfoCellValueSignTypePositive ||
                signType == MyInfoCellValueSignTypeUnNegative) { //只能输入正数
                self.textFileld.keyboardType = UIKeyboardTypeDecimalPad;
            }else {
                self.textFileld.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            }
        }else {
            self.textFileld.keyboardType = [self.info infoCellKeyboardType];
        }
        
        //文本长度
        self.minTextLenght = [self.info infoCellMinTextLenght];
        self.maxTextLenght = [self.info infoCellMaxTextLenght];
        self.minTextLenght = MIN(self.minTextLenght, self.maxTextLenght);
    }
    
    self.textCanNull = [self.info infoCellTextCanNull];
    
    //更新长度指示
    [self _updateTextLenghtIndicater];
}

- (void)setTitle:(NSString *)title
{
    super.title = title;
    
    if (title.length) {
        self.titleLabel.text = [NSString stringWithFormat:@"编辑 %@",title];
    }else{
        self.titleLabel.text = @"编辑";
    }
}

- (id)newValue {
    return self.textFileld.text;
}

#pragma mark - 

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self tryEditToNewValue];
    return NO;
}

- (IBAction)_textFieldTextDidChange:(id)sender {
    [self _updateTextLenghtIndicater];
}

- (void)_updateTextLenghtIndicater
{
    NSInteger textLenght = self.textFileld.text.length;
    
    if ((textLenght >= self.minTextLenght && textLenght<= self.maxTextLenght) ||
        (textLenght == 0 && self.textCanNull)) {
        
        self.textLenghtIndicaterLabel.hidden = YES;
        [self.buttonSegmentedControl setEnabled:YES forSectionAtIndex:1];
        
    }else {
        
        self.textLenghtIndicaterLabel.hidden = NO;
        [self.buttonSegmentedControl setEnabled:NO forSectionAtIndex:1];
        
        if (textLenght < self.minTextLenght) {
            self.textLenghtIndicaterLabel.text = [NSString stringWithFormat:@"%+d",(int)(self.minTextLenght - textLenght)];
        }else {
            self.textLenghtIndicaterLabel.text = [NSString stringWithFormat:@"%d",(int)(self.maxTextLenght - textLenght)];
        }
    }
}

#pragma mark -

- (BOOL)needObserverKeyboardChangePosition {
    return YES;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(260.f, 140.f);
}

- (void)startPopoverViewShow:(BOOL)show animated:(BOOL)animated
{
    if (!show) {
        [self.textFileld resignFirstResponder];
    }else if(animated){
        self.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
        [UIView animateWithDuration:0.5f
                              delay:0.f
             usingSpringWithDamping:0.4f
              initialSpringVelocity:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.transform = CGAffineTransformIdentity;
                         } completion:nil];
    }
}

- (void)endPopoverViewShow:(BOOL)show animated:(BOOL)animated
{
    if (show) {
        [self.textFileld becomeFirstResponder];
    }
}

- (BOOL)popoverViewWillTapHiddenAtPoint:(CGPoint)point
{
    if ([self.textFileld isFirstResponder]) {
        [self.textFileld resignFirstResponder];
    }else{
        return [super popoverViewWillTapHiddenAtPoint:point];
    }
    
    return NO;
}

#pragma mark -

- (IBAction)_buttonsHandle:(id)sender
{
    if (self.buttonSegmentedControl.selectedSectionIndex) {
        [self tryEditToNewValue];
    }else{
        [self didEndEditByCancle];
    }
}

#pragma mark -

- (BOOL)tryEditToNewValue
{
    [self.textFileld resignFirstResponder];
    
    //长度判断
    NSUInteger textLenght = self.textFileld.text.length;
    if (!self.textCanNull || textLenght != 0) {
        
        NSString * alertText = nil;
        
        if (self.minTextLenght == self.maxTextLenght && textLenght != self.minTextLenght) {
            alertText = [NSString stringWithFormat:@"必须为%i个字符",(int)self.minTextLenght];
        }else if (textLenght < self.minTextLenght) {
            alertText = [NSString stringWithFormat:@"不能少于%i个字符",(int)self.minTextLenght];
        }else if (textLenght > self.maxTextLenght) {
            alertText = [NSString stringWithFormat:@"不能超过%i个字符",(int)self.maxTextLenght];
        }
        
        if (alertText != nil) {
            [[XYYMessageUtil shareMessageUtil] showErrorMessageInView:self.window withTitle:self.title.length ? [NSString stringWithFormat:@"%@%@",self.title,alertText] : alertText detail:nil duration:0.0 completedBlock:nil];
            return NO;
        }

    }
    

    //内容判断
    if (textLenght != 0) {
        
        BOOL bRet = YES;
        
        MyInfoCellValueTextType valueTextType = [self.info infoCellValueTextType];
        if (valueTextType == MyInfoCellValueTextTypePhoneNumber) { //电话
            bRet = [self.textFileld.text isPhoneNumber];
        }else if (valueTextType == MyInfoCellValueTextTypeEmail) { //邮箱
            bRet = [self.textFileld.text isEmailAddress];
        }else if (valueTextType == MyInfoCellValueTextTypeQQ) { //QQ
            bRet = [self.textFileld.text isQQNumber];
        }else if (valueTextType == MyInfoCellValueTextTypeNumber) { //数字
            bRet = [self.textFileld.text isNumber];
        }else if(valueTextType == MyInfoCellValueTextTypeInteger ||
                 valueTextType == MyInfoCellValueTextTypeDouble ||
                 valueTextType == MyInfoCellValueTextTypeMoney) { //整形和浮点
            
            //获取符号信息
            MySignOption sign = MySignOptionAll;
            switch ([self.info infoCellValueSignType]) {
                case MyInfoCellValueSignTypeNegative:
                    sign = MySignOptionNegative;
                    break;
                
                case MyInfoCellValueSignTypePositive:
                    sign = MySignOptionPositive;
                    break;
                    
                case MyInfoCellValueSignTypeUnPositive:
                    sign = MySignOptionUnPositive;
                    break;
                    
                case MyInfoCellValueSignTypeUnNegative:
                    sign = MySignOptionUnNegative;
                    break;
                    
                default:
                    break;
            }
            
            if (valueTextType == MyInfoCellValueTextTypeInteger) {
                bRet = [self.textFileld.text isInteger:sign];
            }else if (valueTextType == MyInfoCellValueTextTypeDouble) {
                bRet = [self.textFileld.text isDouble:sign];
            }else if (valueTextType == MyInfoCellValueTextTypeMoney) {
                bRet = [self.textFileld.text isMoney:sign];
            }
            
        }else {
            
            //自定义正则
            NSString * regex = [self.info infoCellValueRegex];
            if (regex.length) {
                bRet = [self.textFileld.text isMatchRegex:regex];
            }
            
        }
        
        if (!bRet) {
             [[XYYMessageUtil shareMessageUtil] showErrorMessageInView:self.window withTitle:[NSString stringWithFormat:@"输入的%@不合法",self.title.length ? self.title : @"内容"] detail:nil duration:0.0 completedBlock:nil];
            
            return NO;
        }
    }

    return [super tryEditToNewValue];
}


@end
