//
//  BCOPuzzleBoard.h
//  PazDra
//
//  Created by 阿部耕平 on 2013/12/08.
//  Copyright (c) 2013年 Kohei Abe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCOStoneTypeDefines.h"

typedef NS_ENUM(NSUInteger, BCOPuzzleBoardState) {
    BCOPuzzleBoardStateNone,            // 初期状態
    BCOPuzzleBoardStateWaiting,         // タッチ待ち状態
    BCOPuzzleBoardStateTouching,        // タッチ中
    BCOPuzzleBoardStateVanishing,       // 石を削除するアニメーション中
    BCOPuzzleBoardStateFalling,         // 落ちるアニメーション中
    BCOPuzzleBoardStateEndTurn,         // ターン終了
};

//===============================
// メインのパズル盤
//===============================
@protocol BCOPuzzleBoardDelegate;
@interface BCOPuzzleBoard : UIView

@property (nonatomic, weak) id<BCOPuzzleBoardDelegate> delegate;

@property (nonatomic, readonly) BCOPuzzleBoardState state;

// 石を動かす時に制限時間をつけるかどうか
@property (nonatomic, getter = isEnableTouchTimer) BOOL enableTouchTimer; // default is YES

// 石を動かせる制限時間。enableTouchTimer=YESでなければ無視される。
@property (nonatomic) NSTimeInterval touchTimeLimitSec;     // default is 4.0

// 石を動かせる制限時間が何秒以下になった時にタイマーを出すか。
@property (nonatomic) NSTimeInterval timerGaugeIsShownSec;  // default is 2.0

// ゲームをスタートする。
// 現在のframeのwidthをもとに石のサイズが決定される。
// 高さも石の領域に合わせたければsizeToFitを呼ぶ。
- (void)setupBoardWithNumberOfRows:(NSUInteger)numberOfRows
                   numberOfColumns:(NSUInteger)numberOfColumns;

// 次のターンを始める。
// stateがBCOPuzzleBoardStateEndTurnになったら明示的に呼ばないと
// 次のターンが始まらない。
- (void)startNextTurn;

@end

// delegate
@class BCOVanishedStoneInfo;
@protocol BCOPuzzleBoardDelegate <NSObject>

// 石が消える度に呼ばれる。
// 引数のstoneInfoはBCOVanishedStoneInfo。
- (void)puzzleBoard:(BCOPuzzleBoard *)puzzleBoard didEndVanishWithStoneInfo:(BCOVanishedStoneInfo *)stoneInfo;

// １回のターンで石が消え終わった後に呼ばれる。
// 引数のstoneInfosはBCOVanishedStoneInfoのNSArray。
- (void)puzzleBoard:(BCOPuzzleBoard *)puzzleBoard didEndTurnWithStoneInfos:(NSArray *)stoneInfos;

@end


//===============================
// 消した石の情報 (deleagteで渡される)
//===============================
@interface BCOVanishedStoneInfo : NSObject

@property (nonatomic, readonly) BCOStoneType type;
@property (nonatomic, readonly) NSUInteger numberOfStones;

@end

