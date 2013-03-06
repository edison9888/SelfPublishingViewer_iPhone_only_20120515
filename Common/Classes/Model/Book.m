//  Book.m
//

#import "Book.h"
#import "BookFiles.h"
#import "ZipFile.h"
#import "ZipEntry.h"
#import "FileUtil.h"

#import "ImageUtil.h"
#import "common.h"
#import "Bookmarks.h"
#import "URLLink.h"
#import "NSString_Util.h"
#import "AppUtil.h"
#import "ZipArchive.h"
#import "PageEntry.h"
#import <QuartzCore/QuartzCore.h>

@implementation Book
@synthesize name, path, uploadingPath,folderName, modifiedTime, cachedPdfImages, isInFolder, pages, extractedAtDir, isImported, isWeirdFlag;
@synthesize bookPages = _bookPages;
@synthesize originPath = _originPath;
@synthesize bookName = _bookName;
@synthesize bookLocation = _bookLocation;

@synthesize bookDataLocation = _bookDataLocation;


@synthesize importOperation = _importOperation;
@synthesize isImporting;


- (void)importOperationDone:(BookImportOperation *)operation
{
    //NSLog(@"Import Operation Done");

    assert([NSThread isMainThread]);
    assert([operation isKindOfClass:[BookImportOperation class]]);
    assert(operation == self.importOperation);
    
  
    
    if (operation.error != nil) {
        NSLog(@"Failed to import");
    } else {

        NSString *oldPath = [self.bookLocation stringByAppendingString:@"_ImportDir"];
        NSString *newPath = self.bookLocation;
        NSError *error = nil;
        [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:&error];
        if (error) {
            NSLog(@"%@",error.localizedDescription);
            // handle error
        } else {
            isImported = TRUE;
        }
        isImporting = FALSE;
        
    }
    
    [self.importOperation release];
    self.importOperation = nil;

}

- (void)startBookImportOperation
{
    //NSLog(@"Will start the book Import Operation");
    assert(self.importOperation == nil);
    self.importOperation = [[[BookImportOperation alloc] initWithBook:path] retain];
    assert(self.importOperation != nil);
    
    [self.importOperation setQueuePriority:NSOperationQueuePriorityNormal];
    
    [[OperationManager sharedManager] addCPUOperation:self.importOperation finishedTarget:self action:@selector(importOperationDone:)];
    isImporting = TRUE;
    
}



-(NSString*)basePath {
    NSString* fname = self.folderName;
    fname = fname ? fname : @"";
    return [NSString stringWithFormat:@"%@/Library/Caches/Bookprefs/%@/f%@",
            NSHomeDirectory(),
            [self.path lastPathComponent],
            fname];
}

- (NSString*)cachePath {
    return [NSString stringWithFormat:@"%@/cache/", [self basePath]];
}

- (NSString*) propPath {
    return [NSString stringWithFormat:@"%@/prop.plist", [self basePath]];
}
- (NSString*) coverPath {
    return [NSString stringWithFormat:@"%@/cover.jpg", [self cachePath]];
}
- (NSString*) thumbPath:(NSInteger)page {
    return [NSString stringWithFormat:@"%@/thumb%d.jpg", [self cachePath], page];
}

- (void) mod {
    modifiedTime = [NSDate timeIntervalSinceReferenceDate];
}

// ファイルのほうが新しいかどうかをチェックする
- (BOOL)isCoverModifiedSince:(NSTimeInterval)since {
    NSTimeInterval ftime = [[FileUtil mtime:self.path]timeIntervalSinceReferenceDate];
    if (ftime > since) {
        return YES;
    } else if (modifiedTime > since) {
        return YES;
    } else {
        return NO;
    }
     
}

- (void)loadPrefs {
    // 設定値をロードする
    NSString* propPath = [self propPath];
    if ([FileUtil exists:propPath]) {
        props = [NSMutableDictionary dictionaryWithContentsOfFile:propPath];
    } else {
        NSString* dir = [propPath stringByDeletingLastPathComponent];
        if (![FileUtil exists:dir]) {
            [FileUtil mkdir:dir];
        }
        props = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"order", @"0", nil];
    }
    [props retain];
}


CGAffineTransform aspectFit(CGRect innerRect, CGRect outerRect) {
    CGFloat scaleFactor = MIN(outerRect.size.width/innerRect.size.width, outerRect.size.height/innerRect.size.height);
    CGAffineTransform scale = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    CGRect scaledInnerRect = CGRectApplyAffineTransform(innerRect, scale);
    CGAffineTransform translation = 
    CGAffineTransformMakeTranslation((outerRect.size.width - scaledInnerRect.size.width) / 2 - scaledInnerRect.origin.x, 
                                     (outerRect.size.height - scaledInnerRect.size.height) / 2 - scaledInnerRect.origin.y);
    return CGAffineTransformConcat(scale, translation);
}




