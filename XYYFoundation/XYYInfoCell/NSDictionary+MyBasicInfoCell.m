//
//  NSDictionary+MyBasicInfoCell.m
//  
//
//  Created by LeslieChen on 15/3/23.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "NSDictionary+MyBasicInfoCell.h"
#import "NSDictionary+MyCategory.h"
#import "MyInfoCellEditerProtocol.h"
#import "UIView+Instance.h"
#import "MyInfoCellTextEditerPopoverView.h"
#import "MyInfoCellDatePickerPopoverView.h"
#import "MyInfoCellSinglePickerPopoverView.h"
#import "MyInfoCellDetailTextEditerPopoverView.h"

//----------------------------------------------------------

@implementation NSDictionary (MyBasicInfoCell)

- (NSDictionary *)infoCellInfo {
    return [self valueForKey:@"cellInfo" withClass:[NSDictionary class]];
}

- (MyBasicInfoCellType)infoCellType {
    return [self integerValueForKey:@"type"];
}

- (MyBasicInfoCellEditType)infoCellEditType {
    return [self integerValueForKey:@"editType"];
}

- (NSString *)infoCellKey {
    return [self stringValueForKey:@"key"];
}

- (NSArray *)infoValues {
    return [self valueForKey:@"values" withClass:[NSArray class]];
}

- (id)value {
    return self[@"value"];
}

- (NSString *)valuePlaceholder {
    return [self stringValueForKey:@"valuePlaceholder"];
}

- (NSInteger)indexForValue:(id)value
{
    NSArray * infoValues = [self infoValues];
    if (infoValues && value) {
        NSInteger i = 0;
        for (NSDictionary * infoValue in infoValues) {
            if ([[infoValue value] isEqual:value]) {
                return i;
            }
            ++ i;
        }
    }
    
    return NSNotFound;
}

- (NSDictionary *)infoValueForValue:(id)value
{
    NSArray * infoValues = [self infoValues];
    if (infoValues && value) {
        for (NSDictionary * infoValue in infoValues) {
            if ([[infoValue value] isEqual:value]) {
                return infoValue;
            }
        }
    }
    
    return nil;
}

- (id<MyInfoCellEditerProtocol>)infoCellEditer
{
    NSString * editerClassName = [self valueForKey:@"editerClass" withClass:[NSString class]];
    Class editerClass = NSClassFromString(editerClassName);
    
    if(![editerClass conformsToProtocol:@protocol(MyInfoCellEditerProtocol)]){
        
        switch ([self infoCellEditType]) {
            case MyBasicInfoCellEditTypePicker:
                editerClass = [MyInfoCellSinglePickerPopoverView class];
            break;
            
            case MyBasicInfoCellEditTypePickerDate:
                editerClass = [MyInfoCellDatePickerPopoverView class];
            break;
            
            case MyBasicInfoCellEditTypeText:
                editerClass = [MyInfoCellTextEditerPopoverView class];
            break;
                
            case MyBasicInfoCellEditTypeDetailText:
                editerClass = [MyInfoCellDetailTextEditerPopoverView class];
            break;
            
            default:
                editerClass = nil;
            break;
        }
    }
    
    return [editerClass isSubclassOfClass:[UIView class]] ? [editerClass xyy_createInstance] : [editerClass new];
}

- (MyBasicInfoCellDatePickerMode)infoCellDatePickerMode {
    return [[self valueForKey:@"datePickerMode" canRespondsToSelector:@selector(integerValue)] integerValue];
}

- (MyBasicInfoCellDateLimitMode)infoCellDateLimitMode {
    return [[self valueForKey:@"dateLimitMode" canRespondsToSelector:@selector(integerValue)] integerValue];
}

- (NSDateFormatter *)infoDateFormatter
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
    
    switch ([self infoCellDatePickerMode]) {
        case UIDatePickerModeTime:
        case UIDatePickerModeCountDownTimer:
        dateFormatter.dateFormat = @"HH:mm";
        break;
        
        case UIDatePickerModeDate:
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        break;
        
        case UIDatePickerModeDateAndTime:
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
        break;
        
        default:
        break;
    }

    return dateFormatter;
}

- (NSDate *)infoDateForValue:(id)value
{
    if ([value isKindOfClass:[NSDate class]]) {
        return value;
    }else{
        
        NSString * dateStr = [value description];
        
        if (dateStr.length) {
            NSDateFormatter * dateFormatter = self.infoDateFormatter;
            NSDate * date = nil;
            if ([dateFormatter getObjectValue:&date forString:dateStr errorDescription:NULL]) {
                return date;
            }
        }
        return nil;
    }
}


- (NSString *)infoDateStrForValue:(id)value
{
    if ([value isKindOfClass:[NSDate class]]) {
        return [self.infoDateFormatter stringFromDate:value];
    }
    
    return [value description];
}

- (NSDate *)_infoCellDateForKey:(NSString *)key {
    return [self infoDateForValue:[self stringValueForKey:key]];
}

- (NSDate *)infoCellMaxDate {
    return [self _infoCellDateForKey:@"maxDate"];
}

- (NSDate *)infoCellMinDate {
    return [self _infoCellDateForKey:@"minDate"];
}

- (NSString *)infoCellPlaceholderText {
    return [self stringValueForKey:@"placeholder"];
}

- (NSInteger)infoCellMinTextLenght {
    return [self integerValueForKey:@"minTextLenght"];
}

- (NSInteger)infoCellMaxTextLenght {
    return [self integerValueForKey:@"maxTextLenght"] ?: NSIntegerMax;
}

- (UIKeyboardType)infoCellKeyboardType {
    return [self integerValueForKey:@"keyboardType"];
}

- (MyInfoCellValueTextType)infoCellValueTextType {
    return [self integerValueForKey:@"valueTextType"];
}

- (MyInfoCellValueSignType)infoCellValueSignType {
    return [self integerValueForKey:@"valueSignType"];
}

- (NSString *)infoCellValueRegex {
    return [self stringValueForKey:@"valueRegex"];
}

- (BOOL)infoCellTextCanNull {
    return [self boolValueForKey:@"textCanNull"];
}

@end
