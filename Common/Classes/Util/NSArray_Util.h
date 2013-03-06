//
//  NSArray_Util.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/17.
//  Copyright 2011 SAT. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray(NSArray_Util)
// objectAtIndexのエイリアス
-(id)at:(NSInteger)idx;

@end

// [NSArray arrayWithObjects]のエイリアス
NSArray* array(id obj, ...);