- (id) initWithPath: (NSString*) bookPath 
{
    
    self = [super init];
    self.path = bookPath;
    
    self.originPath = bookPath;
    self.name = [bookPath lastPathComponent];
    self.bookName = [[bookPath lastPathComponent] stringByDeletingPathExtension];
    
    self.bookLocation = [[AppUtil bookRootDir] stringByAppendingPathComponent:self.name];
    self.bookDataLocation = [self.bookLocation stringByAppendingPathComponent:@"Data"];

    unrar = [[Unrar4iOS alloc] init];
    
    isImported = [FileUtil directoryExistsAtAbsolutePath:self.bookLocation];
    
    isImporting = FALSE;
    
    self.cachedPdfImages = [NSMutableDictionary dictionary];
    links = [[NSMutableDictionary alloc]init];
    modifiedTime = 0;
    [self loadPrefs];
    isInFolder = NO;
    return self;

   
}

// 内部用コンストラクタ
- (id) initWithEntries: (NSString*) bookPath 
                  name:(NSString*)fName 
               entries:(NSMutableArray*)entries {
    self = [super init];
    self.path = bookPath;

    self.folderName = [fName lastPathComponent];
    self.name = fName;
    NSString *_bookFileName = [self.name lastPathComponent];

    self.uploadingPath = [[AppUtil bookExportDir] stringByAppendingPathComponent:_bookFileName];

    [self loadPrefs];
    pages = [entries retain];
    modifiedTime = 0;
    isInFolder = YES;
    return self;
}

// プロパティを保存する
- (void) saveProp {
    NSString* propPath = [self propPath];
    [props writeToFile:propPath atomically:NO];
    [self mod];
}

// Bookオブジェクトを生成して返す
+ (id) bookWithPath: (NSString*) bookPath {
    
    return [[[Book alloc]initWithPath:bookPath]autorelease];
}

// PDFかどうか
- (BOOL) isPDF {
    return [[[path pathExtension]lowercaseString]isEqualToString:@"pdf"];
}

//PNG, JPG
- (BOOL) isPNG {
    return [[[path pathExtension]lowercaseString]isEqualToString:@"png"];
}
- (BOOL) isJPG {
    return [[[path pathExtension]lowercaseString]isEqualToString:@"jpg"];
}

- (BOOL) isRAR {
    BOOL rar = [[[path pathExtension]lowercaseString]isEqualToString:@"rar"];
    BOOL cbr = [[[path pathExtension]lowercaseString]isEqualToString:@"cbr"];
    return (rar || cbr);
}

- (BOOL) isZIP {
    BOOL zip = [[[path pathExtension]lowercaseString]isEqualToString:@"zip"];
    BOOL cbz = [[[path pathExtension]lowercaseString]isEqualToString:@"cbz"];
    return (zip || cbz);
}

- (BOOL) isDOC {
    BOOL doc = [[[path pathExtension]lowercaseString]isEqualToString:@"doc"];
    BOOL docx = [[[path pathExtension]lowercaseString]isEqualToString:@"docx"];
    return (doc || docx);
}

- (BOOL) isPPT {
    BOOL ppt = [[[path pathExtension]lowercaseString]isEqualToString:@"ppt"];
    BOOL pptx = [[[path pathExtension]lowercaseString]isEqualToString:@"pptx"];
    return (ppt || pptx);
}

- (BOOL) isXLS {
    BOOL xls = [[[path pathExtension]lowercaseString]isEqualToString:@"xls"];
    BOOL xlsx = [[[path pathExtension]lowercaseString]isEqualToString:@"xlsx"];
    return (xls || xlsx);
}
// 並び順を設定
- (void) setOrder:(NSInteger)order {
    if (self.order != order) {
        [props setValue:[NSString stringWithFormat:@"%d", order] forKey:@"order"];
        [self saveProp];
    }
}

// 並び順
- (NSInteger) order {
    NSString* ov = [props valueForKey:@"order"];
    return [ov intValue];
}

// 読み途中のページ
- (void) setReadingPage:(NSInteger)readingPage {
    if (self.readingPage != readingPage) {
        [props setValue:[NSString stringWithFormat:@"%d", readingPage] forKey:@"readingPage"];
        [self saveProp];
    }
}

// 読み途中のページ
- (NSInteger)readingPage {
    NSString* rp = [props valueForKey:@"readingPage"];
    return [rp intValue];
}

// 再読み込みを予約する
- (void)invalidate {
    [pages removeAllObjects];
    [pages release];
    pages = nil;
}


// ページ一覧をロードする


