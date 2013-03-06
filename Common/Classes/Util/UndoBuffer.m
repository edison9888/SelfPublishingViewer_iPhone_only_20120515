//
//  Stack.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/12.
//  Copyright 2011 SAT. All rights reserved.
//

#import "UndoBuffer.h"

@interface UndoBuffer() 
@property(nonatomic,retain)NSMutableArray* array;
@end


@implementation UndoBuffer
@synthesize array;

-(void)clear {
    [array removeAllObjects];
}
// 最大数を超えたぶんを削除する
-(void)removeOverlimit {
    if (limit) {
        while ([array count] > limit) {
            [array removeObjectAtIndex:0];
        }
    }
}

// 現在以降のオブジェクトを削除してバッファに加える
-(void)push:(id)obj {
    // 
    for (int i = [array count] - 1; i > current; i--) {
        [array removeObjectAtIndex:i];
    }
    [array addObject:obj];
    [self removeOverlimit];
    current = [array count] - 1;
}
// 1つ前のオブジェクトを返す
-(id)undo {
    current--;
    if (current < 0) {
        current = -1;
        return nil;
    } else {
        return [self current];
    }
}
// 次のオブジェクトを返す
-(id)redo {
    current++;
    if (current > [array count] - 1) {
        current = [array count] - 1;
        return nil;
    } else {
        return [self current];
    }
}
// 現在のオブジェクトを返す
-(id)current {
    if (current < [array count]) {
        return [array objectAtIndex:current];
    } else {
        return nil;
    }
}
// アンドゥ可能
-(BOOL)canUndo {
    return current > 0;
}
// リドゥ可能
-(BOOL)canRedo {
    return current < [array count] - 1;
}


#pragma mark - object lifecycle

-(id)initWithLimit:(NSInteger)lim {
    self = [super init];
    if (self) {
        self.array = [NSMutableArray arrayWithCapacity:lim];
        limit = lim;
        current = -1;
    }
    return self;
}

-(void)dealloc {
    self.array = nil;
    [super dealloc];
}

@end
