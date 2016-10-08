//
//  StoreHourseView.h
//  StoreHourse
//
//  Created by BOOM on 16/9/20.
//  Copyright © 2016年 DEVIL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreHourseView : UIView

+ (StoreHourseView *)attachToScrollView:(UIScrollView *)scrollView
                                 target:(id)target
                          refreshAction:(SEL)refreshAction
                                  plist:(NSString *)plist;
/*
 color : 用于设置item的颜色
 width : 用于设置item的宽度
 dropHeight : 用于设置控件的高度
 scale : 用于设置控件比例
 horizontalRandomness : 改变item的散开方式
 reverseLoadAnimation : item高亮顺序颠倒
 internalAnimationFactor : 改变item动画时间，如果为1，则同时消失和出现
 */
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
                internalAnimationFactor:(CGFloat)internalAnimationFactor;


- (void)scrollViewDidScroll;

- (void)scrollViewDidEndDragging;

- (void)finishingLoading;

@end
