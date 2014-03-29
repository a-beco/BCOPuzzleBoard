//
//  BCOPuzzleBoard.m
//  PazDra
//
//  Created by 阿部耕平 on 2013/12/08.
//  Copyright (c) 2013年 Kohei Abe. All rights reserved.
//

#import "BCOPuzzleBoard.h"
#import "BCOStoneTypeManager.h"
#import "BCOStoneFrameManager.h"
#import "BCOStoneView.h"
#import "BCOEventQueue.h"
#import "BCOSwapStoneEvent.h"
#import "BCOVanishStoneEvent.h"
#import "BCOStoneCollisionChecker.h"
#import "BCOSwapAnimation.h"
#import "BCOVanishAnimation.h"
#import "BCOCollisionUtils.h"
#import "BCOStonePositionDefines.h"
#import "BCOTimer.h"
#import "BCOTimerGauge.h"


// animation duration constants
static const NSTimeInterval kSwapDuration           = 0.1;  // 石を入れ替える時間
static const NSTimeInterval kMoveDuration           = 0.1;  // タッチ中の石が指の位置に移動するまでの時間
static const NSTimeInterval kVanishDuration         = 0.3;  // 石が消えるのにかかる時間
static const NSTimeInterval kFallDuration           = 0.4;  // 石が落ちるのにかかる時間
static const NSTimeInterval kTransparentDuration    = 0.3;  // ターン終了時に石が半透明になるのにかかる時間


//===============================
// 消した石の情報
//===============================

@interface BCOVanishedStoneInfo ()

@property (nonatomic, readwrite) BCOStoneType type;
@property (nonatomic, readwrite) NSUInteger numberOfStones;

@end

@implementation BCOVanishedStoneInfo
@end


//===============================
// メインのパズル盤
//===============================

@interface BCOPuzzleBoard () <BCOStoneCollisionCheckerDelegate, BCOTimerDelegate>

@property (strong, nonatomic) BCOStoneView *movingStoneView;        // 指についてくるBCOStoneView
@property (strong, nonatomic) BCOTimerGauge *timerGauge;            // 残りのタッチ可能時間のゲージ
@property (strong, nonatomic) NSMutableArray *stoneViews;           // 配置されている石のArray
@property (strong, nonatomic) NSMutableArray *vanishedStoneInfos;   // 消した石のArray(delegateで渡す用)

@property (strong, nonatomic) BCOSwapAnimation *swapAnimation;
@property (strong, nonatomic) BCOVanishAnimation *vanishAnimation;

@property (strong, nonatomic) BCOStoneTypeManager *typeManager;
@property (strong, nonatomic) BCOStoneFrameManager *frameManager;
@property (strong, nonatomic) BCOStoneCollisionChecker *collisionChecker;

// animation queue
@property (strong, nonatomic) BCOEventQueue *swapAnimationQueue;
@property (strong, nonatomic) BCOEventQueue *vanishAnimationQueue;

@property (strong, nonatomic) BCOTimer *timer;

@property (nonatomic) BCOPuzzleBoardState state;
@property (nonatomic, getter = isAnimating) BOOL animating;

@end


// BCOPuzzleBoard
@implementation BCOPuzzleBoard {
    NSUInteger _numberOfRows, _numberOfColumns;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
        self.backgroundColor = [UIColor colorWithRed:89 / 255.0
                                               green:70 / 255.0
                                                blue:56 / 255.0
                                               alpha:1.0];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    // touch timer deafult
    _enableTouchTimer       = YES;
    _touchTimeLimitSec      = 4.0;
    _timerGaugeIsShownSec   = 2.0;
    
    // animation queues
    _swapAnimationQueue     = [[BCOEventQueue alloc] init];
    _vanishAnimationQueue   = [[BCOEventQueue alloc] init];
    
    // delegateで渡すデータを作る
    _vanishedStoneInfos = @[].mutableCopy;
    
    self.state = BCOPuzzleBoardStateWaiting;
    self.exclusiveTouch = YES;
}

- (void)dealloc
{
    [_timer destroy];
}

#pragma mark - property

- (void)setState:(BCOPuzzleBoardState)state
{
    switch (state) {
        case BCOPuzzleBoardStateNone:
            break;
        case BCOPuzzleBoardStateWaiting:
            self.userInteractionEnabled = YES;
            break;
        case BCOPuzzleBoardStateTouching:
            break;
        case BCOPuzzleBoardStateVanishing:
            self.userInteractionEnabled = NO;
            break;
        case BCOPuzzleBoardStateFalling:
            break;
        case BCOPuzzleBoardStateEndTurn:
            break;
        default:
            break;
    }
}

