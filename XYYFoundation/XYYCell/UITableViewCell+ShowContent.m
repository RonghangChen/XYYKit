//
//  UITableViewCell+ShowContent.m
//  
//
//  Created by LeslieChen on 15/10/24.
//  Copyright © 2015年 ED. All rights reserved.
//

#import "UITableViewCell+ShowContent.h"
#import "NSDictionary+MyCategory.h"


@implementation UITableViewCell (ShowContent)

+ (CGFloat)heightForCellWithInfo:(NSDictionary *)info
                       tableView:(UITableView *)tableView
                         context:(id)context
{
    id heightValue = [info heightValue];
    CGFloat height = [heightValue floatValue];
    
    if (!heightValue) {
        id sizeValue = [info sizeValue];
        height = sizeValue ? CGSizeFromString(sizeValue).height : tableView.rowHeight;
    }
    
    return height <= 0.f ? tableView.rowHeight : height;// MAX(0.f, height);
}

- (void)updateCellWithInfo:(NSDictionary *)info context:(id)context
{
    self.textLabel.text = [info myTitle];
    self.detailTextLabel.text = [info myDetailTitle];
    
    if (self.imageView) {
        self.imageView.image = [info myImage];
        self.imageView.highlightedImage = [info myHighlightedImage];
    }
}


@end
