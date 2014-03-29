//
//  BCOSwapAnimation.m
//  PazDra
//
//  Created by 阿部耕平 on 2013/12/31.
//  Copyright (c) 2013年 Kohei Abe. All rights reserved.
//

#import "BCOSwapAnimation.h"
#import "BCOStoneView.h"

@interface BCOSwapAnimation ()

@property (nonatomic, strong) BCOSwapAnimationCompletion completion;
@property (nonatomic, strong) BCOStoneView *stoneViewA;
@property (nonatomic, strong) BCOStoneView *stoneViewB;

@end


@implementation BCOSwapAnimation {
    NSUInteger _finishedCount;
    CGPoint _positionA;
    CGPoint _positionB;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        _finishedCount++;
        if (_finishedCount == 2) {
            self.stoneViewA.layer.position = _positionB;
            self.stoneViewB.layer.position = _positionA;
            
            _completion();
            
            self.stoneViewA = nil;
            self.stoneViewB = nil;
        }
    }
}

- (void)swapStoneA:(BCOStoneView *)stoneViewA
            stoneB:(BCOStoneView *)stoneViewB
          duration:(NSTimeInterval)duration
        completion:(BCOSwapAnimationCompletion)completion
{
    self.stoneViewA = stoneViewA;
    self.stoneViewB = stoneViewB;
    
    const NSInteger kNumberOfKeyFrame = 10;
    _positionA = stoneViewA.layer.position;
    _positionB = stoneViewB.layer.position;
    CGPoint centerPoint = CGPointMake((_positionA.x + _positionB.x) / 2,
                                      (_positionA.y + _positionB.y) / 2);
    CGPoint relPosA = CGPointMake(_positionA.x - centerPoint.x,
                                  _positionA.y - centerPoint.y);
    CGPoint relPosB = CGPointMake(_positionB.x - centerPoint.x,
                                  _positionB.y - centerPoint.y);
    
    NSMutableArray *keyTimes    = @[].mutableCopy;
    NSMutableArray *positionsA  = @[].mutableCopy;
    NSMutableArray *positionsB  = @[].mutableCopy;
    for (int i = 0; i < kNumberOfKeyFrame; i++) {
        CFTimeInterval keyTime = (CFTimeInterval)i / (kNumberOfKeyFrame - 1);
        [keyTimes addObject:@(keyTime)];
        
        double angle = M_PI / (kNumberOfKeyFrame - 1) * i;
        
        // Aの動き
        CGPoint nextRelPosA = CGPointMake(relPosA.x * cos(angle) - relPosA.y * sin(angle),
                                          relPosA.x * sin(angle) + relPosA.y * cos(angle));
        CGPoint nextPositionA = CGPointMake(nextRelPosA.x + centerPoint.x,
                                            nextRelPosA.y + centerPoint.y);
        [positionsA addObject:[NSValue valueWithCGPoint:nextPositionA]];
        
        // Bの動き
        CGPoint nextRelPosB = CGPointMake(relPosB.x * cos(angle) - relPosB.y * sin(angle),
                                          relPosB.x * sin(angle) + relPosB.y * cos(angle));
        CGPoint nextPositionB = CGPointMake(nextRelPosB.x + centerPoint.x,
                                            nextRelPosB.y + centerPoint.y);
        [positionsB addObject:[NSValue valueWithCGPoint:nextPositionB]];
    }
    
    CAKeyframeAnimation *animationA = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animationA.keyTimes = keyTimes;
    animationA.duration = duration;
    animationA.values   = positionsA;
    animationA.fillMode = kCAFillModeForwards;
    animationA.removedOnCompletion = NO;
    animationA.delegate = self;
    
    CAKeyframeAnimation *animationB = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animationB.keyTimes = keyTimes;
    animationB.duration = duration;
    animationB.values   = positionsB;
    animationB.fillMode = kCAFillModeForwards;
    animationB.removedOnCompletion = NO;
    animationB.delegate = self;
    
    _finishedCount = 0;
    [stoneViewA.layer addAnimation:animationA forKey:@"animationA"];
    [stoneViewB.layer addAnimation:animationB forKey:@"animationB"];
    
    self.completion = completion;
}

- (void)removeAnimations
{
    [_stoneViewA.layer removeAllAnimations];
    [_stoneViewB.layer removeAllAnimations];
}

@end
