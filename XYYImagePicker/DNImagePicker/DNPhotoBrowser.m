//
//  DNPhotoBrowserViewController.m
//  ImagePicker
//
//  Created by DingXiao on 15/2/28.
//  Copyright (c) 2015年 Dennis. All rights reserved.
//

//----------------------------------------------------------

#import "DNPhotoBrowser.h"
#import "DNImagePickerController.h"
#import "UIView+DNImagePicker.h"
#import "DNSendButton.h"
#import "DNFullImageButton.h"
#import "DNBrowserCell.h"
#import "XYYFoundation.h"

//----------------------------------------------------------

@interface DNPhotoBrowser () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    BOOL _statusBarShouldBeHidden;
    BOOL _didSavePreviousStateOfNavBar;
    BOOL _viewIsActive;
    BOOL _viewHasAppearedInitially;
    // Appearance
    BOOL _previousNavBarHidden;
    BOOL _previousNavBarTranslucent;
    UIBarStyle _previousNavBarStyle;
//    UIStatusBarStyle _previousStatusBarStyle;
    UIColor *_previousNavBarTintColor;
    UIColor *_previousNavBarBarTintColor;
    UIBarButtonItem *_previousViewControllerBackButton;
    UIImage *_previousNavigationBarBackgroundImageDefault;
    UIImage *_previousNavigationBarBackgroundImageLandscapePhone;
}

@property (nonatomic, strong) UICollectionView *browserCollectionView;
@property (nonatomic, strong) UIView *toolbar;
@property (nonatomic, strong) UIToolbar *toolbarContentView;
@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) DNSendButton *sendButton;
@property (nonatomic, strong) DNFullImageButton *fullImageButton;

@property (nonatomic, strong) NSMutableArray *photoDataSources;
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, getter=isFullImage) BOOL fullImage;
@property(nonatomic) BOOL canSelecteFullImage;

//浏览图片的缓冲池，防止每次都加载图片
@property(nonatomic,strong,readonly) NSMutableDictionary * browserImageCaches;

@end

//----------------------------------------------------------

@implementation DNPhotoBrowser

@synthesize browserImageCaches = _browserImageCaches;

- (instancetype)initWithPhotos:(NSArray *)photosArray
                  currentIndex:(NSInteger)index
                     fullImage:(BOOL)isFullImage
           canSelecteFullImage:(BOOL)canSelecteFullImage
{
    self = [super init];
    
    if (self) {
        _photoDataSources = [[NSMutableArray alloc] initWithArray:photosArray];
        _currentIndex = index;
        _fullImage = isFullImage;
        _canSelecteFullImage = canSelecteFullImage;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupView];
    [self updateSelestedNumber];
    [self updateNavigationBarAndToolBar];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
    // Super
    [super viewWillAppear:animated];
//    _previousStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    
    // Navigation bar appearance
    if (!_viewIsActive && [self.navigationController.viewControllers objectAtIndex:0] != self) {
        [self storePreviousNavBarAppearance];
    }
    [self setNavBarAppearance:animated];
    
    // Initial appearance
    if (!_viewHasAppearedInitially) {
        _viewHasAppearedInitially = YES;
    }
    
    //scroll to the current offset
    [self.browserCollectionView setContentOffset:CGPointMake(self.browserCollectionView.frame.size.width * self.currentIndex,0)];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Check that we're being popped for good
    if ([self.navigationController.viewControllers objectAtIndex:0] != self &&
        ![self.navigationController.viewControllers containsObject:self]) {
        
        _viewIsActive = NO;
        [self restorePreviousNavBarAppearance:animated];
    }

    [self.navigationController.navigationBar.layer removeAllAnimations];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self setControlsHidden:NO animated:NO];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
    
    // Super
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewIsActive = YES;
}

#pragma mark - priviate
- (void)setupView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.clipsToBounds = YES;
    [self browserCollectionView];
    [self toolbar];
    [self setupBarButtonItems];
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.checkButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)setupData {
    self.photoDataSources = [NSMutableArray new];
}

- (void)setupBarButtonItems
{
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:self.fullImageButton];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithCustomView:self.sendButton];
    UIBarButtonItem *item4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    item4.width = -10;

    [self.toolbarContentView setItems:@[item1,item2,item3,item4]];
}

