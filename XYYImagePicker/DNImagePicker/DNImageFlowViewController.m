//
//  DNImageFlowViewController.m
//  ImagePicker
//
//  Created by DingXiao on 15/2/11.
//  Copyright (c) 2015年 Dennis. All rights reserved.
//

//----------------------------------------------------------

#import "DNImageFlowViewController.h"
#import "DNImagePickerController.h"
#import "DNPhotoBrowser.h"
#import "UIView+DNImagePicker.h"
//#import "UIColor+Hex.h"
#import "DNAssetsViewCell.h"
#import "DNSendButton.h"
#import "DNAsset.h"
#import "NSURL+DNIMagePickerUrlEqual.h"
#import "XYYFoundation.h"

//----------------------------------------------------------

static NSString* const dnAssetsViewCellReuseIdentifier = @"DNAssetsViewCell";

//----------------------------------------------------------

@interface DNImageFlowViewController () < DNAssetsViewCellDelegate,
                                          DNPhotoBrowserDelegate,
                                          UICollectionViewDelegate,
                                          UICollectionViewDataSource >

@property(nonatomic) NSUInteger maxSelectedImageCount;
@property(nonatomic) BOOL canSelecteFullImage;
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@property(nonatomic,strong) UICollectionView * collectionView;

//预览和发送按钮
@property(nonatomic,strong,readonly) UIBarButtonItem * previewBarButtonItem;
@property (nonatomic, strong,readonly) DNSendButton *sendButton;

@property (nonatomic, strong) NSMutableArray *assetsArray;
@property (nonatomic, strong,readonly) NSMutableArray *selectedAssetsArray;

//是否发送原图
@property (nonatomic, assign) BOOL isFullImage;

//缓存图片
@property(nonatomic,strong,readonly) NSMutableDictionary * aspectRatioThumbnailCaches;

@end

//----------------------------------------------------------

@implementation DNImageFlowViewController

@synthesize selectedAssetsArray = _selectedAssetsArray;
@synthesize sendButton = _sendButton;
@synthesize previewBarButtonItem = _previewBarButtonItem;
@synthesize aspectRatioThumbnailCaches = _aspectRatioThumbnailCaches;

- (DNImagePickerController *)dnImagePickerController
{
    if (self.navigationController == nil || ![self.navigationController isKindOfClass:[DNImagePickerController class]]) {
        NSAssert(false, @"check the navigation controller");
    }
    
    return (DNImagePickerController *)self.navigationController;
}

- (instancetype)initWithAssetsGroup:(ALAssetsGroup *)assetsGroup
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _assetsGroup = assetsGroup;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.maxSelectedImageCount = [[self dnImagePickerController] maxSelectedImageCount];
    self.canSelecteFullImage = [[self dnImagePickerController] canSelecteFullImage];
    
    //加载数据
    [self loadData];
    
    //加载数据
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.toolbarHidden = YES;
}


#pragma mark - setup view and data

- (void)loadData
{
    [self.assetsGroup setAssetsFilter:ALAssetsFilterFromDNImagePickerControllerFilterType([[self dnImagePickerController] filterType])];
    
    if (self.assetsArray.count) {
        
        //清除数据
        self.assetsArray = nil;
        [self.selectedAssetsArray removeAllObjects];
        [self.collectionView reloadData];
        
        //更新工具栏
        [self _updateToolBarView];
    }
    
    
    typeof(self) __weak weak_self = self;
    ALAssetsGroup *assetsGroup = self.assetsGroup;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
 
        //后台读取相册资源数据
        NSMutableArray * assetsArray = [NSMutableArray array];
        [assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                [assetsArray insertObject:result atIndex:0];
            }
        }];
        
        //主线程回调
        dispatch_async(dispatch_get_main_queue(), ^{
            
            typeof(weak_self) _self = weak_self;
            if (_self != nil) { //读取数据过程中没有被销毁
                
                if (assetsArray.count != 0) {
                    
                    //更新数据
                    _self.assetsArray = assetsArray;
                    [_self.collectionView reloadData];
                    
                    //移动到最下端
                    [_self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:assetsArray.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
                    
                    //渐现动画
                    [_self.collectionView.layer addAnimation:[CATransition animation] forKey:nil];
                    
                }else {
                    
                    //无数据直接返回，结束显示
                    [_self backButtonAction];
                }
            }
        });
    });
}

- (UIBarButtonItem *)previewBarButtonItem
{
    if (!_previewBarButtonItem) {
        _previewBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"preview", @"DNImagePicker", @"预览") style:UIBarButtonItemStylePlain target:self action:@selector(previewAction)];
        [_previewBarButtonItem setTintColor:[UIColor blackColor]];
    }
    
    return _previewBarButtonItem;
}

