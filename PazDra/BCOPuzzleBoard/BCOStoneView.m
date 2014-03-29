//
//  BCOStoneView.m
//  PazDra
//
//  Created by 阿部耕平 on 2013/12/08.
//  Copyright (c) 2013年 Kohei Abe. All rights reserved.
//

#import "BCOStoneView.h"

@implementation BCOStoneView {
    UIImageView *_imageView;
}

- (id)initWithFrame:(CGRect)frame type:(BCOStoneType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        _type = type;
        
        UIImage *image = [self p_imageWithType:type];
        _imageView = [[UIImageView alloc] initWithImage:image];
        _imageView.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    BCOStoneView *cloneView = [[BCOStoneView allocWithZone:zone] initWithFrame:self.frame
                                                                          type:_type];
    cloneView.position = _position;
    cloneView.transparent = _transparent;
    
    return cloneView;
}

- (BOOL)isEqual:(id)object
{
    if (!object) return NO;
    
    BCOStoneView *stoneView = (BCOStoneView *)object;
    return BCOStonePositionEqualToPosition(stoneView.position, self.position);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self addSubview:_imageView];
}

#pragma mark - property

- (void)setTransparent:(BOOL)transparent
{
    _transparent = transparent;
    
    self.alpha = (_transparent) ? 0.5 : 1.0;
}

- (void)setType:(BCOStoneType)type
{
    _type = type;
    
    UIImage *image = [self p_imageWithType:_type];
    _imageView.image = image;
}

#pragma mark - private

- (UIImage *)p_imageWithType:(BCOStoneType)type
{
    UIImage *image = nil;
    switch (type) {
        case BCOStoneTypeRed:
            image = [UIImage imageNamed:@"stone_red"];
            break;
        case BCOStoneTypeBlue:
            image = [UIImage imageNamed:@"stone_blue"];
            break;
        case BCOStoneTypeGreen:
            image = [UIImage imageNamed:@"stone_green"];
            break;
        case BCOStoneTypeShine:
            image = [UIImage imageNamed:@"stone_yellow"];
            break;
        case BCOStoneTypeDark:
            image = [UIImage imageNamed:@"stone_purple"];
            break;
        case BCOStoneTypeHeal:
            image = [UIImage imageNamed:@"stone_pink"];
            break;
        default:
            image = nil;
            break;
    }
    return image;
}

@end