- (void)updateNavigationBarAndToolBar
{
    NSUInteger totalNumber = self.photoDataSources.count;
    self.title = [NSString stringWithFormat:@"%@/%@",@(self.currentIndex+1),@(totalNumber)];
    BOOL isSeleted = NO;
    if ([self.delegate respondsToSelector:@selector(photoBrowser:currentPhotoAssetIsSeleted:)]) {
        isSeleted = [self.delegate photoBrowser:self currentPhotoAssetIsSeleted:[self.photoDataSources objectAtIndex:self.currentIndex]];
    }
    self.checkButton.selected = isSeleted;
    
    if (self.canSelecteFullImage) {
    
        self.fullImageButton.selected = self.isFullImage;
        
        if (self.isFullImage) {
            ALAsset *asset = self.photoDataSources[self.currentIndex];
            NSInteger size = (NSUInteger)(asset.defaultRepresentation.size/1024);
            CGFloat imageSize = (CGFloat)size;
            NSString *imageSizeString;
            if (size > 1024) {
                imageSize = imageSize/1024.0f;
                imageSizeString = [NSString stringWithFormat:@"(%.1fM)",imageSize];
            } else {
                imageSizeString = [NSString stringWithFormat:@"(%@K)",@(size)];
            }
            self.fullImageButton.text = imageSizeString;
        }
    }
}

- (void)updateSelestedNumber
{
    NSUInteger selectedNumber = 0;
    if ([self.delegate respondsToSelector:@selector(seletedPhotosNumberInPhotoBrowser:)]) {
        selectedNumber = [self.delegate seletedPhotosNumberInPhotoBrowser:self];
    }
    
    self.sendButton.enabled = selectedNumber != 0;
    self.sendButton.badgeValue = [NSString stringWithFormat:@"%@",@(selectedNumber)];
}

#pragma mark - Nav Bar Appearance

- (void)setNavBarAppearance:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.tintColor = [UIColor whiteColor];
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = nil;
        navBar.shadowImage = nil;
    }
    navBar.translucent = YES;
    navBar.barStyle = UIBarStyleBlackTranslucent;
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsCompact];
    }
}

- (void)storePreviousNavBarAppearance
{
    _didSavePreviousStateOfNavBar = YES;
    if ([UINavigationBar instancesRespondToSelector:@selector(barTintColor)]) {
        _previousNavBarBarTintColor = self.navigationController.navigationBar.barTintColor;
    }
    _previousNavBarTranslucent = self.navigationController.navigationBar.translucent;
    _previousNavBarTintColor = self.navigationController.navigationBar.tintColor;
    _previousNavBarHidden = self.navigationController.navigationBarHidden;
    _previousNavBarStyle = self.navigationController.navigationBar.barStyle;
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        _previousNavigationBarBackgroundImageDefault = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
        _previousNavigationBarBackgroundImageLandscapePhone = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsCompact];
    }
}

- (void)restorePreviousNavBarAppearance:(BOOL)animated
{
    if (_didSavePreviousStateOfNavBar) {
        [self.navigationController setNavigationBarHidden:_previousNavBarHidden animated:animated];
        UINavigationBar *navBar = self.navigationController.navigationBar;
        navBar.tintColor = _previousNavBarTintColor;
        navBar.translucent = _previousNavBarTranslucent;
        if ([UINavigationBar instancesRespondToSelector:@selector(barTintColor)]) {
            navBar.barTintColor = _previousNavBarBarTintColor;
        }
        navBar.barStyle = _previousNavBarStyle;
        if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
            [navBar setBackgroundImage:_previousNavigationBarBackgroundImageDefault forBarMetrics:UIBarMetricsDefault];
            [navBar setBackgroundImage:_previousNavigationBarBackgroundImageLandscapePhone forBarMetrics:UIBarMetricsCompact];
        }
        // Restore back button if we need to
        if (_previousViewControllerBackButton) {
            UIViewController *previousViewController = [self.navigationController topViewController]; // We've disappeared so previous is now top
            previousViewController.navigationItem.backBarButtonItem = _previousViewControllerBackButton;
            _previousViewControllerBackButton = nil;
        }
    }
}

#pragma mark - ui actions
- (void)checkButtonAction
{
    if (self.checkButton.selected) {
        if ([self.delegate respondsToSelector:@selector(photoBrowser:deseletedAsset:)]) {
            [self.delegate photoBrowser:self deseletedAsset:self.photoDataSources[self.currentIndex]];
            self.checkButton.selected = NO;
        }
    } else if ([self.delegate respondsToSelector:@selector(photoBrowser:seletedAsset:)]) {
        self.checkButton.selected = [self.delegate photoBrowser:self seletedAsset:self.photoDataSources[self.currentIndex]];
    }
    
    [self updateSelestedNumber];
}

