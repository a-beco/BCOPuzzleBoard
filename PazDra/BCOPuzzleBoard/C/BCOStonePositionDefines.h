//
//  BCOStonePositionDefines.h
//  PazDra
//
//  Created by 阿部耕平 on 2014/01/19.
//  Copyright (c) 2014年 Kohei Abe. All rights reserved.
//

#import <Foundation/Foundation.h>

//
// BCOStonePosition
//

typedef struct {
    NSUInteger row;
    NSUInteger column;
} BCOStonePosition;

extern const BCOStonePosition BCOStonePositionUndefined;

extern BCOStonePosition BCOStonePositionMake(NSUInteger row, NSUInteger column);
extern BOOL BCOStonePositionEqualToPosition(BCOStonePosition position1, BCOStonePosition position2);
extern BOOL BCOStonePositionNextToPosition(BCOStonePosition position1, BCOStonePosition position2);
extern BOOL BCOStonePositionDiagonalToPosition(BCOStonePosition position1, BCOStonePosition position2);
extern NSString *NSStringFromBCOStonePosition(BCOStonePosition position);

// category
@interface NSValue (BCOStonePosition)

+ (NSValue *)valueWithBCOStonePosition:(BCOStonePosition)position;
- (BCOStonePosition)positionValue;

@end

