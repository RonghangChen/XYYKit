//
//  MyBasicInfoCellPickerPopoverView.m
//  
//
//  Created by LeslieChen on 15/3/23.
//  Copyright (c) 2015年 ED. All rights reserved.
//

//----------------------------------------------------------

#import "MyBasicInfoCellPickerPopoverView.h"
#import "XYYBaseDef.h"
#import "MyPopoverView.h"
#import "NSObject+IntervalAnimation.h"

//----------------------------------------------------------

@interface MyBasicInfoCellPickerPopoverView ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *pickerContentView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomMarginConstraint;

@end

//----------------------------------------------------------

@implementation MyBasicInfoCellPickerPopoverView

@dynamic delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        super.contentAnchorPoint = CGPointMake(0.5f, 1.f);
        super.locationAnchorPoint = CGPointMake(0.5f, 1.f);
        
        //初始化
        UINib * nib = [UINib nibWithNibName:@"MyPickerPopoverContentView" bundle:[NSBundle mainBundle]];
        UIView * contentView = [[nib instantiateWithOwner:self options:nil] firstObject];
        contentView.frame = self.bounds;
        contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:contentView];
    }
    
    return self;
}

- (void)setContentAnchorPoint:(CGPoint)contentAnchorPoint {
}
- (void)setLocationAnchorPoint:(CGPoint)locationAnchorPoint {
}

- (UIView *)pickerContainerView {
    return self.pickerContentView;
}

#pragma mark -

- (void)setTitle:(NSString *)title
{
    super.title = title;
    self.titleLabel.text = self.title;
}

#pragma mark - 

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat height = 0.f;
    id<MyBasicInfoCellPickerPopoverViewDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(contentHeightForPickerPopoverView:containerHeight:)){
        height = [delegate contentHeightForPickerPopoverView:self containerHeight:size.height];
    }else{
        height = [self designContentHeightForContainerSize:size];
    }
    
    //加上底端安全区
    if (@available(iOS 11.0, *)) {
        height += self.popoverView.safeAreaInsets.bottom;
    }
    
    return CGSizeMake(size.width, height + 45.f);
}

- (void)safeAreaInsetsDidChange
{
    if (@available(iOS 11.0, *)) {
        [super safeAreaInsetsDidChange];
        self.bottomMarginConstraint.constant = self.safeAreaInsets.bottom;
    }
}

- (CGFloat)designContentHeightForContainerSize:(CGSize)size {
    return 205.f;
}

- (BOOL)customAnimationForPopoverView:(MyPopoverView *)popoverView
                                 show:(BOOL)show
                       animationBlock:(void(^)(void))animationBlock
                       completedBlock:(void(^)(void))completedBlock
{

    [self defaultPushCustomAnimationForPopoverView:popoverView
                                         direction:MyMoveAnimatedDirectionDown
                                              show:show
                                    animationBlock:animationBlock
                                    completedBlock:completedBlock];
    
    return YES;
}

- (IBAction)_cancleButtonHandle:(id)sender {
    [self didEndEditByCancle];
}

- (IBAction)_completeButtonHandle:(id)sender {
    [self tryEditToNewValue];
}


@end
