//
//  BookmarkEntry.h
//  ブックマークのエントリ一つを表すクラス
//

#import <Foundation/Foundation.h>

@class Book;

@interface BookmarkEntry : NSObject {
    @private
    NSInteger recordId;
    Book* book;
    NSInteger page;
    NSString* displayName;
}
// エントリーを削除する
- (void)deleteEntry;

@property(nonatomic,readonly) Book* book;
@property(nonatomic,readonly) NSString* displayName;
@property(nonatomic,readonly) NSInteger page;
@property(nonatomic,readonly) NSInteger recordId;

- (BookmarkEntry*)initWithRecord: (NSDictionary*)record;


@end
