//
//  KIPageViewCell.m
//  KIPageView
//
//  Created by SmartWalle on 15/8/14.
//  Copyright (c) 2015年 SmartWalle. All rights reserved.
//

#import "KIPageViewCell.h"

@interface KIPageViewCell () {
    @private
    NSInteger _cellIndex;
}

@property (nonatomic, assign) BOOL pageViewCellSelected;
@end

@implementation KIPageViewCell

#pragma mark - Lifecycle

- (instancetype)initWithIdentifier:(NSString *)identifier {
    if (self = [super initWithFrame:CGRectZero]) {
        _reuseIdentifier = [identifier copy];
        [self _initFinished_KIPageViewCell];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _initFinished_KIPageViewCell];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _initFinished_KIPageViewCell];
    }
    return self;
}

- (void)_initFinished_KIPageViewCell {
    [self setClipsToBounds:YES];
    [self setUserInteractionEnabled:YES];
}


#pragma mark -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self setHighlighted:YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self setHighlighted:NO];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [self setHighlighted:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self setSelected:YES animated:YES];
    [self setHighlighted:NO];
}

#pragma mark - Methods

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.pageViewCellSelected = self.isSelected;
}

@end
