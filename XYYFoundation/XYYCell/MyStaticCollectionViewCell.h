//
//  MyStaticCollectionViewCell.h

//
//  Created by LeslieChen on 15/2/27.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#import "MySelectionView.h"

@interface MyStaticCollectionViewCell : MySelectionView

+ (instancetype)createInstanceWithReuseIdentifier:(NSString *)reuseIdentifier;

//design init
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;


//初始化复用定义，只能设置一次，多次设置会被忽略
- (void)setupReuseIdentifier:(NSString *)reuseIdentifier;
//复用定义
@property(nonatomic,strong,readonly) NSString * reuseIdentifier;

//加入复用池前调用，默认没有做任何事
- (void)didAddToReusePool;
//复用前调用，默认没有做任何事
- (void)prepareForReuse;


- (void)updateCellWithInfo:(NSDictionary *)info context:(id)context;

//设置需要更新cell
- (void)setNeedUpdateCell;
//更新cell，如果需要的话
- (void)updateCellIfNeeded;
//更新cell,子类重载进行必要的操作
- (void)updateCell;

//布局block
@property(nonatomic,copy) void(^layoutSubViewsBlock)(MyStaticCollectionViewCell * cell);


- (BOOL)touchPointInside:(CGPoint)point;

@end


@interface MyStaticCollectionViewCell (reuseIdentifier)

+ (NSString *)defaultReuseIdentifier;

@end
