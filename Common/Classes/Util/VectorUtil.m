//
//  VectorUtil.m
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/06.
//  Copyright 2011 SAT. All rights reserved.
//

#import "VectorUtil.h"


@implementation VectorUtil


// ２点間の距離
+(CGFloat) distance:(CGPoint)a :(CGPoint)b {
    return sqrtf(powf(b.x - a.x, 2) + powf(b.y - a.y, 2));
}
// ２点をつなぐベクトル
+(CGPoint) vector:(CGPoint)origin :(CGPoint)destination {
    return CGPointMake(destination.x - origin.x, destination.y - origin.y);
}
// 二つのベクトル間の角度
+(CGFloat) angle:(CGPoint)p1 :(CGPoint)p2 {
    CGPoint d = [self vector:p1 :p2];
    CGFloat r = [self distance:p1 :p2];
    return acosf(d.x / r);
}

@end
