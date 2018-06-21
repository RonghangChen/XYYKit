//
//  MyCollectionViewCell.m

//
//  Created by LeslieChen on 15/1/24.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyCollectionViewCell.h"
#import "XYYSizeUtil.h"

//----------------------------------------------------------

@interface MyCollectionViewCell ()

@property(nonatomic,strong,readonly) CALayer * selectionLayer;
@property(nonatomic,strong,readonly) CALayer * borderLayer;

@end

//----------------------------------------------------------

@implementation MyCollectionViewCell
{
    BOOL _needUpdateCellWhenShowInWindow;
}

@synthesize selectionLayer = _selectionLayer;
@synthesize selectionOption = _selectionOption;
@synthesize selectionColor = _selectionColor;
@synthesize selectionColorAlpha = _selectionColorAlpha;
@synthesize highlightedObjects = _highlightedObjects;
@synthesize animatedSelectionForHidden = _animatedSelectionForHidden;

@synthesize borderStyle = _borderStyle;
@synthesize borderMask = _borderMask;
@synthesize borderColor = _borderColor;
@synthesize borderWidth = _borderWidth;
@synthesize borderInset = _borderInset;
@synthesize borderLineInset = _borderLineInset;
@synthesize borderLineScaleInset = _borderLineScaleInset;
@synthesize borderLayer = _borderLayer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self _initCollectionViewCell];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _initCollectionViewCell];
    }
    
    return self;
}

- (void)_initCollectionViewCell
{
    _selectionColorAlpha = 1.f;
    self.borderWidth = PiexlToPoint(1.f);
}

#pragma mark -

- (void)layoutSubviews
{
    [super layoutSubviews];
//    
//    if (_selectionLayer) {
//        _selectionLayer.frame = [self showSelectionView].layer.bounds;
//    }
    
    [self _updateBorder];
}

#pragma mark - section

- (UIView *)showSelectionView {
    return self;
}

- (UIColor *)selectionColor{
    return _selectionColor ?: [self tintColor];
}

- (void)setSelectionColor:(UIColor *)selectionColor
{
    if(_selectionColor != selectionColor){
        _selectionColor = selectionColor;
        [self selectionColorDidChange];
    }
}

- (void)setSelectionColorAlpha:(CGFloat)selectionColorAlpha
{
    if (_selectionColorAlpha != selectionColorAlpha) {
        _selectionColorAlpha = selectionColorAlpha;
        [self selectionColorDidChange];
    }
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    if (!_selectionColor) {
        [self selectionColorDidChange];
    }
}

- (UIColor *)showingSelectionColor {
    return [self.selectionColor colorWithAlphaComponent:self.selectionColorAlpha];
}

- (void)selectionColorDidChange {
    [self _updateSelectionColor];
}

- (void)_updateSelectionColor
{
    if (!_selectionLayer) {
        return;
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _selectionLayer.backgroundColor = [self showingSelectionColor].CGColor;
    [CATransaction commit];
}


- (void)setSelectionOption:(MySelectionOption)selectionOption
{
    if (_selectionOption != selectionOption) {
        _selectionOption= selectionOption;
        
        if (_selectionOption == MySelectionOptionNone) {
            [_selectionLayer removeFromSuperlayer];
            _selectionLayer = nil;
        }else{
            [self _updateSelectionViewWithAnimated:NO];
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [self setHighlighted:highlighted animated:NO];
}

- (void)setSelected:(BOOL)selected {
    [self setSelected:selected animated:NO];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (self.isHighlighted != highlighted) {
        [super setHighlighted:highlighted];
        [self _updateSelectionViewWithAnimated:animated];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.isSelected != selected) {
        [super setSelected:selected];
        [self _updateSelectionViewWithAnimated:animated];
    }
}


- (BOOL)isShowingSelection {
    return _selectionLayer && !_selectionLayer.hidden;
}

- (CALayer *)selectionLayer
{
    if (!_selectionLayer) {
        _selectionLayer = [[CALayer alloc] init];
        _selectionLayer.actions = @{@"position":[NSNull null],@"bounds":[NSNull null]};
//        _selectionLayer.frame = [self showSelectionView].bounds;
        [self _updateSelectionColor];
    }
    
    return _selectionLayer;
}

- (void)_updateSelectionViewWithAnimated:(BOOL)animated
{
    BOOL show = NO;
    if (self.selectionOption & MySelectionOptionSelected) {
        if(self.selectionOption & MySelectionOptionHighlighted){
            show = self.isSelected || self.isHighlighted;
        }else{
            show = self.isSelected;
        }
    }else if (self.selectionOption & MySelectionOptionHighlighted) {
        show = self.isHighlighted;
    }
    
    [self _showSelectionView:show animated:animated || (!show && self.animatedSelectionForHidden)];
}

- (void)_showSelectionView:(BOOL)show animated:(BOOL)animated
{
    //正在显示
    if ([self isShowingSelection] == show) {
        return;
    }
    
    for (NSObject * object in self.highlightedObjects) {
        if([object respondsToSelector:@selector(setHighlighted:)]){
            [(id)object setHighlighted:show];
        }
    }
    
    if (show) {
        
        [[self showSelectionView].layer insertSublayer:self.selectionLayer atIndex:0];
        self.selectionLayer.frame = [self showSelectionView].bounds;
        
        [CATransaction begin];
        [CATransaction setDisableActions:!animated];
        _selectionLayer.hidden = NO;
        [CATransaction commit];
        
    }else{
        
        [CATransaction begin];
        [CATransaction setDisableActions:!animated];
        _selectionLayer.hidden = YES;
        [CATransaction commit];
    }
}


#pragma mark - border

#define IMP_MUTATOR(mutator, ctype, member, selector) \
- (void)mutator (ctype)value \
{ \
    if(member != value){ \
        member = value; \
        if(selector){ \
            [self performSelector:selector withObject:nil];\
        }\
    }\
}

IMP_MUTATOR(setBorderMask:, MyBorderMask, _borderMask, @selector(setNeedsLayout))
IMP_MUTATOR(setBorderColor:, UIColor *, _borderColor, @selector(setNeedsLayout))
IMP_MUTATOR(setBorderStyle:, MyLineStyle, _borderStyle, @selector(setNeedsLayout))
IMP_MUTATOR(setBorderWidth:, CGFloat, _borderWidth, @selector(setNeedsLayout))

- (void)setBoderInset:(UIEdgeInsets)borderInset
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_borderInset,borderInset)) {
        _borderInset =borderInset;
        [self setNeedsLayout];
    }
}

