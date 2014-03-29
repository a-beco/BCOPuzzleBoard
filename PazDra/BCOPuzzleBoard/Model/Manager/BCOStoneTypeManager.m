//
//  BCOStoneTypeManager.m
//  PazDra
//
//  Created by 阿部耕平 on 2013/12/20.
//  Copyright (c) 2013年 Kohei Abe. All rights reserved.
//

#import "BCOStoneTypeManager.h"

@implementation BCOStoneTypeManager {
    NSUInteger _numberOfRows;
    NSUInteger _numberOfColumns;
    BCOStoneType **_stoneTypes;
}

- (id)initWithNumberOfRows:(NSUInteger)numberOfRows
           numberOfColumns:(NSUInteger)numberOfColumns
{
    self = [super init];
    if (self) {
        _currentPosition    = BCOStonePositionUndefined;
        _numberOfRows       = numberOfRows;
        _numberOfColumns    = numberOfColumns;
        [self p_setupStoneTypes];
    }
    return self;
}

- (void)dealloc
{
    [self p_releaseStoneTypes];
}

// 指定したポジションにある石のタイプを返す。
// ポジションが範囲外か、もしくはまだ設置していない場所ならばBCOStoneTypeNoneを返す。
//      position    : 取得するポジション
- (BCOStoneType)stoneTypeAtPosition:(BCOStonePosition)position
{
    if (position.row < _numberOfRows && position.column < _numberOfColumns) {
        return _stoneTypes[position.row][position.column];
    }
    return BCOStoneTypeNone;
}

- (void)swapPosition:(BCOStonePosition)positionA withPosition:(BCOStonePosition)positionB
{
    BCOStoneType typeA = [self stoneTypeAtPosition:positionA];
    BCOStoneType typeB = [self stoneTypeAtPosition:positionB];
    [self p_setType:typeB atPosition:positionA];
    [self p_setType:typeA atPosition:positionB];
    
    if (BCOStonePositionEqualToPosition(positionA, _currentPosition)) {
        _currentPosition = positionB;
    }
    else if (BCOStonePositionEqualToPosition(positionB, _currentPosition)) {
        _currentPosition = positionA;
    }
}

- (NSArray *)vanishStonePositions
{
    NSMutableArray *vanishingPositionsCollection = @[].mutableCopy;
    [self enumeratePositionsUsingBlock:^(BCOStonePosition position) {
        // すでに消す石に追加されているかどうか判定
        BOOL isAlreadyAdded = NO;
        for (NSArray *vanishingPositions in vanishingPositionsCollection) {
            NSValue *positionVal = [NSValue valueWithBCOStonePosition:position];
            if ([vanishingPositions containsObject:positionVal]) {
                isAlreadyAdded = YES;
                break;
            }
        }
        if (isAlreadyAdded) return;
        
        // まだ消す石に入っていなければ、そこから同じ色で繋がっている石を全て取得
        NSArray *connectingPositions = [self p_connectingPositionsFromPositinon:position];
        if ([connectingPositions count] >= 3) {
            // 縦か横に３個以上繋がっているものだけを取得
            NSArray *vanishingPositions = [self p_vanishingPositionsInConnectingPositions:connectingPositions];
            if ([vanishingPositions count] > 0) {
                
                // 消す石を結果の配列に追加
                [vanishingPositionsCollection addObject:vanishingPositions];
                
                // データを更新（消す場所はBCOStoneTypeEmptyで埋める）
                [self p_setType:BCOStoneTypeEmpty atPositions:vanishingPositions];
            }
        }
    }];
    
    if ([vanishingPositionsCollection count] > 0) {
        return vanishingPositionsCollection.copy;
    }
    
    return nil;
}

- (void)setupNextStoneTypes;
{
    [self enumeratePositionsReverselyUsingBlock:^(BCOStonePosition position) {
        while (1) {
            if (![self p_fallStoneTypesToPosition:position]) break;
        }
    }];
}

#pragma mark - private

