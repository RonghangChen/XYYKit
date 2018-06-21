//
//  MyCollectionView.m

//
//  Created by LeslieChen on 15/2/27.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyStaticCollectionView.h"
#import "XYYBaseDef.h"
#import "XYYSizeUtil.h"
#import "UIView+IntervalAnimation.h"

//----------------------------------------------------------

@implementation MyStaticCollectionViewSeparatorLineInfo

+ (MyStaticCollectionViewSeparatorLineInfo *)defaultSeparatorLineInfo
{
    return [[self alloc] initWithSeparatorLineStyle:MyStaticCollectionViewSeparatorLineStyleLine
                                 separatorLineColor:nil
                                separatorLineInsets:UIEdgeInsetsZero];
}

+ (instancetype)noSeparatorLineInfo
{
    return [[self alloc] initWithSeparatorLineStyle:MyStaticCollectionViewSeparatorLineStyleNone
                                 separatorLineColor:nil
                                 separatorLineWidth:0.f
                                separatorLineInsets:UIEdgeInsetsZero];
}

+ (instancetype)singleSeparatorLineInfoWithColor:(UIColor *)separatorLineColor
{
    return [[self alloc] initWithSeparatorLineStyle:MyStaticCollectionViewSeparatorLineStyleLine
                                 separatorLineColor:separatorLineColor
                                separatorLineInsets:UIEdgeInsetsZero];
}

- (id)initWithSeparatorLineStyle:(MyStaticCollectionViewSeparatorLineStyle)separatorLineStyle
              separatorLineColor:(UIColor *)separatorLineColor
             separatorLineInsets:(UIEdgeInsets)separatorLineInsets

{
    return [self initWithSeparatorLineStyle:separatorLineStyle
                         separatorLineColor:separatorLineColor
                         separatorLineWidth:PiexlToPoint(1.f)
                        separatorLineInsets:separatorLineInsets];
}

- (id)initWithSeparatorLineStyle:(MyStaticCollectionViewSeparatorLineStyle)separatorLineStyle
              separatorLineColor:(UIColor *)separatorLineColor
              separatorLineWidth:(CGFloat)separatorLineWidth
             separatorLineInsets:(UIEdgeInsets)separatorLineInsets
{
    self = [super init];
    
    if (self) {
        _separatorLineStyle  = separatorLineStyle;
        _separatorLineInsets = separatorLineInsets;
        _separatorLineWidth  = separatorLineWidth;
        _separatorLineColor = separatorLineColor ? : [UIColor lightGrayColor];
    }
    
    return self;
}

@end

//----------------------------------------------------------

@interface _MyStaticCollectionViewSection : NSObject

- (id)initWithSpaceFactor:(NSUInteger)spaceFactor
             sectionInset:(UIEdgeInsets)sectionInset
         interitemSpacing:(CGFloat)interitemSpacing
           sectionSpacing:(CGFloat)sectionSpacing
        separatorLineInfo:(MyStaticCollectionViewSeparatorLineInfo *)separatorLineInfo
                    items:(NSArray *)items
    totalItemsSpaceFactor:(NSUInteger)totalItemsSpaceFactor;


@property(nonatomic,readonly) NSUInteger spaceFactor;
@property(nonatomic,readonly) NSUInteger totalItemsSpaceFactor;
@property(nonatomic,readonly) UIEdgeInsets sectionInset;
@property(nonatomic,readonly) CGFloat interitemSpacing;
@property(nonatomic,readonly) CGFloat sectionSpacing;
@property(nonatomic,strong,readonly) MyStaticCollectionViewSeparatorLineInfo * separatorLineInfo;
@property(nonatomic,strong,readonly) NSArray * items;

@property(nonatomic) CGRect contentFrame;

@end

//----------------------------------------------------------

@implementation _MyStaticCollectionViewSection

- (id)initWithSpaceFactor:(NSUInteger)spaceFactor
             sectionInset:(UIEdgeInsets)sectionInset
         interitemSpacing:(CGFloat)interitemSpacing
           sectionSpacing:(CGFloat)sectionSpacing
        separatorLineInfo:(MyStaticCollectionViewSeparatorLineInfo *)separatorLineInfo
                    items:(NSArray *)items
    totalItemsSpaceFactor:(NSUInteger)totalItemsSpaceFactor
{
    self = [super init];
    
    if (self) {
        _spaceFactor = spaceFactor;
        _sectionInset = sectionInset;
        _interitemSpacing = interitemSpacing;
        _sectionSpacing = sectionSpacing;
        _separatorLineInfo = separatorLineInfo;
        _items = items;
        _totalItemsSpaceFactor = totalItemsSpaceFactor;
    }
    
    return self;
}

@end

//----------------------------------------------------------

@interface _MyStaticCollectionViewSectionItem : NSObject

- (id)initWithSpaceFactor:(NSUInteger)spaceFactor
        separatorLineInfo:(MyStaticCollectionViewSeparatorLineInfo *)separatorLineInfo
                     cell:(MyStaticCollectionViewCell *)cell;

@property(nonatomic,readonly) NSUInteger spaceFactor;
@property(nonatomic,strong,readonly) MyStaticCollectionViewSeparatorLineInfo * separatorLineInfo;
@property(nonatomic,strong,readonly) MyStaticCollectionViewCell * cell;

@property(nonatomic) CGRect cellFrame;

@end

//----------------------------------------------------------

@implementation _MyStaticCollectionViewSectionItem

- (id)initWithSpaceFactor:(NSUInteger)spaceFactor
        separatorLineInfo:(MyStaticCollectionViewSeparatorLineInfo *)separatorLineInfo
                     cell:(MyStaticCollectionViewCell *)cell
{
    self = [super init];
    
    if (self) {
        _spaceFactor = spaceFactor;
        _separatorLineInfo = separatorLineInfo;
        _cell = cell;
    }
    
    return self;
}

@end

//----------------------------------------------------------

