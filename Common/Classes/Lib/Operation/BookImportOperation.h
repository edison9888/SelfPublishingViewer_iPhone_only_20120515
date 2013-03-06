//
//  BookImportOperation.h
//  ScanBookShelfReader
//
//  Created by Vlatko Georgievski on 11/2/11.
//  Copyright (c) 2011 Smartebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "NSString_Util.h"

@interface BookImportOperation : NSOperation
{
    
    NSError *_error;
    NSMutableArray *_mutableResults; 
}

@property(nonatomic, retain) NSString *bookSourcePath;


- (id)initWithBook:(NSString *)path;


@property (copy,   readonly ) NSError *error;
@property (copy,   readonly ) NSArray *results;

@end
