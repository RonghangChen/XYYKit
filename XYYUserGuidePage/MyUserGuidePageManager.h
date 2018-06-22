//
//  MyUserGuidePageManager.h
//  
//
//  Created by LeslieChen on 15/5/21.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>
#import "MyUserGuideView.h"

//----------------------------------------------------------

@class MyUserGuidePageManager;

//----------------------------------------------------------

@protocol MyUserGuidePageManagerDelegate <MyUserGuideViewDelegate>

@optional

- (void)userGuidePageManager:(MyUserGuidePageManager *)manager
        startShowPageAtIndex:(NSUInteger)pageIndex
             fromPageAtIndex:(NSUInteger)fromPageIndex;

- (void)userGuidePageManager:(MyUserGuidePageManager *)manager
          showingPageAtIndex:(NSUInteger)pageIndex
             fromPageAtIndex:(NSUInteger)fromPageIndex
                withProgress:(CGFloat)progress;

- (void)userGuidePageManager:(MyUserGuidePageManager *)manager
          didShowPageAtIndex:(NSUInteger)index
             fromPageAtIndex:(NSUInteger)fromPageIndex;

- (void)userGuidePageManager:(MyUserGuidePageManager *)manager
       cancleShowPageAtIndex:(NSUInteger)index
             fromPageAtIndex:(NSUInteger)fromPageIndex;

@end


//----------------------------------------------------------

@interface MyUserGuidePageManager : NSObject

- (id)initWithPageInfosFileName:(NSString *)infoFileName bundle:(NSBundle *)bundleOrNil;
- (id)initWithPageInfos:(NSArray *)pageInfos;

@property(nonatomic,strong,readonly) UIView * contentView;

@property(nonatomic,readonly) NSUInteger pageCount;
@property(nonatomic,readonly) NSUInteger currentPageIndex;
- (NSDictionary *)pageInfoAtIndex:(NSUInteger)index;

@property(nonatomic) BOOL bounces;

@property(nonatomic,weak) id<MyUserGuidePageManagerDelegate> delegate;

@end

//----------------------------------------------------------

@interface NSDictionary (MyUserGuidePage)

- (MyUserGuideView *)userGuidePageView;

@end
