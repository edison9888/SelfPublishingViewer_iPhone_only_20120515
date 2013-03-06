//
//   NSString(SHA1Addition).m
//  ForIphone
//
//  Created by Vlatko Georgievski on 10/30/11.
//  Copyright (c) 2011 Georgievski. All rights reserved.
//
#import "NSString+SHA1Addition.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString(SHA1Addition)

- (NSString *) stringFromSHA1{
    
    if(self == nil || [self length] == 0)
        return nil;
    
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(value, strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_SHA1_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return [outputString autorelease];
}

@end
