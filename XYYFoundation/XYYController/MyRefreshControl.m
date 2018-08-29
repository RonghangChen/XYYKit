//
//  MyRefreshControl.m
//
//
//  Created by LeslieChen on 13-12-16.
//  Copyright (c) 2013年 LeslieChen. All rights reserved.
//

//----------------------------------------------------------

#import "MyRefreshControl.h"
#import "XYYBaseDef.h"
#import "XYYConst.h"
#import "MyActivityIndicatorView.h"

//----------------------------------------------------------

@implementation MyRefreshControlManager

static Class _defaultRefreshControlClass = nil;
+ (Class<MyRefreshControlProtocol>)defaultRefreshControlClass
{
    if (!_defaultRefreshControlClass) {
        _defaultRefreshControlClass = [MyRefreshControl class];
    }
    
    return _defaultRefreshControlClass;
}

+ (void)setDefaultRefreshControlClass:(Class<MyRefreshControlProtocol>)refreshControlClass
{
    if ([refreshControlClass isKindOfClass:[UIControl class]] && [refreshControlClass conformsToProtocol:@protocol(MyRefreshControlProtocol)]) {
        _defaultRefreshControlClass = refreshControlClass;
    }
}

+ (UIControl<MyRefreshControlProtocol> *)createDefaultRefreshControlWithType:(MyRefreshControlType)type {
    return (id)[(id<MyRefreshControlProtocol>)[[self defaultRefreshControlClass] alloc] initWithType:type];
}

@end

//----------------------------------------------------------

@interface MyRefreshControl ()

@property(nonatomic,strong,readonly) NSMutableDictionary * textDictionary;

@property(nonatomic,strong,readonly) UILabel * titleLabel;

//箭头风格
@property(nonatomic,strong,readonly) UIImageView * arrowImage;
@property(nonatomic,strong,readonly) UIActivityIndicatorView * sysActivityIndicatorView;

//进度风格
@property(nonatomic,strong,readonly) MyActivityIndicatorView * activityIndicatorView;

@end

//----------------------------------------------------------

@implementation MyRefreshControl

@synthesize textDictionary = _textDictionary;
@synthesize titleLabel = _titleLabel;
@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize arrowImage = _arrowImage;
@synthesize sysActivityIndicatorView = _sysActivityIndicatorView;

- (id)initWithLocation:(MyScrollTriggerViewLocation)location minTriggerDistance:(CGFloat)minTriggerDistance
{
    return [self initWithType:location == MyScrollTriggerViewLocationBottom ? MyRefreshControlTypeBottom : MyRefreshControlTypeTop];
}

- (id)initWithType:(MyRefreshControlType)type {
    return [self initWithType:type style:MyRefreshControlStyleArrow];
}

- (id)initWithType:(MyRefreshControlType)type style:(MyRefreshControlStyle)style
{
    self = [super initWithLocation:type == MyRefreshControlTypeTop ? MyScrollTriggerViewLocationTop : MyScrollTriggerViewLocationBottom minTriggerDistance:MyRefreshControlTriggerDistance];
    
    if (self) {
        _style = style;
    }
    
    return self;
}


#pragma mark - layout

- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = ColorWithNumberRGB(0xbdbdbd);
        _titleLabel.font      = [UIFont boldSystemFontOfSize:14.f];
        [self addSubview:_titleLabel];
        
        //居中
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        if (self.style == MyRefreshControlStyleArrow) {
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
        }else {
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant:-18.f]];
        }
    }
    
    return _titleLabel;
    
}

- (MyActivityIndicatorView *)activityIndicatorView
{
    if (self.style == MyRefreshControlStyleProgress) {
        
        if (_activityIndicatorView == nil) {
            _activityIndicatorView = [[MyActivityIndicatorView alloc] initWithStyle:MyActivityIndicatorViewStyleDeterminate];
//            _activityIndicatorView.bounds           = CGRectMake(0.f, 0.f, 22.f, 22.f);
            _activityIndicatorView.hidesWhenStopped = NO;
            _activityIndicatorView.clockwise        = self.type == MyRefreshControlTypeTop;
            _activityIndicatorView.twoStepAnimation = NO;
            [self addSubview:_activityIndicatorView];
            
            //竖直居中且到label距离一定
            _activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_activityIndicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_activityIndicatorView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeLeading multiplier:1.f constant:-20.f]];
            
            [_activityIndicatorView addConstraint:[NSLayoutConstraint constraintWithItem:_activityIndicatorView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.f constant:22.f]];
            [_activityIndicatorView addConstraint:[NSLayoutConstraint constraintWithItem:_activityIndicatorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.f constant:22.f]];
        }
        
        return _activityIndicatorView;
    }
    
    return nil;
}

