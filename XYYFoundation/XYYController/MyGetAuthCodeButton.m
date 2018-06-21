//
//  MyGetAuthCodeButton.m
//  
//
//  Created by LeslieChen on 15/3/13.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyGetAuthCodeButton.h"
#import "MyWeakProxy.h"
#import "XYYBaseDef.h"

//----------------------------------------------------------

@interface MyGetAuthCodeButton ()

//计时器
@property(nonatomic,strong) NSTimer * timer;
//计时器代理
@property(nonatomic,strong,readonly) MyWeakProxy * timerProxy;

//可用的状态
@property(nonatomic) BOOL enabledWhenEndWait;

@end

//----------------------------------------------------------

@implementation MyGetAuthCodeButton

@synthesize timerProxy = _timerProxy;

#pragma mark -

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setup_MyGetAuthCodeButton];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _setup_MyGetAuthCodeButton];
    }
    
    return self;
}

- (void)_setup_MyGetAuthCodeButton
{
    self.totalNeedWattingTime = 60;
    [self addTarget:self action:@selector(_touchUpInside) forControlEvents:UIControlEventTouchUpInside];
}

- (MyWeakProxy *)timerProxy
{
    if (!_timerProxy) {
        _timerProxy = [MyWeakProxy weakProxyWithObject:self];
    }
    
    return _timerProxy;
}

- (void)dealloc {
    [self.timer invalidate];
}

#pragma mark -


- (void)setEnabled:(BOOL)enabled
{
    if (!self.isWattingNextGetAuthCode) {
        [super setEnabled:enabled];
    }else{
        self.enabledWhenEndWait = enabled;
    }
}

- (void)_touchUpInside
{
    if (!self.isWattingNextGetAuthCode) {
        id<MyGetAuthCodeButtonDelegate> delegate = self.delegate;
        ifRespondsSelector(delegate, @selector(getAuthCodeButtonDidTapGet:)){
            [delegate getAuthCodeButtonDidTapGet:self];
        }
    }
}

- (void)getAuthCodeSucceed
{
    if (!self.isWattingNextGetAuthCode) {
        _wattingNextGetAuthCode = YES;

        self.enabledWhenEndWait = self.enabled;
        super.enabled = NO;
        
        //开始等待
        id<MyGetAuthCodeButtonDelegate> delegate = self.delegate;
        ifRespondsSelector(delegate, @selector(getAuthCodeButtonStartWait:)){
            [delegate getAuthCodeButtonStartWait:self];
        }
        
        [self.timer invalidate];
        self.timer = [NSTimer timerWithTimeInterval:1.f
                                             target:self.timerProxy
                                           selector:@selector(_timeToUpdate)
                                           userInfo:nil
                                            repeats:YES];

        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        
        //需要等待的时间
        _needWattingTime = self.totalNeedWattingTime + 1;
        
        [self.timer fire];
    }
}

- (void)stopWatting
{
    if (self.isWattingNextGetAuthCode) {
        
        [self.timer invalidate];
        self.timer = nil;
        
        _needWattingTime = 0.f;
        _wattingNextGetAuthCode = NO;
        self.enabled = self.enabledWhenEndWait;
        
        //更新文本
        [self _updateWattingTimeText];
    }
}

- (void)_timeToUpdate
{
    if (_needWattingTime == 0) {
        
        [self stopWatting];
        
        id<MyGetAuthCodeButtonDelegate> delegate = self.delegate;
        ifRespondsSelector(delegate, @selector(getAuthCodeButtonEndWait:)){
            [delegate getAuthCodeButtonEndWait:self];
        }
        
    }else {
        

        //更新文本
        --_needWattingTime;
        [self _updateWattingTimeText];
        
        id<MyGetAuthCodeButtonDelegate> delegate = self.delegate;
        ifRespondsSelector(delegate, @selector(getAuthCodeButton:needWaittingTime:)){
            [delegate getAuthCodeButton:self needWaittingTime:_needWattingTime];
        }
    }
}

#pragma mark -

- (void)setWattingTimeTextAttributed:(NSDictionary *)wattingTimeTextAttributed
{
    _wattingTimeTextAttributed = wattingTimeTextAttributed;
    [self _updateWattingTimeText];
}

- (void)_updateWattingTimeText
{
    if (self.isWattingNextGetAuthCode) {
        
        if (_wattingTimeTextAttributed.count) {
            [self setAttributedTitle:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"(%ds)", (int)_needWattingTime] attributes:_wattingTimeTextAttributed] forState:UIControlStateDisabled];
        }else {
            [self setAttributedTitle:nil forState:UIControlStateDisabled];
            [self setTitle:[NSString stringWithFormat:@"(%ds)", (int)_needWattingTime] forState:UIControlStateDisabled];
        }
        
    }else {
        [self setTitle:nil forState:UIControlStateDisabled];
        [self setAttributedTitle:nil forState:UIControlStateDisabled];
    }
}


@end