@interface _MyStaticCollectionViewHighlightItemInfo : NSObject

- (id)initWithTouch:(UITouch *)touch;
- (id)initWithItemIndexPath:(NSIndexPath *)indexPath;
- (id)initWithTouch:(UITouch *)touch itemIndexPath:(NSIndexPath *)indexPath;

@property(nonatomic,strong,readonly) UITouch * touch;
@property(nonatomic,strong,readonly) NSIndexPath * indexPath;

@end

//----------------------------------------------------------

@implementation _MyStaticCollectionViewHighlightItemInfo

- (id)initWithTouch:(UITouch *)touch {
    return [self initWithTouch:touch itemIndexPath:nil];
}

- (id)initWithItemIndexPath:(NSIndexPath *)indexPath {
    return [self initWithTouch:nil itemIndexPath:indexPath];
}

- (id)initWithTouch:(UITouch *)touch itemIndexPath:(NSIndexPath *)indexPath
{
    self = [super init];
    
    if (self) {
        _touch = touch;
        _indexPath = indexPath;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        _MyStaticCollectionViewHighlightItemInfo * info = object;
        return [info.touch isEqual:self.touch] || [info.indexPath isEqual:self.indexPath];
    }
    
    return NO;
}

@end

//----------------------------------------------------------

@interface MyStaticCollectionView ()

@property(nonatomic,strong) UIView * contentView;

//布局是否有效
@property(nonatomic) BOOL layoutValid;
@property(nonatomic) NSUInteger totalSectionSpaceFactor;
@property(nonatomic) CGRect layoutedContentBounds;


//分隔线layer
@property(nonatomic,strong,readonly) CALayer * separatorLinesLayer;

//数据
@property(nonatomic,strong,readonly) NSArray * sectionsData;

//选择的单元
@property(nonatomic,strong,readonly) NSMutableSet * selectionIndexPaths;
//高亮信息
@property(nonatomic,strong,readonly) NSMutableArray * highlightItemInfos;

//复用池
@property(nonatomic,strong,readonly) NSMutableDictionary * reusableCellPool;

//没有使用的touch
@property(nonatomic,strong,readonly) NSMutableSet * unuseTouches;

@end

//----------------------------------------------------------

@implementation MyStaticCollectionView

@synthesize separatorLinesLayer = _separatorLinesLayer;
@synthesize sectionsData = _sectionsData;
@synthesize selectionIndexPaths = _selectionIndexPaths;
@synthesize highlightItemInfos = _highlightItemInfos;
@synthesize reusableCellPool = _reusableCellPool;
@synthesize unuseTouches = _unuseTouches;

#pragma mark - life circle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self _setup_MyStaticCollectionView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _setup_MyStaticCollectionView];
    }
    
    return self;
}

- (void)_setup_MyStaticCollectionView
{
    _allowsSelection = YES;
    
    self.contentView = [[UIView alloc] initWithFrame:self.bounds];
//    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self insertSubview:self.contentView atIndex:0];
}

#pragma mark -

- (void)setLayoutDirection:(MyStaticCollectionViewLayoutDirection)layoutDirection
{
    if (_layoutDirection != layoutDirection) {
        _layoutDirection = layoutDirection;
        [self _invalidateLayout];
    }
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_contentInset, contentInset)) {
        _contentInset = contentInset;
        [self _invalidateLayout];
    }
}

- (MyStaticCollectionViewSeparatorLineInfo *)separatorLineInfo
{
    if (!_separatorLineInfo) {
        _separatorLineInfo = [MyStaticCollectionViewSeparatorLineInfo defaultSeparatorLineInfo];
    }
    return _separatorLineInfo;
}

- (void)setShowAllSeparatorLine:(BOOL)showAllSeparatorLine
{
    if (_showAllSeparatorLine != showAllSeparatorLine) {
        _showAllSeparatorLine = showAllSeparatorLine;
        [self setNeedsLayout];
    }
}

#pragma mark - layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contentView.frame = self.bounds;
    
    [self _layoutCell];
}

- (void)_invalidateLayout
{
    self.layoutValid = NO;
    [self setNeedsLayout];
}

- (void)_layoutCellWhenNeed
{
    if (!self.layoutValid) {
        [self _layoutCell];
    }
}