#pragma mark - UIView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.state = BCOPuzzleBoardStateTouching;
    
    CGPoint beginPoint = [[touches anyObject] locationInView:self];
    
    // 移動させる石を生成
    self.movingStoneView = [self p_createMovingStoneViewWithTouchedPoint:beginPoint];
    if (!_movingStoneView) return;
    [self addSubview:_movingStoneView];
    
    [UIView animateWithDuration:kMoveDuration animations:^{
        _movingStoneView.center = beginPoint;
    }];
    
    // 現在の石の位置をセット
    _typeManager.currentPosition = _movingStoneView.position;
    [self p_reloadStoneViews];
    
    // 衝突判定
    [_collisionChecker beginTouchingWithPoint:beginPoint];
    
    // タイマーゲージ
    CGRect timerGaugeFrame = CGRectMake(0, 0, 45, 12);
    self.timerGauge = [[BCOTimerGauge alloc] initWithFrame:timerGaugeFrame];
    _timerGauge.center = CGPointMake(_movingStoneView.frame.size.width / 2, -30);
    _timerGauge.value = 1.0;
    _timerGauge.hidden = YES;
    [_movingStoneView addSubview:_timerGauge];
    
    // タイマー
    self.timer = [[BCOTimer alloc] initWithDelegate:self];
    [_timer startTimerWithInterval:0.01 runForTime:4.0];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_movingStoneView) return;
    
    CGPoint movedPoint = [[touches anyObject] locationInView:self];
    
    // 石を移動
    [UIView animateWithDuration:kMoveDuration animations:^{
        _movingStoneView.center = movedPoint;
    }];
    
    // 衝突判定
    [_collisionChecker addTouchPoint:movedPoint];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_timer destroy];
    self.timer = nil;
    
    if (!_movingStoneView) return;
    
    // 移動する石を消去
    [self p_removeMovingStoneView];
    _typeManager.currentPosition = BCOStonePositionUndefined;
    [self p_reloadStoneViews];
    self.timerGauge = nil;
    
    // 衝突判定
    CGPoint endPoint = [[touches anyObject] locationInView:self];
    [_collisionChecker addTouchPoint:endPoint];
    
    // 石を消す
    [self p_vanishStonesAnimated:YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_timer destroy];
    self.timer = nil;
    
    if (!_movingStoneView) return;
    
    CGPoint cancelPoint = [[touches anyObject] locationInView:self];
    [_collisionChecker addTouchPoint:cancelPoint];
    
    // 移動する石を消去
    [self p_removeMovingStoneView];
    _typeManager.currentPosition = BCOStonePositionUndefined;
    [self p_reloadStoneViews];
    self.timerGauge = nil;
    
    // 石をアニメーション無しで消す
    [self p_vanishStonesAnimated:NO];
}

#pragma mark - public

- (void)setupBoardWithNumberOfRows:(NSUInteger)numberOfRows
                   numberOfColumns:(NSUInteger)numberOfColumns
{
    [self p_removeMovingStoneView];
    
    _numberOfRows       = numberOfRows;
    _numberOfColumns    = numberOfColumns;
    
    _typeManager = [[BCOStoneTypeManager alloc] initWithNumberOfRows:numberOfRows
                                                             numberOfColumns:numberOfColumns];
    
    _frameManager = [[BCOStoneFrameManager alloc] initWithNumberOfRows:numberOfRows
                                                       numberOfColumns:numberOfColumns
                                                            boardFrame:self.frame];
    
    _collisionChecker = [[BCOStoneCollisionChecker alloc] initWithTypeManager:_typeManager
                                                                 frameManager:_frameManager];
    _collisionChecker.delegate = self;
    
    // 石を生成
    [self p_setupStoneView];
}

- (void)startNextTurn
{
    if (_state != BCOPuzzleBoardStateNone
        && _state != BCOPuzzleBoardStateEndTurn) {
        return;
    }
    
    self.vanishedStoneInfos = @[].mutableCopy;
    
    // 半透明を解除(アニメーション有)
    __weak BCOPuzzleBoard *weakSelf = self;
    [self p_setAllStoneViewsTransparent:NO animated:YES completion:^{
        
        // タッチ待ち状態に変更
        weakSelf.state = BCOPuzzleBoardStateWaiting;
    }];
}

