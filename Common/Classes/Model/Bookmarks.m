//
//  Bookmarks.m
//

#import "Bookmarks.h"
#import "BookmarkEntry.h"
#import "FMDatabase.h"
#import "DBUtil.h"
#import "BookFiles.h"
#import "Book.h"

@implementation Bookmarks

static Bookmarks* instance = nil;

// シングルトンインスタンスを返す
+ (Bookmarks*)bookmarks {
    if (!instance) {
        instance = [[Bookmarks alloc]init];
    }
    return instance;
}

// BookmarkEntryの配列を返す
- (NSArray*) entries {
    BookFiles* bf = [BookFiles bookFiles];
    [bf checkReload];
    NSMutableArray* ret = [NSMutableArray array];
    
    FMDatabase* db = [DBUtil connect:@"bookmark.sqlite"];
    NSString* sql = @"SELECT bookmark_id, display_name, path, folder, page FROM bookmark";
    NSArray* records = [DBUtil queryRecords:db sql:sql];
    for (NSDictionary* record in records) {
        BookmarkEntry* ent = [[BookmarkEntry alloc]initWithRecord:record];
        if (ent.book) {
            [ret addObject:ent];
        }
        [ent release];
    }
    return ret;
}

- (BOOL) bookmarked:(Book*)book page:(NSInteger)page {
    if ([book pageCount] > page) {
        FMDatabase* db = [DBUtil connect:@"bookmark.sqlite"];
        NSString* fn = book.folderName ? book.folderName : @"";
        NSString* sql = [NSString stringWithFormat:@"SELECT bookmark_id FROM bookmark WHERE path = '%@' AND page = '%d' AND folder = '%@'", book.path, page, fn];
        NSArray* row = [DBUtil queryRecords:db sql:sql];
        if ([row count] > 0) {
            return YES;
        }
    }
    return NO;
}


- (void) add:(Book*)book page:(NSInteger)page {
    if ([book pageCount] > page) {
        FMDatabase* db = [DBUtil connect:@"bookmark.sqlite"];
        NSString* sql = [NSString stringWithFormat:@"SELECT bookmark_id FROM bookmark WHERE path = '%@' AND page = '%d' AND folder = '%@%'", book.path, page, book.folderName];
        NSArray* row = [DBUtil queryRecords:db sql:sql];
        if ([row count] == 0) {
            NSString* pageStr;
            NSString* displayName = [book getPageDisplayName:page];
            NSString* folderName = book.folderName ? book.folderName : @"";
            pageStr = [NSString stringWithFormat:@"%d", page];
            sql = @"INSERT INTO bookmark(path,page,display_name,folder) VALUES (?,?,?,?)";
            NSArray* params = [NSArray arrayWithObjects:
                               book.path, pageStr, displayName, folderName, nil];
            [DBUtil executeUpdate:db sql:sql params:params];
        }
    }
}

- (void) remove:(Book*)book page:(NSInteger)page {
    FMDatabase* db = [DBUtil connect:@"bookmark.sqlite"];
    NSString* fn = book.folderName ? book.folderName : @"";
    NSString* sql = [NSString stringWithFormat:@"DELETE FROM bookmark WHERE path = '%@' AND page = %d AND folder = '%@'", book.path, page, fn];
    [DBUtil executeUpdate:db sql:sql params:nil];
}

- (void) remove:(BookmarkEntry*)entry {
    FMDatabase* db = [DBUtil connect:@"bookmark.sqlite"];
    NSString* sql = [NSString stringWithFormat:@"DELETE FROM bookmark WHERE bookmark_id = %d", entry.recordId];
    [DBUtil executeUpdate:db sql:sql params:nil];
}

// 全削除する
- (void) removeAll {
    FMDatabase* db = [DBUtil connect:@"bookmark.sqlite"];
    NSString* sql = @"DELETE FROM bookmark";
    [DBUtil executeUpdate:db sql:sql params:nil];
}


@end
