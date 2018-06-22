//
//  MyBasicPageLoadController.h
//  
//
//  Created by LeslieChen on 15/3/31.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import "MyPageLoadControllerProtocol.h"

@interface MyBasicPageLoadController : NSObject <MyPageLoadControllerProtocol>

- (id)initWithPageSize:(NSUInteger)pageSize
          startSection:(NSUInteger)startSection
              startRow:(NSUInteger)startRow NS_DESIGNATED_INITIALIZER;

//子类实现
- (BOOL)updateDataStorageWithDatas:(NSArray *)datas;
- (id)addDatasToDataStorage:(NSArray *)datas;

- (NSArray *)removeDatasFromDataStorageWithIndexPath:(NSArray *)indexPaths;
- (NSIndexSet *)removeDatasFromDataStorageWithSections:(NSIndexSet *)sections;

- (NSArray *)insertDatas:(NSArray *)datas toDataStorageWithIndexPath:(NSArray *)indexPaths;
- (NSIndexSet *)insertDatas:(NSArray *)datas toDataStorageWithSections:(NSIndexSet *)sections;

- (NSArray *)replayDatasInDataStorageWithIndexPath:(NSArray *)indexPaths withDatas:(NSArray *)datas;
- (NSIndexSet *)replayDatasInDataStorageWithSections:(NSIndexSet *)sections withDatas:(NSArray *)datas;

@end
