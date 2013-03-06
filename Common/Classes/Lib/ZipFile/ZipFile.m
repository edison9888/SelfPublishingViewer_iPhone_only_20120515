//
//  ZipFile.m
//  ZipFile
//
//  ZIPファイルを解凍せずにデータを読み込む
//

#import "ZipFile.h"
#import "ZipEntry.h"

@implementation ZipFile

static const int CASE_SENSITIVITY = 0;
static const unsigned int BUFFER_SIZE = 8192;
static const unsigned int MAX_FILESIZE = 30 * 1024 * 1024;

- (id)initWithFileAtPath:(NSString *)path {
	NSAssert(path, @"path");
	self = [super init];
	if (self) {
		path_ = [path retain];
		unzipFile_ = NULL;
	}
	return self;
}

- (void)dealloc {
	NSAssert(!unzipFile_, @"!unzipFile_");
	[path_ release];
	[super dealloc];
}

- (BOOL)open {
	NSAssert(!unzipFile_, @"!unzipFile_");
	unzipFile_ = unzOpen([path_ UTF8String]);

	return unzipFile_ != NULL;
}

- (void)close {
	NSAssert(unzipFile_, @"unzipFile_");
	
	unzClose(unzipFile_);
	unzipFile_ = NULL;
}

// Zipファイルを解凍せずにデータを返す
- (NSData *)read:(ZipEntry*)entry {
    NSAssert(unzipFile_, @"unzipFile_");
	NSAssert(entry, @"entry");

	if (unzLocateFile(unzipFile_, entry.fileName, CASE_SENSITIVITY) != UNZ_OK) {
        return nil;
    }
    if (unzOpenCurrentFile(unzipFile_) != UNZ_OK) {
		return nil;
	}
	NSMutableData *data = [NSMutableData data];
	NSUInteger length = 0;
	void *buffer = (void *)malloc(BUFFER_SIZE);
	while (YES) {
		unsigned size = length + BUFFER_SIZE <= MAX_FILESIZE ? BUFFER_SIZE : MAX_FILESIZE - length;
		int readLength = unzReadCurrentFile(unzipFile_, buffer, size);
		if (readLength < 0) {
			free(buffer);
			unzCloseCurrentFile(unzipFile_); 
			return nil;
		}
		if (readLength > 0) {
			[data appendBytes:buffer length:readLength];
			length += readLength;
		}
		if (readLength == 0) {
			break;
		}
	};	
	free(buffer);
	
	unzCloseCurrentFile(unzipFile_); 
	
	return data;
}




// 画像ファイルかどうかを判定する
- (BOOL) isImage: (NSString*) fileName {
    NSArray* extensions = [NSArray arrayWithObjects:@"jpg", @"png", @"jpe", @"jpeg", @"gif", nil];
    NSString* fext = [[fileName pathExtension]lowercaseString];
    for (NSString* ext in extensions) {
        if ([fext isEqualToString:ext]) {
            return YES;
        }
    }
    return NO;
}


// ZipEntryの配列を返す
- (NSArray*)entries {
	NSAssert(unzipFile_, @"unzipFile_");
	
	if (unzGoToFirstFile(unzipFile_) != UNZ_OK) {
		return nil;
	}
	NSMutableArray* entries = [NSMutableArray array];
    
    BOOL goNext;
    do {
        unz_file_info fileInfo;
        char fileName[PATH_MAX];
        
		if (unzGetCurrentFileInfo(unzipFile_, &fileInfo, fileName, PATH_MAX, NULL, 0, NULL, 0) != UNZ_OK) {
			return nil;
		}
        ZipEntry* ent = [[ZipEntry alloc]initWithFilename:fileName];
        [entries addObject:ent];
        [ent release];
        int r = unzGoToNextFile(unzipFile_);

        if (r == UNZ_END_OF_LIST_OF_FILE) {
            goNext = NO;
        } else if (r != UNZ_OK) {
            return nil;
        } else {
            goNext = YES;
        }
    } while (goNext);
    
    NSSortDescriptor* sd = [[NSSortDescriptor alloc]initWithKey:@"displayName" ascending:YES];
    [entries sortUsingDescriptors:[NSArray arrayWithObject:sd]];
    [sd release];
    return entries;
}

@end