// setupBoardWithNumberOfRows:numberOfColumns:が呼ばれた後であれば
// 石の領域を返す。
- (CGSize)sizeThatFits:(CGSize)size
{
    if (_frameManager) {
        return _frameManager.fitBoardFrame.size;
    }
    return CGSizeZero;
}

// setupBoardWithNumberOfRows:numberOfColumns:が呼ばれた後であれば
// 石の領域に合わせてリサイズする。
// setupが終わっていなければ何もしない。
- (void)sizeToFit
{
    if (_frameManager) {
        self.frame = _frameManager.fitBoardFrame;
    }
}

#pragma mark - private

// 指定したポジションにある石ビューを返す。
// ポジションが範囲外か、もしくはまだ設置していない場所ならばnilを返す。
- (BCOStoneView *)p_stoneViewAtPosition:(BCOStonePosition)position
{
    if ((position.row < _numberOfRows) && (position.column < _numberOfColumns)) {
        NSUInteger index = (position.row * _numberOfColumns) + position.column;
        if (_stoneViews.count > index) {
            return _stoneViews[index];
        }
    }
    return nil;
}

- (BCOStoneView *)p_currentStoneView
{
    return [self p_stoneViewAtPosition:_typeManager.currentPosition];
}

// 石をセットアップ。
- (void)p_setupStoneView
{
    if (_stoneViews) {
        for (BCOStoneView *stoneView in _stoneViews) {
            [stoneView removeFromSuperview];
        }
    }
    _stoneViews = @[].mutableCopy;
    
    [_typeManager  enumeratePositionsUsingBlock:^(BCOStonePosition position) {
        CGRect frame = [_frameManager stoneViewFrameAtPosition:position];
        BCOStoneView *stoneView = [[BCOStoneView alloc] initWithFrame:frame
                                                                 type:BCOStoneTypeNone];
        stoneView.position = position;
        
        [self addSubview:stoneView];
        [_stoneViews addObject:stoneView];
    }];
    [self p_reloadStoneViews];
}

- (void)p_swapStoneViewsAtPosition:(BCOStonePosition)positionA
                         positionB:(BCOStonePosition)positionB
{
    NSUInteger indexA = positionA.row * _numberOfColumns + positionA.column;
    BCOStoneView *stoneViewA = nil;
    if ([_stoneViews count] > indexA) {
        stoneViewA = _stoneViews[indexA];
    }
    if (!stoneViewA) return;
    
    NSUInteger indexB = positionB.row * _numberOfColumns + positionB.column;
    BCOStoneView *stoneViewB = nil;
    if ([_stoneViews count] > indexB) {
        stoneViewB = _stoneViews[indexB];
    }
    if (!stoneViewB) return;
    
    if (![stoneViewA isKindOfClass:[BCOStoneView class]]
        || ![stoneViewB isKindOfClass:[BCOStoneView class]]) {
        return;
    }
    
    stoneViewA.position = positionB;
    stoneViewB.position = positionA;
    
    [_stoneViews replaceObjectAtIndex:indexA withObject:stoneViewB];
    [_stoneViews replaceObjectAtIndex:indexB withObject:stoneViewA];
}

// タッチした時に指についてくるビューを作る。
// pointの位置にあるビューを複製して返す。
- (BCOStoneView *)p_createMovingStoneViewWithTouchedPoint:(CGPoint)point
{
    [self p_removeMovingStoneView];
    
    for (BCOStoneView *stoneView in _stoneViews) {
        if (CGRectContainsPoint(stoneView.frame, point)) {
            BCOStoneView *movingStoneView = [stoneView copy];
            movingStoneView.center = stoneView.center;
            return movingStoneView;
        }
    }
    return nil;
}

// 指についてくるビューを削除する
- (void)p_removeMovingStoneView
{
    if (_movingStoneView) {
        [_movingStoneView removeFromSuperview];
        self.movingStoneView = nil;
    }
}

