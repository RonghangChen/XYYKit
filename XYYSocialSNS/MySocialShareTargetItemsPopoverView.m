//
//  ED_SharePopoverView.m
//  
//
//  Created by LeslieChen on 15/3/11.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MySocialShareTargetItemsPopoverView.h"
#import "MySocialShareTargetItem.h"
#import "MySocialShareTargetItemCell.h"

//----------------------------------------------------------

#define PreLineShareItemCount        3.f
#define ShareItemWidth               65.f
#define ShareItemHeight              95.f
#define ShareItemSectionSpacing      25.f

//----------------------------------------------------------

@interface MySocialShareTargetItemsPopoverView ()< MyStaticCollectionViewDelegate,
                                                   MyStaticCollectionViewDataSource >

@property(nonatomic,strong) MyStaticCollectionView * staticCollectionView;

@end

//----------------------------------------------------------


@implementation MySocialShareTargetItemsPopoverView

@synthesize blurredBackgroundType = _blurredBackgroundType;
@synthesize applyBlurredEffectBlock = _applyBlurredEffectBlock;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
@synthesize blurEffectStyle = _blurEffectStyle;
@synthesize blurEffectAlpha = _blurEffectAlpha;
#endif

#pragma mark -

- (id)initWithFrame:(CGRect)frame {
    return [self initWithShareTargetItems:[MySocialShareTargetItem allAvailableShareTargetItems]];
}

- (id)initWithShareTargetItems:(NSArray *)shareTargetItems
{
    self = [super init];
    if (self) {
        
        [self _setup_MySocialShareTargetItemsPopoverView];
        self.shareTargetItems = shareTargetItems;
    }
    
    return self;
}

//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        [self _setup_MySocialShareTargetItemsPopoverView];
//    }
//    
//    return self;
//}


- (void)_setup_MySocialShareTargetItemsPopoverView
{
    self.staticCollectionView = [[MyStaticCollectionView alloc] initWithFrame:self.bounds];
    self.staticCollectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.staticCollectionView.delegate = self;
    self.staticCollectionView.dataSource = self;
    self.staticCollectionView.sectionSpacing = ShareItemSectionSpacing;
    self.staticCollectionView.separatorLineInfo = [MyStaticCollectionViewSeparatorLineInfo noSeparatorLineInfo];
    [self addSubview:self.staticCollectionView];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    
    if (GreaterThanIOS8System) {
        self.blurredBackgroundType = MyBlurredBackgroundTypeDynamic;
        self.blurEffectStyle = UIBlurEffectStyleDark;
        self.blurEffectAlpha = 1.f;
    }else{
        self.blurredBackgroundType = MyBlurredBackgroundTypeStatic;
//        self.applyBlurredEffectBlock = ^(UIImage * image){
//            return [image applyBlurWithRadius:15.f
//                                    tintColor:BlackColorWithAlpha(0.3f)
//                        saturationDeltaFactor:1.8f
//                                    maskImage:nil];
//        };
    }
    
#else
    
    self.blurredBackgroundType = MyBlurredBackgroundTypeStatic;
//    self.applyBlurredEffectBlock = ^(UIImage * image){
//        return [image applyBlurWithRadius:15.f
//                                tintColor:BlackColorWithAlpha(0.3f)
//                    saturationDeltaFactor:1.8f
//                                maskImage:nil];
//    };
    
#endif

}

#pragma mark -

- (void)setShareTargetItems:(NSArray *)shareTargetItems
{
    if (self.isShowing) {
        NSLog(@"视图正在显示无法设置shareTargetItems");
    }else{
        
        for (MySocialShareTargetItem * item in shareTargetItems) {
            if (![item isKindOfClass:[MySocialShareTargetItem class]]) {
                @throw [NSException exceptionWithName:NSGenericException
                                               reason: [NSString stringWithFormat:@"item = %@不是MySocialShareTargetItem实例",item]
                                             userInfo:nil];
            }
        }
        
        _shareTargetItems = [NSArray arrayWithArray:shareTargetItems];
        [self.staticCollectionView reloadData];
    }
}