- (void)setBoderLineInset:(UIEdgeInsets)borderLineInset
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_borderLineInset,borderLineInset)) {
        _borderLineInset =borderLineInset;
        [self setNeedsLayout];
    }
}

- (void)setBorderLineScaleInset:(UIEdgeInsets)borderLineScaleInset
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_borderLineScaleInset, borderLineScaleInset)) {
        _borderLineScaleInset = borderLineScaleInset;
        [self setNeedsLayout];
    }
}

- (UIColor *)borderColor {
    return _borderColor ?: [UIColor blackColor];
}

#pragma mark -

- (BOOL)showTopBorder {
    return _borderMask & MyBorderTop;
}

- (void)setShowTopBorder:(BOOL)showTopBorder
{
    if (showTopBorder) {
        self.borderMask |= MyBorderTop;
    }else {
        self.borderMask = _borderMask & (~MyBorderTop);
    }
}

- (BOOL)showLeftBorder {
    return _borderMask & MyBorderLeft;
}

- (void)setShowLeftBorder:(BOOL)showLeftBorder
{
    if (showLeftBorder) {
        self.borderMask |= MyBorderLeft;
    }else {
        self.borderMask = _borderMask & (~MyBorderLeft);
    }
}

- (BOOL)showBottomBorder {
    return _borderMask & MyBorderBottom;
}

- (void)setShowBottomBorder:(BOOL)showBottomBorder
{
    if (showBottomBorder) {
        self.borderMask |= MyBorderBottom;
    }else {
        self.borderMask = _borderMask & (~MyBorderBottom);
    }
}

- (BOOL)showRightBorder {
    return _borderMask & MyBorderRight;
}

- (void)setShowRightBorder:(BOOL)showRightBorder
{
    if (showRightBorder) {
        self.borderMask |= MyBorderRight;
    }else {
        self.borderMask = _borderMask & (~MyBorderRight);
    }
}

#pragma mark -

- (CALayer *)borderLayer
{
    if (!_borderLayer) {
        _borderLayer = [CALayer layer];
    }
    
    return _borderLayer;
}

