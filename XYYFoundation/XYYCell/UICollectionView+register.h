//
//  UICollectionView+register.h

//
//  Created by LeslieChen on 15/1/23.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

@interface UICollectionReusableView (reuseIdentifier)

+ (NSString *)defaultReuseIdentifier;

@end

//----------------------------------------------------------

@interface UICollectionView (Register)

- (void)registerCellWithClass:(Class)cellClass;
- (void)registerCellWithClass:(Class)cellClass andReuseIdentifier:(NSString *)reuseIdentifier;
- (void)registerCellWithClass:(Class)cellClass
                 nibNameOrNil:(NSString *)nibNameOrNil
                  bundleOrNil:(NSBundle *)bundleOrNil
           andReuseIdentifier:(NSString *)reuseIdentifier;

- (void)registerSupplementaryViewWithClass:(Class)supplementaryViewClass elementKind:(NSString *)elementKind;
- (void)registerSupplementaryViewWithClass:(Class)supplementaryViewClass
                               elementKind:(NSString *)elementKind
                        andReuseIdentifier:(NSString *)reuseIdentifier;
- (void)registerSupplementaryViewWithClass:(Class)supplementaryViewClass
                               elementKind:(NSString *)elementKind
                              nibNameOrNil:(NSString *)nibNameOrNil
                               bundleOrNil:(NSBundle *)bundleOrNil
                        andReuseIdentifier:(NSString *)reuseIdentifier;

@end
