//
//  DNSendButton.h
//  ImagePicker
//
//  Created by DingXiao on 15/2/24.
//  Copyright (c) 2015年 Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DNSendButton : UIView

- (instancetype)initWithFrame:(CGRect)frame;
- (void)addTaget:(id)target action:(SEL)action;

@property (nonatomic, copy) NSString *badgeValue;

@property(nonatomic, getter=isEnabled) BOOL enabled;

@end
