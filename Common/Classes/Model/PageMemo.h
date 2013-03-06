//
//  PageMemo.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/13.
//  Copyright 2011 SAT. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Book;
@class PageMemoComment;

@interface PageMemo : NSObject {
    @private
    NSString* baseDir;
    NSMutableArray* writingFiles;
    NSMutableArray* attachmentFiles;
    NSMutableDictionary* conf;
    NSMutableArray* commentFiles;
}
// 初期化
-(id)initWithBook:(Book*)book page:(NSInteger)page;

// 表示設定を返す
- (BOOL)isVisible:(NSString*)udid index:(int)index;
// 表示設定を変更する
- (void)setVisible:(BOOL)visible udid:(NSString*)udid index:(int)index;


// 落書きレイヤーの数を返す
- (NSInteger)writingCount;
// 落書きレイヤーのUDIDを返す
-(NSString*)writingUdidAt:(NSInteger)idx ;
// 落書きを返す
- (UIImage*)writingImageAt:(NSInteger)idx;
// 自分の落書きが削除されていないかチェックする
-(BOOL)myWritingExists;

// 自分の落書きを返す
- (UIImage*)myWritingImage;
// すべての落書きを重ねて返す
- (UIImage*)layeredWritingImage;
// 落書きをセットする
- (void)setMyWritingImage:(UIImage*)img;
// 落書きレイヤーのUDIDを返す

- (void)removeLayerData;

-(NSString*)writingUdidAt:(NSInteger)idx;
// 落書きレイヤーを削除する
- (void)deleteWritingAt:(NSInteger)idx;
// 落書きレイヤーを並び替える
- (void)changeWritingOrder:(NSInteger)from to:(NSInteger)to;
// 添付ファイルの数を返す
- (NSInteger)attachmentCount;
// 添付ファイルを返す
- (UIImage*)attachmentImageAt:(NSInteger)idx;
// 添付ファイルを追加する
- (void)addAttachment:(UIImage*)img;
// 添付ファイルを削除する
- (void)deleteAttachmentAt:(NSInteger)idx;

// コメントを作成する
- (PageMemoComment*)createComment;
// 自分のコメントの一覧を返す
- (NSArray*)myComments;
// すべてのコメントの一覧を返す
- (NSArray*)comments;
// コメントを削除する
- (void)deleteComment:(PageMemoComment*)comment;
// ページ並べ替えを一括で処理する
+ (void)arrangePageOrder:(NSString*)bookFilename movings:(NSArray*)movings;

// アーカイブを作成してパスを返す
+ (NSString*)createArchive:(Book*)book;
// アーカイブを解凍する
+ (void)extractArchive:(NSString*)bookPath archive:(NSString*)archivePath;





@end

