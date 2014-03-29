//
//  BCOCollisionUtils.m
//  PazDra
//
//  Created by 阿部耕平 on 2013/12/20.
//  Copyright (c) 2013年 Kohei Abe. All rights reserved.
//

#import "BCOCollisionUtils.h"

typedef NS_ENUM(NSUInteger, BCOComparisonResult) {
    kBCOComparisonResultAbove,
    kBCOComparisonResultBelow,
    kBCOComparisonResultEqual,
};

#pragma mark - private

static BOOL isLineOutOfBounds(BCOLine line, CGRect rect)
{
    // 線の始点・終点のどちらも矩形の左にあるとき
    BOOL isLineLeftOfRect = (CGRectGetMinX(rect) > line.start.x
                             && CGRectGetMinX(rect) > line.end.x);
    if (isLineLeftOfRect) return YES;
    
    // 右にあるとき
    BOOL isLineRightOfRect = (CGRectGetMaxX(rect) < line.start.x
                              && CGRectGetMaxX(rect) < line.end.x);
    if (isLineRightOfRect) return YES;
    
    // 上にあるとき
    BOOL isLineAboveOfRect = (CGRectGetMinY(rect) > line.start.y
                              && CGRectGetMinY(rect) > line.end.y);
    if (isLineAboveOfRect) return YES;
    
    // 下にあるとき
    BOOL isLineBelowOfRect = (CGRectGetMaxY(rect) < line.start.y
                              && CGRectGetMaxY(rect) < line.end.y);
    if (isLineBelowOfRect) return YES;
    
    return NO;
}

// lineを ax+b の形にして、pointが線よりiPhone座標系で上か下か判定する。
// 縦に並んでいた場合は左側をAbove、右側をBelowとする。
static BCOComparisonResult comparePointAndLine(CGPoint point, BCOLine line)
{
    // 傾きを算出
    double a = 0;
    double dx = line.end.x - line.start.x;
    double dy = line.end.y - line.start.y;
    
    if (dx != 0) {
        a = dy / dx;
        
        // pointをlineの始点を原点とする座標系に変換
        // (そのままでやるとy切片が大きくなりすぎる可能性などを考慮して。いらぬ心配かも。)
        CGPoint convertedPoint = CGPointMake(point.x - line.start.x,
                                             point.y - line.start.y);
        
        // 上か下か判定
        double y = 0;
        if (dy != 0) {
            y = a * convertedPoint.x;
        }
        
        if (convertedPoint.y < y) {
            return kBCOComparisonResultAbove;
        }
        else if (convertedPoint.y == y) {
            return kBCOComparisonResultEqual;
        }
        
        return kBCOComparisonResultBelow;
    }
    else {
        if (point.x < line.start.x) {
            return kBCOComparisonResultAbove;
        }
        else if (point.x == line.start.x) {
            return kBCOComparisonResultEqual;
        }
        return kBCOComparisonResultBelow;
    }
}

// rectの各点と線を比較した結果を配列で返す。
// 配列は左上、右上、左下、右下の順に並ぶ。
// lineの始点と終点が同じときは比べられないのでNOを返す。
static BOOL compareRectPointsAndLine(CGRect rect, BCOLine line, BCOComparisonResult *result)
{
    if (CGPointEqualToPoint(line.start, line.end)) {
        return NO;
    }
    
    CGPoint leftTop         = rect.origin;
    CGPoint rightTop        = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGPoint leftBottom      = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGPoint rightBottom     = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    
    result[0] = comparePointAndLine(leftTop, line);
    result[1] = comparePointAndLine(rightTop, line);
    result[2] = comparePointAndLine(leftBottom, line);
    result[3] = comparePointAndLine(rightBottom, line);
    return YES;
}

#pragma mark - public

// 線と矩形の衝突判定
BOOL isCollideLineAndRect(BCOLine line, CGRect rect)
{
    if (isLineOutOfBounds(line, rect)) return NO;
    
    // 矩形の各点が線より上にあるか下にあるかを比較
    BCOComparisonResult comparisonResults[4];
    if (compareRectPointsAndLine(rect, line, comparisonResults) == NO) {
        // lineの始点と終点が同じ時は矩形の中かどうかで判定
        if (CGRectContainsPoint(rect, line.start)) return YES;
            
        return NO;
    }
    
    // 矩形のフチに線がかぶっていれば衝突している。
    for (int i = 0; i < 4; i++) {
        BCOComparisonResult comparisonResult = comparisonResults[i];
        if (comparisonResult == kBCOComparisonResultEqual) return YES;
    }
    
    // ある点は線より上、ある点は線より下であれば必ず線は矩形と衝突している。
    for (int i = 0; i < 3; i++) {
        BCOComparisonResult comparisonResultA = comparisonResults[i];
        BCOComparisonResult comparisonResultB = comparisonResults[i + 1];
        if (comparisonResultA != comparisonResultB) return YES;
    }
    
    return NO;
}

