//
//  MyContentViewCellProtocol.h

//
//  Created by LeslieChen on 15/1/26.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "NSObject+ShowViewControllerDelegate.h"
#import "MyCellContext.h"

//----------------------------------------------------------

@protocol MyContentViewCellDelegate <MyShowViewControllerDelegate>

@end

//----------------------------------------------------------

@protocol MyContentViewCellProtocol

//获取尺寸
+ (CGSize)sizeForCellWithInfo:(NSDictionary *)info
            containerViewSize:(CGSize)containerViewSize
                      context:(MyCellContext *)context;

- (void)updateCellWithInfo:(NSDictionary *)info context:(MyCellContext *)context;

@property(nonatomic,weak) id<MyContentViewCellDelegate> delegate;

@end
