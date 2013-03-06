//
//  ZipFile.h
//  ZipFile
//
//  Created by Kenji Nishishiro <marvel@programmershigh.org> on 10/05/08.
//  Copyright 2010 Kenji Nishishiro. All rights reserved.
//

#import "unzip.h"

@class ZipEntry;

@interface ZipFile : NSObject {
	NSString *path_;
	unzFile unzipFile_;
}

- (id)initWithFileAtPath:(NSString *)path;
- (BOOL)open;
- (void)close;
// 解凍せずにデータを読み込む
- (NSData*)read:(ZipEntry*)entry;

/* not sure about this,  well not in the given time frame */
//- (int)write:(ZipEntry*)entry withData:(NSData *)data;

// 画像のファイル一覧を返す
- (NSArray*)entries;
@end