- (UIActivityIndicatorView *)sysActivityIndicatorView
{
    if (self.style == MyRefreshControlStyleArrow) {
        
        if (_sysActivityIndicatorView == nil) {
            _sysActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            _sysActivityIndicatorView.color = self.titleLabel.textColor;
            _sysActivityIndicatorView.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
            [self addSubview:_sysActivityIndicatorView];
            
            //和箭头中心对齐
            _sysActivityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_sysActivityIndicatorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.arrowImage attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_sysActivityIndicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.arrowImage attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
        }
        
        return _sysActivityIndicatorView;
    }
    
    return nil;
}

- (UIImageView *)arrowImage
{
    if (self.style == MyRefreshControlStyleArrow) {
        
        if (_arrowImage == nil) {
            _arrowImage = [[UIImageView alloc] initWithImage:ImageWithName(@"ic_arrow_down.png")];
            [self addSubview:_arrowImage];
            
            //竖直居中且到label距离一定
            _arrowImage.translatesAutoresizingMaskIntoConstraints = NO;
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_arrowImage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_arrowImage attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeLeading multiplier:1.f constant:-8.f]];

        }
        
        return _arrowImage;
    }
    
    return nil;
}


//
//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    
//    CGRect bounds = self.bounds;
//    
//    _activityIndicatorView.center = CGPointMake(CGRectGetWidth(bounds) * 0.3f, CGRectGetMidY(bounds));
//    _titleLabel.bounds = CGRectMake(0.f, 0.f, CGRectGetWidth(bounds) * 0.35f, CGRectGetHeight(bounds));
//    _titleLabel.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
//}


#pragma mark - UI

- (MyRefreshControlType)type {
    return self.location == MyScrollTriggerViewLocationTop ? MyRefreshControlTypeTop : MyRefreshControlTypeBottom;
}

- (UIColor *)textColor {
    return self.titleLabel.textColor;
}
- (void)setTextColor:(UIColor *)textColor
{
    self.titleLabel.textColor = textColor;
    self.sysActivityIndicatorView.color = textColor;
}

- (UIFont *)textFont {
    return self.titleLabel.font;
}
- (void)setTextFont:(UIFont *)textFont {
    self.titleLabel.font = textFont;
}

- (NSMutableDictionary *)textDictionary
{
    if (!_textDictionary) {
        
        if (self.style == MyRefreshControlStyleArrow) {
            
            if (self.type == MyRefreshControlTypeTop) {
                _textDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"下拉刷新"   ,@(MyScrollTriggerViewStatusNormal),
                                   @"释放刷新"   ,@(MyScrollTriggerViewStatusReadyToTrigger),
                                   @"更新中...",@(MyScrollTriggerViewStatusTriggering),nil];
            }else{
                _textDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"上拉加载"   ,@(MyScrollTriggerViewStatusNormal),
                                   @"释放加载"   ,@(MyScrollTriggerViewStatusReadyToTrigger),
                                   @"正在努力加载中...",@(MyScrollTriggerViewStatusTriggering),nil];
                
            }
            
        }else {
            
            if (self.type == MyRefreshControlTypeTop) {
                _textDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"下拉刷新"   ,@(MyScrollTriggerViewStatusNormal),
                                   @"释放刷新"   ,@(MyScrollTriggerViewStatusReadyToTrigger),
                                   @"刷新中...",@(MyScrollTriggerViewStatusTriggering),nil];
            }else{
                _textDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"上拉加载"   ,@(MyScrollTriggerViewStatusNormal),
                                   @"释放加载"   ,@(MyScrollTriggerViewStatusReadyToTrigger),
                                   @"加载中...",@(MyScrollTriggerViewStatusTriggering),nil];
                
            }
        }
    }
    
    return _textDictionary;
}

- (void)setText:(NSString *)text forStatus:(MyScrollTriggerViewStatus)status
{
    if (text != nil) {
        [self.textDictionary setObject:text forKey:@(status)];
    }else{
        [self.textDictionary removeObjectForKey:@(status)];
    }
}