- (DNSendButton *)sendButton
{
    if (!_sendButton) {
        _sendButton = [[DNSendButton alloc] init];
        [_sendButton addTaget:self action:@selector(sendButtonAction:)];
    }
    return  _sendButton;
}

- (void)setupView
{
    //标题
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    //取消
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"cancel", @"DNImagePicker", @"取消") style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    
    //工具栏
    UIBarButtonItem *flexibleSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flexibleSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil  action:nil];
    flexibleSpace2.width = -10;
    [self setToolbarItems:@[self.previewBarButtonItem,flexibleSpace1,[[UIBarButtonItem alloc] initWithCustomView:self.sendButton],flexibleSpace2] animated:NO];
    
    //更新工具栏
    [self _updateToolBarView];
    
    //集合视图
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 2.f;
    layout.minimumInteritemSpacing = 2.f;
    CGFloat itemWidth = floorf(([UIScreen mainScreen].bounds.size.width - 10.f) / 4.f);
    layout.itemSize = CGSizeMake(itemWidth,itemWidth);
    layout.sectionInset =  UIEdgeInsetsMake(2.f, 2.f, 2.f, 2.f);
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView registerClass:[DNAssetsViewCell class] forCellWithReuseIdentifier:dnAssetsViewCellReuseIdentifier];
    [self.view addSubview:self.collectionView];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)_updateToolBarView
{
    self.previewBarButtonItem.enabled = self.selectedAssetsArray.count > 0;
    self.sendButton.enabled = self.selectedAssetsArray.count > 0;
    self.sendButton.badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)self.selectedAssetsArray.count];
}

#pragma mark - 

- (NSMutableArray *)selectedAssetsArray
{
    if (!_selectedAssetsArray) {
        _selectedAssetsArray = [NSMutableArray array];
    }
    
    return _selectedAssetsArray;
}

- (BOOL)_selecteAsset:(ALAsset *)asset
{
    assert(asset != nil);
    NSUInteger index = [self.assetsArray indexOfObjectIdenticalTo:asset];
    assert(index != NSNotFound);
    
    //加入选中的资源数据
    if ([self.selectedAssetsArray indexOfObjectIdenticalTo:asset] == NSNotFound) {
        
        //超过最大选择
        if (self.selectedAssetsArray.count >= self.maxSelectedImageCount) {
            
            [[XYYMessageUtil shareMessageUtil] showAlertViewWithTitle:nil content:[NSString stringWithFormat:NSLocalizedStringFromTable(@"alertContent", @"DNImagePicker", nil), (long)self.maxSelectedImageCount] okText:nil cancleText:NSLocalizedStringFromTable(@"alertButton", @"DNImagePicker", nil) actionBlock:nil];
            
            return NO;
        }
        
        [self.selectedAssetsArray addObject:asset];
        
        //更新工具栏
        [self _updateToolBarView];
    }
    
    //选中
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]
                                      animated:NO
                                scrollPosition:UICollectionViewScrollPositionNone];
    
    return YES;
}

- (void)_deselecteAsset:(ALAsset *)asset
{
    assert(asset != nil);
    NSUInteger index = [self.assetsArray indexOfObjectIdenticalTo:asset];
    assert(index != NSNotFound);
    
    //移除选中的数据
    NSUInteger _index = [self.selectedAssetsArray indexOfObjectIdenticalTo:asset];
    if (_index != NSNotFound) {
        [self.selectedAssetsArray removeObjectAtIndex:_index];
        
        //更新工具栏
        [self _updateToolBarView];
    }
    
    //取消选中
    [self.collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] animated:NO];
}

- (BOOL)_assetIsSelected:(ALAsset *)asset {
    return [self.selectedAssetsArray indexOfObjectIdenticalTo:asset] != NSNotFound;
}

- (NSArray *)seletedDNAssetArray
{
    NSMutableArray *seletedArray = [NSMutableArray new];
    for (ALAsset *asset in self.selectedAssetsArray) {
        [seletedArray addObject:[[DNAsset alloc] initWithAsset:asset]];
    }
    return seletedArray;
}

#pragma mark - UICollectionView delegate and Datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DNAssetsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:dnAssetsViewCellReuseIdentifier
                                                                       forIndexPath:indexPath];
    cell.delegate = self;
    
    ALAsset * asset = self.assetsArray[indexPath.row];
    NSString * assetURL = [[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString];
    
    UIImage * image = self.aspectRatioThumbnailCaches[assetURL];
    if (image == nil) {
        
        //异步读取数据 (首先主线程异步，防止主线程读取小缩略图与后台线程读取大缩略图之间发生等待现象)
        typeof(self) __weak weak_self = self;
        dispatch_async(dispatch_get_main_queue(), ^{

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
                UIImage * aspectRatioThumbnail = [asset suitableThumbnail];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (aspectRatioThumbnail != nil) {
                        
                        typeof(weak_self) _self = weak_self;
                        if (_self != nil) {
                            _self.aspectRatioThumbnailCaches[assetURL] = aspectRatioThumbnail;
                            if (cell.asset == asset) {
                                cell.image = aspectRatioThumbnail;
                            }
                        }
                    }
                });
            });
        });
        
        image = [UIImage imageWithCGImage:[asset thumbnail]];
    }
    
    cell.asset = asset;
    cell.image = image;
    
    return cell;
}

