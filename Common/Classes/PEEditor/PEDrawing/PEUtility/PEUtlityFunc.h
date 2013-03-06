//
//  PEUtlityFunc.h
//  PhotoEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PEUtlityFunc : NSObject
{
    
}
//Basic Access to Documents Dir and Plist Files
+(NSString *)getTheBasePathForPlist:(NSString *)plistName;
+(NSString *)getDocumentsDirectoryPathForFile:(NSString *)fileName;
+(NSString *)getDocumentsDirectoryPath;
+(NSString *)getBundlePathForFileName:(NSString *)imageName forType:(NSString *)fileType;
//+(NSString *)getDocumentsDirectoryPath;

@end