// transparentをYESにすると、全ての石を半透明にする
- (void)p_setAllStoneViewsTransparent:(BOOL)transparent
                             animated:(BOOL)animated
                           completion:(void(^)(void))completion
{
    __block int count = 0;
    [_typeManager  enumeratePositionsUsingBlock:^(BCOStonePosition position) {
        
        BCOStoneView *stoneView = [self p_stoneViewAtPosition:position];
        if (animated) {
            [UIView animateWithDuration:kTransparentDuration animations:^{
                
                stoneView.transparent = transparent;
                
            } completion:^(BOOL finished) {
                
                count++;
                BOOL allAnimationsFinished = (count == _numberOfRows * _numberOfColumns);
                if (allAnimationsFinished) {
                    completion();
                }
            }];
        }
        else {
            stoneView.transparent = transparent;
            
            count++;
            BOOL allAnimationsFinished = (count == _numberOfRows * _numberOfColumns);
            if (allAnimationsFinished) {
                completion();
            }
        }
    }];
}

// delegateで渡すために消した石の情報をBCOVanishedStoneInfoとして保存しておく
- (BCOVanishedStoneInfo *)p_vanishedStoneInfoWithPositions:(NSArray *)positions
{
    BCOStonePosition position = [positions[0] positionValue];
    BCOStoneView *stoneView = [self p_stoneViewAtPosition:position];
    BCOVanishedStoneInfo *vanishedStoneInfo = [[BCOVanishedStoneInfo alloc] init];
    vanishedStoneInfo.type             = stoneView.type;
    vanishedStoneInfo.numberOfStones   = [positions count];
    return vanishedStoneInfo;
}

// 現在のポジションデータから消える対象を判定して消し、
// アニメーションキューにイベントを入れる。
- (void)p_vanishStonesAnimated:(BOOL)animated
{
    NSArray *vanishingPositionsCollection = [_typeManager vanishStonePositions];
    if (vanishingPositionsCollection) {
        [_typeManager setupNextStoneTypes];
        if (animated) {
            for (NSArray *vanishingPositions in vanishingPositionsCollection) {
                
                // 結果としてdelegateに渡す用のデータを作る
                BCOVanishedStoneInfo *vanishedStoneInfo = [self p_vanishedStoneInfoWithPositions:vanishingPositions];
                [_vanishedStoneInfos addObject:vanishedStoneInfo];
                
                // アニメーション用のイベントを作ってキューに入れる
                BCOVanishStoneEvent *event = [BCOVanishStoneEvent vanishStoneEventWithPositions:vanishingPositions];
                [_vanishAnimationQueue enqueueEvent:event];
            }
            [self p_startVanishingAnimation];
        }
        else {
            [self p_reloadStoneViews];
            [self p_vanishStonesAnimated:NO];
        }
    }
    else {
        // 最後まで消し終わったら終了する
        [self p_endTurn];
    }
}

- (void)p_endTurn
{
    self.animating = NO;
    [self p_reloadStoneViews];
    
    __weak BCOPuzzleBoard *weakSelf = self;
    [self p_setAllStoneViewsTransparent:YES animated:YES completion:^{
        weakSelf.state = BCOPuzzleBoardStateEndTurn;
        if ([_delegate respondsToSelector:@selector(puzzleBoard:didEndTurnWithStoneInfos:)]) {
            [_delegate puzzleBoard:self didEndTurnWithStoneInfos:_vanishedStoneInfos.copy];
        }
    }];
}

#pragma mark - private reload

// アニメーションをキャンセルし、現在のpositionManagerの情報に従って
// 石の位置と色を並べ替えます。
- (void)p_reloadStoneViews
{
    if (self.isAnimating) {
        [self p_cancelSwapAnimation];
    }
    
    // 色・透明度を更新
    [_typeManager  enumeratePositionsUsingBlock:^(BCOStonePosition position) {
        BCOStoneView *stoneView = [self p_stoneViewAtPosition:position];
        
        // 色を更新
        BCOStoneType type = [_typeManager stoneTypeAtPosition:position];
        stoneView.type  = type;
        
        // 現在移動中ならその石のみ半透明にを変更
        BCOStonePosition currentPosition = _typeManager.currentPosition;
        BOOL isCurrentPosition = (BCOStonePositionEqualToPosition(stoneView.position, currentPosition));
        stoneView.transparent = (isCurrentPosition) ? YES : NO;
    }];
    
    // 場所を更新
    [self p_reloadStoneViewFrames];
}

- (void)p_reloadStoneViewFrames
{
    [_typeManager  enumeratePositionsUsingBlock:^(BCOStonePosition position) {
        BCOStoneView *stoneView = [self p_stoneViewAtPosition:position];
        stoneView.frame = [_frameManager stoneViewFrameAtPosition:position];;
    }];
}

