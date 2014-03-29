//
//  BCOSwapStoneEvent.h
//  PazDra
//
//  Created by 阿部耕平 on 2013/12/20.
//  Copyright (c) 2013年 Kohei Abe. All rights reserved.
//

#import "BCOEvent.h"
#import "BCOEventQueue.h"
#import "BCOStonePositionDefines.h"

@class BCOStoneView;
@protocol BCOSwapStoneEventDataSource;
@interface BCOSwapStoneEvent : BCOEvent

@property (nonatomic, weak) id<BCOSwapStoneEventDataSource> dataSource;
@property (nonatomic, readonly) BCOStonePosition positionA;
@property (nonatomic, readonly) BCOStonePosition positionB;

+ (instancetype)swapStoneEventWithPositionA:(BCOStonePosition)positionA
                                  positionB:(BCOStonePosition)positionB;

@end


@protocol BCOSwapStoneEventDataSource <NSObject>

- (BCOStoneView *)swapStoneEvent:(BCOSwapStoneEvent *)event
             stoneViewAtPosition:(BCOStonePosition)position;

@end