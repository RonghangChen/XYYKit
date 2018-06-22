//
//  ED_FilterContainerView.m

//
//  Created by LeslieChen on 15/3/2.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyDeclineMenuContainerView.h"
#import "MyBasicDeclineMenuContentView.h"

//----------------------------------------------------------

#define BottomSwipeHeight 20.f

//----------------------------------------------------------

@interface _MyBottomSwipeView : MyBorderView

@property (nonatomic, getter=isHighlighted) BOOL highlighted;

@end

//----------------------------------------------------------

@implementation _MyBottomSwipeView
{
    UIImageView * _imageView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.borderMask = MyBorderTop;
        self.borderColor = ColorWithNumberRGB(0x878686);
        
        _imageView = [[UIImageView alloc] initWithImage:ImageWithName(@"icon_bottom_swipe_indicater.png")];
        [_imageView setHighlightedImage:[_imageView.image imageWithTintColor:self.tintColor]];
        [self addSubview:_imageView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = _imageView.image.size;
    _imageView.frame = CGRectMake((CGRectGetWidth(self.bounds) - size.width) * 0.5f,
                                  (CGRectGetHeight(self.bounds) - size.height) * 0.5f,
                                  size.width, size.height);
}

- (void)setHighlighted:(BOOL)highlighted {
    _imageView.highlighted = highlighted;
}

- (BOOL)isHighlighted {
    return _imageView.isHighlighted;
}


@end

//----------------------------------------------------------

@interface MyDeclineMenuContainerView () <UIGestureRecognizerDelegate>

@property(nonatomic,strong,readonly) UIView * contentView;
@property(nonatomic,strong,readonly) _MyBottomSwipeView *bottomSwipeView;
@property(nonatomic,strong) UIView * contentMaskView;

@property(nonatomic,strong,readonly) NSMutableArray * actionsArray;

@property(nonatomic,readonly) BOOL isSwipeing;
@property(nonatomic,strong,readonly) UIPanGestureRecognizer * panGestureRecognizer;

@end

//----------------------------------------------------------

@implementation MyDeclineMenuContainerView

@synthesize contentView = _contentView;
@synthesize bottomSwipeView = _bottomSwipeView;
@synthesize actionsArray = _actionsArray;
@synthesize bottomSwipeViewColor = _bottomSwipeViewColor;
@synthesize panGestureRecognizer = _panGestureRecognizer;

#pragma mark - 

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self _setup_FilterContainerView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _setup_FilterContainerView];
    }
    
    return self;
}

- (void)_setup_FilterContainerView
{
    self.clipsToBounds = YES;
    super.hidden = YES;
    self.showBottomSwipeView = YES;
    self.animatedDuration = 0.4f;
    
    self.backgroundColor = BlackColorWithAlpha(0.5f);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (void)setHidden:(BOOL)hidden{
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.showing && !self.isSwipeing) {
        [self _updateContentViewFrame];
    }
}

- (void)_updateContentViewFrame
{
    if (self.declineMenuContentView) {
        
        CGFloat height = CGRectGetHeight(self.bounds) - (self.showBottomSwipeView ? BottomSwipeHeight : 0.f);
        height = MAX(0.f, height);
        
        CGFloat contentViewHeight = [self.declineMenuContentView heightForViewWithContainerSize:CGSizeMake(CGRectGetWidth(self.bounds),height)];
        contentViewHeight = MAX(0.f, contentViewHeight);
        contentViewHeight = MIN(height, contentViewHeight);
        
        CGRect contentViewFrame = self.bounds;
        contentViewFrame.size.height = contentViewHeight;
        self.contentView.frame = contentViewFrame;
        self.declineMenuContentView.frame = self.contentView.bounds;
        
        if (_bottomSwipeView.superview) {
            _bottomSwipeView.frame = CGRectMake(CGRectGetMinX(contentViewFrame), CGRectGetMaxY(contentViewFrame), CGRectGetWidth(contentViewFrame), BottomSwipeHeight);
        }
    }
}

