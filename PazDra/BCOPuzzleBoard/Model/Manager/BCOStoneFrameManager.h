//
//  BCOStoneFrameManager.h
//  PazDra
//
//  Created by 阿部耕平 on 2014/01/19.
//  Copyright (c) 2014年 Kohei Abe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCOStoneTypeDefines.h"
#import "BCOStonePositionDefines.h"

//===========================
// ボードや石のフレームを管理
//===========================

@class BCOStonePositionManager;
@interface BCOStoneFrameManager : NSObject

@property (nonatomic, readonly) CGRect fitBoardFrame;
@property (nonatomic, readonly) CGFloat stoneSize;

- (id)initWithNumberOfRows:(NSUInteger)numberOfRows
           numberOfColumns:(NSUInteger)numberOfColumns
                boardFrame:(CGRect)boardFrame;

// 指定された座標がボードの外側なら、ボードの内側の一番近い位置の座標に変換する。
- (CGPoint)pointConvertedToInlineFromPoint:(CGPoint)point;

// 指定されたポジションのStoneViewの矩形を返す。
- (CGRect)stoneViewFrameAtPosition:(BCOStonePosition)position;

@end