- (void)_layoutCell
{
    CGRect bounds = self.bounds;
    if (self.layoutValid && CGRectEqualToRect(self.layoutedContentBounds, bounds)) {
        return;
    }
    
    self.layoutValid = YES;
    self.layoutedContentBounds = bounds;
    
    //计算所有内容大小
    bounds = UIEdgeInsetsInsetRect(bounds, self.contentInset);
    
    
    //首先计算所以section内容的总大小（减去间隔）
    NSUInteger sectionCount = self.sectionsData.count;
    CGSize sectionsContentSize = bounds.size;
    for (NSUInteger index = 1 ; index < sectionCount; ++ index) {
        _MyStaticCollectionViewSection * section = self.sectionsData[index];
        if (self.layoutDirection == MyStaticCollectionViewLayoutDirectionVertical) {
            sectionsContentSize.height -= section.sectionSpacing;
        }else{
            sectionsContentSize.width -= section.sectionSpacing;
        }
    }
    sectionsContentSize.width = MAX(0.f, sectionsContentSize.width);
    sectionsContentSize.height = MAX(0.f, sectionsContentSize.height);
    
    
    BOOL firstSection = YES;
    CGPoint sectionOffset = bounds.origin;
    for (_MyStaticCollectionViewSection * section in self.sectionsData) {
        
        //计算section内容大小
        CGSize sectionContentSize = CGSizeZero;
        if (self.layoutDirection == MyStaticCollectionViewLayoutDirectionVertical) {
            
            sectionContentSize.width = sectionsContentSize.width;
            sectionContentSize.height = (self.totalSectionSpaceFactor ? (CGFloat)section.spaceFactor / self.totalSectionSpaceFactor : 1.f / self.sectionsData.count) * sectionsContentSize.height;
            
            //不是第一个section则加上间距偏移
            if (!firstSection) sectionOffset.y += section.sectionSpacing;
            
        }else{
            
            sectionContentSize.height = sectionsContentSize.height;
            sectionContentSize.width = (self.totalSectionSpaceFactor ? (CGFloat)section.spaceFactor / self.totalSectionSpaceFactor  : 1.f / self.sectionsData.count ) * sectionsContentSize.width;
            
            //不是第一个section则加上间距偏移
            if (!firstSection) sectionOffset.x += section.sectionSpacing;
        }
        
        //计算section的frame
        CGRect sectionContentViewFrame = CGRectMake(sectionOffset.x,
                                                    sectionOffset.y,
                                                    sectionContentSize.width,
                                                    sectionContentSize.height);
        sectionContentViewFrame = UIEdgeInsetsInsetRect(sectionContentViewFrame, section.sectionInset);
        sectionContentViewFrame.size.width = MAX(0.f, sectionContentViewFrame.size.width);
        sectionContentViewFrame.size.height = MAX(0.f, sectionContentViewFrame.size.height);
        section.contentFrame = sectionContentViewFrame;

        //更新偏移
        if (self.layoutDirection == MyStaticCollectionViewLayoutDirectionVertical) {
            sectionOffset.y += sectionContentSize.height;
        }else {
            sectionOffset.x+= sectionContentSize.width;
        }
        
        //标记是否是第一个section
        firstSection = NO;
        if (section.items == 0) {
            continue;
        }
        
        //开始布局cell
        
        //首先计算所有cell内容的总大小（减去间隔）
        CGSize sectionCellsContentSize = CGSizeZero;
        if (self.layoutDirection == MyStaticCollectionViewLayoutDirectionVertical) {
            sectionCellsContentSize.height = CGRectGetHeight(sectionContentViewFrame);
            sectionCellsContentSize.width = CGRectGetWidth(sectionContentViewFrame) - (section.items.count - 1) * section.interitemSpacing;
            sectionCellsContentSize.width = MAX(0.f, sectionCellsContentSize.width);
        }else{
            sectionCellsContentSize.width = CGRectGetWidth(sectionContentViewFrame);
            sectionCellsContentSize.height = CGRectGetHeight(sectionContentViewFrame) - (section.items.count - 1 ) * section.interitemSpacing;
            sectionCellsContentSize.height = MAX(0.f, sectionCellsContentSize.height);
        }
        
        //遍历计算所有cell的位置
        CGPoint itemOffset = section.contentFrame.origin;
        for (_MyStaticCollectionViewSectionItem * item in section.items) {
            
            CGRect itemCellFrame = CGRectMake(itemOffset.x, itemOffset.y, 0.f, 0.f);
            
            if (self.layoutDirection == MyStaticCollectionViewLayoutDirectionVertical) {
                itemCellFrame.size.height = sectionCellsContentSize.height;
                itemCellFrame.size.width = (section.totalItemsSpaceFactor ? (CGFloat)item.spaceFactor / section.totalItemsSpaceFactor : 1.f / section.items.count) * sectionCellsContentSize.width;
                itemOffset.x += (itemCellFrame.size.width + section.interitemSpacing);
            }else{
                itemCellFrame.size.width = sectionCellsContentSize.width;
                itemCellFrame.size.height = (section.totalItemsSpaceFactor ? (CGFloat)item.spaceFactor / section.totalItemsSpaceFactor : 1.f / section.items.count) * sectionCellsContentSize.height;
                itemOffset.y += (itemCellFrame.size.height + section.interitemSpacing);
            }
            
            item.cellFrame = itemCellFrame;
            item.cell.frame = itemCellFrame;
        }
    }
    
    //布局分割线
    [self _layoutSeparatorLine];
}

- (CALayer *)separatorLinesLayer
{
    if (!_separatorLinesLayer) {
        _separatorLinesLayer = [CALayer layer];
    }
    return  _separatorLinesLayer;
}