#pragma mark -

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    
    return _contentView;
}

- (MyBorderView *)bottomSwipeView
{
    if (!_bottomSwipeView) {
        _bottomSwipeView = [[_MyBottomSwipeView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(self.bounds), BottomSwipeHeight)];
        _bottomSwipeView.backgroundColor  = self.bottomSwipeViewColor;
    }
    
    return _bottomSwipeView;
}

- (void)setBottomSwipeViewColor:(UIColor *)bottomSwipeViewColor
{
    if (_bottomSwipeViewColor != bottomSwipeViewColor) {
        _bottomSwipeViewColor = bottomSwipeViewColor;
        _bottomSwipeView.backgroundColor = self.bottomSwipeViewColor;
    }
}

- (UIColor *)bottomSwipeViewColor {
    return _bottomSwipeViewColor ?: [UIColor whiteColor];
}

#pragma mark - 

- (void)_contentViewSizeInvalidateNotification:(NSNotification *)notification {
    [self setNeedsLayout];
}

- (void)showWithView:(MyBasicDeclineMenuContentView *)declineMenuContentView animated:(BOOL)animated {
    [self showWithView:declineMenuContentView animated:animated completedBlock:nil];
}


- (void)showWithView:(MyBasicDeclineMenuContentView *)declineMenuContentView
            animated:(BOOL)animated
      completedBlock:(void(^)())completedBlock
{
    if (declineMenuContentView == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"declineMenuContentView 不能为nil"
                                     userInfo:nil];
    }
    
    
    if (self.isShowing) {
        [self hideWithAnimated:NO];
    }
    
    if (self.isAnimating) {
        
        typeof(self) __weak weak_self = self;
        [self _addActionBlock:^{
            [weak_self showWithView:declineMenuContentView animated:animated];
        }];
        
        return;
    }
    
    _showing = YES;
    
    //更新毛玻璃效果
    [self updateBlurred];
    
    _declineMenuContentView = declineMenuContentView;
    [self.contentView addSubview:declineMenuContentView];
    [self addSubview:self.contentView];
    
    if (self.showBottomSwipeView) {
        [self addSubview:self.bottomSwipeView];
        [self addGestureRecognizer:self.panGestureRecognizer];
    }
    
    //更新
    [self _updateContentViewFrame];
    //添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_contentViewSizeInvalidateNotification:)
                                                 name:MyDeclineMenuContentViewSizeInvalidateNotification
                                               object:declineMenuContentView];
    
    [self.declineMenuContentView viewWillShow:animated duration:self.animatedDuration];
    
    super.hidden = NO;
    
    if (animated) {
        
        self.alpha = 0.f;
        
        if(self.showBottomSwipeView){
            self.bottomSwipeView.frame = CGRectMake(0.f, -BottomSwipeHeight, CGRectGetWidth(self.bounds), BottomSwipeHeight);
        }
        
//        UIView * maskView = nil;
//        if (self.showBottomSwipeView) {
//            maskView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(self.bounds), 0.f)];
//            maskView.backgroundColor = [UIColor whiteColor];
//        }

        UIView * maskView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(self.bounds), 0.f)];
        maskView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.mask = maskView.layer;
        
        [UIView animateWithDuration:self.animatedDuration
                         animations:^{
                             
                             _animating = YES;
                             self.alpha = 1.f;
                             
                             if(self.showBottomSwipeView){
                                 self.bottomSwipeView.frame = CGRectMake(0.f, CGRectGetMaxY(self.contentView.frame), CGRectGetWidth(self.bounds), BottomSwipeHeight);
                             }
                             
                             maskView.frame = self.contentView.bounds;
                             
                         } completion:^(BOOL finished) {
                             
                             [self.declineMenuContentView viewDidShow:animated];
                             
                             if (completedBlock) {
                                 completedBlock();
                             }
                             
                             //引用,防止maskView被释放
                             UIView * __unused _temp = maskView;
                             _temp = nil;
                             self.contentView.layer.mask = nil;
                             
                             _animating = NO;
                             [self _commitAction];
                         }];
    }else{
        
        [self.declineMenuContentView viewDidShow:animated];
        
        if (completedBlock) {
            completedBlock();
        }
    }
}

