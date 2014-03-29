//
//  BCOStoneCollisionChecker.h
//  PazDra
//
//  Created by 阿部耕平 on 2013/12/31.
//  Copyright (c) 2013年 Kohei Abe. All rights reserved.
//

#import <Foundation/Foundation.h>

//=========================
// 衝突チェッカー
//=========================
@protocol BCOStoneCollisionCheckerDelegate;
@class BCOStoneView, BCOStoneTypeManager, BCOStoneFrameManager;
@interface BCOStoneCollisionChecker : NSObject

@property (nonatomic, weak) id<BCOStoneCollisionCheckerDelegate> delegate;

- (id)initWithTypeManager:(BCOStoneTypeManager *)typeManager
             frameManager:(BCOStoneFrameManager *)frameManager;

// タッチ開始時のみbeginTouchingWithPoint:currentStoneViewを呼ぶ。
- (void)beginTouchingWithPoint:(CGPoint)point;

// touchesMove, End, Cancel時はaddTouchPoint:を呼ぶ。
- (void)addTouchPoint:(CGPoint)point;

@end


// delegate
@protocol BCOStoneCollisionCheckerDelegate <NSObject>

// 他の石と衝突していれば石のポジションの配列を返す。
// 配列は現在の位置から近い順にソートされる。
- (void)stoneCollisionChecker:(BCOStoneCollisionChecker *)stoneCollisionChecker
      didCollideWithPositions:(NSArray *)collidedPositionsSorted;

@end

