//
//  NSArray_Util.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/17.
//  Copyright 2011 SAT. All rights reserved.
//

#import "NSArray_Util.h"


@implementation NSArray(NSArray_Util)
-(id)at:(NSInteger)idx {
    return [self objectAtIndex:idx];
}
@end

NSArray* array(id obj, ...) {
    va_list args;
    va_start(args, obj);
    NSMutableArray* ar = [NSMutableArray arrayWithObject:obj];
    while ((obj = va_arg(args, id))) {
        [ar addObject:obj];
    }
    va_end(args);
    return ar;
}