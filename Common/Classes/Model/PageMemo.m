//
//  PageMemo.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/13.
//  Copyright 2011 SAT. All rights reserved.
//

#import "PageMemo.h"
#import "Book.h"
#import "AppUtil.h"
#import "FileUtil.h"
#import "NSString_Util.h"
#import "PageMemoComment.h"
#import "NSString_Util.h"
#import "ZipArchive.h"

@interface PageMemo() 
@property(nonatomic,retain)NSString* baseDir;
@property(nonatomic,retain)NSMutableArray* writingFiles;
@property(nonatomic,retain)NSMutableArray* attachmentFiles;
@property(nonatomic,retain)NSMutableArray* commentFiles;
@property(nonatomic,retain)NSMutableDictionary* conf;

@property(nonatomic,readonly)NSString* writingPath;
@property(nonatomic,readonly)NSString* attachmentPath;
@property(nonatomic,readonly)NSString* commentPath;
@property(nonatomic,readonly)NSString* confPath;
@end


@implementation PageMemo
@synthesize baseDir, writingFiles, attachmentFiles, commentFiles, conf;

#pragma mark - private

-(NSString*) writingPath {
    return [baseDir addPath:@"writing"];
}
-(NSString*) attachmentPath {
    return [baseDir addPath:@"attachment"];
}
-(NSString*) commentPath {
    return [baseDir addPath:@"comment"];
}
-(NSString*) confPath {
    return [baseDir addPath:@"conf/conf.plist"];
}

-(void) countFiles {
    if (!writingFiles) {
        if ([FileUtil exists:self.writingPath]) {
            NSArray *filter = [NSArray arrayWithObjects:@"jpg",@"png",nil];

            self.writingFiles = [NSMutableArray arrayWithArray:[FileUtil files:self.writingPath extensions:filter]];
        } else {
            self.writingFiles = [NSMutableArray array];
        }
    }
}
-(void)countAttachments {
    if (!attachmentFiles) {
        if ([FileUtil exists:self.attachmentPath]) {
            NSArray *filter = [NSArray arrayWithObjects:@"jpg",@"png",nil];

            self.attachmentFiles = [NSMutableArray arrayWithArray:[FileUtil files:self.attachmentPath extensions:filter]];
        } else {
            self.attachmentFiles = [NSMutableArray array];
        }
    }
}
-(void)loadConf {
    if (!conf) {
        if ([FileUtil exists:self.confPath]) {
            self.conf = [NSMutableDictionary dictionaryWithContentsOfFile:self.confPath];
        } else {
            self.conf = [NSMutableDictionary dictionary];
        }
    }
}
-(void)saveConf {
    NSLog(@"writeToFile:%@ object: %@", self.confPath, conf);
    [FileUtil mkdir:[self.confPath dirname]];
    [conf writeToFile:self.confPath atomically:NO];
}


#pragma mark - 設定
// 表示設定を返す
- (BOOL)isVisible:(NSString*)udid index:(int)index {
    [self loadConf];
    NSNumber* v = [conf valueForKey:[udid add:[NSString stringWithFormat:@"-%i-visible", index]]];
    
    if (v == nil) {
        NSLog(@"Visibility YES");

        return YES;
    } else {
        
                return [v boolValue];
    }
}
// 表示設定を変更する
- (void)setVisible:(BOOL)visible udid:(NSString *)udid index:(int)index {
    [self loadConf];
    NSLog(@"configuration : %@", conf);
    [conf setValue:[NSNumber numberWithBool:visible] forKey:[udid add:[NSString stringWithFormat:@"-%i-visible", index]]];
    [self saveConf];
}



#pragma mark - 落書き

// 落書きレイヤーの数を返す
- (NSInteger)writingCount {
    [self countFiles];
    return [writingFiles count];
}

// 落書きレイヤーのUDIDを返す
-(NSString*)writingUdidAt:(NSInteger)idx {
    [self countFiles];
    NSString* fname = [[writingFiles objectAtIndex:idx]basename];
    NSArray* matches = [fname match:@"^\\d+_(.+)$"];
    if ([matches count] > 1) {
        return [matches objectAtIndex:1];
    } else {
        return nil;
    }
}

