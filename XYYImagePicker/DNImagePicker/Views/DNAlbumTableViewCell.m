//
//  DNAlbumTableViewCell.m
//  
//
//  Created by LeslieChen on 15/11/3.
//  Copyright © 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "DNAlbumTableViewCell.h"
#import "XYYFoundation.h"

//----------------------------------------------------------

NSString * const DNAlbumTableViewCellReuseIdentifier = @"DNAlbumTableViewCellReuseIdentifier";

//----------------------------------------------------------

@interface DNAlbumTableViewCell ()

@property (strong, nonatomic) IBOutlet UIImageView *thumbImageView;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@end

//----------------------------------------------------------

@implementation DNAlbumTableViewCell

- (void)setAssetsAlbum:(ALAssetsGroup *)assetsAlbum
{
    _assetsAlbum = assetsAlbum;
    
    self.titleLabel.attributedText  = [self _albumTitle:assetsAlbum];
    self.thumbImageView.image = nil;
    
    //设置为最新一张图为封面
    typeof(self) __weak  weak_self = self;
    [assetsAlbum enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:assetsAlbum.numberOfAssets - 1]
                                  options:NSEnumerationConcurrent
                               usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                   
                                   if (result) {
                                       *stop = YES;
                                       
                                       typeof(weak_self) _self = weak_self;
                                       if (_self.assetsAlbum == assetsAlbum) {
                                           if (result) {
                                               CGImageRef aspectRatioThumbnail = GreaterThanIOS9System ? result.aspectRatioThumbnail : result.thumbnail;
                                               if (aspectRatioThumbnail) {
                                                   _self.thumbImageView.image = [UIImage imageWithCGImage:aspectRatioThumbnail];
                                               }else {
                                                   _self.thumbImageView.image = [UIImage imageNamed:@"assets_placeholder_picture.png"];
                                               }
                                           }
                                       }
                                   }
                               }];
    
}

- (NSAttributedString *)_albumTitle:(ALAssetsGroup *)assetsGroup
{
    NSString *albumTitle = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    NSString *numberString = [NSString stringWithFormat:@"  (%@)",@(assetsGroup.numberOfAssets)];
    NSString *cellTitleString = [NSString stringWithFormat:@"%@%@",albumTitle,numberString];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:cellTitleString];
    [attributedString setAttributes: @{NSFontAttributeName : [UIFont systemFontOfSize:16.0f],
                                       NSForegroundColorAttributeName : [UIColor blackColor]}
                              range:NSMakeRange(0, albumTitle.length)];
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16.0f],
                                      NSForegroundColorAttributeName : [UIColor grayColor]}
                              range:NSMakeRange(albumTitle.length, numberString.length)];
    return attributedString;
    
}


@end
