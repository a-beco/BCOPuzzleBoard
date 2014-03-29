//
//  BCOViewController.m
//  PazDra
//
//  Created by 阿部耕平 on 2013/12/08.
//  Copyright (c) 2013年 Kohei Abe. All rights reserved.
//

#import "BCOViewController.h"
#import "BCOPuzzleBoard.h"

const int kBCONumberOfRows          = 5;
const int kBCONumberOfColumns       = 6;

// extension
@interface BCOViewController () <BCOPuzzleBoardDelegate>
@property (weak, nonatomic) IBOutlet UILabel *comboLabel;
@property (weak, nonatomic) IBOutlet BCOPuzzleBoard *puzzleBoard;
@end

// implementation
@implementation BCOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // パズルをセットアップ
    [_puzzleBoard setupBoardWithNumberOfRows:kBCONumberOfRows
                             numberOfColumns:kBCONumberOfColumns];
    [_puzzleBoard sizeToFit];
    _puzzleBoard.delegate = self;
    
    // 親ビューの下端に合わせる
    CGFloat yOffset = CGRectGetHeight(_puzzleBoard.superview.frame) - CGRectGetMaxY(_puzzleBoard.frame);
    _puzzleBoard.frame = CGRectOffset(_puzzleBoard.frame, 0, yOffset);
}

#pragma mark - BCOPuzzleBoard delegate

- (void)puzzleBoard:(BCOPuzzleBoard *)puzzleBoard didEndVanishWithStoneInfo:(BCOVanishedStoneInfo *)stoneInfo
{
    NSLog(@"type:%lu, %lu", (unsigned long)stoneInfo.type, (unsigned long)stoneInfo.numberOfStones);
}

- (void)puzzleBoard:(BCOPuzzleBoard *)puzzleBoard didEndTurnWithStoneInfos:(NSArray *)stoneInfos
{
    NSUInteger combo = stoneInfos.count;
    _comboLabel.text = [NSString stringWithFormat:@"コンボ数: %lu", (unsigned long)combo];
    [puzzleBoard startNextTurn];
}

@end
