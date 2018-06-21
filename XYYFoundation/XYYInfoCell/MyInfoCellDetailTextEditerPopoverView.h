//
//  MyInfoCellDetailTextEditerPopoverView.h
//  
//
//  Created by LeslieChen on 15/10/19.
//  Copyright © 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyBasicInfoCellEditerPopoverView.h"

//----------------------------------------------------------

@interface MyInfoCellDetailTextEditerPopoverView : MyBasicInfoCellEditerPopoverView


@end

//----------------------------------------------------------

@interface NSDictionary (MyInfoCellDetailTextEditerPopoverView)

//是否能够换行
- (BOOL)infoCellTextCanWrap;

@end
