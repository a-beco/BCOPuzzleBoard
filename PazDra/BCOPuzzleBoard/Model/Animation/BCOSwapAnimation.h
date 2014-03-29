//
//  BCOSwapAnimation.h
//  PazDra
//
//  Created by 阿部耕平 on 2013/12/31.
//  Copyright (c) 2013年 Kohei Abe. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^BCOSwapAnimationCompletion)(void);

//======================================
// 石を入れ替えるアニメーションを実行するクラス
//======================================
@class BCOStoneView;
@interface BCOSwapAnimation : NSObject

// stoneViewAとstoneViewBを円軌道を描きながら入れ替える。
// -cancelAnimationを呼んだ時はcompletionは呼ばれない。
- (void)swapStoneA:(BCOStoneView *)stoneViewA
            stoneB:(BCOStoneView *)stoneViewB
          duration:(NSTimeInterval)duration
        completion:(BCOSwapAnimationCompletion)completion;

// -swapStoneA:stoneB:completion:をキャンセルする。
- (void)removeAnimations;

@end
