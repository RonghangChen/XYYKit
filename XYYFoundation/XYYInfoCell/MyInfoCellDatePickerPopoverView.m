//
//  MyInfoCellDatePickerPopoverView.m
//  
//
//  Created by LeslieChen on 15/3/24.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyInfoCellDatePickerPopoverView.h"
#import "NSDictionary+MyBasicInfoCell.h"

//----------------------------------------------------------

@interface MyInfoCellDatePickerPopoverView ()

@property(nonatomic,strong) UIDatePicker * datePicker;

@end

//----------------------------------------------------------

@implementation MyInfoCellDatePickerPopoverView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        
        self.datePicker = [[UIDatePicker alloc] initWithFrame:self.pickerContainerView.bounds];
        self.datePicker.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.pickerContainerView addSubview:self.datePicker];
    }
    
    return self;
}

- (void)updateWithInfo:(NSDictionary *)info value:(id)value
{
    [super updateWithInfo:info value:value];
    
    self.datePicker.datePickerMode = [info infoCellDatePickerMode];
    
    NSDate * maxDate = [info infoCellMaxDate];
    NSDate * minDate = [info infoCellMinDate];
    
    if (maxDate && minDate) {
        self.datePicker.maximumDate = maxDate;
        self.datePicker.minimumDate = minDate;
    }else {
        
        MyBasicInfoCellDateLimitMode limitMode = [info infoCellDateLimitMode];
        
        if (limitMode == MyBasicInfoCellDateLimitModeToCurrent) {
            self.datePicker.maximumDate = [NSDate date];
            self.datePicker.minimumDate = minDate;
        }else{
            self.datePicker.minimumDate = [NSDate date];
            self.datePicker.maximumDate = [maxDate laterDate:minDate] ? maxDate : nil;
        }
    }
    
    NSDate * date = [info infoDateForValue:value] ?: [info infoDateForValue:info.valuePlaceholder];
    self.datePicker.date = date ?: [NSDate date];
}

- (id)newValue
{
    if ([self.value isKindOfClass:[NSDate class]]) {
        return self.datePicker.date;
    }else if([self.value isKindOfClass:[NSString class]]) {
        return [self.info infoDateStrForValue:self.datePicker.date];
    }
    
    return self.datePicker.date;
}

- (CGFloat)designContentHeightForContainerSize:(CGSize)size {
    return [self.datePicker sizeThatFits:size].height;
}


@end