- (NSMutableDictionary *)aspectRatioThumbnailCaches
{
    if (!_aspectRatioThumbnailCaches) {
        _aspectRatioThumbnailCaches = [NSMutableDictionary dictionary];
    }
    
    return _aspectRatioThumbnailCaches;
}

- (void)didReceiveMemoryWarning {
    [_aspectRatioThumbnailCaches removeAllObjects];
}

//自定义改变选中，屏蔽collectionView的选中，响应成浏览图片
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self _browserPhotoAsstes:self.assetsArray pageIndex:indexPath.row];
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self _browserPhotoAsstes:self.assetsArray pageIndex:indexPath.row];
    return NO;
}

- (BOOL)didSelectItemAssetsViewCell:(DNAssetsViewCell *)assetsCell {
    return [self _selecteAsset:assetsCell.asset];
}

- (void)didDeselectItemAssetsViewCell:(DNAssetsViewCell *)assetsCell {
    [self _deselecteAsset:assetsCell.asset];
}

#pragma mark - ui action

- (void)backButtonAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendButtonAction:(id)sender {
    [self _sendImages];
}

- (void)previewAction {
    [self _browserPhotoAsstes:self.selectedAssetsArray pageIndex:0];
}

- (void)cancelAction
{
    DNImagePickerController *navController = [self dnImagePickerController];
    if ([navController.imagePickerDelegate respondsToSelector:@selector(dnImagePickerControllerDidCancel:)]){
        [navController.imagePickerDelegate dnImagePickerControllerDidCancel:navController];
    }else {
        [navController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - priviate methods

- (void)_sendImages
{
    //保存浏览的相册ID
    NSString *properyID = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyPersistentID];
    [[NSUserDefaults standardUserDefaults] setObject:properyID forKey:kDNImagePickerStoredGroupKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    DNImagePickerController *imagePicker = [self dnImagePickerController];
    if ([imagePicker.imagePickerDelegate respondsToSelector:@selector(dnImagePickerController:sendImages:isFullImage:)]) {
        [imagePicker.imagePickerDelegate dnImagePickerController:imagePicker
                                                      sendImages:[self seletedDNAssetArray]
                                                     isFullImage:self.isFullImage];
    }else {
        [imagePicker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (DNPhotoBrowser *)_photoBrowserViewController
{
    id viewController = self.navigationController.topViewController;
    if ([viewController isKindOfClass:[DNPhotoBrowser class]]) {
        return viewController;
    }
    
    return nil;
}

- (void)_browserPhotoAsstes:(NSArray *)assets pageIndex:(NSInteger)page
{
    if ([self _photoBrowserViewController] == nil) {
        
        DNPhotoBrowser *browser = [[DNPhotoBrowser alloc] initWithPhotos:assets
                                                            currentIndex:page
                                                               fullImage:self.isFullImage
                                                     canSelecteFullImage:self.canSelecteFullImage];
        browser.delegate = self;
        browser.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:browser animated:YES];
    }
}

#pragma mark - DNPhotoBrowserDelegate
- (void)sendImagesFromPhotobrowser:(DNPhotoBrowser *)photoBrowser currentAsset:(ALAsset *)asset
{
    if (self.selectedAssetsArray.count > 0) {
        [self _sendImages];
    }
}

- (NSUInteger)seletedPhotosNumberInPhotoBrowser:(DNPhotoBrowser *)photoBrowser {
    return self.selectedAssetsArray.count;
}

- (BOOL)photoBrowser:(DNPhotoBrowser *)photoBrowser currentPhotoAssetIsSeleted:(ALAsset *)asset {
    return [self _assetIsSelected:asset];
}

- (BOOL)photoBrowser:(DNPhotoBrowser *)photoBrowser seletedAsset:(ALAsset *)asset {
    return [self _selecteAsset:asset];
}

- (void)photoBrowser:(DNPhotoBrowser *)photoBrowser deseletedAsset:(ALAsset *)asset {
    [self _deselecteAsset:asset];
}

- (void)photoBrowser:(DNPhotoBrowser *)photoBrowser seleteFullImage:(BOOL)fullImage {
    self.isFullImage = fullImage;
}

@end
