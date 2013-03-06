//
//  PEDrawing.m
//  PhotoEditiong
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import "PEDrawing.h"

@implementation PEDrawing

@synthesize stampId,typeOfStamp;
@synthesize stampName;
@synthesize stampPath;
@synthesize scale;

-(void)dealloc {
    self.stampName=nil;
    self.stampPath=nil;
    
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        scale = 1.0;
    }
    return self;
}

@end


@implementation PalletColor

@synthesize redVal,greenVal,blueVal;

-(void)dealloc {
        
    [super dealloc];
}

@end

