//
//  MyContentViewTableViewCell.h
//
//
//  Created by LeslieChen on 14/12/2.
//  Copyright (c) 2014年 YB. All rights reserved.
//

//----------------------------------------------------------

#import "MyTableViewCell.h"
#import "MyContentViewCellProtocol.h"

//----------------------------------------------------------

@interface MyContentViewTableViewCell : MyTableViewCell <MyContentViewCellProtocol>

//忽视cell的基本信息（title,image等等），默认为YES
@property(nonatomic) BOOL ignoreCellBasicInfo;

@end

//----------------------------------------------------------

@interface NSDictionary (MyContentViewTableViewCell)

- (NSString *)contentViewTableViewCellClassName;
- (Class)contentViewTableViewCellClass;

@end







