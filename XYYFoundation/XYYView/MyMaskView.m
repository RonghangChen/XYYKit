//
//  MyMaskView.m

//
//  Created by LeslieChen on 15/1/23.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyMaskView.h"
#import "XYYBaseDef.h"

//----------------------------------------------------------

@implementation MyMaskView
{
    BOOL _hadInit;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self _setup_MyMaskView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _setup_MyMaskView];
    }
    
    return self;
}

- (void)_setup_MyMaskView
{
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.reloadMaskWhenSizeChange = YES;
    
    [self _registerKVO];
}

- (void)dealloc {
    [self _unregisterKVO];
}

#pragma mark - KVO

- (NSArray *)_observableKeypaths
{
    return @[ @"dataSource",
              @"maskLayerBlock",
              @"maskPathBlock" ];
}

- (void)_registerKVO
{
    for (NSString * keyPath in [self _observableKeypaths]) {
        [self addObserver:self
               forKeyPath:keyPath
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];
    }
}

- (void)_unregisterKVO
{
    for (NSString * keyPath in [self _observableKeypaths]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self == object && ![change[@"old"] isEqual:change[@"new"]]) {
        
        //update UI
        if ([NSThread isMainThread]) {
            [self _updateUIForKeypath:keyPath];
        }else{
            [self performSelectorOnMainThread:@selector(_updateUIForKeypath:)
                                   withObject:keyPath
                                waitUntilDone:NO];
        }
    }
}

- (void)_updateUIForKeypath:(NSString *)keyPath{
    [self reloadMask];
}

#pragma mark -

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!_hadInit || self.reloadMaskWhenSizeChange) {
        _hadInit = YES;
        [self reloadMask];
    }
}

#pragma mark -

- (void)reloadMask
{
    if (!_hadInit) {
        return;
    }
    
    CALayer * maskLayer = [self _getMaskLayer];
    if (!maskLayer) {
        UIBezierPath * maskPath = [self _getMaskPath];
        if (maskPath) {
            CAShapeLayer * shapeLayer = [CAShapeLayer layer];
            shapeLayer.path = [maskPath CGPath];
            maskLayer = shapeLayer;
        }
    }
    
    self.layer.mask = maskLayer;
}


- (CALayer *)_getMaskLayer
{
    id<MyMaskViewDataSource> dataSource = self.dataSource;
    ifRespondsSelector(dataSource, @selector(maskLayerForMaskView:)){
        return [dataSource maskLayerForMaskView:self];
    }else if(self.maskLayerBlock){
        return self.maskLayerBlock(self);
    }else{
        return nil;
    }
}

- (UIBezierPath *)_getMaskPath
{
    id<MyMaskViewDataSource> dataSource = self.dataSource;
    ifRespondsSelector(dataSource, @selector(maskPathForMaskView:)){
        return [dataSource maskPathForMaskView:self];
    }else if (self.maskPathBlock){
        return self.maskPathBlock(self);
    }else{
        return nil;
    }
}

- (CALayer *)maskLayer{
    return self.layer.mask;
}

@end

//----------------------------------------------------------

@implementation UIView (MyMaskView)

- (MyMaskView *)myMaskView
{
    if ([self isKindOfClass:[MyMaskView class]]) {
        return (MyMaskView *)self;
    }else{
        return [self.superview myMaskView];
    }
}



@end

