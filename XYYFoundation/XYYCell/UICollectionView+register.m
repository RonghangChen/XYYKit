//
//  UICollectionView+register.m

//
//  Created by LeslieChen on 15/1/23.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "UICollectionView+register.h"
#import "ScreenAdaptation.h"

//----------------------------------------------------------

@implementation UICollectionReusableView (reuseIdentifier)

+ (NSString *)defaultReuseIdentifier {
    return NSStringFromClass(self);
}

@end

//----------------------------------------------------------

@implementation UICollectionView (Register)

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
    
    if (![cellClass isSubclassOfClass:[UICollectionViewCell class]]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"cellClass必须为UICollectionViewCell或其子类"
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
        [self registerNib:[UINib nibWithNibName:nibNameOrNil bundle:bundleOrNil] forCellWithReuseIdentifier:reuseIdentifier];
    }else {
        [self registerClass:cellClass forCellWithReuseIdentifier:reuseIdentifier];
    }
}

- (void)registerSupplementaryViewWithClass:(Class)supplementaryViewClass elementKind:(NSString *)elementKind
{
    [self registerSupplementaryViewWithClass:supplementaryViewClass
                                 elementKind:elementKind
                                nibNameOrNil:nil
                                 bundleOrNil:nil
                          andReuseIdentifier:nil];
}

- (void)registerSupplementaryViewWithClass:(Class)supplementaryViewClass
                               elementKind:(NSString *)elementKind
                        andReuseIdentifier:(NSString *)reuseIdentifier
{
    [self registerSupplementaryViewWithClass:supplementaryViewClass
                                 elementKind:elementKind
                                nibNameOrNil:nil
                                 bundleOrNil:nil
                          andReuseIdentifier:reuseIdentifier];
}

- (void)registerSupplementaryViewWithClass:(Class)supplementaryViewClass
                               elementKind:(NSString *)elementKind
                              nibNameOrNil:(NSString *)nibNameOrNil
                               bundleOrNil:(NSBundle *)bundleOrNil
                        andReuseIdentifier:(NSString *)reuseIdentifier
{
    if (![supplementaryViewClass isSubclassOfClass:[UICollectionReusableView class]]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"supplementaryViewClass必须为UICollectionReusableView或其子类"
                                     userInfo:nil];
    }
    
    reuseIdentifier = reuseIdentifier.length ? reuseIdentifier : [supplementaryViewClass defaultReuseIdentifier];
    if (reuseIdentifier.length == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"reuseIdentifie不能为nil"
                                     userInfo:nil];
    }
    
    nibNameOrNil = nibNameOrNil.length ? nibNameOrNil : NSStringFromClass(supplementaryViewClass);
    nibNameOrNil = validAdaptationNibName(nibNameOrNil, bundleOrNil);
    
    if (nibNameOrNil.length) { //有nib则注册nib
        [self registerNib:[UINib nibWithNibName:nibNameOrNil bundle:bundleOrNil] forSupplementaryViewOfKind:elementKind withReuseIdentifier:reuseIdentifier];
    }else {
        [self registerClass:supplementaryViewClass forSupplementaryViewOfKind:elementKind withReuseIdentifier:reuseIdentifier];
    }
}

@end