- (NSString *)textForStatus:(MyScrollTriggerViewStatus)status
{
    NSString * text = [self.textDictionary objectForKey:@(status)];
    if (text == nil && status != MyScrollTriggerViewStatusNormal) {
        text = [self.textDictionary objectForKey:@(MyScrollTriggerViewStatusNormal)];
    }
    
    return text;
}

- (void)_updateText {
    self.titleLabel.text = [self textForStatus:self.status];
}

#pragma mark -

- (void)updateViewForReset
{
    [super updateViewForReset];
    
    if (self.style == MyRefreshControlStyleArrow) {
        
        [self.sysActivityIndicatorView stopAnimating];
        self.arrowImage.hidden = NO;
        self.arrowImage.transform = self.type == MyRefreshControlTypeTop ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(M_PI);
        
    }else {
        self.activityIndicatorView.style = MyActivityIndicatorViewStyleDeterminate;
        self.activityIndicatorView.progress = 0.f;
    }
    
    //更新文本
    [self _updateText];
}

- (void)statusDidChangeFromStatus:(MyScrollTriggerViewStatus)fromStatus
{
    [super statusDidChangeFromStatus:fromStatus];
    
    switch (self.status) {
        case MyScrollTriggerViewStatusNormal:
            
            //
            if (self.type == MyRefreshControlTypeBottom &&
                fromStatus == MyScrollTriggerViewStatusTriggering) {
                [super updateViewForReset];
            }
            
            if (self.style == MyRefreshControlStyleArrow) {
                
                [self.sysActivityIndicatorView stopAnimating];
                self.arrowImage.hidden = NO;
                self.arrowImage.transform = self.type == MyRefreshControlTypeTop ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(M_PI);
                
            }else {
                
                self.activityIndicatorView.style = MyActivityIndicatorViewStyleDeterminate;
                self.activityIndicatorView.progress = 0.f;
            }
            
            break;
        
        case MyScrollTriggerViewStatusBeginReadyTrigger:
            
            if (fromStatus == MyScrollTriggerViewStatusReadyToTrigger) {
                
                if (self.style == MyRefreshControlStyleArrow) {
                    
                    [UIView animateWithDuration:0.2 animations:^{
                        
                        self.arrowImage.transform = self.type == MyRefreshControlTypeTop ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(M_PI);
                    }];
                    
                }else {
                    
                    self.activityIndicatorView.style = MyActivityIndicatorViewStyleDeterminate;
                    self.activityIndicatorView.progress = self.activityIndicatorView.indeterminateProgress;
                }
                
            }
            
            break;
        
        case MyScrollTriggerViewStatusReadyToTrigger:
            
            if (self.style == MyRefreshControlStyleArrow) {
                
                [UIView animateWithDuration:0.2 animations:^{
                    
                    self.arrowImage.transform = self.type == MyRefreshControlTypeBottom ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(M_PI);
                }];
                
            }else {
                
                self.activityIndicatorView.style = MyActivityIndicatorViewStyleIndeterminate;
            }
            
            break;
            
        case MyScrollTriggerViewStatusTriggering:
            
            if (self.style == MyRefreshControlStyleArrow) {
                
                self.arrowImage.hidden = YES;
                [self.sysActivityIndicatorView startAnimating];
                
            }else {
                
                self.activityIndicatorView.style = MyActivityIndicatorViewStyleIndeterminate;
                [self.activityIndicatorView startAnimating];
            }
            
            break;
            
        default:
            break;
    }
    
    //更新文本
    [self _updateText];
}

- (void)updateViewForTriggerProgress:(float)progress
{
    [super updateViewForTriggerProgress:progress];
    
    if (self.style == MyRefreshControlStyleProgress) {
        self.activityIndicatorView.progress = progress * self.activityIndicatorView.indeterminateProgress;
    }
}

#pragma mark -

- (BOOL)isRefreshing {
    return self.status == MyScrollTriggerViewStatusTriggering;
}

- (void)beginRefreshing {
    [self beginRefreshing_e:YES];
}

- (void)beginRefreshing_e:(BOOL)scrollToShow {
    [self beginTrigger_e:scrollToShow];
}

- (void)endRefreshing {
    [self endTrigger];
}

@end
