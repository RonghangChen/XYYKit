//
//  MySelectionView.m

//
//  Created by LeslieChen on 15/2/27.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MySelectionView.h"

//----------------------------------------------------------

@interface MySelectionView ()

@property(nonatomic,strong,readonly) CALayer * selectionLayer;

@end

//----------------------------------------------------------

@implementation MySelectionView

@synthesize highlighted = _highlighted;
@synthesize selected = _selected;
@synthesize selectionLayer = _selectionLayer;
@synthesize selectionOption = _selectionOption;
@synthesize selectionColor = _selectionColor;
@synthesize selectionColorAlpha = _selectionColorAlpha;
@synthesize highlightedObjects = _highlightedObjects;
@synthesize animatedSelectionForHidden = _animatedSelectionForHidden;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self _initSelectionView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self _initSelectionView];
    }
    
    return self;
}

- (void)_initSelectionView {
    _selectionColorAlpha = 1.f;
}

#pragma mark -

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    if (_selectionLayer) {
//        _selectionLayer.frame = [self showSelectionView].bounds;
//    }
    
    self.backgroundView.frame = self.bounds;
    [self sendSubviewToBack:self.backgroundView];
}

#pragma mark - section

- (UIView *)showSelectionView {
    return self;
}

- (UIColor *)selectionColor {
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
    if (_highlighted!= highlighted) {
        _highlighted = highlighted;
        [self _updateSelectionViewWithAnimated:animated];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (_selected != selected) {
        _selected = selected;
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
//        _selectionLayer.frame = [self showSelectionView].layer.bounds;
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
        
        if ([self.backgroundView isDescendantOfView:[self showSelectionView]]) {
            [[self showSelectionView].layer insertSublayer:self.selectionLayer above:self.backgroundView.layer];
        }else{
            [[self showSelectionView].layer insertSublayer:self.selectionLayer atIndex:0];
        }
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

- (void)setBackgroundView:(UIView *)backgroundView
{
    [_backgroundView removeFromSuperview];
    _backgroundView = backgroundView;
    
    if (_backgroundView) {
        _backgroundView.frame = self.bounds;
        [self insertSubview:_backgroundView atIndex:0];
    }
}


@end