- (void)_updateBorder
{
    //移除现有的边界
    _borderLayer.sublayers = nil;
    [_borderLayer removeFromSuperlayer];
    
    if (self.borderMask == MyBorderNone || self.borderWidth <= 0.f) {
        return;
    }
    
    [self.layer addSublayer:self.borderLayer];
    
    CGRect borderContainerRect = UIEdgeInsetsInsetRect(self.bounds, self.borderInset);
    borderContainerRect.size.width = MAX(0.f, borderContainerRect.size.width);
    borderContainerRect.size.height = MAX(0.f, borderContainerRect.size.height);
    
    MyBorderMask mask[4] = {
        MyBorderTop,
        MyBorderBottom,
        MyBorderLeft,
        MyBorderRight};
    
    for (int i = 0; i < 4; ++ i) {
        
        if (self.borderMask & mask[i]) {
            
            CGPoint startPoint = CGPointZero;
            CGPoint endPoint = CGPointZero;
            
            if (mask[i] == MyBorderTop || mask[i] == MyBorderBottom) {
                
                CGFloat width = CGRectGetWidth(borderContainerRect);
                startPoint.x = CGRectGetMinX(borderContainerRect) + self.borderLineInset.left + self.borderLineScaleInset.left * width;
                endPoint.x = CGRectGetMaxX(borderContainerRect) - self.borderLineInset.right - self.borderLineScaleInset.right * width;
                
                if (startPoint.x >= endPoint.x) {
                    continue;
                }
                
                if (mask[i] == MyBorderTop) {
                    startPoint.y = CGRectGetMinY(borderContainerRect) + self.borderWidth * 0.5f;
                }else{
                    startPoint.y  = CGRectGetMaxY(borderContainerRect) - self.borderWidth * 0.5f;
                }
                
                endPoint.y = startPoint.y;
                
            }else{
                
                CGFloat height = CGRectGetHeight(borderContainerRect);
                startPoint.y = CGRectGetMinY(borderContainerRect) + self.borderLineInset.top + self.borderLineScaleInset.top * height;
                endPoint.y = CGRectGetMaxY(borderContainerRect) - self.borderLineInset.bottom - self.borderLineScaleInset.bottom * height;
                
                if (startPoint.y >= endPoint.y) {
                    continue;
                }
                
                if (mask[i] == MyBorderLeft) {
                    startPoint.x = CGRectGetMinX(borderContainerRect) + self.borderWidth * 0.5f;
                }else{
                    startPoint.x  = CGRectGetMaxX(borderContainerRect) - self.borderWidth * 0.5f;
                }
                
                endPoint.x = startPoint.x;
            }
            
            MyLineLayer * borderLineLayer = [MyLineLayer layer];
            borderLineLayer.lineStyle = self.borderStyle;
            borderLineLayer.lineWidth = self.borderWidth;
            borderLineLayer.lineColor = self.borderColor;
            borderLineLayer.startPoint = startPoint;
            borderLineLayer.endPoint = endPoint;
            
            [self.borderLayer addSublayer:borderLineLayer];
        }
    }
}

#pragma mark -

- (void)prepareForReuse
{
    [super prepareForReuse];
    _needUpdateCellWhenShowInWindow = NO;
}

