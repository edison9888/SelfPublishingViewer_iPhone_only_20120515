//
//  BookmarkEntry.m
//

#import "BookmarkEntry.h"
#import "Book.h"
#import "BookFiles.h"
#import "Bookmarks.h"
#import "FileUtil.h"

@implementation BookmarkEntry
@synthesize page, book, displayName, recordId;

// 初期化
- (BookmarkEntry*)initWithRecord: (NSDictionary*)record {
    self = [super init];
    BookFiles* bf = [BookFiles bookFiles];
    NSString* path = [record objectForKey:@"path"];
    NSString* folder = [record objectForKey:@"folder"];
    Book* bk = [bf bookAtPathFolder:path folder:folder];
    if (bk && page < [bk pageCount]) {
        recordId = [[record objectForKey:@"bookmark_id"]intValue];
        book = [bk retain];
        page = [[record objectForKey:@"page"]intValue];
        displayName = [[record objectForKey:@"display_name"]retain];
    }
    return self;
}

/*
- (NSString*) displayName {
    return [NSString stringWithFormat:@"%@/%@",
            book.name,
            [book getPageFilename: page]];
}*/

// エントリーを削除する
- (void)deleteEntry {
    Bookmarks* bm = [Bookmarks bookmarks];
    [bm remove:self];
}


- (void)dealloc {
    [book release];
    [displayName release];
    [super dealloc];
}

@end
