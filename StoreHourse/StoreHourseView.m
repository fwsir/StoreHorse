//
//  StoreHourseView.m
//  StoreHourse
//
//  Created by BOOM on 16/9/20.
//  Copyright © 2016年 DEVIL. All rights reserved.
//

#import "StoreHourseView.h"
#import "RefreshItem.h"

static const CGFloat kLoadingIndividualAnimationTiming = 0.8;
static const CGFloat kBarDarkAlpha = 0.4;
static const CGFloat kLoadingTimingOffset = 0.1;
static const CGFloat kDisappearDuration = 1.2;
static const CGFloat kRelativeHeightFactor = 2.f/5.f;

typedef NS_ENUM(NSInteger, RefreshState)
{
    RefreshStateIdle = 0,
    RefreshStateRefreshing,
    RefreshStateDisappearing
};

NSString *const kStartPoint = @"startPoints";
NSString *const kEndPoint = @"endPoints";
NSString *const kX = @"x";
NSString *const kY = @"y";

@interface StoreHourseView () <UIScrollViewDelegate>

@property (nonatomic) RefreshState state;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *refreshItems;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) id target;
@property (nonatomic) SEL action;

@property (nonatomic) CGFloat dropHeight;
@property (nonatomic) CGFloat originalTopContentInset;
@property (nonatomic) CGFloat disappearProgress;
@property (nonatomic) CGFloat internalAnimationFactor;
@property (nonatomic) int horizontalRandomness;
@property (nonatomic) BOOL reverseLoadingAnimation;

@end

@implementation StoreHourseView

+ (StoreHourseView *)attachToScrollView:(UIScrollView *)scrollView
                                 target:(id)target
                          refreshAction:(SEL)refreshAction
                                  plist:(NSString *)plist
{
    return [StoreHourseView attachToScrollView:scrollView
                                        target:target
                                 refreshAction:refreshAction
                                         plist:plist
                                         color:[UIColor whiteColor]
                                     lineWidth:2
                                    dropHeight:80
                                         scale:1
                          horizontalRandomness:150
                       reverseLoadingAnimation:NO
                       internalAnimationFactor:0.7];
}


+ (StoreHourseView *)attachToScrollView:(UIScrollView *)scrollView
                                 target:(id)target
                          refreshAction:(SEL)refreshAction
                                  plist:(NSString *)plist
                                  color:(UIColor *)color
                              lineWidth:(CGFloat)lineWidth
                             dropHeight:(CGFloat)dropHeight
                                  scale:(CGFloat)scale
                   horizontalRandomness:(CGFloat)horizontalRandomness
                reverseLoadingAnimation:(BOOL)reverseLoadingAnimation
                internalAnimationFactor:(CGFloat)internalAnimationFactor
{
    StoreHourseView *hourseView = [[StoreHourseView alloc] init];
    
    hourseView.dropHeight           = dropHeight;
    hourseView.horizontalRandomness = horizontalRandomness;
    hourseView.scrollView           = scrollView;
    hourseView.target               = target;
    hourseView.action               = refreshAction;
    hourseView.reverseLoadingAnimation = reverseLoadingAnimation;
    hourseView.internalAnimationFactor = internalAnimationFactor;
    [scrollView addSubview:hourseView];
    
    // Calculate frame according to points max width and height
    CGFloat width = 0, height = 0;
    NSDictionary *rootDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plist ofType:@"plist"]];
    NSArray *startPoints = [rootDict objectForKey:kStartPoint];
    NSArray *endPoints = [rootDict objectForKey:kEndPoint];
    for (int index = 0; index < startPoints.count; ++index)
    {
        CGPoint startPoint = CGPointFromString(startPoints[index]);
        CGPoint endPoint = CGPointFromString(endPoints[index]);
        
        if (startPoint.x > width)
        {
            width = startPoint.x;
        }
        
        if (endPoint.x > width)
        {
            width = endPoint.x;
        }
        
        if (startPoint.y > height)
        {
            height = startPoint.y;
        }
        
        if (endPoint.y > height)
        {
            height = endPoint.y;
        }
    }
    
    hourseView.frame = CGRectMake(0, 0, width, height);
    
    // Create refresh Items
    NSMutableArray *mutableItems = [NSMutableArray array];
    for (int index = 0; index < startPoints.count; ++index)
    {
        CGPoint startPoint = CGPointFromString(startPoints[index]);
        CGPoint endPoint = CGPointFromString(endPoints[index]);
        
        RefreshItem *item = [[RefreshItem alloc] initWithFrame:hourseView.frame
                                                    startPoint:startPoint
                                                      endPoint:endPoint
                                                         color:color
                                                     lineWidth:lineWidth];
        item.tag = index;
        item.backgroundColor = [UIColor clearColor];
        item.alpha = 0;
        [mutableItems addObject:item];
        [hourseView addSubview:item];
        
        [item setHorizontalRandomness:hourseView.horizontalRandomness dropHeight:hourseView.dropHeight];
    }
    
    hourseView.refreshItems = mutableItems;
    hourseView.frame = CGRectMake(0, 0, width, height);
    hourseView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, 0);
    for (RefreshItem *item in mutableItems)
    {
        [item setupWithFrame:hourseView.frame];
    }
    
    hourseView.transform = CGAffineTransformMakeScale(scale, scale);
    return hourseView;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll
{
    if (self.originalTopContentInset == 0)
    {
        self.originalTopContentInset = self.scrollView.contentInset.top;
    }
    
    self.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, self.realContentOffsetY * kRelativeHeightFactor);
    if (self.state == RefreshStateIdle)
    {
        [self _updateRefreshItemsWithProgress:self.animationProgress];
    }
}

