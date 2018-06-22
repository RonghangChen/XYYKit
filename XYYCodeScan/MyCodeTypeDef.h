//
//  MyCodeTypeDef.h
//  
//
//  Created by LeslieChen on 15/3/17.
//  Copyright (c) 2015年 ED. All rights reserved.
//

#ifndef __MyCodeTypeDef_h
#define __MyCodeTypeDef_h

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, MyCodeType) {
    MyCodeTypeQR    //二维码
};

static inline AVMetadataObjectType metadataObjectTypeForCodeType(MyCodeType codeType) {
    
    switch (codeType) {
        case MyCodeTypeQR:
            return AVMetadataObjectTypeQRCode;
            break;
    }
}


#endif
