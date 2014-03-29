//
//  BCOTimerGauge.m
//  PazDra
//
//  Created by 阿部耕平 on 2014/02/04.
//  Copyright (c) 2014年 Kohei Abe. All rights reserved.
//

#import "BCOTimerGauge.h"

@implementation BCOTimerGauge

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        _gaugeColor = [UIColor redColor];
    }
    return self;
}

- (void)setValue:(CGFloat)value
{
    if (_value > 1.0) {
        _value = 1.0;
    }
    else if (_value < 0) {
        _value = 0.0;
    }
    else {
        _value = value;
    }
    [self setNeedsDisplay];
}

- (void)setGaugeColor:(UIColor *)gaugeColor
{
    _gaugeColor = gaugeColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    // ゲージ
    [_gaugeColor set];
    CGRect barRect = CGRectMake(0, 0, self.bounds.size.width * _value, self.bounds.size.height);
    UIBezierPath *bar = [UIBezierPath bezierPathWithRect:barRect];
    [bar fill];
    
    // 枠
    [[UIColor whiteColor] set];
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:self.bounds];
    bezierPath.lineWidth = 2.0;
    [bezierPath stroke];
}

@end
