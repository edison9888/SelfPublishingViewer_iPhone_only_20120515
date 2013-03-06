//
//  DBUtil.h
//  LiverliveRecipe
//
//  Created by 藤田正訓 on 11/06/24.
//  Copyright 2011 SAT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "common.h"


@interface DBUtil : NSObject {
	
}
// DBに接続する。
+(FMDatabase*)connect:(NSString*)filename;
+(FMDatabase*)connect:(NSString*)filename updateIfNew:(BOOL)updateIfNew;

// 任意のSQLを実行する
+(FMResultSet*) execute: (FMDatabase*)db 
                    sql:(NSString*)sql;

// 更新系のSQLを実行する
+(BOOL) executeUpdate: (FMDatabase*)db
                  sql: (NSString*)sql
               params: (NSArray*)params;

// SELECTして結果をイテレートする
+(void)queryCallback:(FMDatabase*)db 
                 sql:(NSString*)sql
            callback:(void (^)(FMResultSet*, NSArray*, BOOL*))block;

// SELECTして結果をすべて返す
+(NSArray*)queryRecords:(FMDatabase*)db 
                    sql:(NSString*)sql;

// SELECTした結果を一次元配列として返す
+(NSArray*)queryColumn:(FMDatabase*)db  
                column:(NSString*) col  
                   sql:(NSString*)sql;

// SELECTした結果をハッシュとして返す
+(NSDictionary*)queryAssoc:(FMDatabase*)db 
                   column1:(NSString*) col1 
                   column2:(NSString*) col2  
                       sql:(NSString*)sql;



@end
