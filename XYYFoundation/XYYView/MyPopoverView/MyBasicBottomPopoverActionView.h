//
//  MyBasicBottomPopoverActionView.h
//  leslie
//
//  Created by 陈荣航 on 2017/11/10.
//  Copyright © 2017年 LeslieChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyPopoverView.h"
#import "MyContentView.h"

@interface MyBasicBottomPopoverActionView : MyContentView

- (MyPopoverView *)showWithConfigBlock:(void(^)(MyPopoverView * popoverView))configBlock
                               animated:(BOOL)animated
                        completedBlock:(void(^)(void))completedBlock;

- (void)hideWithAnimted:(BOOL)animated completedBlock:(void(^)(void))completedBlock;

- (CGFloat)heightForContainerSize:(CGSize)size;

@end