- (void)_layoutSeparatorLine
{
    //移除现有的所有分割线
    [_separatorLinesLayer removeFromSuperlayer];
    _separatorLinesLayer.sublayers = nil;
    self.separatorLinesLayer.frame = self.layer.bounds;
    [self.layer insertSublayer:self.separatorLinesLayer above:self.contentView.layer];
    
    
    CGRect bounds = self.bounds;
    NSUInteger sectionsCount = self.sectionsData.count;
    for (NSUInteger sectionIndex = 0; sectionIndex < sectionsCount; ++ sectionIndex) {
        
        _MyStaticCollectionViewSection * section = self.sectionsData[sectionIndex];
        
        if (sectionIndex) {
            
            MyStaticCollectionViewSeparatorLineInfo * separatorLineInfo = section.separatorLineInfo;
            if (separatorLineInfo == nil ||
                separatorLineInfo.separatorLineStyle == MyStaticCollectionViewSeparatorLineStyleNone) {
                continue;
            }
            
            //计算线的容器大小
            CGRect containerViewRect = CGRectZero;
            if (self.layoutDirection == MyStaticCollectionViewLayoutDirectionVertical) {
                containerViewRect.origin.y = CGRectGetMinY(section.contentFrame) - section.sectionInset.top - section.sectionSpacing * 0.5f;
                containerViewRect.size.width = CGRectGetWidth(bounds);
            }else{
                containerViewRect.origin.x = CGRectGetMinX(section.contentFrame) - section.sectionInset.left - section.sectionSpacing * 0.5f;
                containerViewRect.size.height = CGRectGetHeight(bounds);
            }
            
            //生成分割线
            CALayer * separatorLineLayer = [self _createSeparatorLineLayerForInfo:separatorLineInfo
                                                                  layoutDirection:self.layoutDirection == MyStaticCollectionViewLayoutDirectionVertical ? MyStaticCollectionViewLayoutDirectionHorizontal : MyStaticCollectionViewLayoutDirectionVertical
                                                                containerViewRect:containerViewRect];
            
            [self.separatorLinesLayer addSublayer:separatorLineLayer];
            
        }
        
        NSUInteger itemsCount = section.items.count;
        for (NSUInteger itemIndex = 1; itemIndex < itemsCount; ++ itemIndex) {
            
            _MyStaticCollectionViewSectionItem * item = section.items[itemIndex];
            
            if(self.showAllSeparatorLine ||
               (item.cell && [section.items[itemIndex - 1] cell])) {
                
                MyStaticCollectionViewSeparatorLineInfo * separatorLineInfo = item.separatorLineInfo;
                if (separatorLineInfo == nil ||
                    separatorLineInfo.separatorLineStyle == MyStaticCollectionViewSeparatorLineStyleNone) {
                    continue;
                }
                
                //计算线的容器大小
                CGRect containerViewRect = CGRectZero;
                if (self.layoutDirection == MyStaticCollectionViewLayoutDirectionHorizontal) {
                    containerViewRect.origin.y = CGRectGetMinY(item.cellFrame) - section.interitemSpacing * 0.5f;
                    containerViewRect.origin.x = CGRectGetMinX(section.contentFrame) - section.sectionInset.left - section.sectionSpacing * 0.5f;
                    containerViewRect.size.width = CGRectGetWidth(section.contentFrame);
                }else{
                    containerViewRect.origin.x = CGRectGetMinX(item.cellFrame) - section.interitemSpacing * 0.5f;
                    containerViewRect.origin.y = CGRectGetMinY(section.contentFrame) - section.sectionInset.top - section.sectionSpacing * 0.5f;
                    containerViewRect.size.height = CGRectGetHeight(section.contentFrame);
                }
//                containerViewRect = CGRectOffset(containerViewRect, CGRectGetMinX(section.contentFrame), CGRectGetMinY(section.contentFrame));
                
                
                CALayer * separatorLineLayer = [self _createSeparatorLineLayerForInfo:separatorLineInfo
                                                                      layoutDirection:self.layoutDirection
                                                                    containerViewRect:containerViewRect];
                
                [self.separatorLinesLayer addSublayer:separatorLineLayer];
            }
            
        }
    }
}

- (CALayer *)_createSeparatorLineLayerForInfo:(MyStaticCollectionViewSeparatorLineInfo *)separatorLineInfo
                              layoutDirection:(MyStaticCollectionViewLayoutDirection)layoutDirection
                            containerViewRect:(CGRect)containerViewRect
{
    if (separatorLineInfo.separatorLineStyle == MyStaticCollectionViewSeparatorLineStyleNone) {
        return nil;
    }
    
    CGFloat onePiexlLenght = PiexlToPoint(1.f);
    
    CGRect separatorLineFrame = CGRectZero;
    
    if (layoutDirection == MyStaticCollectionViewLayoutDirectionHorizontal) {
        separatorLineFrame.origin.x = CGRectGetMinX(containerViewRect) + separatorLineInfo.separatorLineInsets.left;
        separatorLineFrame.origin.y = CGRectGetMinY(containerViewRect) - separatorLineInfo.separatorLineWidth * 0.5f;
        separatorLineFrame.size.height = separatorLineInfo.separatorLineWidth;
        separatorLineFrame.size.width = CGRectGetWidth(containerViewRect) - separatorLineInfo.separatorLineInsets.left - separatorLineInfo.separatorLineInsets.right;
        separatorLineFrame.origin.y = roundf(separatorLineFrame.origin.y / onePiexlLenght) * onePiexlLenght;
        
    }else{
        separatorLineFrame.origin.y = CGRectGetMinY(containerViewRect) + separatorLineInfo.separatorLineInsets.top;
        separatorLineFrame.origin.x = CGRectGetMinX(containerViewRect) - separatorLineInfo.separatorLineWidth * 0.5f;
        separatorLineFrame.size.width = separatorLineInfo.separatorLineWidth;
        separatorLineFrame.size.height = CGRectGetHeight(containerViewRect) - separatorLineInfo.separatorLineInsets.top - separatorLineInfo.separatorLineInsets.bottom;
        separatorLineFrame.origin.x = roundf(separatorLineFrame.origin.x / onePiexlLenght) * onePiexlLenght;
    }
    
    
    CALayer * separatorLineLayer = nil;
    
    if (CGRectGetWidth(separatorLineFrame) > 0 && CGRectGetHeight(separatorLineFrame) > 0) {
        
        switch (separatorLineInfo.separatorLineStyle) {
            case MyStaticCollectionViewSeparatorLineStyleLine:
                separatorLineLayer = [CALayer layer];
                separatorLineLayer.backgroundColor = separatorLineInfo.separatorLineColor.CGColor;
                
                break;
                
            case MyStaticCollectionViewSeparatorLineStyleGradient:
            {
                CAGradientLayer * gradientLayer = [CAGradientLayer layer];
                UIColor * separatorLineColor = separatorLineInfo.separatorLineColor;
                gradientLayer.colors = @[(__bridge id)[separatorLineColor colorWithAlphaComponent:0.01f].CGColor,
                                         (__bridge id)separatorLineColor.CGColor,
                                         (__bridge id)[separatorLineColor colorWithAlphaComponent:0.01f].CGColor];
                
                if (layoutDirection == MyStaticCollectionViewLayoutDirectionVertical) {
                    gradientLayer.startPoint = CGPointMake(0.5f, 0.f);
                    gradientLayer.endPoint = CGPointMake(0.5f, 1.f);
                }else{
                    gradientLayer.startPoint = CGPointMake(0.f, 0.5f);
                    gradientLayer.endPoint = CGPointMake(1.f, 0.5f);
                }
                
                separatorLineLayer = gradientLayer;
            }
                
                break;
                
            default:
                break;
        }
        
        separatorLineLayer.frame = separatorLineFrame;
    }
    
    return separatorLineLayer;
}

