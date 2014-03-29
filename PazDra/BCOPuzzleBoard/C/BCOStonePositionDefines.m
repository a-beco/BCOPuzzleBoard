//
//  BCOStonePositionDefines.m
//  PazDra
//
//  Created by 阿部耕平 on 2014/01/19.
//  Copyright (c) 2014年 Kohei Abe. All rights reserved.
//

#import "BCOStonePositionDefines.h"

// BCOStonePosition

const BCOStonePosition BCOStonePositionUndefined = {NSUIntegerMax, NSUIntegerMax};

extern BCOStonePosition BCOStonePositionMake(NSUInteger row, NSUInteger column)
{
    BCOStonePosition position;
    position.row      = row;
    position.column   = column;
    return position;
}

BOOL BCOStonePositionEqualToPosition(BCOStonePosition position1, BCOStonePosition position2)
{
    return ((position1.row == position2.row) && (position1.column == position2.column));
}

BOOL BCOStonePositionNextToPosition(BCOStonePosition position1, BCOStonePosition position2)
{
    // 上
    if (position1.row == position2.row - 1
        && position1.column == position2.column) {
        return YES;
    }
    
    // 右
    if (position1.row == position2.row
        && position1.column == position2.column + 1) {
        return YES;
    }
    
    // 下
    if (position1.row == position2.row + 1
        && position1.column == position2.column) {
        return YES;
    }
    
    // 左
    if (position1.row == position2.row
        && position1.column == position2.column - 1) {
        return YES;
    }
    return NO;
}

BOOL BCOStonePositionDiagonalToPosition(BCOStonePosition position1, BCOStonePosition position2)
{
    // 左上
    if (position1.row == position2.row - 1
        && position1.column == position2.column - 1) {
        return YES;
    }
    
    // 右上
    if (position1.row == position2.row - 1
        && position1.column == position2.column + 1) {
        return YES;
    }
    
    // 左下
    if (position1.row == position2.row + 1
        && position1.column == position2.column - 1) {
        return YES;
    }
    
    // 右下
    if (position1.row == position2.row + 1
        && position1.column == position2.column + 1) {
        return YES;
    }
    return NO;
}

NSString *NSStringFromBCOStonePosition(BCOStonePosition position)
{
    return [NSString stringWithFormat:@"[%lu %lu]", (unsigned long)position.row, (unsigned long)position.column];
}


// category
@implementation NSValue (BCOStonePosition)

+ (NSValue *)valueWithBCOStonePosition:(BCOStonePosition)position
{
    NSValue *val = [NSValue value:&position withObjCType:@encode(BCOStonePosition)];
    return val;
}

- (BCOStonePosition)positionValue
{
    BCOStonePosition position;
    [self getValue:&position];
    return position;
}

@end