-(void) loadPages 
{
    if (isImported) {
       
        if (self->_bookPages != nil) {
            return;
        }
        if (self.isRAR) {
            [self loadTheOldPages];
        } else{
            NSString *imageFilter = @"self ENDSWITH '.jpg' OR self ENDSWITH '.png' OR self ENDSWITH '.JPG' OR self ENDSWITH '.PNG' OR self ENDSWITH '.jpeg' OR self ENDSWITH '.JPEG'";
            
            NSPredicate *imageFilterPredicate = [NSPredicate predicateWithFormat:imageFilter];
            NSArray *bookPageEntries = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.bookDataLocation error:nil];
            
            
            NSArray *bookImageFiles = [bookPageEntries filteredArrayUsingPredicate:imageFilterPredicate];
            self->_bookPages = [[NSMutableArray arrayWithArray:bookImageFiles] retain];
            NSArray *theSortedStrings = [bookImageFiles sortedArrayUsingComparator:^(id obj1, id obj2) {
                return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
            }];
            self->_bookPages = [[NSMutableArray arrayWithArray:theSortedStrings] retain];
        }
      
    } else {
       
        [self loadTheOldPages];
    }
}

- (void) loadTheOldPages 
{
    if (self.isPDF) {
        if (pdfPageCount > 0) {
            return;
        }
        CFURLRef url = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)path,
                                                     kCFURLPOSIXPathStyle, 0);
        CGPDFDocumentRef document = CGPDFDocumentCreateWithURL (url);
        pdfPageCount = CGPDFDocumentGetNumberOfPages(document);
        CFRelease(url);
        CGPDFDocumentRelease(document);
        [props setValue:@"0" forKey:@"hasFolders"];
        [self saveProp];
    } else if (self.isPNG) {;
        [props setValue:@"0" forKey:@"hasFolders"];
        [self saveProp];
    } else if (self.isJPG) {;
        [props setValue:@"0" forKey:@"hasFolders"];
        [self saveProp];
    } else if (self.isRAR) {
        if (pages != nil) {
            return;
        }
        
        NSLog(@"isRAR detected");
        
        @try {
            BOOL ok = [unrar unrarOpenFile:path];
            if (ok) {
                NSArray * files = [unrar unrarListFiles];
                for (NSString * filename in files) {
                    NSLog(@"File: %@", filename);
                }
                NSArray * entries = [unrar unrarListFiles];
                
                pages = [[NSMutableArray arrayWithCapacity:[entries count]]retain];
                self->_bookPages = [[NSMutableArray alloc] init];
                folders = [[NSMutableArray array]retain];
                
                int entryindex = 0;
                
                for (NSString * file in files) {
                    NSString * ext = [[file pathExtension] lowercaseString];
                    NSLog(@"extension: %@", ext);
                    if ([ext isEqualToString:@"png"] || [ext isEqualToString:@"jpg"] || [ext isEqualToString:@"jpeg"] || [ext isEqualToString:@"jpe"]|| [ext  isEqualToString:@"gif"]) 
                    {
                        // Extract the stream
                        // NSData * fileData = [unrar extractStream:[files objectAtIndex:entryindex]];
                        
                        [pages addObject:file];
                        [self->_bookPages addObject:file];
                        NSString * folder = [file stringByDeletingLastPathComponent];
                        
                        if (![folders containsObject:folder]) {
                            [folders addObject:folder];
                        }
                        
                    }
                    entryindex++;
                }
            }
            else{
                NSLog(@"RAR Open failed.");
            }
            [unrar unrarCloseFile];
            
        }
        @catch (NSException* exc) {
            NSLog(@"rar/cbr open failed. %@", [exc description]);
        }
        @finally {
            //[unrar release];
        }
    }
    else {
        if (pages != nil) {
            return;
        }
                
        ZipFile* zip = [[ZipFile alloc] initWithFileAtPath:path];
              
        @try {
            [zip open];
            
        
            NSArray* entries = [zip entries];
            
            
            pages = [[NSMutableArray arrayWithCapacity:[entries count]]retain];
            folders = [[NSMutableArray array]retain];
            for (ZipEntry* ent in entries) {
                NSString* ext = [[ent.displayName pathExtension]lowercaseString];
                if ([ext isEqualToString:@"png"] || [ext isEqualToString:@"jpg"] || [ext isEqualToString:@"jpeg"] || [ext isEqualToString:@"jpe"]|| [ext  isEqualToString:@"gif"]) 
                {
                    [pages addObject:ent];
                    NSString* folder = [ent.displayName stringByDeletingLastPathComponent];
                    
                    if (![folders containsObject:folder]) {
                        [folders addObject:folder];
                        //NSLog(@"%s / %@", __func__, folder);
                    }
            
                } else {
                    NSString* n = [ent.displayName lastPathComponent];
                    if ([n isEqualToString:@".creation"]) {
                        NSString* crdata = [[NSString alloc]initWithData:[zip read:ent]
                                                                encoding:NSUTF8StringEncoding];
                        [props setValue:crdata forKey:@"creator"];
                        [self saveProp];
                        [crdata release];
                    }
                }
            }
            
    
            [zip close];
            [props setValue:[folders count] > 1 ? @"1" : @"0" forKey:@"hasFolders"];
            [self saveProp];
        }
        @catch (NSException* exc) {
            //NSLog(@"zip open failed. %@", [exc description]);
        }
        @finally {
            [zip release];
        }
    }
}

