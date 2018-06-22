//
//  MySectionArrayPageLoadController.m
//  
//
//  Created by LeslieChen on 15/4/25.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MySectionArrayPageLoadController.h"

//----------------------------------------------------------

@interface MySectionArrayPageLoadController ()

//数据
@property(nonatomic,strong,readonly) NSMutableArray * datasArray;

@end

//----------------------------------------------------------

@implementation MySectionArrayPageLoadController

@synthesize datasArray = _datasArray;

#pragma mark -

- (NSUInteger)sectionCount {
    return self.startSection + self.datasArray.count;
}

- (NSUInteger)dataCountAtSection:(NSUInteger)section {
    return  1 + self.startRow;
}

- (NSUInteger)currentDataCount {
    return _datasArray.count;
}

#pragma mark -

- (NSMutableArray *)datasArray {
    return _datasArray ?: (_datasArray = [NSMutableArray array]);
}

- (NSArray *)allDatas {
    return [NSArray arrayWithArray:self.datasArray];
}

- (BOOL)containDataAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath && indexPath.section >= self.startSection &&
           indexPath.section < self.datasArray.count + self.startSection &&
           indexPath.row == self.startRow;
}

- (NSIndexPath *)indexPathForDataAtIndex:(NSUInteger)index
{
    if (index < self.datasArray.count) {
        return [NSIndexPath indexPathForItem:self.startRow inSection:self.startSection + index];
    }
    
    return nil;
}

- (NSUInteger)indexForDataAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self containDataAtIndexPath:indexPath]) {
        return indexPath.section - self.startSection;
    }
    
    return NSNotFound;
}

- (id)dataAtIndex:(NSUInteger)index {
    return self.datasArray[index];
}

- (id)dataAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = [self indexForDataAtIndexPath:indexPath];
    return index == NSNotFound ? nil : self.datasArray[index];
}

- (NSIndexPath *)indexPathForData:(id)data
{
    NSUInteger index = [self.datasArray indexOfObject:data];
    return (index != NSNotFound) ? [self indexPathForDataAtIndex:index] : nil;
}

#pragma mark -

- (BOOL)updateDataStorageWithDatas:(NSArray *)datas
{
    [self.datasArray removeAllObjects];
    [self.datasArray addObjectsFromArray:datas];
    
    return YES;
}

- (id)addDatasToDataStorage:(NSArray *)datas
{
    NSIndexSet * sectionsSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.startSection + self.datasArray.count, datas.count)];
    [self.datasArray addObjectsFromArray:datas];
    
    return sectionsSet;
}

- (void)removeDatas:(NSArray *)datas
{
    if (datas.count) {
        
        NSMutableIndexSet * sections = [NSMutableIndexSet indexSet];
        for (id data in datas) {
            NSIndexPath * indexPath = [self indexPathForData:data];
            if (indexPath) {
                [sections addIndex:indexPath.section];
            }
        }
        
        [self removeDataAtSections:sections];
    }
}

- (NSIndexSet *)removeDatasFromDataStorageWithSections:(NSIndexSet *)sections
{
    NSMutableIndexSet * indexSet = [NSMutableIndexSet indexSet];
    NSMutableIndexSet * removedSections = [NSMutableIndexSet indexSet];
    
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if (idx >= self.startSection) {
            [indexSet addIndex:idx - self.startSection]; 
            [removedSections addIndex:idx];
        }
    }];
    
    [self.datasArray removeObjectsAtIndexes:indexSet];
    
    return removedSections;
}

- (NSIndexSet *)insertDatas:(NSArray *)datas toDataStorageWithSections:(NSIndexSet *)sections
{
    NSMutableIndexSet * indexSet = [NSMutableIndexSet indexSet];
    
    NSUInteger index = [sections firstIndex];
    for (NSUInteger i = 0; index != NSNotFound; ++ i) {
        
        if (index >= self.startSection) {
            [indexSet addIndex:index];
            [self.datasArray insertObject:datas[i] atIndex:index - self.startSection];
        }
        
        index = [indexSet indexGreaterThanIndex:index];
    }

    return indexSet;
}

- (NSIndexSet *)replayDatasInDataStorageWithSections:(NSIndexSet *)sections withDatas:(NSArray *)datas
{
    NSMutableIndexSet * indexSet = [NSMutableIndexSet indexSet];
    
    NSUInteger index = [sections firstIndex];
    for (NSUInteger i = 0; index != NSNotFound; ++ i) {
        
        if (index >= self.startSection) {
            [indexSet addIndex:index];
            [self.datasArray replaceObjectAtIndex:index - self.startSection withObject:datas[i]];
        }
        
        index = [indexSet indexGreaterThanIndex:index];
    }
    
    return indexSet;
}


@end
