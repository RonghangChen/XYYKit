//
//  MyContentViewCollectionViewCell.h

//
//  Created by LeslieChen on 15/1/25.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyCollectionViewCell.h"
#import "MyContentViewCellProtocol.h"

//----------------------------------------------------------

@interface MyContentViewCollectionViewCell : MyCollectionViewCell <MyContentViewCellProtocol>

@end

//----------------------------------------------------------

@interface NSDictionary (MyContentViewCollectionViewCell)

- (NSString *)contentViewCollectionViewCellClassName;
- (Class)contentViewCollectionViewCellClass;

@end