-(BOOL)isSelfMade 
{
    return [[AppUtil udid] isEqualToString:[props valueForKey:@"creator"]];
}


// このBookに含まれるフォルダBookの配列を返す
- (NSArray*)folders {
    [self loadPages];
    if (!folderBooks) {
        NSMutableArray* ret = [NSMutableArray array];
        for (NSString* folName in folders) {
            NSString* n = [self.name stringByAppendingFormat:@"!#%@", folName];
            NSMutableArray* entries = [NSMutableArray array];
            for (ZipEntry* ent in pages) {
                if ([ent.displayName hasPrefix:folName]) {
                    [entries addObject:ent];
                }
            }
            Book* b = [[[Book alloc]initWithEntries:path
                                              name:n
                                           entries:entries]retain];
            [ret addObject:b];
            [b release];
        }
        folderBooks = [ret retain];
    }
    return folderBooks;
}

// 複数のフォルダが存在する
-(BOOL)hasFolders {
    NSString* hasFolders = [props valueForKey:@"hasFolders"];
    if (hasFolders) {
        return [hasFolders intValue] == 1;
    } else {
        [self loadPages];
        return ([folders count] > 1);
    }
    
}
     


// ページのファイル名を返す
- (NSString*) getPageFilename: (NSInteger) pageNum 
{
    [self loadPages];

    if (isImported) {

        if (pageNum < [self.bookPages count]) {
            return [self.bookPages objectAtIndex:pageNum];
        }

    } else {
        if (self.isPDF) {
            ZipEntry* page = [pages objectAtIndex:pageNum];
            return [page.displayName lastPathComponent];
        } else {
            return @"";
        }
    }
       return nil;
}

- (NSString*) getBookPagePath: (NSInteger) pageNum 
{
    [self loadPages];

    if (isImported) {
        
        if (pageNum < [self.bookPages count]) {
            NSString *filename = [self.bookPages objectAtIndex:pageNum];
            
            return [self.bookDataLocation stringByAppendingPathComponent:filename];
       
        }


    } else {
        if (self.isPDF) {
             ZipEntry* page = [pages objectAtIndex:pageNum];
             return [page.displayName lastPathComponent];
        } else {
             return @"";
        }

    }
    
    return nil;
}


// ページの表示名を返す
- (NSString*) getPageDisplayName: (NSInteger) pageNum {
    if (self.isPDF) {
        return [NSString stringWithFormat:@"%@ #%dPage", self.name, pageNum];
    } else if (self.isPNG) {
        return [NSString stringWithFormat:@"%@ #%dPage", self.name, pageNum];
    } else if (self.isJPG) {
        return [NSString stringWithFormat:@"%@ #%dPage", self.name, pageNum];
    } else if (self.isRAR) {
        return [NSString stringWithFormat:@"%@ #%dPage", self.name, pageNum];
    }
    else {
        ZipEntry* ze = [pages objectAtIndex:pageNum];
        return [NSString stringWithFormat:@"%@/%@", self.name, [ze.displayName lastPathComponent]];
    }
}


// 表示の画像を設定する
- (void) setCoverImage: (UIImage*)img {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
    if (img.size.width > img.size.height) {
        img = [ImageUtil clip:img rect:CGRectMake(0, 0, 0.5, 1)];
    }
    UIImage* cimg = [ImageUtil shrink:img toSize:CGSizeMake(2 * SF_ICON_WIDTH, 2 * SF_ICON_HEIGHT)];
    NSData* data = UIImageJPEGRepresentation(cimg, 0.9); // releaseしてはいけない
    
    //NSLog(@"Cover Path : %@", [self coverPath]);
    NSString* f = [self coverPath];
    [FileUtil mkdir:[f stringByDeletingLastPathComponent]];
    [FileUtil rm:f];
    if (![data writeToFile:f atomically:NO]) {
        //NSLog(@"writeToFile failed.");
    } else {
        //NSLog(@"write to %@ / %s", f, __func__);
    }
    [self mod];
    [pool release];
}

// 最後に開かれたBookかどうかを返す
- (BOOL) isLastOpened {
    NSUserDefaults* ud = [AppUtil config];
    NSString* lastOpenBookPath = [ud valueForKey:@"lastOpenBookPath"];
    NSString* lastFolder = [ud valueForKey:@"lastOpenBookFolder"];
    if ([self.path isEqualToString:lastOpenBookPath]) {
        if ((self.folderName == nil && lastFolder == nil)
            || ([self.folderName isEqualToString:lastFolder])) {
            return YES;
        }
    }
    return NO;
}