#pragma mark - swap animation

// アニメーションキューを順々にdequeueして石のスワップを開始する。
// queueの中身のイベント（BCOSwapStoneEvent）がなくなるか、
// p_cancelSwapAnimationでキャンセルされるまでアニメーションは続く。
- (void)p_startSwapAnimation
{
    if (!self.isAnimating) {
        self.animating = YES;
        [self p_executeNextSwapAnimation];
    }
}

// アニメーションキューの中身を１つdequeueして実行し、
// アニメーションが完了したら再起的にp_executeNextSwapAnimationを呼び、
// queueが無くなるまで繰り返し実行する。
- (void)p_executeNextSwapAnimation
{
    BCOSwapStoneEvent *swapEvent = [_swapAnimationQueue dequeueEvent];
    if (!swapEvent) {
        [self p_reloadStoneViews];
        self.animating = NO;
        return;
    }
    
    BCOStoneView *stoneViewA = [self p_stoneViewAtPosition:swapEvent.positionA];
    BCOStoneView *stoneViewB = [self p_stoneViewAtPosition:swapEvent.positionB];
    
    if (_movingStoneView) {
        [self insertSubview:stoneViewA belowSubview:_movingStoneView];
        [self insertSubview:stoneViewB belowSubview:_movingStoneView];
    }
    else {
        [self bringSubviewToFront:stoneViewA];
        [self bringSubviewToFront:stoneViewB];
    }
    
    self.swapAnimation = [[BCOSwapAnimation alloc] init];
    __weak BCOPuzzleBoard *weakSelf = self;
    [_swapAnimation swapStoneA:stoneViewA
                        stoneB:stoneViewB
                      duration:kSwapDuration
                    completion:^() {
                        // 石の位置を更新
                        [weakSelf p_swapStoneViewsAtPosition:stoneViewA.position
                                                   positionB:stoneViewB.position];
                        [weakSelf p_reloadStoneViewFrames];
                        
                        // アニメーションが点滅しないようにremovedOnCompletionはNOにしてあるため、
                        // 明示的にここでremoveする必要あり。
                        [_swapAnimation removeAnimations];
                        
                        // 次のアニメーションを実行
                        [weakSelf p_executeNextSwapAnimation];
                    }];
}

// アニメーションをキャンセルする。石の位置がおかしくなるので単体では呼ばず、
// 基本的にはp_stopSwapAnimationを呼ぶ。
// もし単体で呼ぶ時はキャンセル後にp_reloadStoneViewを呼ぶのを推奨。
- (void)p_cancelSwapAnimation
{
    [_swapAnimationQueue clearAllEvents];
    [_swapAnimation removeAnimations];
    self.swapAnimation = nil;
    self.animating = NO;
}

// アニメーションを終了させる
- (void)p_stopSwapAnimation
{
    if (self.isAnimating) {
        [self p_cancelSwapAnimation];
        [self p_reloadStoneViews];
    }
}

#pragma mark - vanish animation

- (void)p_startVanishingAnimation
{
    self.animating = YES;
    self.state = BCOPuzzleBoardStateVanishing;
    [self p_cancelSwapAnimation];
    [self p_executeNextVanishingAnimation];
}

- (void)p_executeNextVanishingAnimation
{
    BCOVanishStoneEvent *vanishEvent = [_vanishAnimationQueue dequeueEvent];
    if (!vanishEvent) {
        [self p_startFallAnimation];
        return;
    }
    
    NSArray *vanishingPositions = vanishEvent.vanishingPositions;
    
    // delegateで消した通知
    BCOVanishedStoneInfo *vanishedStoneInfo = [self p_vanishedStoneInfoWithPositions:vanishingPositions];
    if ([_delegate respondsToSelector:@selector(puzzleBoard:didEndVanishWithStoneInfo:)]) {
        [_delegate puzzleBoard:self didEndVanishWithStoneInfo:vanishedStoneInfo];
    }
    
    NSMutableArray *vanishingStones = @[].mutableCopy;
    for (NSValue *positionValue in vanishingPositions) {
        BCOStonePosition position = positionValue.positionValue;
        [vanishingStones addObject:[self p_stoneViewAtPosition:position]];
    }
    
    self.vanishAnimation = [[BCOVanishAnimation alloc] init];
    [_vanishAnimation vanishStoneViews:vanishingStones.copy
                              duration:kVanishDuration
                            completion:^{
                                [self p_executeNextVanishingAnimation];
                            }];
}
         
