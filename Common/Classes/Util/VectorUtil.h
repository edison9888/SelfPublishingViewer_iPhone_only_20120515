//
//  VectorUtil.h
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/06.
//  Copyright 2011 SAT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "common.h"


@interface VectorUtil : NSObject {
    
}
// ２点間の距離
+(CGFloat) distance:(CGPoint)a : (CGPoint)b;
// ２点をつなぐベクトル
+(CGPoint) vector:(CGPoint)origin: (CGPoint)destination;
// 二つのベクトル間の角度
+(CGFloat) angle:(CGPoint)p1: (CGPoint)p2;
@end
