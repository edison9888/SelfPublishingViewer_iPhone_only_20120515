//
//  PEPhotFrame.m
//  PhotoEditiong
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import "PEPhotoFrame.h"

@implementation PEPhotoFrame
@synthesize photoFrameName;
@synthesize photoFrameId;
@synthesize photoFramePath;

-(void)dealloc {
    self.photoFramePath=nil;
    self.photoFrameName=nil;
    [super dealloc];
}

@end
