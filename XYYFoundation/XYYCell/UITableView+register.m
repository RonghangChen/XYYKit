//
//  UITableView+register.m

//
//  Created by LeslieChen on 15/1/23.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "UITableView+register.h"
#import "ScreenAdaptation.h"

//----------------------------------------------------------

@implementation UITableViewCell (reuseIdentifier)

+ (NSString *)defaultReuseIdentifier {
    return NSStringFromClass(self);
}

@end

//----------------------------------------------------------

@implementation UITableViewHeaderFooterView (reuseIdentifier)

+ (NSString *)defaultReuseIdentifier {
    return NSStringFromClass(self);
}

@end

//----------------------------------------------------------

@implementation UITableView (Register)

- (void)registerCellWithClass:(Class)cellClass
{
    [self registerCellWithClass:cellClass
                   nibNameOrNil:nil
                    bundleOrNil:nil
             andReuseIdentifier:nil];
}

- (void)registerCellWithClass:(Class)cellClass andReuseIdentifier:(NSString *)reuseIdentifier
{
    [self registerCellWithClass:cellClass
                   nibNameOrNil:nil
                    bundleOrNil:nil
             andReuseIdentifier:reuseIdentifier];
}

- (void)registerCellWithClass:(Class)cellClass
                 nibNameOrNil:(NSString *)nibNameOrNil
                  bundleOrNil:(NSBundle *)bundleOrNil
           andReuseIdentifier:(NSString *)reuseIdentifier
{
    
    if (![cellClass isSubclassOfClass:[UITableViewCell class]]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"cellClass必须为UITableViewCell或其子类"
                                     userInfo:nil];
    }
    
    reuseIdentifier = reuseIdentifier.length ? reuseIdentifier : [cellClass defaultReuseIdentifier];
    if (reuseIdentifier.length == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"reuseIdentifie不能为nil"
                                     userInfo:nil];
    }
    
    nibNameOrNil = nibNameOrNil.length ? nibNameOrNil : NSStringFromClass(cellClass);
    nibNameOrNil = validAdaptationNibName(nibNameOrNil, bundleOrNil);
    
    if (nibNameOrNil.length) { //有nib则注册nib
        [self registerNib:[UINib nibWithNibName:nibNameOrNil bundle:bundleOrNil] forCellReuseIdentifier:reuseIdentifier];
    }else {
        [self registerClass:cellClass forCellReuseIdentifier:reuseIdentifier];
    }
}

- (void)registerHeaderFooterViewWithClass:(Class)viewClass
{
    [self registerHeaderFooterViewWithClass:viewClass
                               nibNameOrNil:nil
                                bundleOrNil:nil
                         andReuseIdentifier:nil];
}

- (void)registerHeaderFooterViewWithClass:(Class)viewClass andReuseIdentifier:(NSString *)reuseIdentifier
{
    [self registerHeaderFooterViewWithClass:viewClass
                               nibNameOrNil:nil
                                bundleOrNil:nil
                         andReuseIdentifier:reuseIdentifier];
}

- (void)registerHeaderFooterViewWithClass:(Class)viewClass
                             nibNameOrNil:(NSString *)nibNameOrNil
                              bundleOrNil:(NSBundle *)bundleOrNil
                       andReuseIdentifier:(NSString *)reuseIdentifier
{
    
    if (![viewClass isSubclassOfClass:[UITableViewHeaderFooterView class]]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"viewClass必须为UITableViewHeaderFooterView或其子类"
                                     userInfo:nil];
    }
    
    reuseIdentifier = reuseIdentifier.length ? reuseIdentifier : [viewClass defaultReuseIdentifier];
    if (reuseIdentifier.length == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"reuseIdentifie不能为nil"
                                     userInfo:nil];
    }
    
    nibNameOrNil = nibNameOrNil.length ? nibNameOrNil : NSStringFromClass(viewClass);
    nibNameOrNil = validAdaptationNibName(nibNameOrNil, bundleOrNil);
    
    if (nibNameOrNil.length) { //有nib则注册nib
        [self registerNib:[UINib nibWithNibName:nibNameOrNil bundle:bundleOrNil] forHeaderFooterViewReuseIdentifier:reuseIdentifier];
    }else {
        [self registerClass:viewClass forHeaderFooterViewReuseIdentifier:reuseIdentifier];
    }
}

@end
