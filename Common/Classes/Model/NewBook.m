//
//  NewBook.m
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/25.
//  Copyright 2011 SAT. All rights reserved.
//

#import "NewBook.h"
#import "FileUtil.h"
#import "Book.h"
#import "ZipArchive.h"
#import "ImageUtil.h"
#import "BookFiles.h"
#import "AppUtil.h"
#import "NSString_Util.h"
#import "NSArray_Util.h"

@implementation NewBook
@synthesize name, dirPath, readingPage, fileNames, originalPath;
@synthesize  isImporting, isImported, isWeirdFlag;


- (id)init {
    self = [super init];
    if (self) {
        self.dirPath = [AppUtil tmpPath:@"newbook"];
        if (![FileUtil exists:self.dirPath]) {
            [FileUtil mkdir:self.dirPath];
        }
        NSString* fnPath = [dirPath addPath:@".filenames"];
        self.fileNames = [NSMutableArray arrayWithContentsOfFile:fnPath];
        if (!fileNames) {
            self.fileNames = [NSMutableArray array];
        }
        self.name = [FileUtil read:[self.dirPath addPath:@".name"]];
        self.isImported = YES;
        self.isImporting = NO;
        self.isWeirdFlag = FALSE;
    }
    return self;
}



// メタ情報を保存する
- (void)saveMeta {
    if (![FileUtil exists:dirPath]) {
        [FileUtil mkdir:dirPath];
    }
    // 自分で作成した情報出力
    [FileUtil write:[AppUtil udid] path:[dirPath addPath:@".creation"]];
    [FileUtil write:self.name path:[dirPath addPath:@".name"]];
    [self.fileNames writeToFile:[dirPath addPath:@".filenames"] atomically:NO];
}

// フォルダに入っていない
- (BOOL)isInFolder {
    return NO;
}


- (void)openBook:(Book*)book {
    // テンポラリフォルダを削除
    [self deleteTmpdir];
    // 配列をクリア
    [fileNames removeAllObjects];
    
    //元のファイルのpathを保存
    self.originalPath = book.path;
    
    // テンポラリフォルダに解凍
    [FileUtil mkdir:dirPath];
    [ZipArchive extract:book.path toDir:dirPath];
    
    NSArray* files = [FileUtil files:self.dirPath 
                          extensions:array(@"jpg", @"png", @"gif", @"jpeg", @"jpe", nil)];
    for (int i = 0; i < [files count]; i++) {
        NSString* file = [files objectAtIndex:i];
        // テンポラリ用にリネーム。あとでPageMemoを並べ替えるためにもとの順番を覚えておく。
        NSString* fn = [NSString stringWithFormat:@"tmp-%d-%d.jpg", i, rand()];
        NSString* fnPath = [dirPath addPath:fn];
        [FileUtil mv:file toPath:fnPath];
        [fileNames addObject:fn];
    }
    self.name = [book.path basename];
    [self saveMeta];
    
}

// キャッシュしない
- (void)fetchCache:(NSInteger)pageNum size:(CGSize)size {
    // nop
}



// ページ数を返す
- (NSInteger) pageCount {
    return [fileNames count];
}
// ブックマークされているかどうか
- (BOOL) isBookmarked: (NSInteger) page {
    return NO;
}
// ブックマークする
- (void) addToBookmark: (NSInteger) page {
    //nop
}
// 表紙の画像を返す
- (UIImage*) getCoverImage:(CGSize)size {
    return [self getPageImage:0];
}
// 表示の画像を設定する
- (void) setCoverImage: (UIImage*)img {
    //nop
}
// ページの画像を返す
- (UIImage*) getPageImage: (NSInteger)pageNum {
    NSString* path = [dirPath stringByAppendingPathComponent:[fileNames objectAtIndex:pageNum]];
    return [UIImage imageWithContentsOfFile:path];
}

// サムネイル画像を返す
- (UIImage*) getThumbnailImage: (NSInteger)pageNum {
    UIImage* img = [self getPageImage:pageNum];
    return [ImageUtil shrinkClip:img toSize:CGSizeMake(SF_ICON_WIDTH, SF_ICON_HEIGHT) left:YES];
}
// ページに含まれるリンクを返す（返さない）
- (NSArray*)getPageLinks:(NSInteger)pageNum {
    return nil;
}