- (BOOL)isShowing {
    return self.popoverView.isShowing || [[MyAlertViewManager sharedManager] isShowAlertView:self];
}

#pragma mark -

- (NSUInteger)numberOfSectionInStaticCollectionView:(MyStaticCollectionView *)collectionView {
    return ceilf(self.shareTargetItems.count / PreLineShareItemCount);
}

- (NSUInteger)staticCollectionView:(MyStaticCollectionView *)collectionView numberOfItemsInSection:(NSUInteger)section {
    return PreLineShareItemCount;
}

- (UIEdgeInsets)staticCollectionView:(MyStaticCollectionView *)collectionView sectionInsetForSection:(NSUInteger)section
{
    CGFloat margin = (CGRectGetWidth(collectionView.bounds) - PreLineShareItemCount * ShareItemWidth) / (PreLineShareItemCount + 1);
    return UIEdgeInsetsMake(0.f, margin, 0.f, margin);
}

- (CGFloat)staticCollectionView:(MyStaticCollectionView *)collectionView interitemSpacingForSection:(NSUInteger)section {
    return (CGRectGetWidth(collectionView.bounds) - PreLineShareItemCount * ShareItemWidth) / (PreLineShareItemCount + 1);
}

- (MyStaticCollectionViewCell *)staticCollectionView:(MyStaticCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = indexPath.section * PreLineShareItemCount + indexPath.item;
    if (index < self.shareTargetItems.count ) {
        
        MySocialShareTargetItemCell * cell =  [collectionView dequeueReusableCellWithIdentifier:defaultReuseDef];
        if (cell == nil) { //无复用则初始化
            cell = [MySocialShareTargetItemCell xyy_createInstance];
            [cell setupReuseIdentifier:defaultReuseDef];
        }
    
        //更新信息
        [cell updateCellWithInfo:nil context:self.shareTargetItems[index]];
        
        return cell;
    }
    
    return nil;
}

- (void)staticCollectionView:(MyStaticCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = indexPath.section * PreLineShareItemCount + indexPath.item;
    if (index < self.shareTargetItems.count ) {
        
        id<MySocialShareTargetItemsPopoverViewDelegate> delegate = self.delegate;
        ifRespondsSelector(delegate, @selector(sharePopoverView:didTapShareTargetItem:)){
            [delegate sharePopoverView:self didTapShareTargetItem:self.shareTargetItems[index]];
        }else{
            [self hide:nil];
        }
    }
}

#pragma mark -

- (void)show:(void (^)(void))completedBlock
{
    if (self.popoverView.showing) {
        NSLog(@"改分享页面已经显示");
    }else{
        
        MyPopoverView * popoverView = [[MyPopoverView alloc] initWithContentView:self];
        popoverView.contentViewAnchorPoint = CGPointMake(0.5f, 0.5f);
        popoverView.locationAnchorPoint = CGPointMake(0.5f, 0.37f);
        popoverView.blurredBackgroundType = self.blurredBackgroundType;
        popoverView.applyBlurredEffectBlock = self.applyBlurredEffectBlock;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
        popoverView.blurEffectStyle = self.blurEffectStyle;
        popoverView.blurEffectAlpha = self.blurEffectAlpha;
#endif
        [[MyAlertViewManager sharedManager] showAlertView:self withBlock:^{
           [popoverView showInView:nil animated:YES completedBlock:completedBlock];
        }];
    }
    
}

- (void)hide:(void (^)(void))completedBlock
{
    if ([[MyAlertViewManager sharedManager] isShowAlertView:self]) {
        [[MyAlertViewManager sharedManager] hideAlertView:self withAnimated:YES completedBlock:completedBlock];
    }else {
        [self hideAlertViewWithAnimated:YES completedBlock:completedBlock];
    }
}

