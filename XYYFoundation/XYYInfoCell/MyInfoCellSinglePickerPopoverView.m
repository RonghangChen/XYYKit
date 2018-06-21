//
//  MyInfoCellSinglePickerPopoverView.m
//  
//
//  Created by LeslieChen on 15/3/23.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyInfoCellSinglePickerPopoverView.h"
#import "NSDictionary+MyBasicInfoCell.h"
#import "ScreenAdaptation.h"
#import "NSDictionary+MyCategory.h"

//----------------------------------------------------------

@interface MyInfoCellSinglePickerPopoverView () < UIPickerViewDataSource,
                                                  UIPickerViewDelegate>

@property(nonatomic,strong) UIPickerView * pickerView;

@end

//----------------------------------------------------------

@implementation MyInfoCellSinglePickerPopoverView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:[self _designInitFrame]];
    
    if (self) {
        
        [self layoutIfNeeded];
        
        self.pickerView = [[UIPickerView alloc] initWithFrame:self.pickerContainerView.bounds];
        self.pickerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.pickerView.delegate = self;
        self.pickerView.dataSource = self;
        self.pickerView.showsSelectionIndicator = YES;
        [self.pickerContainerView addSubview:self.pickerView];
    }
    
    return self;
}

#pragma mark -

- (void)updateWithInfo:(NSDictionary *)info value:(id)value
{
    [super updateWithInfo:info value:value];
    [self.pickerView reloadAllComponents];
    
    NSInteger i = [info indexForValue:value];
    if (i != NSNotFound) {
        [self.pickerView selectRow:i inComponent:0 animated:NO];
    }
}

- (id)newValue
{
    NSInteger selectedRow =  [self.pickerView selectedRowInComponent:0];
    if (selectedRow != -1) {
        return [(NSDictionary *)self.values[selectedRow] value];
    }
    
    return nil;
}

#pragma mark - 

- (CGFloat)designContentHeightForContainerSize:(CGSize)size {
    return ceilf(MAX(235.f, MIN(205.f, size.height * 0.4f)));
}

- (CGRect)_designInitFrame {
    return CGRectMake(0.f, 0.f, screenSize().width, [self designContentHeightForContainerSize:screenSize()]);
}

#pragma mark -

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.values.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30.f;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if (![view isKindOfClass:[UILabel class]]) {
        
        UILabel * label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:20.f];
        label.textAlignment = NSTextAlignmentCenter;
        view = label;
    }
    
    NSString * title = [self.values[row] myTitle];
    title = title ?: [(NSDictionary *)self.values[row] value];
    [(UILabel *)view setText:title];
    
    return view;
}



@end