- (NSArray*) getLinks:(CGPDFPageRef)page size:(CGSize)size {
    
    CGPDFDictionaryRef pageDictionary = CGPDFPageGetDictionary(page);
    
    CGPDFArrayRef outputArray;
    if(!CGPDFDictionaryGetArray(pageDictionary, "Annots", &outputArray)) {
        return nil;
    }
    
    int arrayCount = CGPDFArrayGetCount( outputArray );
    if(!arrayCount) {
        //continue;
    }
    
    NSMutableArray* ret = [NSMutableArray array];
    
    for( int j = 0; j < arrayCount; ++j ) {
        CGPDFObjectRef aDictObj;
        if(!CGPDFArrayGetObject(outputArray, j, &aDictObj)) {
            return nil;
        }
        
        CGPDFDictionaryRef annotDict;
        if(!CGPDFObjectGetValue(aDictObj, kCGPDFObjectTypeDictionary, &annotDict)) {
            return nil;
        }
        
        CGPDFDictionaryRef aDict;
        if(!CGPDFDictionaryGetDictionary(annotDict, "A", &aDict)) {
            return nil;
        }
        
        CGPDFStringRef uriStringRef;
        if(!CGPDFDictionaryGetString(aDict, "URI", &uriStringRef)) {
            return nil;
        }
        
        CGPDFArrayRef rectArray;
        if(!CGPDFDictionaryGetArray(annotDict, "Rect", &rectArray)) {
            return nil;
        }
        
        int arrayCount = CGPDFArrayGetCount( rectArray );
        CGPDFReal coords[4];
        for( int k = 0; k < arrayCount; ++k ) {
            CGPDFObjectRef rectObj;
            if(!CGPDFArrayGetObject(rectArray, k, &rectObj)) {
                return nil;
            }
            
            CGPDFReal coord;
            if(!CGPDFObjectGetValue(rectObj, kCGPDFObjectTypeReal, &coord)) {
                return nil;
            }
            
            coords[k] = coord;
        }               
        
        char *uriString = (char *)CGPDFStringGetBytePtr(uriStringRef);
        
        NSString *uri = [NSString stringWithCString:uriString encoding:NSUTF8StringEncoding];
        CGRect rect = CGRectMake(coords[0],coords[1],coords[2],coords[3]);
        CGPDFInteger pageRotate = 0;
        CGPDFDictionaryGetInteger( pageDictionary, "Rotate", &pageRotate ); 
        CGRect pageRect = CGRectIntegral( CGPDFPageGetBoxRect( page, kCGPDFMediaBox ));
        if( pageRotate == 90 || pageRotate == 270 ) {
            CGFloat temp = pageRect.size.width;
            pageRect.size.width = pageRect.size.height;
            pageRect.size.height = temp;
        }
        
        rect.size.width -= rect.origin.x;
        rect.size.height -= rect.origin.y;
        
        CGAffineTransform trans = CGAffineTransformIdentity;
        trans = CGAffineTransformTranslate(trans, 35, pageRect.size.height+150);
        trans = CGAffineTransformScale(trans, 1.15, -1.15);
        
        rect = CGRectApplyAffineTransform(rect, trans);
        
        //RectLog(rect, uri);
        URLLink* ul = [[URLLink alloc]init];
        // ページ上の割合
        ul.rect = CGRectMake(rect.origin.x / size.width,
                             rect.origin.y / size.height,
                             rect.size.width / size.width,
                             rect.size.height / size.height);
        ul.url = [NSURL URLWithString:uri];
        
        [ret addObject:ul];
        [ul release];
    }
    return ret;
}



// PDFファイルの画像を返す
- (UIImage*) getPDFPageImageInner: (NSInteger)pageNum size:(CGSize)size loadLink:(BOOL)loadLink 
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
    CFURLRef url = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)path,
                                                 kCFURLPOSIXPathStyle, 0);
    CGPDFDocumentRef document = CGPDFDocumentCreateWithURL (url);
    CFRelease(url);
    // ページ
    CGPDFPageRef page = CGPDFDocumentGetPage(document, pageNum + 1);
    CGRect pdfPageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);

    BOOL fitToAspect = TRUE;
    
    if (pdfPageRect.size.width > 2000) {
        fitToAspect = FALSE;
    }
    
    if (pdfPageRect.size.height > 2000) {
        fitToAspect = FALSE;
    }
   
    isWeirdFlag = !fitToAspect;
    
    
    if ([[[UIDevice currentDevice] model] contains:@"iPad"]) {
        size.width *= 2;
        size.height *= 2;
    }
    // 横長ページの場合
    
    if (!([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0))) {
        // Retina display
        size.width /= 2;
        size.height /= 2;
    }
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, 
                                                 size.width, 
                                                 size.height, 
                                                 8,                      /* bits per component*/
                                                 size.width * 8,   /* bytes per row */
                                                 colorSpace, 
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextClipToRect(context, CGRectMake(0, 0, size.width, size.height));
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    CGRect contextRect = CGContextGetClipBoundingBox(context);
   

    
    if (fitToAspect) {
        CGAffineTransform tr = aspectFit(pdfPageRect, contextRect);
        CGContextConcatCTM(context, tr);
    }

    
    
    CGContextDrawPDFPage(context, page);
    
    CGImageRef image = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    UIImage *uiImage = [[UIImage alloc]initWithCGImage:image];
    CGImageRelease(image);
    
    NSString* pageStr = [NSString stringWithFormat:@"%d", pageNum];
    if (loadLink) {
        NSArray* urlLinks = [links objectForKey:pageStr];
        if (!urlLinks) {
            urlLinks = [self getLinks:page size:size];
            if (!urlLinks) {
                urlLinks = [NSArray array];
            }
            [links setValue:urlLinks forKey:pageStr];
        }
    }
    
    
    // ドキュメント
    //CGPDFPageRelease(page);
    CGPDFDocumentRelease(document);
    [pool release];
    return [uiImage autorelease];
}

