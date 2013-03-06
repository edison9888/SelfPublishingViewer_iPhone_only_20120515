//
//  Viewable.h
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/26.
//  Copyright 2011 SAT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PageMemo.h"

@protocol Viewable <NSObject>
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
- (UIImage *) getHighResPDFImage:(NSInteger)pageNum;
// サムネイル画像を返す
- (UIImage*) getThumbnailImage: (NSInteger)pageNum;
// キャッシュする
- (void)fetchCache:(NSInteger)pageNum size:(CGSize)size;
// ページに含まれるリンクを返す
- (NSArray*)getPageLinks:(NSInteger)pageNum;

// 表示名
@property(nonatomic, retain) NSString* name;
// PDFかどうかを返す
@property(nonatomic, readonly) BOOL isPDF;

/* JPG, PNG Support */
@property(nonatomic, readonly) BOOL isPNG;
@property(nonatomic, readonly) BOOL isJPG;


// 読み途中のページ
@property(nonatomic, assign) NSInteger readingPage;

@property(readonly) BOOL isInFolder;

@end
