//
//  ED_ShareCell.m
//  
//
//  Created by LeslieChen on 15/3/11.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MySocialShareTargetItemCell.h"
#import "MySocialShareTargetItem.h"
#import "XYYFoundation.h"

//----------------------------------------------------------

@interface MySocialShareTargetItemCell ()

@property(nonatomic,strong) UIImageView * imageView;
@property(nonatomic,strong) UIView * shadowView;

@property(nonatomic,strong) UILabel * titleLabel;

@end

//----------------------------------------------------------

@implementation MySocialShareTargetItemCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.imageView = [[UIImageView alloc] init];
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
        
        self.shadowView = [[UIView alloc] init];
        self.shadowView.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        self.shadowView.layer.shadowOpacity = 0.5;
        [self insertSubview:self.shadowView belowSubview:self.imageView];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = ColorWithNumberRGB(0xE4E4E4);
        self.titleLabel.font = [UIFont systemFontOfSize:15.f];
        [self addSubview:self.titleLabel];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    self.imageView.frame = CGRectMake(0.f, 0.f, width, width);
    self.imageView.layer.cornerRadius = width * 0.5f;
    
    self.shadowView.frame = self.imageView.frame;
    self.shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-5, -5, CGRectGetWidth(self.shadowView.frame) + 10, CGRectGetHeight(self.shadowView.frame) + 10) cornerRadius:(CGRectGetHeight(self.shadowView.frame) + 10) / 2.0].CGPath;
    
    self.titleLabel.frame = CGRectMake(0.f, width + 10.f, width, 18.f);
}

- (void)updateCellWithInfo:(NSDictionary *)info context:(id)context
{
    MySocialShareTargetItem * shareTargetItem = ConvertToClassPointer(MySocialShareTargetItem, context);
    self.imageView.image = shareTargetItem.icon;
    self.titleLabel.text = shareTargetItem.title;
    
    //阴影颜色
    if (!shareTargetItem.shadowColor) {
        self.shadowView.hidden = YES;
    }else {
        self.shadowView.hidden = NO;
        self.shadowView.layer.shadowColor = shareTargetItem.shadowColor.CGColor;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (self.isHighlighted != highlighted) {
        [super setHighlighted:highlighted animated:animated];
        [self _setHover:highlighted animated:animated];
    }
}

- (void)_setHover:(BOOL)hover animated:(BOOL)animated
{
    if(animated) {
        [UIView animateWithDuration:0.6
                              delay:0.f
             usingSpringWithDamping:0.35f
              initialSpringVelocity:1.f
                            options:0
                         animations:^{
                             self.transform = hover ? CGAffineTransformMakeScale(1.3f, 1.3f) : CGAffineTransformIdentity;
                         } completion:nil];
        
    }else {
        self.transform = hover ? CGAffineTransformMakeScale(1.3f, 1.3f) : CGAffineTransformIdentity;
    }
}

- (CGFloat)animationDampingRatioForDuration:(NSTimeInterval)duration{
    return 0.7f;
}

@end