#pragma mark - data

- (NSArray *)sectionsData
{
    if (!_sectionsData) {
        
        self.totalSectionSpaceFactor = 0.f;
        
        id<MyStaticCollectionViewDataSource> dataSource = self.dataSource;
        if (dataSource) {
            
            NSUInteger sectionCount = 1;
            if ([dataSource respondsToSelector:@selector(numberOfSectionInStaticCollectionView:)]) {
                sectionCount = [dataSource numberOfSectionInStaticCollectionView:self];
            }
            
            id<MyStaticCollectionViewDelegate> delegate = self.delegate;
            
            NSUInteger itemIndex = 0;
            NSMutableArray * sections = [NSMutableArray arrayWithCapacity:sectionCount];
            for (NSUInteger section = 0; section < sectionCount; ++ section) {
                
                //大小信息
                NSUInteger spaceFactor = 1;
                ifRespondsSelector(delegate, @selector(staticCollectionView:spaceFactorForSection:)){
                    spaceFactor = [delegate staticCollectionView:self spaceFactorForSection:section];
                }
                
                //section缩进
                UIEdgeInsets sectionInset = self.sectionInset;
                ifRespondsSelector(delegate, @selector(staticCollectionView:sectionInsetForSection:)){
                    sectionInset = [delegate staticCollectionView:self sectionInsetForSection:section];
                }
                
                //item间距
                CGFloat interitemSpacing = self.interitemSpacing;
                ifRespondsSelector(delegate, @selector(staticCollectionView:interitemSpacingForSection:)){
                    interitemSpacing = [delegate staticCollectionView:self interitemSpacingForSection:section];
                }
                
                //section间距和分割线
                CGFloat sectionSpacing = 0.f;
                MyStaticCollectionViewSeparatorLineInfo * separatorLineInfo = nil;
                
                if (section > 0) {
                    
                    ifRespondsSelector(delegate, @selector(staticCollectionView:separatorLineInfoForSection:betweenSection:)){
                        separatorLineInfo = [delegate staticCollectionView:self
                                               separatorLineInfoForSection:section - 1
                                                            betweenSection:section];
                    }else {
                        separatorLineInfo = self.separatorLineInfo;
                    }
                    
                    ifRespondsSelector(delegate, @selector(staticCollectionView:sectionSpacingForSection:betweenSection:)){
                        sectionSpacing = [delegate staticCollectionView:self
                                               sectionSpacingForSection:section - 1
                                                         betweenSection:section];
                    }else {
                        sectionSpacing = self.sectionSpacing;
                    }
                }
                
                //section项目
                if (![dataSource respondsToSelector:@selector(staticCollectionView:numberOfItemsInSection:)]) {
                    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                                   reason:@"代理必须响应消息staticCollectionView:numberOfItemsInSection:"
                                                 userInfo:nil];
                }
                
                NSUInteger itemsCount = [dataSource staticCollectionView:self numberOfItemsInSection:section];
                NSMutableArray * items = [NSMutableArray arrayWithCapacity:itemsCount];
                NSUInteger totalItemsSpaceFactor = 0;
                for (NSUInteger item = 0; item < itemsCount; ++ item) {
                    _MyStaticCollectionViewSectionItem * itemData = [self _getItemDataAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section] itemIndex:itemIndex ++];
                    [items addObject:itemData];
                    totalItemsSpaceFactor += itemData.spaceFactor;
                    [self.contentView addSubview:itemData.cell];
                }
                
                _MyStaticCollectionViewSection * sectionData = [[_MyStaticCollectionViewSection alloc] initWithSpaceFactor:spaceFactor sectionInset:sectionInset interitemSpacing:interitemSpacing sectionSpacing:sectionSpacing separatorLineInfo:separatorLineInfo items:items totalItemsSpaceFactor:totalItemsSpaceFactor];
                [sections addObject:sectionData];
                
                self.totalSectionSpaceFactor += spaceFactor;
            }
            
            _sectionsData = sections;
        }else{
            _sectionsData = [NSArray array];
        }
    }
    
    return  _sectionsData;
}

- (_MyStaticCollectionViewSectionItem *)_getItemDataAtIndexPath:(NSIndexPath *)indexPath itemIndex:(NSUInteger)itemIndex
{
    id<MyStaticCollectionViewDataSource> dataSource = self.dataSource;
    if (![dataSource respondsToSelector:@selector(staticCollectionView:cellForItemAtIndexPath:itemIndex:)] &&
        ![dataSource respondsToSelector:@selector(staticCollectionView:cellForItemAtIndexPath:)]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"代理必须响应消息staticCollectionView:cellForItemAtIndexPath:itemIndex:或者staticCollectionView:cellForItemAtIndexPath:"
                                     userInfo:nil];
    }
    
    MyStaticCollectionViewCell * cell = nil;
    if ([dataSource respondsToSelector:@selector(staticCollectionView:cellForItemAtIndexPath:itemIndex:)]) {
        cell = [dataSource staticCollectionView:self cellForItemAtIndexPath:indexPath itemIndex:itemIndex];
    }else {
        cell = [dataSource staticCollectionView:self cellForItemAtIndexPath:indexPath];
    }
    cell.highlighted = NO;
    cell.selected = NO;
    
    if (cell && ![cell isKindOfClass:[MyStaticCollectionViewCell class]]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"staticCollectionView:cellForItemAtIndexPath:返回的cell必须为MyStaticCollectionViewCell及其子类的实例子"
                                     userInfo:nil];
    }
    
    NSUInteger spaceFactor = 1;
    id<MyStaticCollectionViewDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(staticCollectionView:spaceFactorForItemAtIndexPath:)){
        spaceFactor = [delegate staticCollectionView:self spaceFactorForItemAtIndexPath:indexPath];
    }
    
    MyStaticCollectionViewSeparatorLineInfo * separatorLineInfo = nil;
    if (indexPath.item > 0) {
        ifRespondsSelector(delegate, @selector(staticCollectionView:separatorLineInfoForItem:betweenItem:inSection:)){
            separatorLineInfo = [delegate staticCollectionView:self
                                      separatorLineInfoForItem:indexPath.item - 1
                                                   betweenItem:indexPath.item
                                                     inSection:indexPath.section];
        }else {
            separatorLineInfo = self.separatorLineInfo;
        }
    }
    
    return [[_MyStaticCollectionViewSectionItem alloc] initWithSpaceFactor:spaceFactor
                                                         separatorLineInfo:separatorLineInfo
                                                                      cell:cell];
}

