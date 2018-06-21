//
//  DNImagePickerController.m
//  ImagePicker
//
//  Created by DingXiao on 15/2/10.
//  Copyright (c) 2015年 Dennis. All rights reserved.
//

//----------------------------------------------------------

#import "DNImagePickerController.h"
#import "DNAlbumTableViewController.h"
#import "DNImageFlowViewController.h"
#import "XYYFoundation.h"

//----------------------------------------------------------

NSString *kDNImagePickerStoredGroupKey = @"com.dennis.kDNImagePickerStoredGroup";

//----------------------------------------------------------

ALAssetsLibrary * shareAssetsLibrary()
{
    static ALAssetsLibrary * shareAssetsLibrary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareAssetsLibrary = [[ALAssetsLibrary alloc] init];
    });
    
    return shareAssetsLibrary;
}

ALAssetsFilter * ALAssetsFilterFromDNImagePickerControllerFilterType(DNImagePickerFilterType type)
{
    switch (type) {
        default:
        case DNImagePickerFilterTypeNone:
            return [ALAssetsFilter allAssets];
            break;
        case DNImagePickerFilterTypePhotos:
            return [ALAssetsFilter allPhotos];
            break;
        case DNImagePickerFilterTypeVideos:
            return [ALAssetsFilter allVideos];
            break;
    }
}

//----------------------------------------------------------

@interface DNImagePickerController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) id<UINavigationControllerDelegate> navDelegate;
@property (nonatomic, assign) BOOL isDuringPushAnimation;

@end

//----------------------------------------------------------

@implementation DNImagePickerController


- (NSUInteger)maxSelectedImageCount {
    return _maxSelectedImageCount ?: 9;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.interactivePopGestureRecognizer.delegate = self;
    
    if ([super delegate] != self) {
        [super setDelegate:self];
    }
    
    NSString *propwetyID = [[NSUserDefaults standardUserDefaults] objectForKey:kDNImagePickerStoredGroupKey];

    if (propwetyID.length <= 0) {
        [self showAlbumList];
    } else {
        [shareAssetsLibrary() enumerateGroupsWithTypes:ALAssetsGroupAll
                                            usingBlock:^(ALAssetsGroup *assetsGroup, BOOL *stop)
         {
             void(^block)(void) = ^{
             
                 if (assetsGroup == nil && *stop ==  NO) {
                     [self showAlbumList];
                 }
                 
                 NSString *assetsGroupID= [assetsGroup valueForProperty:ALAssetsGroupPropertyPersistentID];
                 if ([assetsGroupID isEqualToString:propwetyID]) {
                     *stop = YES;
                     DNAlbumTableViewController *albumTableViewController = [[DNAlbumTableViewController alloc] init];
                     DNImageFlowViewController *imageFlowController = [[DNImageFlowViewController alloc] initWithAssetsGroup:assetsGroup];
                     [self setViewControllers:@[albumTableViewController,imageFlowController]];
                 }
             };
             
             if ([NSThread isMainThread]) {
                 block();
             }else {
                 dispatch_async(dispatch_get_main_queue(), block);
             }
             
         }
                                   failureBlock:^(NSError *error)
         {
             if ([NSThread isMainThread]) {
                 [self showAlbumList];
             }else {
                 [self performSelectorOnMainThread:@selector(showAlbumList) withObject:nil waitUntilDone:NO];
             }
         }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
    
    [super viewWillAppear:animated];
}


#pragma mark - priviate methods
- (void)showAlbumList
{
    DNAlbumTableViewController *albumTableViewController = [[DNAlbumTableViewController alloc] init];
    [self setViewControllers:@[albumTableViewController]];
}

#pragma mark - UINavigationController

- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated __attribute__((objc_requires_super))
{
    self.isDuringPushAnimation = YES;
    [super pushViewController:viewController animated:animated];
}

#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    self.isDuringPushAnimation = NO;
    if ([self.navDelegate respondsToSelector:_cmd]) {
        [self.navDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        return [self.viewControllers count] > 1 && !self.isDuringPushAnimation;
    } else {
        return YES;
    }
}

#pragma mark - 代理方法转发

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate
{
    if (delegate != self.navDelegate) {
        self.navDelegate = delegate != self ? delegate : nil;
        
        //更新代理
        if ([super delegate] == self) {
            [super setDelegate:nil];
            [super setDelegate:self];
        }
    }
}

- (id<UINavigationControllerDelegate>)delegate {
    return self.navDelegate;
}

- (BOOL)_isNavigationControllerDelegateSelector:(SEL)aSelector {
    return NSProtocolContainSelector(@protocol(UINavigationControllerDelegate), aSelector, NO, YES);
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if (![super respondsToSelector:aSelector]) {
        if ([self _isNavigationControllerDelegateSelector:aSelector]) {
            return [self.navDelegate respondsToSelector:aSelector];
        }
        return NO;
    }
    return YES;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([self _isNavigationControllerDelegateSelector:aSelector] &&
        [self.navDelegate respondsToSelector:aSelector]) {
        return self.navDelegate;
    }else {
        return [super forwardingTargetForSelector:aSelector];
    }
}


#pragma mark -

- (BOOL)shouldAutorotate {
    return NO;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#else
- (NSUInteger)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

@end

//----------------------------------------------------------

@implementation ALAsset(DNImagePickerController)

- (BOOL)_isLongImage
{
    CGSize size = self.defaultRepresentation.dimensions;
    if (size.width && size.height) {
        CGFloat factor = size.height / size.width;
        factor = factor < 1.f ? 1.f / factor : factor;
        return factor >= 5.f;
    }
    
    return NO;
}


- (UIImage *)suitableFullScreenImage
{
    if ([self _isLongImage]) { //长图则手动压缩
        UIImage * fullResolutionImage = [[UIImage alloc] initWithCGImage:self.defaultRepresentation.fullResolutionImage];
        return [fullResolutionImage imageZoomInToMaxSize:CGSizeMake(1536.f, 1536.f)];
    }else {
        return [[UIImage alloc] initWithCGImage:self.defaultRepresentation.fullScreenImage];
    }
}

- (UIImage *)suitableThumbnail
{
    if ([self _isLongImage]) { //长图则手动压缩
        UIImage * fullResolutionImage = [[UIImage alloc] initWithCGImage:self.defaultRepresentation.fullResolutionImage];
        return [fullResolutionImage thumbnailWithSize:180.f sizeScaleMode:MyScaleModePixel];
    }else {
        return [[UIImage alloc] initWithCGImage:GreaterThanIOS9System ? self.aspectRatioThumbnail : self.thumbnail];
    }
}

- (UIImage *)suitableAspectRatioThumbnail:(BOOL)copy
{
    if ([self _isLongImage]) { //长图则手动压缩
        UIImage * fullResolutionImage = [[UIImage alloc] initWithCGImage:self.defaultRepresentation.fullResolutionImage];
        return [fullResolutionImage aspectRatioThumbnailWithSize:180.f sizeScaleMode:MyScaleModePixel];
    }else {
        return [[UIImage alloc] initWithCGImage:copy ? CGImageCreateCopy(self.aspectRatioThumbnail) : self.aspectRatioThumbnail];
    }
}

@end






