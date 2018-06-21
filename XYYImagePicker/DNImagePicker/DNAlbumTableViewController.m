//
//  DNAlbumTableViewController.m
//  ImagePicker
//
//  Created by DingXiao on 15/2/10.
//  Copyright (c) 2015年 Dennis. All rights reserved.
//

//----------------------------------------------------------

#import "DNImagePickerController.h"
#import "DNAlbumTableViewController.h"
#import "DNImagePickerController.h"
#import "DNImageFlowViewController.h"
#import "DNUnAuthorizedTipsView.h"
#import "DNAlbumTableViewCell.h"

//----------------------------------------------------------

@interface DNAlbumTableViewController ()

@property (nonatomic, strong) NSArray *groupTypes;

#pragma mark - dataSources
@property (nonatomic, strong) NSArray *assetsGroups;

@end

//----------------------------------------------------------

@implementation DNAlbumTableViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self setupData];
    [self loadData];
}

#pragma mark - mark setup Data and View
- (void)loadData
{
    __weak typeof(self) weakSelf = self;
    [self loadAssetsGroupsWithTypes:self.groupTypes completion:^(NSArray *groupAssets) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.assetsGroups = groupAssets;
            [strongSelf.tableView reloadData];
        }
    }];
}

- (void)setupData {
    self.groupTypes = @[@(ALAssetsGroupAll)];
}

- (void)setupView
{
    self.title = NSLocalizedStringFromTable(@"albumTitle", @"DNImagePicker", @"photos");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"cancel", @"DNImagePicker", @"取消") style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.rowHeight = 64.f;
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = view;
    [self.tableView registerNib:[UINib nibWithNibName:@"DNAlbumTableViewCell" bundle:nil] forCellReuseIdentifier:DNAlbumTableViewCellReuseIdentifier];
}


#pragma mark - ui actions
- (void)cancelAction:(id)sender
{
    DNImagePickerController *navController = [self dnImagePickerController];
    if (navController && [navController.imagePickerDelegate respondsToSelector:@selector(dnImagePickerControllerDidCancel:)]) {
        [navController.imagePickerDelegate dnImagePickerControllerDidCancel:navController];
    }else {
        [navController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - getter/setter

- (DNImagePickerController *)dnImagePickerController
{
    if (nil == self.navigationController
        ||
        ![self.navigationController isKindOfClass:[DNImagePickerController class]])
    {
        NSAssert(false, @"check the navigation controller");
    }
    return (DNImagePickerController *)self.navigationController;
}

- (void)showUnAuthorizedTipsView
{
    DNUnAuthorizedTipsView *view  = [[DNUnAuthorizedTipsView alloc] initWithFrame:self.tableView.frame];
    self.tableView.backgroundView = view;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.assetsGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DNAlbumTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:DNAlbumTableViewCellReuseIdentifier
                                                                  forIndexPath:indexPath];
    cell.assetsAlbum = self.assetsGroups[indexPath.row];
    return cell;
}


#pragma mark - tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DNImageFlowViewController *imageFlowViewController = [[DNImageFlowViewController alloc] initWithAssetsGroup:self.assetsGroups[indexPath.row]];
    [self.navigationController pushViewController:imageFlowViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - get assetGroups
- (void)loadAssetsGroupsWithTypes:(NSArray *)types completion:(void (^)(NSArray *assetsGroups))completion
{
    NSMutableArray *assetsGroups = [NSMutableArray array];
    ALAssetsFilter *assetsFilter = ALAssetsFilterFromDNImagePickerControllerFilterType([[self dnImagePickerController] filterType]);
    __block NSUInteger numberOfFinishedTypes = 0;
    
    for (NSNumber *type in types) {
        __weak typeof(self) weakSelf = self;
        [shareAssetsLibrary() enumerateGroupsWithTypes:[type unsignedIntegerValue]
                                            usingBlock:^(ALAssetsGroup *assetsGroup, BOOL *stop)
         {
             __strong typeof(weakSelf) strongSelf = weakSelf;
             if (strongSelf == nil) {
                 if (assetsGroup) {
                     *stop = YES;
                 }
                 return;
             }
             
             if (assetsGroup) {
                 // Filter the assets group
                 [assetsGroup setAssetsFilter:assetsFilter];
                 // Add assets group
                 if (assetsGroup.numberOfAssets > 0) {
                     // Add assets group
                     [assetsGroups addObject:assetsGroup];
                 }
             } else {
                 numberOfFinishedTypes++;
             }
             
             // Check if the loading finished
             if (numberOfFinishedTypes == types.count) {
                 //sort
                 NSArray *sortedAssetsGroups = [assetsGroups sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                     
                     ALAssetsGroup *a = obj1;
                     ALAssetsGroup *b = obj2;
                     
                     NSNumber *apropertyType = [a valueForProperty:ALAssetsGroupPropertyType];
                     NSNumber *bpropertyType = [b valueForProperty:ALAssetsGroupPropertyType];
                     if ([apropertyType compare:bpropertyType] == NSOrderedAscending)
                     {
                         return NSOrderedDescending;
                     }
                     return NSOrderedSame;
                 }];

                 // Call completion block
                 if (completion) {
                     if ([NSThread isMainThread]) {
                         completion(sortedAssetsGroups);
                     }else {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             completion(sortedAssetsGroups);
                         });
                     }
                 }
             }
         } failureBlock:^(NSError *error) {
             
             __strong typeof(weakSelf) strongSelf = weakSelf;
             if (strongSelf == nil) {
                 return;
             }
             
             if ([ALAssetsLibrary authorizationStatus] != ALAuthorizationStatusAuthorized){
                 if ([NSThread isMainThread]) {
                    [strongSelf showUnAuthorizedTipsView];
                 }else {
                    [strongSelf performSelectorOnMainThread:@selector(showUnAuthorizedTipsView) withObject:nil waitUntilDone:NO];
                 }
             }
         }];
    }
}
@end
