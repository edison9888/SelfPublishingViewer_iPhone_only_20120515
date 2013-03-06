//
//  NewBook.h
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/25.
//  Copyright 2011 SAT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZipArchive.h"
#import "Viewable.h"
#import "Book.h"

@interface NewBook : NSObject<Viewable> {
    NSString* name;
    NSMutableArray* fileNames;
    NSString* dirPath;
    NSInteger readingPage;
    NSString* originalPath;
    BOOL isImported;
    BOOL isImporting;
    BOOL isWeirdFlag;

}


@property(nonatomic, readwrite) BOOL isImported;
@property(nonatomic, readwrite) BOOL isImporting;

// 表示名
@property(nonatomic,retain) NSString* name;
// ファイル名配列
@property(nonatomic,retain) NSMutableArray* fileNames;
// ディレクトリパス
@property(nonatomic,retain) NSString* dirPath;
// PDFかどうかを返す
@property(nonatomic, readonly) BOOL isPDF;



@property(nonatomic, readonly) BOOL isPNG;
@property(nonatomic, readonly) BOOL isJPG;

@property(nonatomic, readwrite) BOOL isWeirdFlag;


// 読み途中のページ
@property(nonatomic, assign) NSInteger readingPage;
// 元のファイルのPATH
@property(nonatomic, retain) NSString* originalPath;

// ページ数を返す
- (NSInteger) pageCount;
// ブックマークされているかどうか
- (BOOL) isBookmarked: (NSInteger) page;
// ブックマークする
- (void) addToBookmark: (NSInteger) page;
// 表紙の画像を返す
- (UIImage*) getCoverImage:(CGSize)size;
// 表示の画像を設定する
- (void) setCoverImage: (UIImage*)img;
// ページの画像を返す
- (UIImage*) getPageImage: (NSInteger)pageNum;


// 既存のブックを開く
- (void) openBook:(Book*)book;
// 画像をすべて削除する
- (void) removeAllPages;
// 画像を追加する
- (void) addPage: (UIImage*)img;
// 画像を削除する
- (void) removePageAt:(NSInteger)idx;
// 画像を変更する
- (void) changeImage:(UIImage*)img atPage:(NSInteger)idx;
// 画像を移動する
- (void) movePage:(NSInteger)from to:(NSInteger)to;

// メタ情報を保存する
- (void)saveMeta;

// ZIPファイルを作成する
- (void) makeZipFile: (NSString*) name;
// テンポラリフォルダを削除する
- (void)deleteTmpdir;
// テンポラリフォルダにファイルが存在する
+ (BOOL)fileExists;

@end
