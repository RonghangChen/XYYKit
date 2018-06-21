//
//  UITableView+register.h

//
//  Created by LeslieChen on 15/1/23.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

@interface UITableViewCell (reuseIdentifier)

+ (NSString *)defaultReuseIdentifier;

@end

//----------------------------------------------------------

@interface UITableViewHeaderFooterView (reuseIdentifier)

+ (NSString *)defaultReuseIdentifier;

@end


//----------------------------------------------------------

@interface UITableView (Register)

- (void)registerCellWithClass:(Class)cellClass;
- (void)registerCellWithClass:(Class)cellClass andReuseIdentifier:(NSString *)reuseIdentifier;
- (void)registerCellWithClass:(Class)cellClass
                 nibNameOrNil:(NSString *)nibNameOrNil
                  bundleOrNil:(NSBundle *)bundleOrNil
           andReuseIdentifier:(NSString *)reuseIdentifier;

- (void)registerHeaderFooterViewWithClass:(Class)viewClass;
- (void)registerHeaderFooterViewWithClass:(Class)viewClass andReuseIdentifier:(NSString *)reuseIdentifier;
- (void)registerHeaderFooterViewWithClass:(Class)viewClass
                             nibNameOrNil:(NSString *)nibNameOrNil
                              bundleOrNil:(NSBundle *)bundleOrNil
                       andReuseIdentifier:(NSString *)reuseIdentifier;

@end