- (void)hideWithAnimated:(BOOL)animated {
    [self _hideWithAnimated:animated duration:self.animatedDuration completedBlock:nil];
}

- (void)hideWithAnimated:(BOOL)animated completedBlock:(void(^)())completedBlock {
    [self _hideWithAnimated:animated duration:self.animatedDuration completedBlock:completedBlock];
}

- (void)_hideWithAnimated:(BOOL)animated
                 duration:(NSTimeInterval)duration
           completedBlock:(void(^)())completedBlock
{
    if (_showing) {
        
        if (self.isAnimating) {
            
            typeof(self) __weak weak_self = self;
            [self _addActionBlock:^{
                [weak_self hideWithAnimated:animated];
            }];
            
            return;
        }
        
        _showing = NO;
        
        void (^_completionBlock) () = ^ {
            
            [self.declineMenuContentView viewDidHide:animated];
            [self.declineMenuContentView removeFromSuperview];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:MyDeclineMenuContentViewSizeInvalidateNotification object:self.declineMenuContentView];
            _declineMenuContentView = nil;
            
            //清除毛玻璃效果
            [self clearBlurred];
            [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            self.contentMaskView = nil;
            
            self.contentView.layer.mask = nil;
            
            if (self.panGestureRecognizer.view) {
                [self removeGestureRecognizer:self.panGestureRecognizer];
            }
            
            super.hidden = YES;
            
            if (completedBlock) {
                completedBlock();
            }
            
        };
        
        [self.declineMenuContentView viewWillHide:animated duration:duration];
        
        if (animated) {
            
//            if (!self.isSwipeing && self.showBottomSwipeView) {
//                self.contentMaskView = [[UIView alloc] initWithFrame:self.contentView.bounds];
//                self.contentMaskView.backgroundColor = [UIColor whiteColor];
//                self.contentView.layer.mask = self.contentMaskView.layer;
//            }
            
            if (!self.isSwipeing) {
                self.contentMaskView = [[UIView alloc] initWithFrame:self.contentView.bounds];
                self.contentMaskView.backgroundColor = [UIColor whiteColor];
                self.contentView.layer.mask = self.contentMaskView.layer;
            }
            
            [UIView animateWithDuration:duration
                             animations:^{
                                 
                                 _animating = YES;
                                 
                                 if (_bottomSwipeView.superview) {
                                     _bottomSwipeView.frame = CGRectMake(0.f, -BottomSwipeHeight, CGRectGetWidth(self.bounds), BottomSwipeHeight);
                                 }
                                 
                                 self.contentMaskView.frame = CGRectMake(0.f, 0.f, CGRectGetWidth(self.bounds), 0.f);
                                 
                             } completion:^(BOOL finished) {
                                 
                                 [UIView animateWithDuration:self.animatedDuration * 0.5
                                                  animations:^{
                                                      self.alpha = 0.f;
                                                  } completion:^(BOOL finished) {
                                                      
                                                      self.alpha = 1.f;
                                                      _completionBlock();
                                                      _animating = NO;
                                                      [self _commitAction];
                                                  }];
                             }];
            
        }else{
            _completionBlock();
        }
        
        _isSwipeing = NO;
        _bottomSwipeView.highlighted = NO;
    }
}

- (NSMutableArray *)actionsArray
{
    if (!_actionsArray) {
        _actionsArray = [NSMutableArray array];
    }
    
    return _actionsArray;
}

- (void)_addActionBlock:(void(^)())block {
    [self.actionsArray addObject:block];
}

