//
//  MyContentViewTableViewCell.m
//
//
//  Created by LeslieChen on 14/12/2.
//  Copyright (c) 2014年 YB. All rights reserved.
//

//----------------------------------------------------------

#import "MyContentViewTableViewCell.h"
#import "XYYBaseDef.h"
#import "UIView+IntervalAnimation.h"
#import "UITableViewCell+ShowContent.h"
#import "NSDictionary+MyCategory.h"

//----------------------------------------------------------

@implementation MyContentViewTableViewCell

@synthesize delegate = _delegate;

+ (CGFloat)heightForCellWithInfo:(NSDictionary *)info tableView:(UITableView *)tableView context:(id)context
{
    CGFloat height = [self sizeForCellWithInfo:info
                             containerViewSize:tableView.bounds.size
                                       context:[context isKindOfClass:[MyCellContext class]] ? context : nil].height;
    
    return height <= 0.f ? tableView.rowHeight : height;
}

+ (CGSize)sizeForCellWithInfo:(NSDictionary *)info containerViewSize:(CGSize)containerViewSize context:(MyCellContext *)context
{
    
    CGSize cellSize = CGSizeZero;
    
    NSString * cellSizeValue = [info sizeValue];
    if (!cellSizeValue) {
        
        id heightValue = [info heightValue];
        id widthValue = [info widthValue];
        
        if (heightValue || widthValue) {
            cellSize = CGSizeMake(widthValue ? [widthValue floatValue] : containerViewSize.width, heightValue ? [heightValue floatValue] : containerViewSize.height);
        }
    }else {
        cellSize = CGSizeFromString(cellSizeValue);
    }
    
    cellSize.width  = MAX(0.f, cellSize.width);
    cellSize.height = MAX(0.f, cellSize.height);
    
    return cellSize;

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.ignoreCellBasicInfo = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.ignoreCellBasicInfo = YES;
    }
    
    return self;
}


- (void)updateCellWithInfo:(NSDictionary *)info context:(MyCellContext *)context
{
    if (!self.ignoreCellBasicInfo) {
        [super updateCellWithInfo:info context:context];
    }
}
 
@end

//----------------------------------------------------------

@implementation NSDictionary (MyContentViewTableViewCell)

- (NSString *)contentViewTableViewCellClassName
{
    NSString * className = [self valueForKey:@"tableViewCellClass" withClass:[NSString class]];
    
    if ([NSClassFromString(className) isSubclassOfClass:[MyContentViewTableViewCell class]]) {
        return className;
    }else{
        return nil;
    }
}

- (Class)contentViewTableViewCellClass {
    return NSClassFromString([self contentViewTableViewCellClassName]);
}

@end

