//
//  Page.m
//  ForIphone
//
//  Created by Vlatko Georgievski on 10/29/11.
//  Copyright (c) 2011 SAT. All rights reserved.
//

#import "PageEntry.h"

@implementation PageEntry

@synthesize displayName;

- (id) initWithFilename:(const char *)fileName {
    self = [super init];

	NSStringEncoding encodings[] = {
		NSShiftJISStringEncoding, 
        NSUTF8StringEncoding,
		NSJapaneseEUCStringEncoding,
		NSNonLossyASCIIStringEncoding,
		NSMacOSRomanStringEncoding,
		NSWindowsCP1251StringEncoding,
		NSWindowsCP1252StringEncoding,
		NSWindowsCP1253StringEncoding,
		NSWindowsCP1254StringEncoding,
		NSWindowsCP1250StringEncoding,
		NSISOLatin1StringEncoding,
		NSUnicodeStringEncoding,
		0
	};
    for (int i = 0; encodings[i] != 0; i++) {
        NSStringEncoding enc = encodings[i];
        NSString* tstr = [NSString stringWithCString:fileName encoding:enc];
        NSData* tdata = [tstr dataUsingEncoding:enc allowLossyConversion:NO];
        if (tstr != nil && tdata != nil) {
            encoding = enc;
            displayName = [tstr retain];
            origFilename = [[NSData dataWithBytes:fileName length:strlen(fileName) + 1]retain];
            break;
        }
    }
    return self;
}

- (const char*) fileName {
    return [origFilename bytes];
}

- (void)dealloc {
    [origFilename release];
    [displayName release];
    [super dealloc];
}




@end
