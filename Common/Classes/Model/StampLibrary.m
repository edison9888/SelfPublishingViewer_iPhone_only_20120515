//
//  StampLibrary.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/15.
//  Copyright 2011 SAT. All rights reserved.
//

#import "StampLibrary.h"
#import "AppUtil.h"
#import "FileUtil.h"
#import "NSString_Util.h"

@interface StampLibrary()
@property(nonatomic,retain)NSMutableArray* files;
@property(nonatomic,readonly)NSString* baseDir;
@end

@implementation StampLibrary
@synthesize files;

#pragma mark - basic private
-(NSString*)baseDir {
    return [AppUtil cachePath:@"stamps"];
}
-(void) loadFiles {
    if (!files) {
        NSArray* list = [FileUtil files:self.baseDir extensions:[NSArray arrayWithObject:@"png"]];
        self.files = [NSMutableArray arrayWithCapacity:[list count]];
        // ファイル名の逆順に登録
        for (NSString* f in [list reverseObjectEnumerator]) {
            [files addObject:f];
        }
    }
}

#pragma mark -public

-(NSInteger)imageCount {
    [self loadFiles];
    return [files count];
}
// 画像を登録する
-(void)addImage:(UIImage*)img {
    [self loadFiles];
    NSString* fname = [NSString stringWithFormat:@"user%010d.png", (int)[NSDate timeIntervalSinceReferenceDate]];
    NSString* path = [self.baseDir addPath:fname];
    NSData* data = UIImagePNGRepresentation(img);
    [data writeToFile:path atomically:NO];
    [files insertObject:path atIndex:0];
}
// 新しいものが上に来る
-(UIImage*)getImageAt:(NSInteger)idx {
    [self loadFiles];
    if (0 <= idx && idx < [files count]) {
        NSString* path = [files objectAtIndex:idx];
        return [UIImage imageWithContentsOfFile:path];
    }
    return nil;
}
// 削除する
-(void)deleteImageAt:(NSInteger)idx {
    [self loadFiles];
    if (0 <= idx && idx < [files count]) {
        NSString* path = [files objectAtIndex:idx];
        [FileUtil rm:path];
        [files removeObjectAtIndex:idx];
    }
}





// リソースから初期プリセットをコピーする
-(void)initialCopy {
    if (![FileUtil exists:self.baseDir]) {
        NSString* resPath = [AppUtil resPath:@"Samples/stamps"];
        [FileUtil copy:resPath :self.baseDir];
        
    }
}

#pragma mark- object lifecycle

-(id)init {
    self = [super init];
    if (self) {
        
        [self initialCopy];
    }
    return self;
}

-(void)dealloc {
    self.files = nil;
    [super dealloc];
}


#pragma mark - static

+(StampLibrary*)library {
    return [[[StampLibrary alloc]init]autorelease];
}

@end
