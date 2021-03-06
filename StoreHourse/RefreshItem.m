//
//  RefreshItem.m
//  StoreHourse
//
//  Created by BOOM on 16/9/20.
//  Copyright © 2016年 DEVIL. All rights reserved.
//

#import "RefreshItem.h"

@interface RefreshItem ()

@property (nonatomic) CGPoint middlePoint;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic) UIColor *color;

@end

@implementation RefreshItem

- (instancetype)initWithFrame:(CGRect)frame startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint color:(UIColor *)color lineWidth:(CGFloat)lineWidth
{
    if (self = [super initWithFrame:frame])
    {
        _startPoint = startPoint;
        _endPoint = endPoint;
        _lineWidth = lineWidth;
        _color = color;
        
        CGPoint (^middlePoint)(CGPoint, CGPoint) = ^(CGPoint a, CGPoint b){
            CGFloat x = (a.x + b.x) / 2.f;
            CGFloat y = (a.y + b.y) / 2.f;
            return CGPointMake(x, y);
        };
        
        _middlePoint = middlePoint(startPoint, endPoint);
    }
    
    return self;
}

- (void)setupWithFrame:(CGRect)rect
{
    self.layer.anchorPoint = CGPointMake(self.middlePoint.x / self.frame.size.width, self.middlePoint.y / self.frame.size.height);
    self.frame = CGRectMake(self.frame.origin.x + self.middlePoint.x - self.frame.size.width / 2, self.frame.origin.y + self.middlePoint.y - self.frame.size.height, self.frame.size.width, self.frame.size.height);
}

- (void)setHorizontalRandomness:(int)horizontalRandomness dropHeight:(CGFloat)dropHeight
{
    int randNum = -horizontalRandomness + arc4random() % horizontalRandomness * 2;
    self.translationX = randNum;
    self.transform = CGAffineTransformMakeTranslation(self.translationX, -dropHeight);
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:self.startPoint];
    [bezierPath addLineToPoint:self.endPoint];
    [self.color setStroke];
    
    bezierPath.lineWidth = self.lineWidth;
    [bezierPath stroke];
}


@end
