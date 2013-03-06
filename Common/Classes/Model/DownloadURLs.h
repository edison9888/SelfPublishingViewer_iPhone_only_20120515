//
//  DownloadURLs.h
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/28.
//  Copyright 2011 SAT. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DOWNLOADURL_LIMIT 10

@interface DownloadURLs : NSObject {
    @private
    NSMutableArray* urls;
    NSString* savePath;
}

-(NSInteger) count;


-(NSString*)getURLAtIndex:(NSInteger)index;

-(void)setURL:(NSString*)url atIndex:(NSInteger)index;

-(void)move:(NSInteger)from to:(NSInteger)to;

-(void)addURL:(NSString*)url;

-(void)removeURLAt:(NSInteger)index;

-(BOOL)isLimit;


@end
