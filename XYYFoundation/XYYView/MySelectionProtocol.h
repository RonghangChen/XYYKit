//
//  MySelectionPro.h

//
//  Created by LeslieChen on 15/1/24.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

typedef NS_OPTIONS(NSUInteger,MySelectionOption) {
    MySelectionOptionNone        = 0,
    MySelectionOptionHighlighted = 1 << 0,
    MySelectionOptionSelected    = 1 << 1,
    MySelectionOptionAll         = ~0UL
};

//----------------------------------------------------------

@protocol MySelectionProtocol

//默认为MySelectionOptionNone
@property(nonatomic) MySelectionOption selectionOption;

//默认为nil，使用tintColor
@property(nonatomic,strong) UIColor * selectionColor;
//selectionColor的透明度
@property(nonatomic) CGFloat selectionColorAlpha;

//显示的选择颜色
- (UIColor *)showingSelectionColor;
//选择的颜色改变
- (void)selectionColorDidChange;

//高亮的的对象
@property(nonatomic,strong) NSArray * highlightedObjects;

//是否在显示选择
@property(nonatomic,readonly,getter = isShowingSelection) BOOL showingSelection;

//当消失的时候选择是否强制有动画，默认为NO
@property(nonatomic) BOOL animatedSelectionForHidden;

@optional

- (UIView *)showSelectionView;

@property (nonatomic, getter=isSelected)  BOOL   selected;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

@end
