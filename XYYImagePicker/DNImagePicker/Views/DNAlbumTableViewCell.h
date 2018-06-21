//
//  DNAlbumTableViewCell.h
//  
//
//  Created by LeslieChen on 15/11/3.
//  Copyright © 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

//----------------------------------------------------------

UIKIT_EXTERN NSString * const DNAlbumTableViewCellReuseIdentifier;

//----------------------------------------------------------

@interface DNAlbumTableViewCell : UITableViewCell

@property(nonatomic,strong) ALAssetsGroup * assetsAlbum;

@end
