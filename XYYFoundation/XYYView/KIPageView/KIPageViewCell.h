//
//  KIPageViewCell.h
//  KIPageView
//
//  Created by SmartWalle on 15/8/14.
//  Copyright (c) 2015年 SmartWalle. All rights reserved.
//

#import "MySelectionView.h"

@interface KIPageViewCell : MySelectionView

- (instancetype)initWithIdentifier:(NSString *)identifier;

@property (nonatomic, readonly, copy) NSString  * reuseIdentifier;

@end
