//
//  BookFiles.m
//

#import "BookFiles.h"
#import "Book.h"
#import "FileUtil.h"


@implementation BookFiles
@synthesize books;

static BookFiles* instance = nil;

- (void) loadBooks {
    if (books == nil) {
        NSString* bookDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        
        NSLog(@"Document Lyb Path :: %@",bookDir);
        
        NSArray* bookPaths = [FileUtil files:bookDir  extensions:[NSArray arrayWithObjects: @"zip", @"cbz", @"rar", @"cbr", @"pdf", @"png",@"jpg", @"doc", @"docx", @"ppt", @"pptx", @"xls", @"xlsx", nil]];
       
        if ([bookPaths count] == 0) {
            // ひとつもなければサンプルファイルをコピー
            //_¦pü¿_Åpüä_äpüæ
            //_Ppâ¦_½péÖ_ªpéÖF¬__sñ¦µòù_ùpü¬_ät+Äs«¦µò¦s+_íô
            NSArray* samples = [NSArray arrayWithObjects:
                                @"_¦pü¿_Åpüä_äpüæ.zip",
                                @"_Ppâ¦_½péÖ_ªpéÖF¬__sñ¦µòù_ùpü¬_ät+Äs«¦µò¦s+_íô.zip",
                                /*@"Darkness.cbz",
                                @"Kurogasa.cbr",
                                @"AmericasBestComics24.rar",*/
                                nil];
           NSString* sampleDir = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"Samples"];

            for (NSString* sample in samples) {
                NSString* spath = [sampleDir stringByAppendingPathComponent:sample];
                NSLog(@"spath: %@", spath);
                [FileUtil copy: spath: bookDir];
            }
        }
        self.books = [NSMutableArray arrayWithCapacity:[bookPaths count]];
        NSLog(@"bookpaths: %@", bookPaths);
        for (NSString* bookPath in bookPaths) {
            if ([FileUtil exists:bookPath]) {
                [books addObject:[Book bookWithPath:bookPath]];
            }
        }
        
        // ソート
        NSSortDescriptor* sd1 = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
        NSSortDescriptor* sd2 = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        [books sortUsingDescriptors:[NSArray arrayWithObjects:sd1, sd2, nil]];
        
        // orderを再設定する
        for (NSInteger i = 0; i < [books count]; i++) {
            Book* b = [books objectAtIndex:i];
            b.order = i + 1;
        }
    }
}

- (BOOL) hasBook: (NSString*)path {
    if (!books) {
        return NO;
    }
    for (Book* b in books) {
        if ([b.path isEqualToString:path]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) checkReload {
    if (!books) {
        [self loadBooks];
        return YES;
    }
    NSString* bookDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSArray* bookPaths = [FileUtil files:bookDir  extensions:[NSArray arrayWithObjects: @"zip", @"cbz", @"rar", @"cbr", @"pdf", @"png",@"jpg", @"doc", @"docx", @"ppt", @"pptx", @"xls", @"xlsx", nil]];
    // 数が違っていたら再読込
    if ([bookPaths count] != [books count]) {
        self.books = nil;
        [self loadBooks];
        return YES;
    }
    // 内容が違っていたら再読込
    for (NSString* p in bookPaths) {
        if (![self hasBook:p]) {
            self.books = nil;
            [self loadBooks];
            return YES;
        }
    }
    // 変化はない
    return NO;
}

// 並び順を変更する
- (void) changeBookOrder:(NSInteger)from to:(NSInteger)to {
    Book* b = [[books objectAtIndex:from]retain];
    [books removeObjectAtIndex:from];
    if (to < [books count]) {
        [books insertObject:b atIndex:to];
    } else {
        [books addObject:b];
    }
    [b release];
    NSInteger min = MAX(0, MIN(from, to));
    NSInteger max = MIN(MAX(from, to), [books count] - 1);
    for (NSInteger i = min; i <= max; i++) {
        b = [books objectAtIndex:i];
        b.order = i;
    }
}

// 表紙が更新されているかどうかを返す
- (BOOL)isCoverModifiedSince:(NSTimeInterval)since {
    for (Book* b in books) {
        if ([b isCoverModifiedSince:since]) {
            return YES;
        }
    }
    return NO;
}


// シングルトンインスタンスを返す
+ (BookFiles*)bookFiles {
    if (!instance) {
        instance = [[BookFiles alloc]init];
        NSString* oldPrefPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/Bookprefs"];
        NSString* newPrefPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/Bookprefs"];
        if ([FileUtil exists:oldPrefPath]) {
            if (![FileUtil exists:newPrefPath]) {
                [FileUtil mv:oldPrefPath toPath:newPrefPath];
            } else {
                [FileUtil rm:oldPrefPath];
            }
        }
    }
    return instance;
}

// Bookオブジェクトを削除する
- (void) deleteBookAt: (NSInteger)idx {
    Book* b = [[books objectAtIndex:idx]retain];
    [books removeObjectAtIndex:idx];
    [b deleteFile];
    [b release];
}

// パスに対応するBookオブジェクトを削除する
- (void) deleteBookAtPath:(NSString*)path {
    Book* b = [self bookAtPath:path];
    if (b) {
        NSInteger idx = [books indexOfObject:b];
        if (idx >= 0) {
            [self deleteBookAt:idx];
        }
    }
}


// Bookオブジェクトを返す
- (Book*) bookAtIndex: (NSInteger) index {
    [self loadBooks];
    if (books && index < [books count]) {
        return [books objectAtIndex:index];
    }
    return nil;
}

// Bookオブジェクトを返す
- (Book*) bookAtPath: (NSString*)path {
    [self loadBooks];
    for (Book* b in books) {
        if ([b.path isEqualToString:path]) {
            return b;
        }
    }
    return nil;
}

- (Book*)bookAtPathFolder: (NSString*)path folder:(NSString*)folder {
    [self loadBooks];
    if ([FileUtil exists:path]) {
        for (Book* b in books) {
            if ([b.path isEqualToString:path]) {
                if ([folder isEqualToString:@""]) {
                    return b;
                } else {
                    for (Book* fb in [b folders]) {
                        if ([fb.folderName isEqualToString:folder]) {
                            return fb;
                        }
                    }
                }
                break;
            }
        }
    } else {
        // キャッシュを削除する
        self.books = nil;
    }
    return nil;
}


// ファイルの個数を返す
- (NSInteger) bookCount {
    [self loadBooks];
    if (books) {
        return [books count];
    } else {
        return 0;
    }
}

// modifiedTimeの一番新しい値
- (NSTimeInterval) lastModifiedTime {
    [self loadBooks];
    NSTimeInterval lm = 0;
    for (Book* b in books) {
        if (b.modifiedTime > lm) {
            lm = b.modifiedTime;
        }
    }
    return lm;
}


+ (void)purge {
    [self bookFiles].books = nil;
}

- (void) dealloc {
    self.books = nil;
    [super dealloc];
}

@end