- (void)backButtonAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendButtonAction
{
    if ([self.delegate respondsToSelector:@selector(sendImagesFromPhotobrowser:currentAsset:)]) {
        [self.delegate sendImagesFromPhotobrowser:self currentAsset:self.photoDataSources[self.currentIndex]];
    }
}

- (void)fullImageButtonAction
{
    self.fullImageButton.selected = !self.fullImageButton.selected;
    self.fullImage = self.fullImageButton.selected;
    if ([self.delegate respondsToSelector:@selector(photoBrowser:seleteFullImage:)]) {
        [self.delegate photoBrowser:self seleteFullImage:self.isFullImage];
    }
    
    if (self.fullImageButton.selected) {
        [self updateNavigationBarAndToolBar];
    }
}

#pragma mark - get/set
- (UIButton *)checkButton
{
    if (nil == _checkButton) {
        _checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkButton.frame = CGRectMake(0, 0, 25, 25);
        [_checkButton setBackgroundImage:[UIImage imageNamed:@"photo_check_selected.png"] forState:UIControlStateSelected];
        [_checkButton setBackgroundImage:[UIImage imageNamed:@"photo_check_default.png"] forState:UIControlStateNormal];
        [_checkButton addTarget:self action:@selector(checkButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkButton;
}

- (DNFullImageButton *)fullImageButton
{
    if (nil == _fullImageButton) {
        _fullImageButton = [[DNFullImageButton alloc] initWithFrame:CGRectZero];
        [_fullImageButton addTarget:self action:@selector(fullImageButtonAction)];
        _fullImageButton.selected = self.isFullImage;
        _fullImageButton.hidden = !self.canSelecteFullImage;
    }
    return _fullImageButton;
}

- (DNSendButton *)sendButton
{
    if (nil == _sendButton) {
        _sendButton = [[DNSendButton alloc] initWithFrame:CGRectZero];
        [_sendButton addTaget:self action:@selector(sendButtonAction)];
    }
    return  _sendButton;
}

- (UIView *)toolbar
{
    if (nil == _toolbar) {
        CGFloat height = 44;
        _toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height)];
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:_toolbar];
        
        UIToolbar * bgView = [[UIToolbar alloc] initWithFrame:_toolbar.bounds];
        if ([[UIToolbar class] respondsToSelector:@selector(appearance)]) {
            [bgView setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
            [bgView setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsCompact];
        }
        bgView.barStyle = UIBarStyleBlackTranslucent;
        bgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_toolbar addSubview:bgView];
        
    }
    return _toolbar;
}

- (UIToolbar *)toolbarContentView
{
    if (nil == _toolbarContentView) {
        _toolbarContentView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.toolbar.width, 44.f)];
        if ([[UIToolbar class] respondsToSelector:@selector(appearance)]) {
            [_toolbarContentView setBackgroundImage:[UIImage resizableImageWithColor:[UIColor clearColor]] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
            [_toolbarContentView setBackgroundImage:[UIImage resizableImageWithColor:[UIColor clearColor]] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsCompact];
        }
        _toolbarContentView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        [self.toolbar addSubview:_toolbarContentView];
    }
    
    return _toolbarContentView;
}

- (void)viewSafeAreaInsetsDidChange
{
    if (@available(iOS 11.0, *)) {
        [super viewSafeAreaInsetsDidChange];
        
        if (![self areControlsHidden]) {
            CGFloat height = 44.f + self.view.safeAreaInsets.bottom;
            self.toolbar.frame = CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height);
        }
    }
}