// PDFファイルの画像を返す
- (UIImage*) getPDFPageImage: (NSInteger)pageNum size:(CGSize)size {
    @synchronized(self) {
        UIImage* cached = [cachedPdfImages objectForKey:[NSNumber numberWithInt:pageNum]];
        if (!cached) {
            //NSLog(@"cache miss:%d", pageNum);
            cached = [self getPDFPageImageInner:pageNum size:size loadLink:YES];
            [cachedPdfImages setObject:cached forKey:[NSNumber numberWithInt:pageNum]];
        } else {
            //NSLog(@"cache hit:%d", pageNum);
        }
        return cached;
    }
}


- (UIImage*) getJPGPageImage: (NSInteger)pageNum size:(CGSize)size {
    
    NSString *imagePath = self.path;    
    return [UIImage imageWithContentsOfFile:imagePath];  
}

- (UIImage*) getPNGPageImage: (NSInteger)pageNum size:(CGSize)size {
    NSString *imagePath = self.path;
    
    return [UIImage imageWithContentsOfFile:imagePath];  
}



// 2ページぶんキャッシュする
- (void)fetchCache:(NSInteger)pageNum size:(CGSize)size {
    if (self.isPDF) {
        @synchronized(self) {
            // 遠いページのキャッシュを削除する
            for (NSNumber* p in [cachedPdfImages allKeys]) {
                if (abs([p intValue] - pageNum) > 2) {
                    [cachedPdfImages removeObjectForKey:p];
                    //NSLog(@"cache remove:%d", [p intValue]);
                }
            }
            
            // キャッシュする
            NSInteger l = MIN(pageNum + 2, [self pageCount] - 1);
            for (NSInteger pg = pageNum; pg <= l; pg++) {
                UIImage* img = [cachedPdfImages objectForKey:[NSNumber numberWithInt:pg]];
                if (!img) {
                    img = [self getPDFPageImageInner:pg size:size loadLink:YES];
                    [cachedPdfImages setObject:img forKey:[NSNumber numberWithInt:pg]];
                    //NSLog(@"cached:%d", pg);
                }
            }
        }
    }
}

// Zipファイルの画像を返す
- (UIImage*) getZIPPageImage: (NSInteger)pageNum {
    [self loadTheOldPages];
    ZipFile* zip = [[ZipFile alloc] initWithFileAtPath:path];
    @try {
        [zip open];
        ZipEntry* page = [pages objectAtIndex:pageNum];
        NSData* data = [zip read:page];
        [zip close];
        if (data) {
            UIImage * img = [UIImage imageWithData:data];
            //[data release];
            return img;
        } else {
            @throw [NSException exceptionWithName:@"ZipLoadException"
                                           reason:@"ページを開けません"
                                         userInfo:nil];
        }
    } @finally {
        [zip release];
    }
}

- (UIImage*) getRARPageImage: (NSInteger)pageNum {
    [self loadTheOldPages];
    return [UIImage imageWithData:[unrar extractStream:[pages objectAtIndex:pageNum]]];
}

- (UIImage*) getBookPageImage: (NSInteger)pageNum 
{
    if (self.isRAR) {
        return [self getRARPageImage:pageNum];
    }
    [self loadPages];
    NSString *imageLocation = [self.bookDataLocation stringByAppendingPathComponent:[self->_bookPages objectAtIndex:pageNum]];
    //NSLog(@"imageLocation : %@", imageLocation);
    return [UIImage imageWithContentsOfFile:imageLocation];
}


