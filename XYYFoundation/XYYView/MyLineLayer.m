//
//  MyLineLayer.m

//
//  Created by LeslieChen on 15/2/28.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import "MyLineLayer.h"
#import "XYYSizeUtil.h"
#import "XYYCommonUtil.h"

@implementation MyLineLayer

@synthesize lineColor = _lineColor;

- (id)init
{
    self = [super init];
    
    if (self) {
        _gradientStartLocation = _gradientEndLocation = 0.5f;
    }
    
    return self;
}



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

IMP_MUTATOR(setLineStyle:, MyLineStyle, _lineStyle, @selector(setNeedsLayout))
IMP_MUTATOR(setLineColor:, UIColor *, _lineColor, @selector(setNeedsLayout))
IMP_MUTATOR(setLineWidth:, CGFloat, _lineWidth, @selector(setNeedsLayout))


- (void)setStartPoint:(CGPoint)startPoint
{
    if (!CGPointEqualToPoint(startPoint, _startPoint)) {
        _startPoint = startPoint;
        [self setNeedsLayout];
    }
}


- (void)setEndPoint:(CGPoint)endPoint
{
    if (!CGPointEqualToPoint(endPoint, _endPoint)) {
        _endPoint = endPoint;
        [self setNeedsLayout];
    }
}

- (UIColor *)lineColor {
    return _lineColor ?: [UIColor blackColor];
}

IMP_MUTATOR(setGradientStartLocation:, CGFloat, _gradientStartLocation, @selector(_needsLayoutWhenGradient))
IMP_MUTATOR(setGradientEndLocation:, CGFloat, _gradientEndLocation, @selector(_needsLayoutWhenGradient))


- (void)_needsLayoutWhenGradient
{
    if (self.lineStyle == MyLineStyleGradient) {
        [self setNeedsLayout];
    }
}


- (void)layoutSublayers
{
    [super layoutSublayers];
    
    self.sublayers = nil;
    
    if(self.lineWidth > 0.f && !CGPointEqualToPoint(self.startPoint, self.endPoint)){
        
#define lineV 0 //竖直的线
#define lineH 1 //水平的线
#define lineS 2 //倾斜的线
        
        //线的类型
        NSInteger lineType = lineS;
        if (self.startPoint.x == self.endPoint.x) {
            lineType = lineV;
        }else if (self.startPoint.y == self.startPoint.y){
            lineType = lineH;
        }
        
        if (self.lineStyle == MyLineStyleNormal) {
            
            if (lineType == lineS) {
                [self addSublayer:createLineLayer(self.startPoint, self.endPoint, self.lineWidth, self.lineColor)];
            }else{
                CALayer * layer = [CALayer layer];
                layer.backgroundColor = self.lineColor.CGColor;
                layer.frame = [self _getLineRect:lineType];
                [self addSublayer:layer];
            }
            
        }else{
            
            CAGradientLayer * gradientLayer = [CAGradientLayer layer];
            UIColor * lineColor = self.lineColor;
            gradientLayer.colors = @[(__bridge id)[lineColor colorWithAlphaComponent:0.01f].CGColor,
                                     (__bridge id)lineColor.CGColor,
                                     (__bridge id)lineColor.CGColor,
                                     (__bridge id)[lineColor colorWithAlphaComponent:0.01f].CGColor];
            
            if (self.gradientStartLocation >=0.f && self.gradientEndLocation >=0.f &&
                self.gradientStartLocation + self.gradientEndLocation <=1.f &&
                self.gradientStartLocation <= self.gradientEndLocation) {
                gradientLayer.locations = @[@(0.f),
                                            @(self.gradientStartLocation),
                                            @(self.gradientEndLocation),
                                            @(1.f)];
            }
            
            if (lineType == lineS) {
                
                CGRect gradientLayerFrame = CGRectZero;
                gradientLayerFrame.origin.x = MIN(self.startPoint.x, self.endPoint.x);
                gradientLayerFrame.origin.y = MIN(self.startPoint.y, self.endPoint.y);
                gradientLayerFrame.size.width = fabs(self.startPoint.x - self.endPoint.x);
                gradientLayerFrame.size.height = fabs(self.startPoint.y - self.endPoint.y);
                
                gradientLayer.frame = gradientLayerFrame;
                
                CGPoint startPoint = CGPointMake(self.startPoint.x - CGRectGetMinX(gradientLayerFrame),
                                                 self.startPoint.y - CGRectGetMinY(gradientLayerFrame));
                CGPoint endPoint = CGPointMake(self.endPoint.x - CGRectGetMinX(gradientLayerFrame),
                                               self.endPoint.y - CGRectGetMinY(gradientLayerFrame));
                
                gradientLayer.startPoint = CGPointMake(startPoint.x ? 1.f : 0.f,
                                                       startPoint.y ? 1.f : 0.f);
                gradientLayer.endPoint = CGPointMake(endPoint.x ? 1.f : 0.f,
                                                     endPoint.y ? 1.f : 0.f);
            
                //蒙版
                CAShapeLayer * maskLayer = createLineLayer(startPoint, endPoint, self.lineWidth, [UIColor blackColor]);
                gradientLayer.mask = maskLayer;
                
            }else{
                
                if (lineType == lineH) {
                    gradientLayer.startPoint = CGPointMake(0.f, 0.5f);
                    gradientLayer.endPoint = CGPointMake(1.f, 0.5f);
                }
                
                gradientLayer.frame = [self _getLineRect:lineType];
            }
            
            [self addSublayer:gradientLayer];
        }
    }
}

- (CGRect)_getLineRect:(NSInteger) lineType
{
    CGRect lineRect = CGRectZero;
    CGFloat onePiexlLenght = PiexlToPoint(1.f);
    
    if (lineType == lineV) {
        lineRect.origin.y = MIN(self.startPoint.y, self.endPoint.y);
        lineRect.origin.x = self.startPoint.x - self.lineWidth * 0.5f;
        lineRect.origin.x = roundf(lineRect.origin.x / onePiexlLenght) * onePiexlLenght;
        lineRect.size.width = self.lineWidth;
        lineRect.size.height = fabs(self.startPoint.y - self.endPoint.y);
    }else if(lineType == lineH){
        lineRect.origin.x = MIN(self.startPoint.x, self.endPoint.x);
        lineRect.origin.y = self.startPoint.y - self.lineWidth * 0.5f;
        lineRect.origin.y = roundf(lineRect.origin.y / onePiexlLenght) * onePiexlLenght;
        lineRect.size.height = self.lineWidth;
        lineRect.size.width = fabs(self.startPoint.x - self.endPoint.x);
    }

    return lineRect;
}




@end
