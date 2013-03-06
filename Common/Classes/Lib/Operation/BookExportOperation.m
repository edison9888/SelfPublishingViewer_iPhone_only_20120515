//
//  BookExportOperation.m
//  ScanBookShelfReader
//
//  Created by Vlatko Georgievski on 11/2/11.
//  Copyright (c) 2011 Smartebook. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "BookExportOperation.h"
#import "FileUtil.h"
#import "ZipFile.h"
#import "ZipEntry.h"
#import "ZipArchive.h"
#import "AppUtil.h"
#import "NSString_Util.h"


@interface BookExportOperation ()


@property (copy,   readwrite) NSError *                 error;

@property (retain, readwrite ) NSMutableArray *          mutableResults;

@end



@implementation BookExportOperation
@synthesize bookSourcePath = _bookSourcePath;


- (id)initWithBook:(NSString *)path;
{
    assert(path != nil);
    self = [super init];
    if (self != nil) {
        self->_bookSourcePath = [path retain];
        assert(self->_bookSourcePath != nil);
        
        self->_mutableResults  = [[NSMutableArray alloc] init];
        assert(self->_mutableResults != nil);
    }
    return self;
}

- (void)dealloc
{
    [self->_bookSourcePath release];
    [self->_error release];
    [self->_mutableResults release];
    
    [super dealloc];
}


@synthesize error           = _error;
@synthesize mutableResults  = _mutableResults;


- (NSArray *)results
{
    return [[self->_mutableResults copy] autorelease];
}


- (void)main
{
    
    NSString *_bookFileName = [self->_bookSourcePath lastPathComponent];
    NSString *_exportFilename = [[AppUtil bookExportDir] stringByAppendingPathComponent:_bookFileName];

    [FileUtil rm:_exportFilename];

    
    NSString *_exportDir = [[[AppUtil bookRootDir] stringByAppendingPathComponent:_bookFileName]stringByAppendingPathComponent:@"Data"];

    if ([_bookFileName hasSuffix:@"zip"]) {
        [ZipArchive archive:_exportDir toZip:_exportFilename];

    }
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *destPath = [documentsDirectory stringByAppendingPathComponent:_bookFileName];
    
    
    if ([fileManager fileExistsAtPath:destPath] == YES) {
        [fileManager removeItemAtPath:destPath error:&error];
    }

    if ([fileManager fileExistsAtPath:destPath] == NO) {
        [fileManager copyItemAtPath:_exportFilename toPath:destPath error:&error];
    }
    
        
     return;
}


@end
