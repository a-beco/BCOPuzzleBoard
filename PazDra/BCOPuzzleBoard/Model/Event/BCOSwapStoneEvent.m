//
//  BCOSwapStoneEvent.m
//  PazDra
//
//  Created by 阿部耕平 on 2013/12/20.
//  Copyright (c) 2013年 Kohei Abe. All rights reserved.
//

#import "BCOSwapStoneEvent.h"
#import "BCOStoneView.h"

@interface BCOSwapStoneEvent ()

@property (nonatomic) BCOStonePosition positionA;
@property (nonatomic) BCOStonePosition positionB;

@end

@implementation BCOSwapStoneEvent

+ (BCOSwapStoneEvent *)swapStoneEventWithPositionA:(BCOStonePosition)positionA
                                         positionB:(BCOStonePosition)positionB
{
    BCOSwapStoneEvent *event = [[BCOSwapStoneEvent alloc] init];
    event.positionA = positionA;
    event.positionB = positionB;
    return event;
}

@end

