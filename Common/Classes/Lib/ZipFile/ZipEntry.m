//
//  ZipEntry.m
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/11.
//  Copyright 2011 SAT. All rights reserved.
//

#import "ZipEntry.h"


@implementation ZipEntry
@synthesize displayName, fileName;

// 文字コードを自動判定する
- (id) initWithFilename:(const char *)fName {
    self = [super init];
    //origFilename = [[NSString alloc]initWithCString:fileName encoding:NSUTF8StringEncoding];
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
        NSString* tstr = [NSString stringWithCString:fName encoding:enc];
        NSData* tdata = [tstr dataUsingEncoding:enc allowLossyConversion:NO];
        if (tstr != nil && tdata != nil) {
            encoding = enc;
            displayName = [tstr retain];
            origFilename = [[NSData dataWithBytes:fName length:strlen(fName) + 1]retain];
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
