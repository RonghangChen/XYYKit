//
//  MyBasicInfoCellPickerPopoverView.h
//  
//
//  Created by LeslieChen on 15/3/23.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyBasicInfoCellEditerPopoverView.h"

//----------------------------------------------------------

@class MyBasicInfoCellPickerPopoverView;

//----------------------------------------------------------

@protocol MyBasicInfoCellPickerPopoverViewDelegate <MyInfoCellEditerDelegate>

@optional

- (CGFloat)contentHeightForPickerPopoverView:(MyBasicInfoCellPickerPopoverView *)pickerPopoverView
                             containerHeight:(CGFloat)containerHeight;

@end

//----------------------------------------------------------

@interface MyBasicInfoCellPickerPopoverView : MyBasicInfoCellEditerPopoverView

@property(nonatomic,weak) id<MyBasicInfoCellPickerPopoverViewDelegate> delegate;
@property(nonatomic,strong,readonly) UIView * pickerContainerView;

- (CGFloat)designContentHeightForContainerSize:(CGSize)size;

@end
