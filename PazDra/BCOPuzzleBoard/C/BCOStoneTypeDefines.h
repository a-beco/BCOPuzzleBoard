//
//  BCOStoneTypeDefines.h
//  PazDra
//
//  Created by 阿部耕平 on 2014/01/19.
//  Copyright (c) 2014年 Kohei Abe. All rights reserved.
//

#import <Foundation/Foundation.h>

//
// BCOStoneType
//

// BCOStoneTypeのうち、色でないもの。
// BCOStoneTypeNone と BCOStoneTypeEmpty
extern const NSUInteger BCOStoneTypeNumberOfInvalidTypes;

// BCOStoneTypeのうち、BCOStoneTypeNoneとBCOStoneTypeEmptyを抜いた数。
extern const NSUInteger BCOStoneTypeNumberOfColors;

typedef NS_ENUM(NSUInteger, BCOStoneType) {
    BCOStoneTypeNone    = 0,
    BCOStoneTypeEmpty   = 1,
    BCOStoneTypeRed     = 2,
    BCOStoneTypeBlue    = 3,
    BCOStoneTypeGreen   = 4,
    BCOStoneTypeShine   = 5,
    BCOStoneTypeDark    = 6,
    BCOStoneTypeHeal    = 7
};
