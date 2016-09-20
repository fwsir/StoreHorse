//
//  StoreHourseView.m
//  StoreHourse
//
//  Created by BOOM on 16/9/20.
//  Copyright © 2016年 DEVIL. All rights reserved.
//

#import "StoreHourseView.h"

static const CGFloat kLoadingIndividualAnimationTiming = 0.8;
static const CGFloat kBarDarkAlpha = 0.4;
static const CGFloat kLoadingTimingOffset = 0.1;
static const CGFloat kDisappearDuration = 1.2;
static const CGFloat kRelativeHeightFactor = 2.f/5.f;

NS_ENUM(NSInteger, RefreshState)
{
    RefreshStateIdle = 0,
    RefreshStateRefreshing,
    RefreshStateDisappearing
};

@interface StoreHourseView ()

@end

@implementation StoreHourseView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
