//
//  NSString_Util.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/13.
//  Copyright 2011 SAT. All rights reserved.
//

#import "NSString_Util.h"


@implementation NSString(Util)
// 文字列連結
-(NSString*)add:(NSString *)str {
    return [self stringByAppendingString:str];
}
// パス結合
-(NSString*)addPath:(NSString*)str {
    return [self stringByAppendingPathComponent:str];
}
// ディレクトリだけ除く
-(NSString*)filename {
    return [self lastPathComponent];
}
// ディレクトリと拡張子を除く
-(NSString*)basename {
    return [[self lastPathComponent]stringByDeletingPathExtension];
}
// ファイル名を除く
-(NSString*)dirname {
    return [self stringByDeletingLastPathComponent];
}
// 等しいかどうか
-(BOOL)eq:(NSString*)str {
    return [self isEqualToString:str];
}
// 含むかどうか
-(BOOL)contains:(NSString*)str {
    NSRange r = [self rangeOfString:str];
    return r.location != NSNotFound;
}

// 正規表現に一致するかどうかを返す
-(BOOL)isMatch:(NSString*)pattern {
    NSRegularExpression* regex = [NSRegularExpression 
                                  regularExpressionWithPattern:pattern
                                  options:NSRegularExpressionCaseInsensitive
                                  | NSRegularExpressionDotMatchesLineSeparators
                                  error:NULL];
    NSTextCheckingResult* m = [regex 
                               firstMatchInString:self
                               options:0
                               range:NSMakeRange(0, [self length])];
    return m.numberOfRanges > 0;
    
}


// 正規表現に一致する部分を返す
-(NSArray*)match:(NSString*)pattern {
    NSRegularExpression* regex = [NSRegularExpression 
                                  regularExpressionWithPattern:pattern
                                  options:NSRegularExpressionCaseInsensitive
                                  | NSRegularExpressionDotMatchesLineSeparators
                                  error:NULL];
    NSTextCheckingResult* m = [regex firstMatchInString:self
                                   options:0
                                     range:NSMakeRange(0, [self length])];
    
    NSMutableArray* ret = [NSMutableArray arrayWithCapacity:m.numberOfRanges];
    for (int i = 0; i < m.numberOfRanges; i++) {
        [ret addObject:[self substringWithRange:[m rangeAtIndex:i]]];
    }
    return ret;
}

// 正規表現に一致する部分をすべて返す
-(NSArray*)matches:(NSString *)pattern {
    NSRegularExpression* regex = [NSRegularExpression 
                                  regularExpressionWithPattern:pattern
                                  options:NSRegularExpressionCaseInsensitive
                                  | NSRegularExpressionDotMatchesLineSeparators
                                  error:NULL];
    NSArray* ms = [regex matchesInString:self
                                 options:0
                                   range:NSMakeRange(0, [self length])];
    NSMutableArray* ret = [NSMutableArray arrayWithCapacity:[ms count]];
    for (NSTextCheckingResult* m in ms) {
        NSMutableArray* elem = [NSMutableArray arrayWithCapacity:m.numberOfRanges];
        for (int i = 0; i < m.numberOfRanges; i++) {
            [elem addObject:[self substringWithRange:[m rangeAtIndex:i]]];
        }
        [ret addObject:elem];
    }
    return ret;
}

@end

NSString* join(NSString* str, ...) {
    NSMutableString* ret = [NSMutableString stringWithString:str];
    va_list args;
    va_start(args, str);
    NSString* s;
    while ((s = va_arg(args, NSString*))) {
        [ret appendString:s];
    }
    va_end(args);
    return ret;
}
// リソース文字列
NSString* res(NSString* name) {
    return NSLocalizedString(name, nil);
}
// 数値
NSString* intStr(NSInteger i) {
    return [NSString stringWithFormat:@"%d", i];
}
// 数値
NSString* floatStr(CGFloat f) {
    return [NSString stringWithFormat:@"%f", f];
}