- (void)scrollViewDidEndDragging
{
    if (self.state == RefreshStateIdle && self.realContentOffsetY < -self.dropHeight)
    {
        if (self.animationProgress == 1)
        {
            self.state = RefreshStateRefreshing;
        }
        
        if (self.state == RefreshStateRefreshing)
        {
            UIEdgeInsets newInset = self.scrollView.contentInset;
            newInset.top = self.originalTopContentInset + self.dropHeight;
            CGPoint contentOffset = self.scrollView.contentOffset;
            
            [UIView animateWithDuration:0 animations:^{
                self.scrollView.contentInset = newInset;
                self.scrollView.contentOffset = contentOffset;
            }];
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if ([self.target respondsToSelector:self.action])
            {
                [self.target performSelector:self.action withObject:self];
            }
#pragma clang diagnostic pop
            
            [self _startLoadingAnimation];
        }
    }
}

#pragma mark - Private Methods

- (CGFloat)realContentOffsetY
{
    NSLog(@"ContentOffset is %f  and topInset is %f", self.scrollView.contentOffset.y, self.originalTopContentInset);
    
    return self.scrollView.contentOffset.y + self.originalTopContentInset;
}

- (CGFloat)animationProgress
{
    return MIN(1.f, MAX(0, fabs(self.realContentOffsetY)/self.dropHeight));
}

- (void)_updateRefreshItemsWithProgress:(CGFloat)progress
{
    NSInteger index = 0;
    for (RefreshItem *item in self.refreshItems)
    {
        CGFloat startPadding = (1 - self.internalAnimationFactor) / self.refreshItems.count * index++;
        CGFloat endPadding = 1 - self.internalAnimationFactor - startPadding;
        if (progress == 1 || progress >= 1 - endPadding)
        {
            item.transform = CGAffineTransformIdentity;
            item.alpha = kBarDarkAlpha;
        }
        else if (progress == 0)
        {
            [item setHorizontalRandomness:self.horizontalRandomness dropHeight:self.dropHeight];
        }
        else
        {
            CGFloat realProgress = (progress <= startPadding) ? 0 : MIN(1, (progress - startPadding)/self.internalAnimationFactor);
            
            item.transform = CGAffineTransformMakeTranslation(item.translationX*(1 - realProgress), -self.dropHeight * (1-realProgress));
            item.transform = CGAffineTransformRotate(item.transform, M_PI * realProgress);
            item.transform = CGAffineTransformScale(item.transform, realProgress, realProgress);
            item.alpha = realProgress * kBarDarkAlpha;
        }
    }
}

- (void)_updateDisappearAnimation
{
    if (self.disappearProgress >= 0 && self.disappearProgress <= 1)
    {
        self.disappearProgress -= 1/60.f/kDisappearDuration;
        [self _updateRefreshItemsWithProgress:self.disappearProgress];
    }
}

- (void)_startLoadingAnimation
{
    if (self.reverseLoadingAnimation)
    {
        int count = (int)self.refreshItems.count;
        for (int index = count - 1; index >= 0; --index)
        {
            RefreshItem *item = self.refreshItems[index];
            [self performSelector:@selector(_refreshItemAnimation:) withObject:item afterDelay:(self.refreshItems.count - index - 1) * kLoadingTimingOffset inModes:@[NSRunLoopCommonModes]];
        }
    }
    else
    {
        for (int index = 0; index < self.refreshItems.count; ++index)
        {
            RefreshItem *item = self.refreshItems[index];
            [self performSelector:@selector(_refreshItemAnimation:) withObject:item afterDelay:index * kLoadingTimingOffset inModes:@[NSRunLoopCommonModes]];
        }
    }
}

- (void)_refreshItemAnimation:(RefreshItem *)item
{
    if (self.state == RefreshStateRefreshing)
    {
        item.alpha = 1;
        [item.layer removeAllAnimations];
        [UIView animateWithDuration:kLoadingIndividualAnimationTiming animations:^{
            item.alpha = kBarDarkAlpha;
        }];
    }
    
    BOOL isLastOne;
    if (self.reverseLoadingAnimation)
    {
        isLastOne = item.tag == 0;
    }
    else
    {
        isLastOne = item.tag == self.refreshItems.count - 1;
    }
    
    if (isLastOne && self.state == RefreshStateRefreshing)
    {
        [self _startLoadingAnimation];
    }
}

#pragma mark - Public Methods

- (void)finishingLoading
{
    self.state = RefreshStateDisappearing;
    UIEdgeInsets newInsets = self.scrollView.contentInset;
    newInsets.top = self.originalTopContentInset;
    
    [UIView animateWithDuration:kDisappearDuration animations:^{
        self.scrollView.contentInset = newInsets;
    } completion:^(BOOL finished) {
        self.state = RefreshStateIdle;
        [self.displayLink invalidate];
        self.disappearProgress = 1;
    }];
    
    for (RefreshItem *item in self.refreshItems)
    {
        [item.layer removeAllAnimations];
        item.alpha = kBarDarkAlpha;
    }
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_updateDisappearAnimation)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.disappearProgress = 1;
}

@end
