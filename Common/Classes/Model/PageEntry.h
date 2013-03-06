//
//  Page.h
//  ForIphone
//
//  Created by Vlatko Georgievski on 10/29/11.
//  Copyright (c) 2011 SAT. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface PageEntry : NSObject {
    NSString* displayName;
    NSData* origFilename;
    NSStringEncoding encoding;
}


- (id)initWithFilename:(const char*)fileName;

@property(nonatomic,readonly) const char* fileName;
@property(nonatomic,readonly) NSString* displayName;


@end
