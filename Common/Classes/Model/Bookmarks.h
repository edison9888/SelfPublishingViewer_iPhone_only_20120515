//
//  Bookmarks.h
//

#import <Foundation/Foundation.h>

@class Book;
@class BookmarkEntry;

@interface Bookmarks : NSObject {
    
}
// シングルトンインスタンスを返す
+ (Bookmarks*)bookmarks;
// BookmarkEntryの配列を返す
- (NSArray*) entries;

// すでにブックマークされているかどうかを返す
- (BOOL) bookmarked:(Book*)book page:(NSInteger)page;
// ブックマークする
- (void) add:(Book*)book page:(NSInteger)page;
// ブックマークを削除する
- (void) remove:(BookmarkEntry*)entry;
// ブックマークを削除する
- (void) remove:(Book*)book page:(NSInteger)page;
// 全削除する
- (void) removeAll;


@end
