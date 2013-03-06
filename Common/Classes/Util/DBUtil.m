//
//  DBUtil.m
//  LiverliveRecipe
//  SQLiteを便利に使うためのユーティリティ
//  Created by 藤田正訓 on 11/06/24.
//  Copyright 2011 SAT. All rights reserved.
//

#import "DBUtil.h"
#import "FileUtil.h"
#import "common.h"

@implementation DBUtil

// DBに接続する。
+(FMDatabase*)connect:(NSString*)filename {
    return [self connect:filename updateIfNew:NO];
}
+(FMDatabase*)connect:(NSString*)filename updateIfNew:(BOOL)updateIfNew {
	// 使用するファイル
    NSString* filePath = [[NSHomeDirectory() 
                           stringByAppendingPathComponent:@"Library/Caches/db"]
                          stringByAppendingPathComponent:filename];
    NSString* oldFilePath = [[NSHomeDirectory() 
                              stringByAppendingPathComponent:@"Library/Preferences"]
                             stringByAppendingPathComponent:filename];
    if ([FileUtil exists:oldFilePath]) {
        // 古いパスから移動
        @try {
            [FileUtil mv:oldFilePath toPath:filePath];
        }
        @catch (NSException *exception) {
        }
    } else {
		
        // リソースファイル
        NSString* srcPath = [[[[NSBundle mainBundle]resourcePath]
                              stringByAppendingPathComponent:@"data"]
                             stringByAppendingPathComponent:filename];
        
        if (![FileUtil exists:filePath] || (updateIfNew && [FileUtil newer:srcPath :filePath])) {
            NSLog(@"リソースからコピーする→ %@", filePath);
            // リソースからコピーする
            [FileUtil copy:srcPath :filePath];
            NSLog(@"コピー成功");
        }
    }
	FMDatabase* db = [FMDatabase databaseWithPath:filePath];
    db.logsErrors = YES;
    return db;
}

// 任意のSQLを実行する
+(FMResultSet*) execute: (FMDatabase*)db 
                    sql:(NSString*)sql {
	if (![db open]) {
		@throw [NSException exceptionWithName:@"DBOpenException"
									   reason:@"データベースが開けません。" 
									 userInfo:nil];
	}
	FMResultSet* rs = [db executeQuery:sql];
    return rs;
}

+(BOOL) executeUpdate: (FMDatabase*)db
                  sql: (NSString*)sql
               params: (NSArray*)params {
	if (![db open]) {
		@throw [NSException exceptionWithName:@"DBOpenException"
									   reason:@"データベースが開けません。" 
									 userInfo:nil];
	}
    BOOL success = [db executeUpdate:sql withArgumentsInArray:params];
    if (!success) {
        @throw [NSException exceptionWithName:@"DBExecuteException"
                                       reason:[db lastErrorMessage]
                                     userInfo:nil];
    }
    return success;
    
}



// SELECTして結果をイテレートする
+(void)queryCallback:(FMDatabase*)db 
                 sql:(NSString*)sql
            callback:(void (^)(FMResultSet*, NSArray*, BOOL*))block {
    FMResultSet* rs = [self execute:db sql:sql];
	[rs setupColumnNames];
	NSArray* columns = [rs.columnNameToIndexMap allKeys];
	while ([rs next]) {
		BOOL stop = FALSE;
		block(rs, columns, &stop);
		if (stop) {
			break;
		}
	}
	[rs close];
	[db close];
}

// SELECTして結果をすべて返す
+(NSArray*)queryRecords:(FMDatabase*)db 
                    sql:(NSString*)sql {
	NSMutableArray* records = [[[NSMutableArray alloc]init]autorelease];
	[DBUtil queryCallback:db 
                      sql:sql 
                 callback:^(FMResultSet* rs, NSArray* columns, BOOL* stop) {
		NSMutableDictionary* record = [NSMutableDictionary dictionary];
		for (NSString* col in columns) {
			[record setValue:[rs stringForColumn:col] forKey:col];
		}
		[records addObject:record];
	}];
	return records;
}


// SELECTした結果を一次元配列として返す
+(NSArray*)queryColumn:(FMDatabase*)db  
                column:(NSString*) col  
                   sql:(NSString*)sql {
	NSMutableArray* ret = [[[NSMutableArray alloc]init]autorelease];
	[DBUtil queryCallback:db 
                      sql:sql 
                 callback:^(FMResultSet* rs, NSArray* columns, BOOL* stop) {
		[ret addObject:[rs stringForColumn:col]];
	}];	
	return ret;
}


// SELECTした結果をハッシュとして返す
+(NSDictionary*)queryAssoc:(FMDatabase*)db 
                   column1:(NSString*) col1 
                   column2:(NSString*) col2  
                       sql:(NSString*)sql {
	NSMutableDictionary* ret = [[[NSMutableDictionary alloc]init]autorelease];
	[DBUtil queryCallback:db 
                      sql:sql 
                 callback:^(FMResultSet* rs, NSArray* columns, BOOL* stop) {
		[ret setValue:[rs stringForColumn:col2] forKey:[rs stringForColumn:col1]];
	}];
	return ret;
}





@end