// Book内の指定ページを枠に入るように画像として返す
- (UIImage*) getPageImage: (NSInteger)pageNum {
    //[self loadPages];
    UIImage *pageImage = nil;

    if (isImported) {
        pageImage = [self getBookPageImage:pageNum];
    } else {
        if (pageNum < [self pageCount]) {
            if (self.isPDF) {
                return [self getPDFPageImage:pageNum size:CGSizeMake(BOOK_PDF_WIDTH, BOOK_PDF_HEIGHT)];
            } else if (self.isJPG) {
                return [self getJPGPageImage:pageNum size:CGSizeMake(BOOK_PDF_WIDTH, BOOK_PDF_HEIGHT)];
            } else if (self.isPNG) {
                return [self getPNGPageImage:pageNum size:CGSizeMake(BOOK_PDF_WIDTH, BOOK_PDF_HEIGHT)];
            } else if (self.isRAR) {
                return [self getRARPageImage:pageNum];
            } else if (self.isZIP) {
                return [self getZIPPageImage:pageNum];
            } else{
                return nil;
            }
        }
    }
    return pageImage;
}

-(UIImage *)getHighResPDFImage:(NSInteger)pageNum{
    UIImage * img = [self getPDFPageImageInner:pageNum size:CGSizeMake(2.5 * 640, 2.5 * 960) loadLink:YES];
    NSLog(@"large pdf image size: %f by %f", img.size.width, img.size.height);
    return img;
}

// サムネイル画像ファイルを生成する
- (void) makeThumbnail: (NSInteger) page 
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];

    UIImage* img;
    UIImage* pageImg = [self getPageImage:page];
    
    if (pageImg) {
        img = [ImageUtil shrinkClip:pageImg toSize:CGSizeMake(2 * SF_ICON_WIDTH, 2 * SF_ICON_HEIGHT) left:YES];

    } else {
    
        if (self.isPDF) {

            img = [self getPDFPageImageInner:page size:CGSizeMake(2 * SF_ICON_WIDTH, 2 * SF_ICON_HEIGHT) loadLink:NO];

        }else if (self.isPNG) {
            img = [self getPNGPageImage:page size:CGSizeMake(2 * SF_ICON_WIDTH, 2 * SF_ICON_HEIGHT)];
        }else if (self.isJPG) {
            img = [self getJPGPageImage:page size:CGSizeMake(3 * SF_ICON_WIDTH, 2 * SF_ICON_HEIGHT)];
        }else if (self.isRAR) {
            img = [self getRARPageImage:page];
        }else if (self.isDOC) {
            img = [UIImage imageNamed:@"Word.png"];
        }else if (self.isPPT) {
            img = [UIImage imageNamed:@"PowerPoint.png"];
        }else if (self.isXLS) {
            img = [UIImage imageNamed:@"Excel.png"];
        }
        else {
        img = [ImageUtil shrinkClip:[self getZIPPageImage:page] 
                             toSize:CGSizeMake(2 * SF_ICON_WIDTH, 2 * SF_ICON_HEIGHT) 
                               left:YES];
        }
    }
    NSData* data = UIImageJPEGRepresentation(img, 0.9); // releaseしてはいけない
    NSString* f = [self thumbPath:page];
    [FileUtil mkdir:[f stringByDeletingLastPathComponent]];
    if (![data writeToFile:f atomically:NO]) {
        @throw [NSException exceptionWithName:@"FileWriteException"
                                       reason:@"failed to write thumbnail image"
                                     userInfo:nil];
    }
    [pool release];
}

// サムネイル画像を返す
- (UIImage*) getThumbnailImage:(NSInteger) page 
{
    
    NSString* f = [self thumbPath:page];
    if (![FileUtil exists:f]) {
        @try {
            [self makeThumbnail:page];
        } @catch (NSException* ex) {
            //NSLog(@"%@", [ex description]);
        }
    }
    UIImage* img = [UIImage imageWithContentsOfFile:f];
    if (img) {
        return img;
    } else {
        [FileUtil rm:f];
        return nil;
    }
}


// 表紙の画像を返す
- (UIImage*) getCoverImage:(CGSize)size {
    NSString* f = [self coverPath];
    if (![FileUtil exists:f]) {
        @try {
            [self setCoverImage:[self getThumbnailImage:0]];
        } @catch (NSException* exc) {
            //NSLog(@"%@", [exc reason]);
        }
    }
    UIImage* img = [UIImage imageWithContentsOfFile:f];
    if (img) {
        return img;
    } else {
        [FileUtil rm:f];
        return nil;
    }
}



// ページ数を返す
- (NSInteger) pageCount {
    [self loadPages];

    if (isImported) {

        return [self.bookPages count];

    }
    if (self.isPDF) {
        return pdfPageCount;
    }else if (self.isPNG) {
        return 1;
    }else if (self.isJPG) {
        return 1;
    }
    else {
        return [pages count];
    }

}

// ブックマークされているかどうか
- (BOOL) isBookmarked: (NSInteger) page {
    Bookmarks* bm = [Bookmarks bookmarks];
    return [bm bookmarked:self page:page];
}


// ブックマークする
- (void) addToBookmark: (NSInteger) page {
    Bookmarks* bm = [Bookmarks bookmarks];
    [bm add:self page:page];
}

