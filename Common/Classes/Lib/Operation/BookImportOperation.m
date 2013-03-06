//
//  BookImportOperation.m
//  ScanBookShelfReader
//
//  Created by Vlatko Georgievski on 11/2/11.
//  Copyright (c) 2011 Smartebook. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "BookImportOperation.h"
#import "FileUtil.h"
#import "ZipFile.h"
#import "ZipEntry.h"

#import "AppUtil.h"
#import "NSString_Util.h"
#import <Unrar4iOS/Unrar4iOS.h>


@interface BookImportOperation ()


@property (copy,   readwrite) NSError *                 error;

@property (retain, readwrite ) NSMutableArray *          mutableResults;

@end


@implementation BookImportOperation
@synthesize bookSourcePath = _bookSourcePath;

- (id)initWithBook:(NSString *)path;
{
    assert(path != nil);
    self = [super init];
    if (self != nil) {
        self->_bookSourcePath = [NSString stringWithString:path];
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
    NSString *_bookFileName;
    NSString *_bookName;
    NSString *_bookImportRootPath;
    NSString *_bookImportDataPath;
    
    
    NSString *_bookRootFolder;
    
    NSMutableArray* _pages;
    NSMutableArray* _folders; 
    
    
    _bookFileName = [self->_bookSourcePath lastPathComponent];    
    
    _bookName = [_bookFileName stringByDeletingPathExtension];
    
    
    _bookRootFolder = [[AppUtil bookRootDir] stringByAppendingPathComponent:_bookFileName];
    assert(_bookRootFolder != nil);
    
    
    _bookImportRootPath = [_bookRootFolder stringByAppendingString:@"_ImportDir"];
    assert(_bookImportRootPath != nil);
    
    _bookImportDataPath = [_bookImportRootPath stringByAppendingPathComponent:@"Data"];
    assert(_bookImportDataPath != nil);
    
    [FileUtil mkdir:_bookImportRootPath];
    [FileUtil mkdir:_bookImportDataPath];
    
    if ([_bookFileName hasSuffix:@"rar"] || [_bookFileName hasSuffix:@"cbr"]) {
        NSLog(@"rar/cbr detected");
        
        Unrar4iOS * unrar = [[Unrar4iOS alloc] init];
        
        @try {
            BOOL ok = [unrar unrarOpenFile:self->_bookSourcePath];
            if (ok) {
                NSLog(@"inside ok");
                NSArray * files = [unrar unrarListFiles];
                for (NSString * filename in files) {
                    NSLog(@"File: %@", filename);
                }
                
                NSArray * entries = [unrar unrarListFiles];
                
                _pages = [[NSMutableArray arrayWithCapacity:[entries count]] retain];
                _folders = [[NSMutableArray array]retain];
                
                int entryindex = 0;
                
                for (NSString * file in files) {
                    NSString * ext = [[file pathExtension] lowercaseString];
                    NSLog(@"extension: %@", ext);
                    if ([ext isEqualToString:@"png"] || [ext isEqualToString:@"jpg"] || [ext isEqualToString:@"jpeg"] || [ext isEqualToString:@"jpe"]|| [ext  isEqualToString:@"gif"]) 
                    {
                        // Extract the stream
                        NSData * fileData = [unrar extractStream:[files objectAtIndex:entryindex]];
                        
                        [_pages addObject:fileData];
                        NSString * folder = [file stringByDeletingLastPathComponent];
                        
                        if (![_folders containsObject:folder]) {
                            [_folders addObject:folder];
                        }
                        
                    }
                    entryindex++;
                }
                
                [unrar unrarCloseFile];
            }
            else{
                NSLog(@"RAR Open failed.");
                [unrar unrarCloseFile];
            }
            
        }
        @catch (NSException* exc) {
            NSLog(@"rar/cbr open failed. %@", [exc description]);
        }
        @finally {
            [unrar release];
        }
    }

    
    /* don't forget about the char cases , later.... */
        
    if ([_bookFileName hasSuffix:@"zip"] || [_bookFileName hasSuffix:@"cbz"]) {        
        
        ZipFile* zip = [[ZipFile alloc] initWithFileAtPath:self->_bookSourcePath];
        
        @try {
            [zip open];
            
            
            NSArray* entries = [zip entries];
            
            _pages = [[NSMutableArray arrayWithCapacity:[entries count]] retain];
            _folders = [[NSMutableArray array]retain];
            for (ZipEntry* ent in entries) {
                NSString* ext = [[ent.displayName pathExtension]lowercaseString];
                if ([ext isEqualToString:@"png"] || [ext isEqualToString:@"jpg"] || [ext isEqualToString:@"jpeg"] || [ext isEqualToString:@"jpe"]|| [ext  isEqualToString:@"gif"]) 
                {
                    [_pages addObject:ent];
                    NSString* folder = [ent.displayName stringByDeletingLastPathComponent];
                    
                    if (![_folders containsObject:folder]) {
                        [_folders addObject:folder];
                    }
                    
                } 
            }
            
            [zip close];
        }
        @catch (NSException* exc) {
            NSLog(@"zip open failed. %@", [exc description]);
        }
        @finally {
            [zip release];
        }
        

        
        zip = [[ZipFile alloc] initWithFileAtPath:self->_bookSourcePath];
        
        [zip open];
        
        
        for (ZipEntry* page in _pages) {
            NSData* data = [zip read:page];
            NSString *fileName = [page.displayName lastPathComponent];
            NSString *fname = [_bookImportDataPath stringByAppendingPathComponent:fileName];
            [data writeToFile:fname atomically:NO];
        }
        [zip close];
        [zip release];
        zip = nil;
        
    }
    

    if ([_bookFileName hasSuffix:@"jpg"] || [_bookFileName hasSuffix:@"png"] || [_bookFileName hasSuffix:@"jpeg"]) {
        [FileUtil copy:self->_bookSourcePath :_bookImportDataPath ];
    }
    
    /* As is it should never match pdfs */
    if ([_bookFileName hasSuffix:@"pdf"]) {
        [FileUtil copy:self->_bookSourcePath :_bookImportDataPath ];
    }
    
    if ([_bookFileName hasSuffix:@"doc"]  ||
        [_bookFileName hasSuffix:@"docx"] ||
        [_bookFileName hasSuffix:@"ppt"]  ||
        [_bookFileName hasSuffix:@"pptx"] ||
        [_bookFileName hasSuffix:@"xls"]  ||
        [_bookFileName hasSuffix:@"xlsx"]) {
        NSLog(@"saving word file");
        [FileUtil copy:self->_bookSourcePath :_bookImportDataPath ];
    }
    
    return;
}


@end
