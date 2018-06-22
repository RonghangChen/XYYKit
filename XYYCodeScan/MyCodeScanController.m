//
//  MyCodeScanController.m
//  
//
//  Created by LeslieChen on 15/3/17.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyCodeScanController.h"
//#import "QRCodeGenerator.h"
#import <CoreImage/CoreImage.h>

//----------------------------------------------------------

@implementation MyCodeScanController

//+ (UIImage *)codeImageWithData:(NSString *)data
//                          size:(CGSize)imageSize
//                          type:(MyCodeType)codeType
//{
//    return [self codeImageWithData:data size:imageSize margin:1.f type:codeType];
//}
//
//+ (UIImage *)codeImageWithData:(NSString *)data
//                          size:(CGSize)imageSize
//                        margin:(CGFloat)margin
//                          type:(MyCodeType)codeType
//{
//    if (data == nil) {
//        return nil;
//    }
//    
//    switch (codeType) {
//        case MyCodeTypeQR:
//        {
//            QRCodeGenerator * qrCodeGenerator = [[QRCodeGenerator alloc] initWithText:data];
//            qrCodeGenerator.qrErrCorrLv = kTCQR_ECLEVEL_H;
//            qrCodeGenerator.qrMargin = margin;
//            return [qrCodeGenerator qrImageForSize:MAX(imageSize.height, imageSize.width)];
//        }
//            break;
//    }
//}

+ (NSArray<NSString *> *)dataWithCodeImage:(UIImage *)codeImage forType:(MyCodeType)codeType
{
    if (codeImage == nil) {
        return nil;
    }
    
    CIDetector * detector = nil;
    switch (codeType) {
        case MyCodeTypeQR:
            detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
            break;
            
    }
    
    if (detector == nil) {
        return nil;
    }
    
    NSArray * features = [detector featuresInImage:[CIImage imageWithCGImage:codeImage.CGImage]];
    NSMutableArray * result =  [NSMutableArray arrayWithCapacity:features.count];
    for (CIQRCodeFeature * feature  in features) {
        [result addObject:feature.messageString];
    }
    
    return result;
}


@end