- (void)_invalidateData
{
    if (_sectionsData) {
        
        //cell加入复用池
        [self _addCellToReusablePool];
        
        //移除所有单元
        [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        self.totalSectionSpaceFactor = 0;
        
        _sectionsData = nil;
    }
}

- (void)reloadData
{
    //设置布局有效，防止不必要的布局
    self.layoutValid = YES;
    
    //触摸无效
    [self _invalidateTouch];
    //清除选择
    [self _clearSelection];
    //数据无效
    [self _invalidateData];
    //布局无效
    [self _invalidateLayout];
}

- (NSUInteger)numberOfSections {
    return self.sectionsData.count;
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
    return [[(_MyStaticCollectionViewSection *)self.sectionsData[section] items] count];
}

- (_MyStaticCollectionViewSectionItem *)_sectionItemAtIndexPath:(NSIndexPath *)indexPath
{
    _MyStaticCollectionViewSection * section = self.sectionsData[indexPath.section];
    return section.items[indexPath.item];
}

- (void)_checkIndexIndexPath:(NSIndexPath *)indexPath
{
    NSException * expection = nil;
    
    if (indexPath) {
        
        if (self.sectionsData.count - 1 < indexPath.section) {
            expection = [NSException exceptionWithName:NSRangeException
                                                reason:[NSString stringWithFormat:@"indexPath.section = %i 索引超出范围",(int)indexPath.section]
                                              userInfo:nil];
        }else if([self numberOfItemsInSection:indexPath.section] - 1 < indexPath.item){
            expection = [NSException exceptionWithName:NSRangeException
                                                reason:[NSString stringWithFormat:@"indexPath.item = %i 索引超出范围",(int)indexPath.item]
                                              userInfo:nil];
        }
        
    }else{
        expection = [NSException exceptionWithName:NSRangeException
                                            reason:@"indexPath不能为nil"
                                          userInfo:nil];
    }
    
    if (expection) {
        @throw expection;
    }
}

- (id)cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //核对indexPath
    [self _checkIndexIndexPath:indexPath];
    //必要时布局
    [self _layoutCellWhenNeed];
    
    return [self _sectionItemAtIndexPath:indexPath].cell;
}

- (NSArray *)cellsAtSections:(NSIndexSet *)sections
{
    //必要时布局
    [self _layoutCellWhenNeed];
    
    NSMutableArray * cells = [NSMutableArray array];
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        _MyStaticCollectionViewSection * section = [self.sectionsData objectAtIndex:idx];
        for (_MyStaticCollectionViewSectionItem * item in section.items) {
            if (item.cell) {
                [cells addObject:item.cell];
            }
        }
    }];
    
    return cells;
}

- (NSArray *)allCells {
    return [self cellsAtSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.sectionsData.count)]];
}

#pragma mark -

- (NSIndexPath *)indexPathForCell:(MyStaticCollectionViewCell *)cell
{
    if (cell.superview == self.contentView) {
        NSInteger sectionIndex = 0;
        for (_MyStaticCollectionViewSection * section in self.sectionsData) {
            NSInteger itemIndex = 0;
            for (_MyStaticCollectionViewSectionItem * item in section.items) {
                if (item.cell == cell) {
                    return [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
                }
                ++ itemIndex;
            }
            ++ sectionIndex;
        }
    }
    
    return nil;
}

#pragma mark - selection

- (NSMutableSet *)selectionIndexPaths
{
    if (!_selectionIndexPaths) {
        _selectionIndexPaths = [NSMutableSet set];
    }
    
    return _selectionIndexPaths;
}

- (void)_clearSelection
{
    for (NSIndexPath * indexPath in self.selectionIndexPaths) {
        _MyStaticCollectionViewSectionItem * item = [self _sectionItemAtIndexPath:indexPath];
        item.cell.selected = NO;
    }
    
    [self.selectionIndexPaths removeAllObjects];
}

- (void)setAllowsSelection:(BOOL)allowsSelection
{
    if (_allowsSelection != allowsSelection) {
        _allowsSelection = allowsSelection;
        [self _invalidateTouch];
        [self _clearSelection];
    }
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    if (_allowsMultipleSelection != allowsMultipleSelection) {
        _allowsMultipleSelection = allowsMultipleSelection;
        [self _invalidateTouch];
        [self _clearSelection];
    }
}

- (NSIndexPath *)indexPathForSelectedItem {
    return [self.selectionIndexPaths anyObject];
}

- (NSArray *)indexPathsForSelectedItems {
    return self.selectionIndexPaths.count ? self.selectionIndexPaths.allObjects : nil;
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    [self _checkIndexIndexPath:indexPath];
    
    if (self.allowsSelection) {
        
        if (![self.selectionIndexPaths containsObject:indexPath]) {
            
            if (!self.allowsMultipleSelection) {
                
                //删除
                NSIndexPath * indexPath = [self indexPathForSelectedItem];
                if (indexPath) {
                    [self.selectionIndexPaths removeObject:indexPath];
                    MyStaticCollectionViewCell * cell = [self cellForItemAtIndexPath:indexPath];
                    cell.selected = NO;
                }
            }
            
            //选择
            [self.selectionIndexPaths addObject:indexPath];
            MyStaticCollectionViewCell * cell = [self cellForItemAtIndexPath:indexPath];
            [cell setSelected:YES animated:animated];
            
        }
    }
}

- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    if ([self.selectionIndexPaths containsObject:indexPath]) {
        [self.selectionIndexPaths removeObject:indexPath];
        
        MyStaticCollectionViewCell * cell = [self cellForItemAtIndexPath:indexPath];
        [cell setSelected:NO animated:animated];
    }
}

