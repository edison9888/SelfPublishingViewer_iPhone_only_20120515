//
//  Stack.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/12.
//  Copyright 2011 SAT. All rights reserved.
//

#import <Foundation/Foundation.h>

// FIFOのスタックの実装
@interface UndoBuffer : NSObject {
    NSInteger limit;
    NSInteger current;
    NSMutableArray* array;
}
// 最大数を指定する
-(id)initWithLimit:(NSInteger)lim;

// 現在以降のオブジェクトを削除してバッファに加える
-(void)push:(id)obj;
// 1つ前のオブジェクトを返す
-(id)undo;
// 次のオブジェクトを返す
-(id)redo;
// 現在のオブジェクトを返す
-(id)current;
// アンドゥ可能
-(BOOL)canUndo;
// リドゥ可能
-(BOOL)canRedo;
// クリア
-(void)clear;
@end
