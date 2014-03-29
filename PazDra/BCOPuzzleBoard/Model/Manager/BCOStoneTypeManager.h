//
//  BCOStoneTypeManager.h
//  PazDra
//
//  Created by 阿部耕平 on 2013/12/20.
//  Copyright (c) 2013年 Kohei Abe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCOStoneTypeDefines.h"
#import "BCOStonePositionDefines.h"

//===========================
// 石の位置を管理・操作。
//===========================

@interface BCOStoneTypeManager : NSObject

@property (nonatomic) BCOStonePosition currentPosition;
@property (nonatomic, readonly) NSUInteger numberOfRows;
@property (nonatomic, readonly) NSUInteger numberOfColumns;

- (id)initWithNumberOfRows:(NSUInteger)numberOfRows
           numberOfColumns:(NSUInteger)numberOfColumns;

- (BCOStoneType)stoneTypeAtPosition:(BCOStonePosition)position;

// 入れ替え
- (void)swapPosition:(BCOStonePosition)positionA withPosition:(BCOStonePosition)positionB;

// 消す石を判定して、BCOStoneTypeEmptyで置き換える。
// 戻り値は消した石のポジションで、NSArrayのNSArray。
// 各NSArrayは同じ色の石のまとまりを表し、BCOStonePositionをNSValueでラップしたものを格納。
- (NSArray *)vanishStonePositions;

// BCOStoneTypeEmptyを発見し、同じ列の上側の石を全て下げる。
// 開いた部分にはランダムに石を詰める。
- (void)setupNextStoneTypes;

@end


// category
@interface BCOStoneTypeManager (Enumeration)

// BCOStonePositionを左上から各行ごとに列挙
- (void)enumeratePositionsUsingBlock:(void (^)(BCOStonePosition position))block;

// BCOStonePositionを右下から角行ごとに逆順で列挙
- (void)enumeratePositionsReverselyUsingBlock:(void (^)(BCOStonePosition position))block;

@end