- (UICollectionView *)browserCollectionView
{
    if (nil == _browserCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _browserCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, self.view.bounds.size.width+20, self.view.bounds.size.height+1) collectionViewLayout:layout];
        _browserCollectionView.backgroundColor = [UIColor blackColor];
        [_browserCollectionView registerClass:[DNBrowserCell class] forCellWithReuseIdentifier:NSStringFromClass([DNBrowserCell class])];
        _browserCollectionView.delegate = self;
        _browserCollectionView.dataSource = self;
        _browserCollectionView.pagingEnabled = YES;
        _browserCollectionView.showsHorizontalScrollIndicator = NO;
        _browserCollectionView.showsVerticalScrollIndicator = NO;
        
        //适配iOS11
        configurationContentScrollViewForAdaptation(_browserCollectionView);
        
        [self.view addSubview:_browserCollectionView];
    }
    return _browserCollectionView;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.photoDataSources count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DNBrowserCell *cell = (DNBrowserCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DNBrowserCell class]) forIndexPath:indexPath];
    cell.photoBrowser = self;
    
    ALAsset * asset = [self.photoDataSources objectAtIndex:indexPath.row];
    NSString * assetURL = [[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString];

    cell.asset = asset;
    
    //读取缓存图片数据
    UIImage * image = self.browserImageCaches[assetURL];
    if (image == nil) {
        
        //首先主线程异步（防止主线程等待）
        typeof(self) __weak weak_self = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
                UIImage * fullScreenImage = [asset suitableFullScreenImage];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (fullScreenImage != nil) {
                        
                        typeof(weak_self) _self = weak_self;
                        if (_self != nil) {
                            _self.browserImageCaches[assetURL] = fullScreenImage;
                            if (cell.asset == asset) { //cell没有改变asset
                                cell.image = fullScreenImage;
                            }
                        }
                    }
                });
            });
        });
        
        [cell setImage:[UIImage imageWithCGImage:[asset aspectRatioThumbnail]] sourceImageSize:[asset defaultRepresentation].dimensions];
        
    }else {
       cell.image = image;
    }
    
    return cell;
}


- (NSMutableDictionary *)browserImageCaches
{
    if (!_browserImageCaches) {
        _browserImageCaches = [NSMutableDictionary dictionary];
    }
    
    return _browserImageCaches;
}

- (void)didReceiveMemoryWarning {
    [_browserImageCaches removeAllObjects];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.bounds.size.width+20, self.view.bounds.size.height);
}

#pragma mark - scrollerViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.canSelecteFullImage) {
        return;
    }
    
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat itemWidth = CGRectGetWidth(self.browserCollectionView.frame);
    CGFloat currentPageOffset = itemWidth * self.currentIndex;
    CGFloat deltaOffset = offsetX - currentPageOffset;
    if (fabs(deltaOffset) >= itemWidth/2 ) {
        [self.fullImageButton shouldAnimating:YES];
    } else {
        [self.fullImageButton shouldAnimating:NO];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat itemWidth = CGRectGetWidth(self.browserCollectionView.frame);
    if (offsetX >= 0){
        NSInteger page = offsetX / itemWidth;
        [self didScrollToPage:page];
    }
    
    if (!self.canSelecteFullImage) {
        return;
    }

    [self.fullImageButton shouldAnimating:NO];
}

- (void)didScrollToPage:(NSInteger)page
{
    self.currentIndex = page;
    [self updateNavigationBarAndToolBar];
}

#pragma mark - Control Hiding / Showing
// Fades all controls slide and fade
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated{
    
    // Force visible
    if (nil == self.photoDataSources || self.photoDataSources.count == 0)
        hidden = NO;
    // Animations & positions
    CGFloat animatonOffset = 20;
    CGFloat animationDuration = (animated ? 0.35 : 0);
    
    
    _statusBarShouldBeHidden = hidden;
    
    // Status bar
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // Hide status bar
        [UIView animateWithDuration:animationDuration animations:^(void) {
            [self setNeedsStatusBarAppearanceUpdate];
        } completion:nil];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:_statusBarShouldBeHidden withAnimation:UIStatusBarAnimationSlide];
    
    CGFloat height = 44.f;
    if (@available(iOS 11.0, *)) {
        height += self.view.safeAreaInsets.bottom;
    }
    CGRect frame = CGRectIntegral(CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height));
    
    // Pre-appear animation positions for iOS 7 sliding
    if ([self areControlsHidden] && !hidden && animated) {
        // Toolbar
        self.toolbar.frame = CGRectOffset(frame, 0, animatonOffset);
    }
    
    [UIView animateWithDuration:animationDuration animations:^(void) {
        CGFloat alpha = hidden ? 0 : 1;
        // Nav bar slides up on it's own on iOS 7
        [self.navigationController.navigationBar setAlpha:alpha];
        // Toolbar
        _toolbar.frame = frame;
        if (hidden) _toolbar.frame = CGRectOffset(_toolbar.frame, 0, animatonOffset);
        _toolbar.alpha = alpha;
        
    } completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return _statusBarShouldBeHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)areControlsHidden { return (_toolbar.alpha == 0); }
- (void)hideControls { [self setControlsHidden:YES animated:YES]; }
- (void)toggleControls { [self setControlsHidden:![self areControlsHidden] animated:YES]; }



@end
