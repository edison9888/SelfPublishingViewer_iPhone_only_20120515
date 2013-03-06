//
//  FileUtil.h
//  LiverliveRecipe
// ファイル操作に関するユーティリティ
//
//  Created by 藤田正訓 on 11/06/24.
//  Copyright 2011 SAT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "common.h"


@interface FileUtil : NSObject {
	
}
// ファイルが存在するかどうか返す
+ (BOOL)exists: (NSString*) path;
// ファイルの最終更新日時を返す
+ (NSDate*) mtime: (NSString*) path;
// path1がpath2よりも新しいかどうかを返す
+ (BOOL) newer: (NSString*) path1: (NSString*) path2;
// コピーする
+ (void) copy: (NSString*) src: (NSString*) dst;
// 削除する
+ (void) rm: (NSString*) path;
// ディレクトリ内のファイル一覧を返す
+ (NSArray*) files: (NSString*)dir extensions:(NSArray*) extensions;
// ディレクトリを再帰的にたどってファイル一覧を返す
+ (NSArray*) rfiles:(NSString*)dir extensions:(NSArray*)extensions;

// ディレクトリを作成する
+ (void) mkdir: (NSString*) dir;
// かぶらない名前を生成する
+ (NSString*) unexistingPath: (NSString*)path;
// テキストファイルの中身を読み取って返す
+ (NSString*) read:(NSString*) path;
// テキストファイルに書きこむ
+ (void) write:(NSString*) str path:(NSString*)path;
// 追記する
+ (void) append:(NSData*) data path:(NSString*)path;
// 移動（名前変更）
+ (void) mv:(NSString*)from toPath:(NSString*)to;
// ファイル名
+ (BOOL)isValidFilename:(NSString*)fileName;
// ファイルサイズ
+ (NSUInteger)length:(NSString*)path;




+(BOOL)fileExistsAtAbsolutePath:(NSString*)filename ;
+(BOOL)directoryExistsAtAbsolutePath:(NSString*)filename ;

@end