#pragma mark - fall animation

// 消えた石を一番上に持っていく
- (void)p_bringEmptyStonesToTop
{
    // 一番上から二番目の石
    BCOStonePosition secondPosition = {1, 0};
    BCOStoneView *secondStoneView = [self p_stoneViewAtPosition:secondPosition];
    CGFloat secondY = CGRectGetMinY(secondStoneView.frame);
    
    [_typeManager enumeratePositionsReverselyUsingBlock:^(BCOStonePosition position) {
        while (1) {
            BCOStoneView *stoneView = [self p_stoneViewAtPosition:position];
            if (stoneView.alpha != 0.0) break;
            
            // バブルソートの要領で消えた石のpositionを一番上に移動させる
            // この時点では移動はさせていない。
            BCOStonePosition positionA, positionB;
            positionA = position;
            for (int i = 0; i < position.row; i++) {
                positionB = position;
                positionB.row -= i + 1;
                [self p_swapStoneViewsAtPosition:positionA
                                       positionB:positionB];
                positionA = positionB;
            }
            
            // 消えた石をフレームの外に移動
            BCOStonePosition secondPos = {1, position.column};
            BCOStoneView *secondStoneView = [self p_stoneViewAtPosition:secondPos];
            CGRect frame = secondStoneView.frame;
            if (CGRectGetMinY(frame) == secondY) {    // ボード上の1番上の石の場合はさらにその1マス上に移動
                frame = stoneView.frame;
            }
            frame = CGRectOffset(frame, 0, -CGRectGetHeight(frame));
            
            stoneView.frame = frame;
            stoneView.alpha = 1.0;
        }
    }];
}

- (void)p_startFallAnimation
{
    self.state = BCOPuzzleBoardStateFalling;
    
    // 消えた石を一番上に持っていく
    [self p_bringEmptyStonesToTop];
    
    // アニメーションを実行
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kFallDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [self p_reloadStoneViews];
    [UIView commitAnimations];
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    self.animating = NO;
    [self p_vanishStonesAnimated:YES];
}

#pragma mark - collide checker delegate

- (void)stoneCollisionChecker:(BCOStoneCollisionChecker *)stoneCollisionChecker
      didCollideWithPositions:(NSArray *)collidedPositionsSorted
{
    // 衝突が来たら前のアニメーションは止める。
    [self p_stopSwapAnimation];
    
    BCOStonePosition currentStonePosition = [self p_currentStoneView].position;
    for (NSValue *positionValue in collidedPositionsSorted) {
        
        BCOStonePosition collidedPosition = positionValue.positionValue;
        
        // ポジションデータを更新
        [_typeManager swapPosition:currentStonePosition
                          withPosition:collidedPosition];
        
        // アニメーションキューに追加
        BCOSwapStoneEvent *event = [BCOSwapStoneEvent swapStoneEventWithPositionA:currentStonePosition
                                                                        positionB:collidedPosition];
        [_swapAnimationQueue enqueueEvent:event];
        
        currentStonePosition = collidedPosition;
    }
    
    [self p_startSwapAnimation];
}

#pragma mark - timer delegate

- (void)timerDidFired:(BCOTimer *)timer count:(NSUInteger)count progressTime:(NSTimeInterval)progressTime
{
    if (progressTime >= _timerGaugeIsShownSec) {
        _timerGauge.hidden = NO;
    }
    
    // タイマーゲージを赤〜黄色の範囲で単振動させる
    double anglarVelocity = 2 * M_PI;
    double cosValue = cos((double)progressTime * anglarVelocity);
    CGFloat greenValue = (cosValue + 1) / 2; // 0 ~ 1 に正規化
    _timerGauge.gaugeColor = [UIColor colorWithRed:1.0 green:greenValue blue:0.0 alpha:1.0];
    
    _timerGauge.value = (_touchTimeLimitSec - progressTime) / _timerGaugeIsShownSec;
}

- (void)timerDidEnd:(BCOTimer *)timer
{
    [self p_stopSwapAnimation];
    
    // 移動する石を消去
    [self p_removeMovingStoneView];
    _typeManager.currentPosition = BCOStonePositionUndefined;
    [self p_reloadStoneViews];
    self.timerGauge = nil;
    
    // 石を消す
    [self p_vanishStonesAnimated:YES];
}

@end


