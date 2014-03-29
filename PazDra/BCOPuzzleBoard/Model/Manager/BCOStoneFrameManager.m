//
//  BCOStoneFrameManager.m
//  PazDra
//
//  Created by 阿部耕平 on 2014/01/19.
//  Copyright (c) 2014年 Kohei Abe. All rights reserved.
//

#import "BCOStoneFrameManager.h"

static const CGFloat kBoardFrameWidth = 1.0;

@implementation BCOStoneFrameManager {
    NSUInteger _numberOfRows, _numberOfColumns;
}

- (id)initWithNumberOfRows:(NSUInteger)numberOfRows
           numberOfColumns:(NSUInteger)numberOfColumns
                boardFrame:(CGRect)boardFrame
{
    self = [super init];
    if (self) {
        _numberOfRows       = numberOfRows;
        _numberOfColumns    = numberOfColumns;
        
        // 石のサイズを計算
        _stoneSize = (CGRectGetWidth(boardFrame) - kBoardFrameWidth * 2) / numberOfColumns;
        
        // 石が配置されている領域の矩形を計算
        CGRect frame = boardFrame;
        frame.size.height = _stoneSize * numberOfRows + kBoardFrameWidth * 2;
        _fitBoardFrame = frame;
    }
    return self;
}

// pointをボードの内側の座標に変換する。
- (CGPoint)pointConvertedToInlineFromPoint:(CGPoint)point
{
    const CGFloat kBorderWidth = 1.0;
    
    if (point.y < kBorderWidth) point.y = kBorderWidth;
    if (point.x < kBorderWidth) point.x = kBorderWidth;
    
    CGFloat rightEdge = CGRectGetWidth(_fitBoardFrame) - kBorderWidth;
    if (point.x > rightEdge) point.x = rightEdge;
    
    CGFloat bottomEdge = CGRectGetHeight(_fitBoardFrame) - kBorderWidth;
    if (point.y > bottomEdge) point.y = bottomEdge;
    
    return point;
}

// 指定したポジションの石の矩形を返す。
// ポジションが範囲外ならばCGRectZeroを返す。
- (CGRect)stoneViewFrameAtPosition:(BCOStonePosition)position
{
    if ((position.row < _numberOfRows) && (position.column < _numberOfColumns)) {
        return CGRectMake(1 + position.column * _stoneSize,
                          1 + position.row * _stoneSize,
                          _stoneSize,
                          _stoneSize);
    }
    return CGRectZero;
}

@end
