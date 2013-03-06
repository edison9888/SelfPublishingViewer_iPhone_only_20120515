//
//  NSString_Util.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/13.
//  Copyright 2011 SAT. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString(Util)
// 文字列連結
-(NSString*)add:(NSString*)str;
// パス結合
-(NSString*)addPath:(NSString*)str;
// ディレクトリだけ除く
-(NSString*)filename;
// ディレクトリと拡張子を除く
-(NSString*)basename;
// ファイル名を除く
-(NSString*)dirname;
// 等しいかどうか
-(BOOL)eq:(NSString*)str;
// 含むかどうか
-(BOOL)contains:(NSString*)str;
// 正規表現に一致するかどうかを返す
-(BOOL)isMatch:(NSString*)pattern;
// 正規表現に一致する部分を返す
-(NSArray*)match:(NSString*)pattern;
// 正規表現に一致する部分をすべて返す
-(NSArray*)matches:(NSString*)pattern;
@end
// 文字列を連結する
NSString* join(NSString* str, ...);


// NSLocalizedStringのエイリアス
NSString* res(NSString* name);
// 数値
NSString* intStr(NSInteger i);
// 数値
NSString* floatStr(CGFloat f);