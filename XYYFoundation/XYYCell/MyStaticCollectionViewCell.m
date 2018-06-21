//
//  MyStaticCollectionViewCell.m

//
//  Created by LeslieChen on 15/2/27.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import "MyStaticCollectionViewCell.h"
#import "UIView+Instance.h"

@implementation MyStaticCollectionViewCell
{
    BOOL _needUpdateCellWhenShowInWindow;
}

+ (instancetype)createInstanceWithReuseIdentifier:(NSString *)reuseIdentifier
{
    MyStaticCollectionViewCell * cell = [self xyy_createInstance];
    [cell setupReuseIdentifier:reuseIdentifier];
    
    return cell;
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame reuseIdentifier:nil];
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    return [self initWithFrame:CGRectZero reuseIdentifier:reuseIdentifier];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupReuseIdentifier:reuseIdentifier];
    }
    
    return self;
}

- (void)setupReuseIdentifier:(NSString *)reuseIdentifier
{
    if (_reuseIdentifier.length == 0 && reuseIdentifier.length != 0) {
        _reuseIdentifier = reuseIdentifier;
    }
}

#pragma mark -

- (BOOL)touchPointInside:(CGPoint)point {
    return CGRectContainsPoint(self.bounds, point);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.layoutSubViewsBlock) {
        self.layoutSubViewsBlock(self);
    }
}

#pragma mark -

- (void)updateCellWithInfo:(NSDictionary *)info context:(id)context {
    //do nothing
}

- (void)prepareForReuse {
    _needUpdateCellWhenShowInWindow = NO;
}

- (void)didAddToReusePool {
    //do nothing
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


@implementation MyStaticCollectionViewCell (reuseIdentifier)

+ (NSString *)defaultReuseIdentifier {
    return NSStringFromClass(self);
}

@end