// ２次元配列を生成
- (void)p_allocateStoneTypes
{
    _stoneTypes = (BCOStoneType **)calloc(sizeof(BCOStoneType *), _numberOfRows);
    for (int i = 0; i < _numberOfRows; i++) {
        _stoneTypes[i] = (BCOStoneType *)calloc(sizeof(BCOStoneType), _numberOfColumns);
    }
}

// 2次元配列を廃棄
- (void)p_releaseStoneTypes
{
    for (int i = 0; i < _numberOfRows; i++) {
        free(_stoneTypes[i]);
    }
    free(_stoneTypes);
}

// 石をセットアップ。
- (void)p_setupStoneTypes
{
    [self p_allocateStoneTypes];
    [self enumeratePositionsUsingBlock:^(BCOStonePosition position) {
        BCOStoneType type = [self p_initialTypeAtPosition:position];
        _stoneTypes[position.row][position.column] = type;
    }];
}

// セットアップ用。
// positionで指定した場所にある石の属性を、石が3つ並ばないように決定して返す。
//      position    : 属性を決めるポジション
- (BCOStoneType)p_initialTypeAtPosition:(BCOStonePosition)position
{
    int ignoreOffset = (int) BCOStoneTypeNumberOfInvalidTypes;
    unsigned int numberOfColors = (unsigned int) BCOStoneTypeNumberOfColors;
    
    BCOStoneType type = (BCOStoneType)arc4random_uniform(numberOfColors) + ignoreOffset;
    
    BCOStoneType leftStoneTypes[2];
    BCOStoneType topStoneTypes[2];
    
    [self p_prevStoneTypes:leftStoneTypes
                atPosition:position
                 leftOrTop:0];
    [self p_prevStoneTypes:topStoneTypes
                atPosition:position
                 leftOrTop:1];
    
    BCOStoneType left = (leftStoneTypes[0] == leftStoneTypes[1]) ? leftStoneTypes[0] : BCOStoneTypeNone;
    BCOStoneType top  = (topStoneTypes[0] == topStoneTypes[1]) ? topStoneTypes[0] : BCOStoneTypeNone;
    
    // 左２つか上２つの石の色と同じなら、同じ色が3つ並ばないように調整
    if (type == left || type == top) {
        u_int32_t numberOfValidColors = numberOfColors;
        numberOfValidColors -= (left != BCOStoneTypeNone) + (top != BCOStoneTypeNone);
        
        BCOStoneType validTypes[numberOfColors];
        NSUInteger count = 0;
        for (int i = ignoreOffset; i < numberOfColors + ignoreOffset; i++) {
            // i はBCOStoneTypeとみなす。左2つか上2つが同じ色のとき
            // その色だけは含まないような配列validTypesを作る。
            if (i != left && i != top) {
                validTypes[count] = i;
                count++;
            }
        }
        
        // 配列typesの中からランダムに選ぶ
        int rand = (BCOStoneType)arc4random_uniform(numberOfValidColors);
        type = validTypes[rand];
    }
    return type;
}

// セットアップ用。
// positionで指定した場所にある石の左2つ/上2つの石を返す。
//      position     : 基点となるポジション
//      leftOrTop    : 左方向なら0、上方向なら1を渡す
- (void)p_prevStoneTypes:(BCOStoneType *)prevStoneTypes
              atPosition:(BCOStonePosition)position
               leftOrTop:(NSUInteger)leftOrTop
{
    for (int i = 0; i < 2; i++) {
        if (leftOrTop == 0) {
            position.column--;
        }
        else {
            position.row--;
        }
        
        BCOStoneType stoneType = [self stoneTypeAtPosition:position];
        prevStoneTypes[i] = stoneType;
    }
}

- (void)p_setType:(BCOStoneType)type atPosition:(BCOStonePosition)position
{
    _stoneTypes[position.row][position.column] = type;
}

- (void)p_setType:(BCOStoneType)type atPositions:(NSArray *)positions
{
    for (NSValue *positionValue in positions) {
        [self p_setType:type atPosition:positionValue.positionValue];
    }
}