- (void)deselectAllItem:(BOOL)animated
{
    for (NSIndexPath * indexPath in self.selectionIndexPaths) {
        MyStaticCollectionViewCell * cell = [self cellForItemAtIndexPath:indexPath];
        [cell setSelected:NO animated:animated];
    }
    
    [self.selectionIndexPaths removeAllObjects];
}

#pragma mark - touch

- (CGRect)itemFrameAtIndexPath:(NSIndexPath *)indexPath
{
    //核对索引
    [self _checkIndexIndexPath:indexPath];
    
    //必须时进行布局
    [self _layoutCellWhenNeed];
    
    //返回位置
    return [[self cellForItemAtIndexPath:indexPath] frame];
}


- (NSIndexPath *)indexPathForItemAtPoint:(CGPoint)point
{
    NSIndexPath * indexPath = nil;
    
    if (CGRectContainsPoint(self.bounds, point)) {
        
        //必须时进行布局
        [self _layoutCellWhenNeed];
        
        NSUInteger sectionIndex = 0;
        for (_MyStaticCollectionViewSection * section in self.sectionsData) {
            //在section里面
            if (CGRectContainsPoint(section.contentFrame, point)) {
                
                NSUInteger itemIndex = 0;
                for (_MyStaticCollectionViewSectionItem * item in section.items) {
                    
                    //包含
                    if (CGRectContainsPoint(item.cellFrame, point)) {
                        
                        if ([item.cell touchPointInside:[item.cell convertPoint:point fromView:self]]) {
                            indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
                        }
                        
                        break;
                    }
                    
                    ++ itemIndex;
                }
                
                break;
            }
            
            ++ sectionIndex;
        }
    }
    
    return indexPath;
}

- (NSMutableArray *)highlightItemInfos
{
    if (!_highlightItemInfos) {
        _highlightItemInfos = [NSMutableArray array];
    }
    
    return _highlightItemInfos;
}

- (void)_invalidateTouch
{
    for (_MyStaticCollectionViewHighlightItemInfo * highlightItemInfo in _highlightItemInfos) {
        MyStaticCollectionViewCell * cell = [self cellForItemAtIndexPath:highlightItemInfo.indexPath];
        cell.highlighted = NO;
    }
    
    [_highlightItemInfos removeAllObjects];
}

- (NSMutableSet *)unuseTouches
{
    if (!_unuseTouches) {
        _unuseTouches = [NSMutableSet set];
    }
    
    return _unuseTouches;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSMutableSet * unuseTouches = [NSMutableSet setWithSet:touches];
    
    if (self.allowsSelection) {
        
        for (UITouch * touch in touches) {
            
            NSIndexPath * indexPath = [self indexPathForItemAtPoint:[touch locationInView:self]];
            if (indexPath) {
                
                [unuseTouches removeObject:touch];
                
                //单选且已有选中的则直接忽略
                if (!self.allowsMultipleSelection && self.highlightItemInfos.count != 0) {
                    return;
                }
                
                _MyStaticCollectionViewHighlightItemInfo * highlightItemInfo = [[_MyStaticCollectionViewHighlightItemInfo alloc] initWithTouch:touch itemIndexPath:indexPath];
                
                //不包含当前触摸的单元
                if (![self.highlightItemInfos containsObject:highlightItemInfo]) {
                    
                    id<MyStaticCollectionViewDelegate> delegate = self.delegate;
                    if ([delegate respondsToSelector:@selector(staticCollectionView:shouldHighlightItemAtIndexPath:)]) {
                        if (![delegate staticCollectionView:self shouldHighlightItemAtIndexPath:highlightItemInfo.indexPath]) {
                            [unuseTouches addObject:touch];
                            continue;
                        }
                    }
                    
                    [self.highlightItemInfos addObject:highlightItemInfo];
                    
                    MyStaticCollectionViewCell * cell = [self cellForItemAtIndexPath:highlightItemInfo.indexPath];
                    [cell setHighlighted:YES animated:YES];
                    
                    ifRespondsSelector(delegate, @selector(staticCollectionView:didHighlightItemAtIndexPath:)){
                        [delegate staticCollectionView:self didHighlightItemAtIndexPath:highlightItemInfo.indexPath];
                    }
                }
            }
        }
    }
    
    //触摸消息转发
    if (unuseTouches.count) {
        [self.unuseTouches unionSet:unuseTouches];
        [super touchesBegan:unuseTouches withEvent:event];
    }
}

- (_MyStaticCollectionViewHighlightItemInfo *)_highlightItemInfoForTouch:(UITouch *)touch
{
    _MyStaticCollectionViewHighlightItemInfo * highlightItemInfo = [[_MyStaticCollectionViewHighlightItemInfo alloc] initWithTouch:touch];
    
    NSUInteger index = [self.highlightItemInfos indexOfObject:highlightItemInfo];
    if (index != NSNotFound) {
        return self.highlightItemInfos[index];
    }else{
        return nil;
    }
}

