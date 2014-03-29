//
//  BCOStoneCollisionChecker.m
//  PazDra
//
//  Created by 阿部耕平 on 2013/12/31.
//  Copyright (c) 2013年 Kohei Abe. All rights reserved.
//

#import "BCOStoneCollisionChecker.h"
#import "BCOCollisionUtils.h"
#import "BCOStoneView.h"
#import "BCOStoneTypeManager.h"
#import "BCOStoneFrameManager.h"

@implementation BCOStoneCollisionChecker {
    CGPoint _prevTouchPoint;
    BCOStoneTypeManager *_typeManager;
    BCOStoneFrameManager *_frameManager;
}

- (id)initWithTypeManager:(BCOStoneTypeManager *)typeManager
             frameManager:(BCOStoneFrameManager *)frameManager
{
    self = [super init];
    if (self) {
        _typeManager    = typeManager;
        _frameManager   = frameManager;
    }
    return self;
}

- (void)beginTouchingWithPoint:(CGPoint)point
{
    point = [_frameManager pointConvertedToInlineFromPoint:point];
    _prevTouchPoint = point;
}

- (void)addTouchPoint:(CGPoint)point
{
    BCOStonePosition currentStonePosition = _typeManager.currentPosition;
    
    point = [_frameManager pointConvertedToInlineFromPoint:point];
    BCOLine line = {_prevTouchPoint, point};
    _prevTouchPoint = point;
    
    // 前回と同じポジションの点ならreturn
    CGRect currentStoneFrame = [_frameManager stoneViewFrameAtPosition:currentStonePosition];
    BOOL isSamePosition = (CGRectContainsPoint(currentStoneFrame, point));
    if (isSamePosition) return;
    
    // 当たり判定処理を開始
    NSMutableArray *collidedPositions = @[].mutableCopy;
    
    // 斜め移動判定
    __block BOOL isDiagonal = NO;
    [_typeManager enumeratePositionsUsingBlock:^(BCOStonePosition position) {
        CGRect stoneFrame = [_frameManager stoneViewFrameAtPosition:position];
        if (CGRectContainsPoint(stoneFrame, point)
            && BCOStonePositionDiagonalToPosition(currentStonePosition, position))  {
            
            NSValue *positionValue = [NSValue valueWithBCOStonePosition:position];
            [collidedPositions addObject:positionValue];
            [self p_addCollidedPositions:collidedPositions];
            isDiagonal = YES;
        }
    }];
    if (isDiagonal) return;

    // 線と矩形の衝突判定
    [_typeManager enumeratePositionsUsingBlock:^(BCOStonePosition position) {
        CGRect stoneFrame = [_frameManager stoneViewFrameAtPosition:position];
        if (isCollideLineAndRect(line, stoneFrame)) {
            NSValue *positionValue = [NSValue valueWithBCOStonePosition:position];
            
            // 現在のビューでなければ衝突した石として追加
            if (!BCOStonePositionEqualToPosition(position, currentStonePosition)
                && ![collidedPositions containsObject:positionValue]) {
                [collidedPositions addObject:positionValue];
            }
        }
    }];
    
    if ([collidedPositions count] > 0) {
        [self p_addCollidedPositions:collidedPositions];
    }
}

#pragma mark - private

- (void)p_addCollidedPositions:(NSMutableArray *)stonePositions
{
    NSMutableArray *sortedPositions = @[].mutableCopy;
    BCOStonePosition currentPosition = _typeManager.currentPosition;
    
    // 現在の位置から接地している順に並べていく
    while (1) {
        BCOStonePosition nextStonePosition = BCOStonePositionUndefined;
        
        // 上下左右方向をチェック
        for (NSValue *positionValue in stonePositions) {
            // 接地した次の石を探す
            if (BCOStonePositionNextToPosition(currentPosition, positionValue.positionValue)) {
                nextStonePosition = positionValue.positionValue;
                break;
            }
        }
        
        // ナナメ方向のチェック
        if (BCOStonePositionEqualToPosition(nextStonePosition, BCOStonePositionUndefined)) {
            for (NSValue *positionValue in stonePositions) {
                // 接地した次の石を探す
                if (BCOStonePositionDiagonalToPosition(currentPosition, positionValue.positionValue)) {
                    nextStonePosition = positionValue.positionValue;
                    break;
                }
            }
        }
        
        if (!BCOStonePositionEqualToPosition(nextStonePosition, BCOStonePositionUndefined)) {
            NSValue *nextStonePositionValue = [NSValue valueWithBCOStonePosition:nextStonePosition];
            [sortedPositions addObject:nextStonePositionValue];
            [stonePositions removeObject:nextStonePositionValue];
            currentPosition = nextStonePosition;
        }
        else {
            break;
        }
    }
    
    // delegateでsortedStonesを渡す
    if ([_delegate respondsToSelector:@selector(stoneCollisionChecker:didCollideWithPositions:)]) {
        [_delegate stoneCollisionChecker:self didCollideWithPositions:sortedPositions.copy];
    }
}

@end