// 落書きを返す
- (UIImage*)writingImageAt:(NSInteger)idx {
    [self countFiles];
    if (0 <= idx && idx < [writingFiles count]) {
        NSString* path = [writingFiles objectAtIndex:idx];
        return [UIImage imageWithContentsOfFile:path];
    } else {
        return nil;
    }
}
// 自分の落書きを返す
- (UIImage*)myWritingImage {
    [self countFiles];
    NSString* udid = [AppUtil udid];
    for (NSString* f in writingFiles) {
        if ([f contains:udid]) {
            return [UIImage imageWithContentsOfFile:f];
        }
    }
    return nil;
}
// 落書きを重ねた画像を返す
- (UIImage*)layeredWritingImage {
    [self countFiles];
    BOOL begin = NO;
    CGSize size;
    NSInteger cnt = [writingFiles count];
    for (int i = 0; i < cnt; i++) {
        NSString* f = [writingFiles objectAtIndex:i];
        NSString* udid = [self writingUdidAt:i];
        if ([self isVisible:udid index:i]) {
            NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
            UIImage* img = [UIImage imageWithContentsOfFile:f];
            if (!begin) {
                UIGraphicsBeginImageContext(img.size);
                size = img.size;
                begin = YES;
            }
            [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
            [pool release];
        }
    }
    UIImage* ret = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (cnt == 0) {
        ret = Nil;
    }
    return ret;
}

// リネームする
- (void)renameFiles:(NSInteger)from to:(NSInteger)to {
    [self countFiles];
    for (int i = from; i <= to; i++) {
        NSString* path = [writingFiles objectAtIndex:i];
        NSString* name = [path filename];
        NSString* prefix = [NSString stringWithFormat:@"%03d_", i];
        if (![name hasPrefix:prefix]) {
            NSString* suffix = [name substringFromIndex:[prefix length]];
            NSString* newName = [prefix add:suffix];
            NSString* newPath = [[path dirname]addPath:newName];
            [FileUtil mv:path toPath:newPath];
            [writingFiles replaceObjectAtIndex:i withObject:newPath];
        }
    }
}

// 自分の落書きが削除されていないかチェックする
- (BOOL)myWritingExists {
    [self countFiles];
    NSString* udid = [AppUtil udid];
    for (NSString* f in writingFiles) {
        if ([f contains:udid]) {
            return YES;
        }
    }
    return NO;
}

// 自分の落書きをセットする
- (void)setMyWritingImage:(UIImage*)img {
    [self countFiles];
    NSString* udid = [AppUtil udid];
    NSString* path = [self.writingPath 
                      stringByAppendingFormat:@"/%03d_%@.png",
                      [writingFiles count],
                      udid];
    BOOL newFile = YES;
    if (img) {
        NSData* d = UIImagePNGRepresentation(img);
        if (![FileUtil directoryExistsAtAbsolutePath:[path dirname]]) {
            [FileUtil mkdir:[path dirname]];
        }
        [d writeToFile:path atomically:NO];
        if (newFile) {
            [writingFiles addObject:path];
        }
        [self countFiles];
    } else {
        if ([FileUtil exists:path]) {
            [FileUtil rm:path];
            [writingFiles removeObject:path];
        }
    }
}

- (void)removeLayerData
{
}


// 落書きレイヤーを削除する
- (void)deleteWritingAt:(NSInteger)idx {
    [self countFiles];
    NSString* path = [writingFiles objectAtIndex:idx];
    [FileUtil rm:path];
    [writingFiles removeObjectAtIndex:idx];
    [self renameFiles:idx to:[writingFiles count] - 1];
}
// 落書きレイヤーを並び替える
- (void)changeWritingOrder:(NSInteger)from to:(NSInteger)to {
    [self renameFiles:from to:to];
    [self countFiles];
}

#pragma mark - 添付ファイル

// 添付ファイルの数を返す
- (NSInteger)attachmentCount {
    [self countAttachments];
    return [attachmentFiles count];
}
- (UIImage*)attachmentImageAt:(NSInteger)idx {
    [self countAttachments];
    NSString* path = [attachmentFiles objectAtIndex:idx];
    return [UIImage imageWithContentsOfFile:path];
}

// 添付ファイルを追加する
- (void)addAttachment:(UIImage*)img {
    [self countAttachments];
    NSString* udid = [AppUtil udid];
    NSString* fname = [[[udid add:@"_"]add:intStr([NSDate timeIntervalSinceReferenceDate])]add:@".jpg"];
    NSString* path = [self.attachmentPath addPath:fname];
    NSData* data = UIImageJPEGRepresentation(img, 0.8);
    [FileUtil mkdir:[path dirname]];
    [data writeToFile:path atomically:NO];
    [attachmentFiles addObject:path];
}
// 添付ファイルを削除する
- (void)deleteAttachmentAt:(NSInteger)idx {
    [self countAttachments];
    NSString* path = [attachmentFiles objectAtIndex:idx];
    [FileUtil rm:path];
    [attachmentFiles removeObject:path];
}

#pragma mark -コメント

// コメントを作成する
- (PageMemoComment*)createComment {
    NSString* udid = [AppUtil udid];
    NSString* fname = [intStr([NSDate timeIntervalSinceReferenceDate])add:@".txt"];
    NSString* path = [[self.commentPath addPath:udid]addPath:fname];
    return [[[PageMemoComment alloc]initWithPath:path]autorelease];
}

- (NSArray*)commentsInner:(NSString*)path 
{

    NSMutableArray* ret = [NSMutableArray array];
    if ([FileUtil directoryExistsAtAbsolutePath:path]) {
        NSArray *filter = [NSArray arrayWithObjects:@"txt",nil];

        NSArray* files = [FileUtil rfiles:path extensions:filter];
        for (NSString* file in files) {
            PageMemoComment* pmc = [[PageMemoComment alloc]initWithPath:file];
            [ret addObject:pmc];
            [pmc release];
        }
    }
    return ret;
}

// 自分のコメントの一覧を返す
- (NSArray*)myComments {
    NSString* udid = [AppUtil udid];
    return [self commentsInner:[self.commentPath addPath:udid]];
}
// すべての表示されているコメントの一覧を返す
- (NSArray*)comments {
    NSMutableArray* ret = [NSMutableArray array];

    if ([FileUtil exists:self.commentPath]) {
        int index = 0;
        for (NSString* dir in [FileUtil files:self.commentPath extensions:nil]) {
            NSString* dname = [dir filename];//ディレクトリ名がUDIDになっている
            if ([self isVisible:dname index:index]) {
                NSLog(@"testing visibility for : %@", dname);
                [ret addObjectsFromArray:[self commentsInner:dir]];
            }
            index++;
        }
    }
    return ret;
}

// コメントを削除する
- (void)deleteComment:(PageMemoComment*)comment {
    [FileUtil rm:comment.path];
}

#pragma mark - object lifecycle


// 初期化
-(id)initWithBook:(Book*)book page:(NSInteger)page {
    self = [super init];
    if (self) {
        NSString* subPath = [NSString stringWithFormat:@"bookmemo/%@/f%@/%d", 
                             [book.path lastPathComponent], 
                             (book.folderName ? book.folderName : @""),
                             page];
        self.baseDir = [AppUtil cachePath:subPath];
    
    }
    return self;
}

-(void)dealloc {
//    NSLog(@"%s", __func__);
    self.conf = nil;
    self.baseDir = nil;
    self.writingFiles = nil;
    self.attachmentFiles = nil;
    self.commentFiles = nil;
    [super dealloc];
}

#pragma mark -static

// アーカイブを作成してパスを返す
+ (NSString*)createArchive:(Book*)book {
    NSString* bookFilename = [book.path filename];
    NSString* memosDir = [AppUtil cachePath:join(@"bookmemo/", bookFilename, nil)];
    if ([FileUtil exists:memosDir]) {
        NSString* tmpPath = [AppUtil tmpPath:[[book.path filename]add:@".sbrmemo"]];
        [ZipArchive archive:memosDir toZip:tmpPath];
        return tmpPath;
    } else {
        return nil;
    }
}
// アーカイブを解凍する
+ (void)extractArchive:(NSString*)bookPath archive:(NSString*)archivePath {
    NSString* bookFilename = [bookPath filename];
    NSString* memosDir = [AppUtil cachePath:join(@"bookmemo/", bookFilename, nil)];
    [ZipArchive extract:archivePath toDir:memosDir];
}

// ページ並べ替えを一括で処理する（フォルダ名無しの場合のみ）
+ (void)arrangePageOrder:(NSString*)bookFilename movings:(NSArray*)movings {
    NSString* memosDir = [AppUtil cachePath:join(@"bookmemo/", bookFilename, @"/f", nil)];
    for (PageMoving* pm in movings) {
        NSString* tgtDir = [NSString stringWithFormat:@"%@/%d", memosDir, pm.from];
        if ([FileUtil exists:tgtDir]) {
            // 一旦テンポラリの名前に変更
            NSString* tmpDir = [NSString stringWithFormat:@"%@/tmp_%d", memosDir, pm.from];
            [FileUtil mv:tgtDir toPath:tmpDir];
        }
    }
    for (PageMoving* pm in movings) {
        NSString* tmpDir = [NSString stringWithFormat:@"%@/tmp_%d", memosDir, pm.from];
        if ([FileUtil exists:tmpDir]) {
            // テンポラリの名前から本当の名前に変更
            NSString* tgtDir = [NSString stringWithFormat:@"%@/%d", memosDir, pm.to];
            [FileUtil mv:tmpDir toPath:tgtDir];
        }
    }
    
}

@end
