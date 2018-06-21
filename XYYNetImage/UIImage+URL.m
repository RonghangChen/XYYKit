//
//  UIImage+URL.m
//  
//
//  Created by LeslieChen on 15/8/12.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "UIImage+URL.h"
#import  <objc/runtime.h>

//----------------------------------------------------------

static char UIImageAssociateURLKey;

//----------------------------------------------------------

@implementation UIImage (URL)


- (BOOL)associateWithURL:(NSString *)url
{
    if (self.imageURL.length == 0 && url.length) {
        
        //设置关联
        objc_setAssociatedObject(self, &UIImageAssociateURLKey, url, OBJC_ASSOCIATION_COPY);
        
        return YES;
    }
    
    return NO;
}

- (NSString *)imageURL {
    return objc_getAssociatedObject(self, &UIImageAssociateURLKey);
}

@end