// positionで指定した場所がBCOStoneTypeEmptyなら、
// その場所から上の石を全て下にずらし、一番上に新しいBCOStoneTypeを設定する。
- (BOOL)p_fallStoneTypesToPosition:(BCOStonePosition)position
{
    BCOStoneType fallPosition = [self stoneTypeAtPosition:position];
    if (fallPosition != BCOStoneTypeEmpty) return NO;
    
    // 上にある石をすべて１つ下にずらす
    for (int i = 0; i < position.row; i++) {
        BCOStonePosition checkPos = {position.row - i - 1, position.column};
        BCOStoneType type = [self stoneTypeAtPosition:checkPos];
        
        BCOStonePosition setPosition = {checkPos.row + 1, position.column};
        [self p_setType:type atPosition:setPosition];
    }
    
    // 新しいBCOStoneTypeを設定
    unsigned int numberOfColors = (unsigned int) BCOStoneTypeNumberOfColors;
    BCOStoneType newType = (BCOStoneType)arc4random_uniform(numberOfColors) + 1;
    BCOStonePosition newPosition = {0, position.column};
    [self p_setType:newType atPosition:newPosition];
    
    return YES;
}

#pragma mark - find connecting positions

// 指定したpositionから同じ色で繋がっているポジション配列を返す。
- (NSArray *)p_connectingPositionsFromPositinon:(BCOStonePosition)position
{
    NSArray *naborPositions =  [self p_naborPositionsWithSameColorAtPosition:position
                                                              exceptPosition:BCOStonePositionUndefined];
    
    NSMutableIndexSet *allIndexSet = [[NSMutableIndexSet alloc] init];
    for (int i = 0; i < [naborPositions count]; i++) {
        if ([allIndexSet containsIndex:i]) continue;
        
        NSValue *positionVal = naborPositions[i];
        NSMutableArray *subArray = naborPositions.mutableCopy;
        [subArray removeObject:positionVal];
        
        NSIndexSet *indexSet = [subArray indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            NSValue *checkPosVal = (NSValue *)obj;
            BCOStonePosition pos = [positionVal positionValue];
            BCOStonePosition checkPos = [checkPosVal positionValue];
            if (BCOStonePositionEqualToPosition(pos, checkPos)) {
                return YES;
            }
            return NO;
        }];
        
        if (indexSet) {
            [allIndexSet addIndexes:indexSet];
        }
    }
    
    NSMutableArray *connectingPositions = naborPositions.mutableCopy;
    [connectingPositions removeObjectsAtIndexes:allIndexSet];
    return connectingPositions.copy;
}

- (NSArray *)p_naborPositionsWithSameColorAtPosition:(BCOStonePosition)position
                                      exceptPosition:(BCOStonePosition)exceptPosition
{
    BCOStoneType centerType = [self stoneTypeAtPosition:position];
    if (centerType == BCOStoneTypeNone) return nil;
    
    NSMutableArray *resultArray = @[].mutableCopy;
    [resultArray addObject:[NSValue valueWithBCOStonePosition:position]];
    
    BCOStonePosition leftPosition   = {position.row, position.column - 1};
    BCOStonePosition rightPosition  = {position.row, position.column + 1};
    BCOStonePosition bottomPosition = {position.row + 1, position.column};
    NSArray *positions = @[[NSValue valueWithBCOStonePosition:leftPosition],
                           [NSValue valueWithBCOStonePosition:rightPosition],
                           [NSValue valueWithBCOStonePosition:bottomPosition]];
    
    for (NSValue *positionVal in positions) {
        BCOStonePosition checkPos = [positionVal positionValue];
        if (BCOStonePositionEqualToPosition(checkPos, exceptPosition)) continue;
        
        BCOStoneType type = [self stoneTypeAtPosition:checkPos];
        if (type == centerType) {
            NSArray *nextArray = [self p_naborPositionsWithSameColorAtPosition:checkPos
                                                                exceptPosition:position];
            [resultArray addObjectsFromArray:nextArray];
        }
    }
    
    return resultArray.copy;
}

