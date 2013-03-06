//
//  PEUtlityFunc.m
//  PhotoEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import "PEUtlityFunc.h"

@implementation PEUtlityFunc

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+(NSString *)getTheBasePathForPlist:(NSString *)plistName
{
    NSString *basePath = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    NSLog(@"basePath is %@",basePath);
    return basePath;
}

+(NSString *)getDocumentsDirectoryPathForFile:(NSString *)fileName
{	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *plistPath =[NSString stringWithFormat:@"%@",fileName];
	basePath = [basePath stringByAppendingPathComponent:plistPath];
	return basePath;
}

+(NSString *)getDocumentsDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

+(NSString *)getBundlePathForFileName:(NSString *)imageName forType:(NSString *)fileType
{
    NSString *basePath = [[NSBundle mainBundle] pathForResource:imageName ofType:fileType];
    NSLog(@"basePath is %@",basePath);
    return basePath;
}


- (void)dealloc {
    
    [super dealloc];
}

@end
