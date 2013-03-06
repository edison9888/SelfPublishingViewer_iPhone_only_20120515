//
//  BookFiles.h
//

#import <Foundation/Foundation.h>
@class Book;

@interface BookFiles : NSObject {
    NSMutableArray* books;
}
@property (nonatomic, retain) NSMutableArray* books;

// Bookオブジェクトを返す
- (Book*) bookAtIndex: (NSInteger) index;

// Bookオブジェクトを返す
- (Book*) bookAtPath: (NSString*)path;
// Bookオブジェクトを返す
- (Book*)bookAtPathFolder: (NSString*)path folder:(NSString*)folder;

// ファイルの個数を返す
- (NSInteger) bookCount;

// ファイル一覧の確認を行い、変更があれば読み込み直してTRUEを返す
- (BOOL) checkReload;
// Bookオブジェクトを削除する
- (void) deleteBookAt:(NSInteger)idx;
// Bookオブジェクトを削除する
-(void)deleteBookAtPath:(NSString*)path;
// 並び順を変更する
- (void) changeBookOrder:(NSInteger)from to:(NSInteger)to;
// 表紙が更新されているかどうかを返す
- (BOOL)isCoverModifiedSince:(NSTimeInterval)since;

// シングルトンインスタンスを返す
+ (BookFiles*)bookFiles;
// メモリが足りなくなったときに解放する
+ (void)purge;

@end
