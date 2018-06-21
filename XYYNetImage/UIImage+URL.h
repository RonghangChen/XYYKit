//
//  UIImage+URL.h
//  
//
//  Created by LeslieChen on 15/8/12.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

@interface UIImage (URL)

/**
 * 将图片与URL关联，仅能关联一次，多次关联将无效
 * @param url url为关联的url
 * @return 关联成功返回YES，没有关联且将要关联的url不为空即关联成功
 */
- (BOOL)associateWithURL:(NSString *)url;

//图片的URL
@property(nonatomic,strong,readonly) NSString * imageURL;


@end
