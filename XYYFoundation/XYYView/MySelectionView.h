//
//  MySelectionView.h

//
//  Created by LeslieChen on 15/2/27.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import "MySelectionProtocol.h"
#import "MyBorderView.h"

@interface MySelectionView : MyBorderView <MySelectionProtocol>

@property(nonatomic,strong) UIView * backgroundView;

@end