- (void)setNeedUpdateCell
{
    if (self.window) {
        [self updateCell];
    }else {
        _needUpdateCellWhenShowInWindow = YES;
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    
    if (newWindow) {
        [self updateCellIfNeeded];
    }
}

- (void)updateCellIfNeeded
{
    if (_needUpdateCellWhenShowInWindow) {
        _needUpdateCellWhenShowInWindow = NO;
        [self updateCell];
    }
}

- (void)updateCell {
    //do  nothing
}



@end

////----------------------------------------------------------
//
//@interface MyCollectionReusableView ()
//
//@property(nonatomic,strong,readonly) CALayer * selectionLayer;
//
//@end
//
////----------------------------------------------------------
//
//
//@implementation MyCollectionReusableView
//
//@synthesize selectionLayer = _selectionLayer;
//@synthesize selectionOption = _selectionOption;
//@synthesize selectionColor = _selectionColor;
//@synthesize selectionColorAlpha = _selectionColorAlpha;
//@synthesize highlightedObjects = _highlightedObjects;
//@synthesize animatedSelectionForHidden = _animatedSelectionForHidden;
//
//@synthesize highlighted = _highlighted;
//@synthesize selected = _selected;
//
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    
//    if (self) {
//        [self _setup_MyCollectionReusableView];
//    }
//    
//    return self;
//}
//
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        [self _setup_MyCollectionReusableView];
//    }
//    
//    return self;
//}
//
//- (void)_setup_MyCollectionReusableView{
//    _selectionColorAlpha = 1.f;
//}
//
//#pragma mark -
//
//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    
//    if (_selectionLayer) {
//        _selectionLayer.frame = [self showSelectionView].layer.bounds;
//    }
//}
//
//#pragma mark - section
//
//- (UIView *)showSelectionView {
//    return self;
//}
//
//- (UIColor *)selectionColor{
//    return _selectionColor ?: [self tintColor];
//}
//
//- (void)setSelectionColor:(UIColor *)selectionColor
//{
//    if(_selectionColor != selectionColor){
//        _selectionColor = selectionColor;
//        [self selectionColorDidChange];
//    }
//}
//
//- (void)setSelectionColorAlpha:(CGFloat)selectionColorAlpha
//{
//    if (_selectionColorAlpha != selectionColorAlpha) {
//        _selectionColorAlpha = selectionColorAlpha;
//        [self selectionColorDidChange];
//    }
//}
//
//- (void)tintColorDidChange
//{
//    [super tintColorDidChange];
//    
//    if (!_selectionColor) {
//        [self selectionColorDidChange];
//    }
//}
//
//- (UIColor *)showingSelectionColor {
//    return [self.selectionColor colorWithAlphaComponent:self.selectionColorAlpha];
//}
//
//- (void)selectionColorDidChange {
//    [self _updateSelectionColor];
//}
//
//- (void)_updateSelectionColor
//{
//    if (!_selectionLayer) {
//        return;
//    }
//    
//    [CATransaction begin];
//    [CATransaction setDisableActions:YES];
//    _selectionLayer.backgroundColor = [self showingSelectionColor].CGColor;
//    [CATransaction commit];
//}
//
//
//- (void)setSelectionOption:(MySelectionOption)selectionOption
//{
//    if (_selectionOption != selectionOption) {
//        _selectionOption= selectionOption;
//        
//        if (_selectionOption == MySelectionOptionNone) {
//            [_selectionLayer removeFromSuperlayer];
//            _selectionLayer = nil;
//        }else{
//            [self _updateSelectionViewWithAnimated:NO];
//        }
//    }
//}
//
//- (void)setHighlighted:(BOOL)highlighted {
//    [self setHighlighted:highlighted animated:NO];
//}
//
//- (void)setSelected:(BOOL)selected {
//    [self setSelected:selected animated:NO];
//}
//
//- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
//{
//    if (_highlighted != highlighted) {
//        _highlighted = highlighted;
//        [self _updateSelectionViewWithAnimated:animated];
//    }
//}
//
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    if (_selected != selected) {
//        _selected = selected;
//        [self _updateSelectionViewWithAnimated:animated];
//    }
//}
//
//
//- (BOOL)isShowingSelection {
//    return _selectionLayer && !_selectionLayer.hidden;
//}
//
//- (CALayer *)selectionLayer
//{
//    if (!_selectionLayer) {
//        _selectionLayer = [[CALayer alloc] init];
//        _selectionLayer.actions = @{@"position":[NSNull null],@"bounds":[NSNull null]};
//        _selectionLayer.frame = [self showSelectionView].bounds;
//        [self _updateSelectionColor];
//    }
//    
//    return _selectionLayer;
//}
//
//- (void)_updateSelectionViewWithAnimated:(BOOL)animated
//{
//    BOOL show = NO;
//    if (self.selectionOption & MySelectionOptionSelected) {
//        if(self.selectionOption & MySelectionOptionHighlighted){
//            show = self.isSelected || self.isHighlighted;
//        }else{
//            show = self.isSelected;
//        }
//    }else if (self.selectionOption & MySelectionOptionHighlighted) {
//        show = self.isHighlighted;
//    }
//    
//    [self _showSelectionView:show animated:animated || (!show && self.animatedSelectionForHidden)];
//}
//
//- (void)_showSelectionView:(BOOL)show animated:(BOOL)animated
//{
//    //正在显示
//    if ([self isShowingSelection] == show) {
//        return;
//    }
//    
//    for (NSObject * object in self.highlightedObjects) {
//        if([object respondsToSelector:@selector(setHighlighted:)]){
//            [(id)object setHighlighted:show];
//        }
//    }
//    
//    if (show) {
//        [[self showSelectionView].layer insertSublayer:self.selectionLayer atIndex:0];
//        
//        [CATransaction begin];
//        [CATransaction setDisableActions:!animated];
//        _selectionLayer.hidden = NO;
//        [CATransaction commit];
//        
//    }else{
//        
//        [CATransaction begin];
//        [CATransaction setDisableActions:!animated];
//        _selectionLayer.hidden = YES;
//        [CATransaction commit];
//    }
//}
//
//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if (self.selectionOption == MySelectionOptionNone) {
//        [super touchesBegan:touches withEvent:event];
//    }else{
//        self.highlighted = YES;
//    }
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch * touch = [touches anyObject];
//    self.highlighted = CGRectContainsPoint(self.bounds, [touch locationInView:self]);
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if (self.highlighted) {
//        self.highlighted = NO;
//        
//        UITouch * touch = [touches anyObject];
//        if (CGRectContainsPoint(self.bounds, [touch locationInView:self])) {
//            self.selected = !self.isSelected;
//        }
//    }
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//    self.highlighted = NO;
//}
//
//- (void)prepareForReuse
//{
//    [super prepareForReuse];
//    
//    self.highlighted = NO;
//    self.selected = NO;
//}
//
//@end
