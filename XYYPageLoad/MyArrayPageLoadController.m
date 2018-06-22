//
//  MyArrayPageLoadController.m
//  
//
//  Created by LeslieChen on 15/3/31.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyArrayPageLoadController.h"
#import "XYYFoundation.h"

//----------------------------------------------------------

@interface MyArrayPageLoadController ()

//数据
@property(nonatomic,strong,readonly) NSMutableArray * datasArray;

@end

//----------------------------------------------------------

@implementation MyArrayPageLoadController

@synthesize datasArray = _datasArray;

#pragma mark -

- (NSUInteger)sectionCount {
    return self.startSection + 1;
}

- (NSUInteger)dataCountAtSection:(NSUInteger)section {
    return section == self.startSection ? self.currentDataCount + self.startRow : 0;
}

- (NSUInteger)currentDataCount {
    return _datasArray.count;
}


#pragma mark -

- (NSMutableArray *)datasArray {
    return _datasArray ?: (_datasArray = [NSMutableArray array]);
}


- (NSArray *)allDatas {
    return [NSArray arrayWithArray:self.datasArray];;
}


- (BOOL)containDataAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath && indexPath.section == self.startSection &&
           indexPath.row >= self.startRow &&
           indexPath.row < self.datasArray.count + self.startRow;
}

- (NSIndexPath *)indexPathForDataAtIndex:(NSUInteger)index
{
    if (index < self.datasArray.count) {
        return [NSIndexPath indexPathForItem:index + self.startRow inSection:self.startSection];
    }
    
    return nil;
}

- (NSUInteger)indexForDataAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self containDataAtIndexPath:indexPath]) {
        return indexPath.row - self.startRow;
    }
    
    return NSNotFound;
}

- (id)dataAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = [self indexForDataAtIndexPath:indexPath];
    return index == NSNotFound ? nil : self.datasArray[index];
}

- (id)dataAtIndex:(NSUInteger)index {
    return self.datasArray[index];
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

- (NSArray *)addDatasToDataStorage:(NSArray *)datas
{
    NSArray * indexPaths = indexPathsFromRange(self.startSection, NSMakeRange(self.startRow + self.datasArray.count, datas.count));
    [self.datasArray addObjectsFromArray:datas];
    
    return indexPaths;
}


- (void)removeDatas:(NSArray *)datas
{
    if (datas.count) {
        
        NSMutableArray * indexPaths = [NSMutableArray arrayWithCapacity:datas.count];
        for (id data in datas) {
            NSIndexPath * indexPath = [self indexPathForData:data];
            if (indexPath) {
                [indexPaths addObject:indexPath];
            }
        }
        
        [self removeDataAtIndexPaths:indexPaths];
    }
}

- (NSArray *)removeDatasFromDataStorageWithIndexPath:(NSArray *)indexPaths
{
    NSMutableIndexSet * indexSet = [NSMutableIndexSet indexSet];
    NSMutableArray * resultIndexPaths = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath * indexPath in indexPaths) {
        
        NSUInteger index = [self indexForDataAtIndexPath:indexPath];
        if (index != NSNotFound) {
            [indexSet addIndex:index];
            [resultIndexPaths addObject:indexPath];
        }
    }
    
    [self.datasArray removeObjectsAtIndexes:indexSet];
    return resultIndexPaths;
}

- (NSArray *)insertDatas:(NSArray *)datas toDataStorageWithIndexPath:(NSArray *)indexPaths
{
    NSMutableArray * insertIndexPaths = [NSMutableArray arrayWithCapacity:indexPaths.count];
    
    NSUInteger i = 0, dataCount = self.datasArray.count;;
    for (NSIndexPath * indexPath in indexPaths) {
        NSInteger index = indexPath.row - self.startRow;
        if (indexPath.section == self.startSection && index >= 0 && dataCount >= index) {
            [insertIndexPaths addObject:indexPath];
            [self.datasArray insertObject:datas[i] atIndex:index];
        }
        
        ++ i;
    }
    
    return insertIndexPaths;
}

- (NSArray *)replayDatasInDataStorageWithIndexPath:(NSArray *)indexPaths withDatas:(NSArray *)datas
{
    NSMutableArray * replaceIndexPaths = [NSMutableArray arrayWithCapacity:indexPaths.count];
    
    NSUInteger i = 0;
    for (NSIndexPath * indexPath in indexPaths) {
        NSUInteger index = [self indexForDataAtIndexPath:indexPath];
        if (index != NSNotFound) {
            [replaceIndexPaths addObject:indexPath];
            [self.datasArray replaceObjectAtIndex:index withObject:datas[i]];
        }
        
        ++ i;
    }
    
    return replaceIndexPaths;
}


@end