// ファイルを削除する
- (void) deleteFile {
    
    if ([FileUtil exists:self.path]) {
        [FileUtil rm:self.path];
        [FileUtil rm:[self basePath]];
        [FileUtil rm:[self bookLocation]];
        [[BookFiles bookFiles]deleteBookAtPath:self.path];
    }
}

// 表紙画像とサムネイルを削除する
- (void) deleteThumbnails {
    [FileUtil rm:[self cachePath]];
}


// ページに含まれるリンクを返す
- (NSArray*)getPageLinks:(NSInteger)pageNum {
    if (self.isPDF) {
        NSString* pageStr = [NSString stringWithFormat:@"%d", pageNum];
        return (NSArray*)[links objectForKey:pageStr];
    } else {
        return nil;
    }
}

// 複製実行
-(void)duplicateTo:(NSString *)dstPath 
{
    
    
    [FileUtil copy:path :dstPath];
    
    if (self.isPDF) {
        [FileUtil copy:path :dstPath];

    }
    
    if (self.isZIP) {
        [ZipArchive archive:self->_bookLocation toZip:dstPath];

    }

    
    if (self.isJPG || self.isPNG) {
        NSString *picSrc = [self->_bookDataLocation stringByAppendingPathComponent:[path lastPathComponent]];
        [FileUtil copy:picSrc  :dstPath];
    }
    
    
    // 作業用ディレクトリを準備
    NSString* workDir = [AppUtil tmpPath:@"duplicate"];
    [FileUtil rm:workDir];
    [FileUtil mkdir:workDir];
    
    // ZipEntryからファイルを取り出す
    /*
    ZipFile* zip = [[ZipFile alloc] initWithFileAtPath:path];
    [zip open];
    for (ZipEntry* page in pages) {
        NSData* data = [zip read:page];
        NSString* to = [workDir addPath:[page.displayName filename]];
        [data writeToFile:to atomically:NO];
    }
    [zip close];
    [zip release];
    zip = nil;
    */
    // creationファイルを作成
    
    //NSString* workDir = [AppUtil tmpPath:@"duplicate"];
    //[FileUtil rm:workDir];
    //[FileUtil mkdir:workDir];
    NSString* creationPath = [workDir addPath:@".creation"];
    
    [FileUtil write:[AppUtil udid] path:creationPath];
    
    // zip圧縮
    //[ZipArchive archive:workDir toZip:dstPath];
    
    // 作業用ディレクトリを削除
    [FileUtil rm:workDir];
    
    // bookmemoをコピー
    NSString* memoDir = [AppUtil cachePath:@"bookmemo"];
    NSString* memoFromPath;
    NSString* memoToPath;
    if (self.folderName) {
        // *.zip/fフォルダ名 -> *.zip/f にコピー
        memoFromPath = join(memoDir, @"/", [path filename], @"/f",
                            self.folderName, nil);
        memoToPath = join(memoDir, @"/", [dstPath filename], @"/f", nil);
    } else {
        // *.zipディレクトリをまるごとコピー
        memoFromPath = [memoDir addPath:[path filename]];
        memoToPath = [memoDir addPath:[dstPath filename]];
    }
    if ([FileUtil exists:memoFromPath]) {
        [FileUtil copy:memoFromPath :memoToPath];
    }
    
}

// 複製ファイル名の候補
- (NSString*)dupFilenameCandidate {
    NSString* prefix = res(@"dupPrefix");
    NSString* dir = [AppUtil docPath:@""];
    NSString* fname;
    if (self.folderName) {
        fname = [self.folderName add:@".zip"];
    } else {
        fname = self.name;
    }
    NSString* dp = [dir addPath:[prefix add:fname]];
    NSInteger cnt = 0;
    while ([FileUtil exists:dp]) {
        cnt++;
        dp = [NSString stringWithFormat:@"%@/%@(%d)%@", dir, prefix, cnt, fname];
    }
    return [dp basename];    
}




- (void) dealloc {
    //NSLog(@"%s", __func__);
    [name release];
    [path release];
    [folderName release];
    [cachedPdfImages release];;
    [links release];

    [pages release];
    [folders release];
    [props release];
    [folderBooks release];
    [unrar release];
    
    [self->_bookDataLocation release];
    self->_bookDataLocation = nil;
    
    [self->_bookLocation release];
    self->_bookDataLocation = nil;
    
    [self->_bookName release];
    self->_bookName = nil;
    
    [self->_bookPages release];
    self->_bookPages = nil;
    
    [self->_originPath release];
    self->_originPath = nil;
    [super dealloc];
}


@end


@implementation PageMoving
@synthesize from, to;

+ (PageMoving*) pageMoving:(NSInteger)from :(NSInteger)to {
    PageMoving* pm = [[PageMoving alloc]init];
    pm.from = from;
    pm.to = to;
    return [pm autorelease];
}


@end