- (void)hideAlertViewWithAnimated:(BOOL)animated completedBlock:(void (^)(void))completedBlock {
     [self.popoverView hide:animated completedBlock:completedBlock];
}

- (BOOL)customAnimationForPopoverView:(MyPopoverView *)popoverView
                                 show:(BOOL)show
                       animationBlock:(void (^)(void))animationBlock
                       completedBlock:(void (^)(void))completedBlock
{
    self.staticCollectionView.frame = self.bounds;
    [popoverView startCommitIntervalAnimatedWithDirection:show ? MyMoveAnimatedDirectionUp : MyMoveAnimatedDirectionDown
                                                 duration:show ?  0.6 : 0.5
                                                    delay:0.0
                                                  forShow:show
                                                  context:nil
                                           completedBlock:nil];
    
    popoverView.alpha = show ? 0.f : 1.f;
    [UIView animateWithDuration:0.5
                          delay:show ? 0.0 : 0.4
         usingSpringWithDamping:1.f
          initialSpringVelocity:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         if (animationBlock) {
                             animationBlock();
                         }
                         popoverView.alpha = show ? 1.f : 0.f;
                         
                     } completion:^(BOOL finished) {
                         if (completedBlock) {
                             completedBlock();
                         }
                     }];
    return YES;
}

#pragma mark -

- (CGSize)sizeThatFits:(CGSize)size
{
    NSUInteger lineCount = ceilf(self.shareTargetItems.count / PreLineShareItemCount);
    return CGSizeMake(size.width, lineCount * ShareItemHeight + (lineCount - 1) * ShareItemSectionSpacing);
}

- (BOOL)popoverViewWillTapHiddenAtPoint:(CGPoint)point
{
    BOOL bRet = YES;
    id<MySocialShareTargetItemsPopoverViewDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(sharePopoverViewWillCancleShare:)){
        bRet = [delegate sharePopoverViewWillCancleShare:self];
    }
    
    if (bRet) {
        [self hide:nil];
    }
    
    return NO;
}


- (void)startPopoverViewShow:(BOOL)show animated:(BOOL)animated
{
    id<MySocialShareTargetItemsPopoverViewDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(sharePopoverView:willShow:)){
        [delegate sharePopoverView:self willShow:show];
    }
}

- (void)endPopoverViewShow:(BOOL)show animated:(BOOL)animated
{
    id<MySocialShareTargetItemsPopoverViewDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(sharePopoverView:didShow:)){
        [delegate sharePopoverView:self didShow:show];
    }
}

#pragma mark -

- (NSArray *)needAnimatedViewsForShow:(BOOL)show context:(id)context
{
    NSArray * allCells = self.staticCollectionView.allCells;
    
    //进行分组
    NSUInteger viewGroupsCount = MIN(PreLineShareItemCount, allCells.count);
    NSUInteger maxGorupViewsCount = ceil(allCells.count / PreLineShareItemCount);
    NSMutableArray * animationViewGroups = [NSMutableArray arrayWithCapacity:viewGroupsCount];
    for (NSInteger i = 0; i < viewGroupsCount; ++ i) {
        [animationViewGroups addObject:[NSMutableArray arrayWithCapacity:maxGorupViewsCount]];
    }
    
    //加入
    NSUInteger index = 0;
    for (UIView * cell in allCells) {
        if (show) {
            [animationViewGroups[index % (int)PreLineShareItemCount] addObject:cell];
        }else {
            [animationViewGroups[index % (int)PreLineShareItemCount] insertObject:cell atIndex:0];
        }
        
        ++ index;
    }
    
    return animationViewGroups;
}

- (NSTimeInterval)animationIntervalForDuration:(NSTimeInterval)duration forShow:(BOOL)show {
    return 0.05f;
}

- (NSTimeInterval)animationIntervalForGroupWithDuration:(NSTimeInterval)duration  forShow:(BOOL)show {
    return 0.02f;
}


@end