#pragma mark - find vanish positions

// connectingPositionsの中から消すべき石だけを判定して返す。
- (NSArray *)p_vanishingPositionsInConnectingPositions:(NSArray *)connectingPositions
{
    NSMutableArray *resultPositions = @[].mutableCopy;
    
    for (NSValue *positionVal in connectingPositions) {
        BCOStonePosition position = [positionVal positionValue];
        if ([self p_shouldVanishStonePosition:position inConnectingPositions:connectingPositions]) {
            [resultPositions addObject:positionVal];
        }
    }
    return resultPositions.copy;
}

// 指定したpositionが消すべき石かどうかを判定する。
// connectingPositionsは同じ色で繋がっているBCOStonePositionの配列。
- (BOOL)p_shouldVanishStonePosition:(BCOStonePosition)position
              inConnectingPositions:(NSArray *)connectingPositions
{
    // connectingPositionsの中に無ければreturn
    if (![connectingPositions containsObject:[NSValue valueWithBCOStonePosition:position]]) {
        return NO;
    }
    
    // i=0の時に水平方向、i=1の時に垂直方向をチェック
    for (int i = 0; i < 2; i++) {
        BOOL isHorizontal = (i == 0) ? YES : NO;
        
        // 各方向3パターンずつチェック
        for (int j = 0; j < 3; j++) {
            BCOStonePosition edgePos = BCOStonePositionUndefined;
            if (isHorizontal) {
                // 水平方向は左端をedgePosにする
                edgePos = BCOStonePositionMake(position.row,
                                               position.column - 2 + j);
            }
            else {
                // 垂直方向は上端をedgePosにする
                edgePos = BCOStonePositionMake(position.row - 2 + j,
                                               position.column);
            }
            
            NSMutableArray *horizontalPositions = @[].mutableCopy;
            for (int k = 0; k < 3; k++) {
                BCOStonePosition checkPos = edgePos;
                if (isHorizontal) {
                    checkPos.column += k;
                }
                else {
                    checkPos.row += k;
                }
                [horizontalPositions addObject:[NSValue valueWithBCOStonePosition:checkPos]];
            }
            
            if ([self p_isSameColorsAtPositions:horizontalPositions
                          inConnectingPositions:connectingPositions]) {
                return YES;
            }
        }
    }
    return NO;
}

// positionsで指定した石がconnectingPositionsに含まれており、
// かつ全て同じ色かどうかを判定する。
- (BOOL)p_isSameColorsAtPositions:(NSArray *)positions
            inConnectingPositions:(NSArray *)connectingPositions
{
    if ([positions count] == 0) return NO;
    
    BCOStoneType type = BCOStoneTypeNone;
    for (NSValue *positionVal in positions) {
        if ([connectingPositions containsObject:positionVal]) {
            BCOStoneType typeBuf = [self stoneTypeAtPosition:positionVal.positionValue];
            if (type != BCOStoneTypeNone && type != typeBuf) {
                return NO;
            }
            type = typeBuf;
        }
        else {
            return NO;
        }
    }
    return YES;
}

@end


@implementation BCOStoneTypeManager (Enumeration)

- (void)enumeratePositionsUsingBlock:(void (^)(BCOStonePosition position))block
{
    for (int i = 0; i < _numberOfRows; i++) {
        for (int j = 0; j < _numberOfColumns; j++) {
            BCOStonePosition position = {i, j};
            block(position);
        }
    }
}

- (void)enumeratePositionsReverselyUsingBlock:(void (^)(BCOStonePosition position))block
{
    for (int i = 0; i < _numberOfRows; i++) {
        for (int j = 0; j < _numberOfColumns; j++) {
            BCOStonePosition position = {_numberOfRows - i - 1, _numberOfColumns - j - 1};
            block(position);
        }
    }
}

@end
