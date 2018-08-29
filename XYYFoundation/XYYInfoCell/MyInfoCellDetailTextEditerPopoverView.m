//
//  MyInfoCellDetailTextEditerPopoverView.m
//  
//
//  Created by LeslieChen on 15/10/19.
//  Copyright © 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyInfoCellDetailTextEditerPopoverView.h"
#import "NSDictionary+MyCategory.h"
#import "NSDictionary+MyBasicInfoCell.h"
#import "MyTextView.h"
#import "MySegmentedControl.h"
#import "MyBorderView.h"
#import "XYYConst.h"
#import "XYYMessageUtil.h"
#import "MyPopoverView.h"

//----------------------------------------------------------

@interface MyInfoCellDetailTextEditerPopoverView () < UITextViewDelegate >

@property (strong, nonatomic) IBOutlet MyBorderView *titleView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet MyTextView *textView;
@property (strong, nonatomic) IBOutlet MySegmentedControl *buttonSegmentedControl;
@property (strong, nonatomic) IBOutlet UILabel *textLenghtIndicaterLabel;

@property(nonatomic) NSInteger minTextLenght;
@property(nonatomic) NSInteger maxTextLenght;

//是否可以换行
@property(nonatomic) BOOL canWarp;

@end

//----------------------------------------------------------

@implementation MyInfoCellDetailTextEditerPopoverView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    super.contentAnchorPoint = CGPointMake(0.5f, 0.f);
    super.locationAnchorPoint = CGPointMake(0.5f, 0.2f);
    
    self.layer.cornerRadius = 5.f;
    self.clipsToBounds = YES;
    
    self.titleView.borderColor = ColorWithNumberRGB(0xC3C3C3);
    self.titleView.borderMask = MyBorderBottom;
    
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
    self.textView.text = self.value;
    self.textView.placeholderText = [self.info infoCellPlaceholderText];
    self.textView.keyboardType = [self.info infoCellKeyboardType];
    self.canWarp = [self.info infoCellTextCanWrap];
    
    //文本长度
    _minTextLenght = [self.info infoCellMinTextLenght];
    _maxTextLenght = [self.info infoCellMaxTextLenght];
    _minTextLenght = MIN(_minTextLenght, _maxTextLenght);
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

- (void)setCanWarp:(BOOL)canWarp
{
    _canWarp = canWarp;
    self.textView.returnKeyType = _canWarp ? UIReturnKeyDefault : UIReturnKeyDone;
}

- (id)newValue {
    return  self.textView.text;
}

#pragma mark -

- (void)textViewDidChange:(UITextView *)textView {
    [self _updateTextLenghtIndicater];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (!self.canWarp  && [text isEqualToString:@"\n"]) {
        [self tryEditToNewValue];
        return NO;
    }
    
    return YES;
}


- (void)_updateTextLenghtIndicater
{
    NSInteger textLenght = self.textView.text.length;
    
    //太短
    if (textLenght < self.minTextLenght) {
        self.textLenghtIndicaterLabel.hidden = NO;
        self.textLenghtIndicaterLabel.text = [NSString stringWithFormat:@"+%i",(int)(self.minTextLenght - textLenght)];
        [self.buttonSegmentedControl setEnabled:NO forSectionAtIndex:1];
        return;
    }
    
    //太长
    if (textLenght > self.maxTextLenght) {
        self.textLenghtIndicaterLabel.hidden = NO;
        self.textLenghtIndicaterLabel.text = [NSString stringWithFormat:@"%i",(int)(self.maxTextLenght - textLenght)];
        [self.buttonSegmentedControl setEnabled:NO forSectionAtIndex:1];
        return;
    }
    
    self.textLenghtIndicaterLabel.hidden = YES;
    [self.buttonSegmentedControl setEnabled:YES forSectionAtIndex:1];
}

#pragma mark -

- (BOOL)needObserverKeyboardChangePosition {
    return YES;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat width = MIN(300.f, ceilf(size.width * 0.8f));
    return CGSizeMake(width, ceilf(width / 260.f * 200.f));
}

- (void)startPopoverViewShow:(BOOL)show animated:(BOOL)animated
{
    if (!show) {
        [self.textView resignFirstResponder];
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
        [self.textView becomeFirstResponder];
    }
}

- (BOOL)popoverViewWillTapHiddenAtPoint:(CGPoint)point
{
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
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
    [self.textView resignFirstResponder];
    
    NSUInteger textLenght = self.textView.text.length;
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
    
    return [super tryEditToNewValue];
}

@end


@implementation NSDictionary (MyInfoCellDetailTextEditerPopoverView)

- (BOOL)infoCellTextCanWrap {
    return [self boolValueForKey:@"canWrap"];
}

@end