- (void)_divideTounches:(NSSet *)touches unusedTouches:(NSSet **)unusedTouches usedTouches:(NSSet **)usedTouches
{
    NSMutableSet * __unuseTouches = [NSMutableSet setWithSet:touches];
    NSMutableSet * __useTouches = [NSMutableSet setWithSet:touches];
    
    [__unuseTouches intersectSet:self.unuseTouches];
    [__useTouches minusSet:self.unuseTouches];
    
    if (unusedTouches) {
        *unusedTouches = __unuseTouches;
    }
    
    if (usedTouches) {
        *usedTouches = __useTouches;
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet * unusedTouches, *usedTouches;
    [self _divideTounches:touches unusedTouches:&unusedTouches usedTouches:&usedTouches];
    
    if (unusedTouches.count) {
        [super touchesMoved:unusedTouches withEvent:event];
    }
    
    for (UITouch * touch in usedTouches) {
        
        _MyStaticCollectionViewHighlightItemInfo * highlightItemInfo = [self _highlightItemInfoForTouch:touch];
        if (highlightItemInfo) {
            
            _MyStaticCollectionViewSectionItem * item = [self _sectionItemAtIndexPath:highlightItemInfo.indexPath];
            if (!CGRectContainsPoint(item.cellFrame, [touch locationInView:self])) { //触点移出
                [self _unhighlightItem:highlightItemInfo];
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet * unusedTouches, *usedTouches;
    [self _divideTounches:touches unusedTouches:&unusedTouches usedTouches:&usedTouches];
    
    if (unusedTouches.count) {
        [super touchesEnded:unusedTouches withEvent:event];
        [self.unuseTouches minusSet:unusedTouches];
    }
    
    for (UITouch * touch in usedTouches) {
        
        _MyStaticCollectionViewHighlightItemInfo * highlightItemInfo = [self _highlightItemInfoForTouch:touch];
        
        if (highlightItemInfo) {
            
            id<MyStaticCollectionViewDelegate> delegate = self.delegate;
            //多选，取消
            if (self.allowsMultipleSelection && [self.selectionIndexPaths containsObject:highlightItemInfo.indexPath]) {
                
                //取消选择
                if ([delegate respondsToSelector:@selector(staticCollectionView:shouldDeselectItemAtIndexPath:)]) {
                    if (![delegate staticCollectionView:self shouldDeselectItemAtIndexPath:highlightItemInfo.indexPath]) {
                        goto END;
                    }
                }
                
                [self.selectionIndexPaths removeObject:highlightItemInfo.indexPath];
                
                MyStaticCollectionViewCell * cell = [self cellForItemAtIndexPath:highlightItemInfo.indexPath];
                cell.selected = NO;
                
                ifRespondsSelector(delegate, @selector(staticCollectionView:didDeselectItemAtIndexPath:)){
                    [delegate staticCollectionView:self didDeselectItemAtIndexPath:highlightItemInfo.indexPath];
                }
                
            }else{
                
                if ([delegate respondsToSelector:@selector(staticCollectionView:shouldSelectItemAtIndexPath:)]) {
                    if (![delegate staticCollectionView:self shouldSelectItemAtIndexPath:highlightItemInfo.indexPath]) {
                        goto END;
                    }
                }
                
                [self selectItemAtIndexPath:highlightItemInfo.indexPath animated:YES];
                
                ifRespondsSelector(delegate, @selector(staticCollectionView:didSelectItemAtIndexPath:)){
                    [delegate staticCollectionView:self didSelectItemAtIndexPath:highlightItemInfo.indexPath];
                }
                
            }
            
        END:
            
            [self _unhighlightItem:highlightItemInfo];
            
        }
        
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet * unusedTouches, *usedTouches;
    [self _divideTounches:touches unusedTouches:&unusedTouches usedTouches:&usedTouches];
    
    if (unusedTouches.count) {
        [super touchesCancelled:unusedTouches withEvent:event];
        [self.unuseTouches minusSet:unusedTouches];
    }
    
    for (UITouch * touch in usedTouches) {
        _MyStaticCollectionViewHighlightItemInfo * highlightItemInfo = [self _highlightItemInfoForTouch:touch];
        [self _unhighlightItem:highlightItemInfo];
    }
}

- (void)_unhighlightItem:(_MyStaticCollectionViewHighlightItemInfo *)highlightItemInfo
{
    if (highlightItemInfo) {
        
        MyStaticCollectionViewCell * cell = [self cellForItemAtIndexPath:highlightItemInfo.indexPath];
        [cell setHighlighted:NO animated:YES];
        
        id<MyStaticCollectionViewDelegate> delegate = self.delegate;
        ifRespondsSelector(delegate, @selector(staticCollectionView:didUnhighlightItemAtIndexPath:)){
            [delegate staticCollectionView:self didUnhighlightItemAtIndexPath:highlightItemInfo.indexPath];
        }
        
        [self.highlightItemInfos removeObject:highlightItemInfo];
    }
}

#pragma mark -

- (NSArray *)needAnimatedViewsForShow:(BOOL)show context:(id)context {
    return self.allCells;
}

#pragma mark -

- (NSMutableDictionary *)reusableCellPool
{
    if (!_reusableCellPool) {
        _reusableCellPool = [NSMutableDictionary dictionary];
    }
    
    return _reusableCellPool;
}

//所有元素加入
- (void)_addCellToReusablePool
{
    NSArray * allCells = [self allCells];
    for (MyStaticCollectionViewCell * cell in allCells) {
        
        NSString * reuseIdentifier = cell.reuseIdentifier;
        if (reuseIdentifier.length) { //存在复用定义则加入复用池
            
            NSMutableArray * reusableCells = self.reusableCellPool[reuseIdentifier];
            if (!reusableCells) {
                reusableCells = [NSMutableArray array];
                self.reusableCellPool[reuseIdentifier] = reusableCells;
            }
            
            [reusableCells addObject:cell];
            
            //加入复用池
            [cell didAddToReusePool];
        }
    }
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    MyStaticCollectionViewCell * cell = nil;
    
    if (identifier.length) {
        
        NSMutableArray * reusableCells = self.reusableCellPool[identifier];
        if (reusableCells.count) { //取出最后一个cell
            cell = [reusableCells lastObject];
            [reusableCells removeLastObject];
            
            //准备复用
            [cell prepareForReuse];
        }
        
        //无cell后移除数组
        if (reusableCells && reusableCells.count == 0) {
            [self.reusableCellPool removeObjectForKey:identifier];
        }
    }
    
    return cell;
}

@end
