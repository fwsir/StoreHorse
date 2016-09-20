//
//  RefreshItem.h
//  StoreHourse
//
//  Created by BOOM on 16/9/20.
//  Copyright © 2016年 DEVIL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RefreshItem : UIView

@property (nonatomic) CGFloat translationX;

- (instancetype)initWithFrame:(CGRect)frame startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint color:(UIColor*)color lineWidth:(CGFloat)lineWidth;

- (void)setupWithFrame:(CGRect)rect;

- (void)setHorizontalRandomness:(int)horizontalRandomness dropHeight:(CGFloat)dropHeight;

@end