- (BOOL) isPDF {
    return NO;
}


- (BOOL) isPNG {
    return NO;
}


- (BOOL) isJPG {
    return NO;
}
// 画像を追加する
- (void) addPage: (UIImage*)img {
    NSString* filePath = [dirPath stringByAppendingFormat:@"/tmp-%d-%d.jpg", [fileNames count], rand()];
    NSData *data = UIImageJPEGRepresentation(img, 0.85);
    [data writeToFile:filePath atomically:NO];
    [self.fileNames addObject:[filePath lastPathComponent]];
    [self.fileNames writeToFile:[dirPath stringByAppendingPathComponent:@".filenames"] atomically:NO];
}

// 画像をすべて削除する
- (void) removeAllPages {
    [self.fileNames removeAllObjects];
    [FileUtil rm:dirPath];
    [self saveMeta];
}

// 画像を削除する
- (void) removePageAt:(NSInteger)idx {
    NSString* f = [fileNames objectAtIndex:idx];
    [FileUtil rm:[dirPath stringByAppendingPathComponent:f]];
    [fileNames removeObjectAtIndex:idx];
    [self.fileNames writeToFile:[dirPath stringByAppendingPathComponent:@".filenames"] atomically:NO];
}

// 画像を移動する
- (void) movePage:(NSInteger)from to:(NSInteger)to {
    NSString* fn = [[fileNames objectAtIndex:from]retain];
    [fileNames removeObjectAtIndex:from];
    if (to < [fileNames count]) {
        [fileNames insertObject:fn atIndex:to];
    } else {
        [fileNames addObject:fn];
    }
    [fn release];
}

// 画像を変更する
- (void) changeImage:(UIImage*)img atPage:(NSInteger)idx {
    NSString* path = [dirPath stringByAppendingPathComponent:[fileNames objectAtIndex:idx]];
    NSData *data = UIImageJPEGRepresentation(img, 0.95);
    [data writeToFile:path atomically:NO];
}



// ZIPファイルを作成する
- (void) makeZipFile: (NSString*) filePath {
    // ZIP圧縮
    ZipArchive* zip = [[ZipArchive alloc]init];
    [zip CreateZipFile2:filePath];
    NSMutableArray* movings = [NSMutableArray arrayWithCapacity:[fileNames count]];
    for (NSInteger i = 0; i < [fileNames count]; i++) {
        NSString* fn = [fileNames at:i];
        NSArray* ms = [fn match:@"^tmp-(\\d+)-(\\d+)\\.(\\w+)$"];
        NSInteger origOrder = [[ms at:1]intValue];
        if (i != origOrder) {
            [movings addObject:[PageMoving pageMoving:origOrder :i]];
        }
        NSString* path = [dirPath addPath:fn];
        [zip addFileToZip:path newname:[NSString stringWithFormat:@"%04d.jpg", i]];
    }
    // メタ情報
    [zip addFileToZip:[dirPath addPath:@".creation"] newname:@".creation"];
    [zip CloseZipFile2];
    [zip release];
    // すでにBookがある場合はサムネイルをクリアする
    Book* b = [[BookFiles bookFiles]bookAtPath:filePath];
    if (b) {
        [b deleteThumbnails];
    }
    // メモディレクトリのページ並べ替えが発生している
    if ([movings count] > 0) {
        [PageMemo arrangePageOrder:[filePath filename] movings:movings];
    }
}

// テンポラリフォルダを削除
- (void)deleteTmpdir {
    // 画像用テンポラリフォルダも削除
    NSString* tmpPath = [NSString stringWithFormat:@"%@/tmp/tmpimages",
                         NSHomeDirectory()];
    [FileUtil rm:tmpPath];
    [FileUtil rm:dirPath];
}

// テンポラリフォルダにファイルが存在する
+ (BOOL)fileExists {
    NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"/tmp/newbook"];
    if ([FileUtil exists:path]) {
        NSArray* files = [FileUtil files:path extensions:[NSArray arrayWithObject:@"jpg"]];
        return [files count] > 0;
    } else {
        return NO;
    }
}



- (void)dealloc {
    self.name = nil;
    self.dirPath = nil;
    self.fileNames = nil;
    [super dealloc];
}

@end
