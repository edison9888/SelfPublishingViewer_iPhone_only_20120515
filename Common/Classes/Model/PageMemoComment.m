//
//  PageMemoComment.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/13.
//  Copyright 2011 SAT. All rights reserved.
//

#import "PageMemoComment.h"
#import "FileUtil.h"
#import "NSString_Util.h"

@implementation PageMemoComment
@synthesize point, comment, path, commentId;

-(BOOL)isNew {
    return ![FileUtil exists:path];
}

-(void)load {
    if ([FileUtil exists:path]) {
        NSString* cont = [FileUtil read:path];
        NSArray* matches = [cont match:@"^(\\d+\\.\\d+),(\\d+\\.\\d+) (.+)$"];
        if ([matches count] == 4) {
            CGFloat x = [[matches objectAtIndex:1]floatValue];
            CGFloat y = [[matches objectAtIndex:2]floatValue];
            self.point = CGPointMake(x, y);
            self.comment = [matches objectAtIndex:3];
        }
    }
}

-(void)save {
    NSString* cont = [NSString stringWithFormat:@"%f,%f %@", 
                      point.x, point.y, comment];
    [FileUtil write:cont path:path];
}


-(id)initWithPath:(NSString*)commentPath {
    self = [super init];
    if (self) {
        path = [commentPath retain];
        commentId = [[path basename]intValue];
        [self load];
    }
    return self;
}

-(void)dealloc {
    self.comment = nil;
    [path release];
    [super dealloc];
}

@end