- (void)_commitAction
{
    if (self.actionsArray.count) {
        
        void(^actionBlock)() = self.actionsArray.firstObject;
        [self.actionsArray removeObjectAtIndex:0];
        actionBlock();
    }
}


#pragma mark -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isAnimating && self.isSwipeing) {
        return;
    }
    
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    CGRect contentRect = self.contentView.frame;
    if (_bottomSwipeView.superview) {
        contentRect = CGRectUnion(contentRect, _bottomSwipeView.frame);
    }
    
    if (!CGRectContainsPoint(contentRect, touchPoint)) {
        
        BOOL bRet = [self.declineMenuContentView shouldTapHiddenInContainerView:self];
        
        if (bRet) { //询问代理
            id<MyDeclineMenuContainerViewDelegate> delegate = self.delegate;
            ifRespondsSelector(delegate, @selector(declineMenuContainerViewShouldTapHidden:)){
                bRet = [delegate declineMenuContainerViewShouldTapHidden:self];
            }
        }
        
        if(bRet){
            
            [self hideWithAnimated:YES];
            
            id<MyDeclineMenuContainerViewDelegate> delegate = self.delegate;
            ifRespondsSelector(delegate, @selector(declineMenuContainerViewDidTapHidden:)){
                [delegate declineMenuContainerViewDidTapHidden:self];
            }
            
            ifRespondsSelector(delegate, @selector(declineMenuContainerViewDidHidden:)){
                [delegate declineMenuContainerViewDidHidden:self];
            }
        }
    }
}

- (UIPanGestureRecognizer *)panGestureRecognizer
{
    if (!_panGestureRecognizer) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panGestureRecognizerHandle_:)];
        _panGestureRecognizer.delaysTouchesBegan = YES;
        _panGestureRecognizer.delegate = self;
    }
    
    return _panGestureRecognizer;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer != _panGestureRecognizer) {
        return YES;
    }
    
    if (!self.isAnimating && self.showBottomSwipeView) {
        return  CGRectContainsPoint(CGRectInset(self.bottomSwipeView.frame, 0.f, -10.f), [touch locationInView:self]);
    }else {
        return NO;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer != _panGestureRecognizer) {
        return YES;
    }
    
    BOOL bRet = NO;
    CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self];
    if (translation.y < 0 && fabs(translation.y) > fabs(translation.x)) { //向上滑动
        bRet = [self.declineMenuContentView shouldBeginSwipeHiddenInContainerView:self];
        if (bRet) {
            id<MyDeclineMenuContainerViewDelegate> delegate = self.delegate;
            ifRespondsSelector(delegate, @selector(declineMenuContainerViewShouldBeginSwipeHidden:)){
                bRet = [delegate declineMenuContainerViewShouldBeginSwipeHidden:self];
            }
        }
    }
    
    return bRet;
}

