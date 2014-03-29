//
//  BCOStoneView.h
//  PazDra
//
//  Created by 阿部耕平 on 2013/12/08.
//  Copyright (c) 2013年 Kohei Abe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCOStoneTypeDefines.h"
#import "BCOStonePositionDefines.h"

@interface BCOStoneView : UIView <NSCopying>

@property (nonatomic) BCOStonePosition position;
@property (nonatomic, getter=isTransparent) BOOL transparent;
@property (nonatomic) BCOStoneType type;

- (id)initWithFrame:(CGRect)frame type:(BCOStoneType)type;

@end
