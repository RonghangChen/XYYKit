//
//  UITableViewCell+ShowContent.h
//  
//
//  Created by LeslieChen on 15/10/24.
//  Copyright © 2015年 ED. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (ShowContent)

+ (CGFloat)heightForCellWithInfo:(NSDictionary *)info
                       tableView:(UITableView *)tableView
                         context:(id)context;

- (void)updateCellWithInfo:(NSDictionary *)info context:(id)context;


@end
