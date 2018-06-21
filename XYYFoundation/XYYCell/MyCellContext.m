//
//  MyCellContext.m

//
//  Created by LeslieChen on 15/3/7.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import "MyCellContext.h"

@implementation MyCellContext

- (id)initWithIndexPath:(NSIndexPath *)indexPath {
    return [self initWithIndexPath:indexPath totalInfoIndexPath:nil context:nil otherInfo:nil];
}

- (id)initWithIndexPath:(NSIndexPath *)indexPath context:(id)context{
    return [self initWithIndexPath:indexPath totalInfoIndexPath:nil context:context otherInfo:nil];
}

- (id)initWithIndexPath:(NSIndexPath *)indexPath totalInfoIndexPath:(NSIndexPath *)totalInfoIndexPath context:(id)context
{
    return [self initWithIndexPath:indexPath totalInfoIndexPath:totalInfoIndexPath context:context otherInfo:nil];
}

- (id)initWithIndexPath:(NSIndexPath *)indexPath totalInfoIndexPath:(NSIndexPath *)totalInfoIndexPath context:(id)context otherInfo:(NSDictionary *)otherInfo
{
    self = [super init];
    
    if (self) {
        _indexPath = indexPath;
        _totalInfoIndexPath = totalInfoIndexPath;
        _context = context;
        _otherInfo = otherInfo;
    }
    
    return self;
}


@end