- (void)_panGestureRecognizerHandle_:(UIPanGestureRecognizer *)panGestureRecognizer
{
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            
            _isSwipeing = YES;
            self.bottomSwipeView.highlighted = YES;
        
            self.contentMaskView = [[UIView alloc] initWithFrame:self.contentView.bounds];
            self.contentMaskView.backgroundColor = [UIColor whiteColor];
            self.contentView.layer.mask = self.contentMaskView.layer;
            
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [panGestureRecognizer translationInView:panGestureRecognizer.view];
            translation.y = MIN(0.f, translation.y);
            translation.y = MAX(- CGRectGetHeight(self.contentView.bounds), translation.y);
            
            CGRect contentMaskViewFrame = CGRectAppendSize(self.contentView.bounds,CGSizeMake(0.f, translation.y));
            CGFloat offsetY = CGRectGetHeight(contentMaskViewFrame) - CGRectGetHeight(self.contentMaskView.frame);
            self.contentMaskView.frame = contentMaskViewFrame;
            self.bottomSwipeView.frame = CGRectOffset(self.bottomSwipeView.frame, 0.f, offsetY);
        }
            
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            CGPoint translation = [panGestureRecognizer translationInView:panGestureRecognizer.view];
            CGPoint velocity = [panGestureRecognizer velocityInView:panGestureRecognizer.view];
        
            CGFloat translationProgress = (translation.y / - CGRectGetHeight(self.contentView.bounds));
            CGFloat velocityProgress = (velocity.y / - CGRectGetHeight(self.contentView.bounds));
            
            BOOL bRet= NO;            //滑动大于0.4开始隐藏
            if (translationProgress >= 0 && translationProgress + velocityProgress >= 0.4f) {
                
                bRet = [self.declineMenuContentView shouldSwipeHiddenInContainerView:self];
                
                if (bRet) { //询问代理
                    id<MyDeclineMenuContainerViewDelegate> delegate = self.delegate;
                    ifRespondsSelector(delegate, @selector(declineMenuContainerViewShouldSwipeHidden:)){
                        bRet = [delegate declineMenuContainerViewShouldSwipeHidden:self];
                    }
                }
            }
            
            if (bRet) {
                
                self.bottomSwipeView.highlighted = NO;
                
                if (translationProgress >= 1.f) {
                    [self _hideWithAnimated:YES duration:0.05f completedBlock:nil];
                }else if(translationProgress + velocityProgress >= 1.f){
                    [self _hideWithAnimated:YES  duration:self.animatedDuration * (1.f - translationProgress) completedBlock:nil];
                }else if(translationProgress + velocityProgress >= 0.f){
                    [self _hideWithAnimated:YES duration:(1.f - translationProgress - velocityProgress) * self.animatedDuration completedBlock:nil];
                }else{
                    [self _hideWithAnimated:YES duration:self.animatedDuration * translationProgress completedBlock:nil];
                }
                
                id<MyDeclineMenuContainerViewDelegate> delegate = self.delegate;
                ifRespondsSelector(delegate, @selector(declineMenuContainerViewDidSwipeHidden:)){
                    [delegate declineMenuContainerViewDidSwipeHidden:self];
                }
                
                ifRespondsSelector(delegate, @selector(declineMenuContainerViewDidHidden:)){
                    [delegate declineMenuContainerViewDidHidden:self];
                }
                
            }else{
                [self _cancleSwipe:translationProgress];
            }
            
        }
            break;
            
        case UIGestureRecognizerStateCancelled:
        {
            CGPoint translation = [panGestureRecognizer translationInView:panGestureRecognizer.view];
            [self _cancleSwipe:translation.y / CGRectGetHeight(self.contentView.bounds)];
        }
            break;
            
        default:
            break;
    }
}

- (void)_cancleSwipe:(CGFloat)progress
{
    self.bottomSwipeView.highlighted = NO;
    
    if (progress > 0) {
        
        progress = MIN(progress, 1.f);
        
        [UIView animateWithDuration:self.animatedDuration * progress
                         animations:^{
                             
                             _animating = YES;
                             [self _updateContentViewFrame];
                             self.contentMaskView.frame = self.contentView.bounds;
                             
                         } completion:^(BOOL finished) {

                             _isSwipeing = NO;
                             self.contentView.layer.mask = nil;
                             self.contentMaskView = nil;
                             
                             _animating = NO;
                             [self _commitAction];
                             
                         }];
    }else{
        
        _isSwipeing = NO;
        self.contentView.layer.mask = nil;
        self.contentMaskView = nil;
        
        [self setNeedsLayout];
    }
}

@end

//----------------------------------------------------------

@implementation UIView (MyDeclineMenuContainerView)

- (MyDeclineMenuContainerView *)declineMenuContainerView
{
    if ([self isKindOfClass:[MyDeclineMenuContainerView class]]) {
        return (id)self;
    }else {
        return [self.superview declineMenuContainerView];
    }
}

@end

