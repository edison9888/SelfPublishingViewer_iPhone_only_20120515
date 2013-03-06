//
//  DownloadURLs.m
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/28.
//  Copyright 2011 SAT. All rights reserved.
//

#import "DownloadURLs.h"


@implementation DownloadURLs

-(id)init {
    self = [super init];
    if (self) {
        savePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/downloadURLs.txt"]retain];
        urls = [NSMutableArray arrayWithContentsOfFile:savePath];
        if (!urls) {
            urls = [NSMutableArray arrayWithCapacity:DOWNLOADURL_LIMIT];
        }
        [urls retain];
    }
    
    return self;
}

-(void)dealloc {
    [savePath release];
    [urls release];
    [super dealloc];
}

-(NSInteger) count {
    return [urls count];
}

-(void)save {
    [urls writeToFile:savePath atomically:NO];
}

-(NSString*)getURLAtIndex:(NSInteger)index {
    return [urls objectAtIndex:index];
}

-(void)setURL:(NSString*)url atIndex:(NSInteger)index {
    if (index < [urls count]) {
        [urls replaceObjectAtIndex:index withObject:url];
    } else {
        [urls addObject:url];
    }
    [self save];
}

-(void)move:(NSInteger)from to:(NSInteger)to {
    NSString* url = [urls objectAtIndex:from];
    [urls removeObjectAtIndex:from];
    if (to < [urls count]) {
        [urls insertObject:url atIndex:to];
    } else {
        [urls addObject:url];
    }
    [self save];
}

-(BOOL)isLimit {
    return [urls count] >= DOWNLOADURL_LIMIT;
}

-(void)addURL:(NSString*)url {
    if ([urls indexOfObject:url] != NSNotFound) {
        return;
    }
    if ([urls count] == 0) {
        [urls addObject:url];
    } else {
        [urls insertObject:url atIndex:0];
    }
    while ([urls count] > DOWNLOADURL_LIMIT) {
        [urls removeObjectAtIndex:[urls count] - 1];
    }
    [self save];
}

-(void)removeURLAt:(NSInteger)index {
    [urls removeObjectAtIndex:index];
    [self save];
}

@end
