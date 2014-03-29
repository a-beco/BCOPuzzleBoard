//
//  BCOVanishAnimation.m
//  PazDra
//
//  Created by 阿部耕平 on 2014/01/02.
//  Copyright (c) 2014年 Kohei Abe. All rights reserved.
//

#import "BCOVanishAnimation.h"
#import "BCOStoneView.h"

@interface BCOVanishAnimation ()

@property (nonatomic, strong) BCOVanishAnimationCompletion completion;
@property (nonatomic, strong) NSArray *vanishStones;

@end

@implementation BCOVanishAnimation

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    _completion();
    self.vanishStones = nil;
}

- (void)vanishStoneViews:(NSArray *)vanishStones
                duration:(NSTimeInterval)duration
              completion:(BCOVanishAnimationCompletion)completion
{
    self.completion = completion;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    
    for (BCOStoneView *stoneView in vanishStones) {
        stoneView.alpha = 0.0;
    }
    
    [UIView commitAnimations];
}

- (void)cancelAnimation
{
    for (BCOStoneView *stoneView in _vanishStones) {
        [stoneView.layer removeAllAnimations];
        stoneView.alpha = 0.0;
    }
}

@end
