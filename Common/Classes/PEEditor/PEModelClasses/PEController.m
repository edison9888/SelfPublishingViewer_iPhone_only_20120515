//
//  PEController.m
//  PhotoEditiong
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import "PEController.h"

@implementation PEController

@synthesize brush_Size,normalColorImageName,specialColorImageName;
@synthesize brushType;
@synthesize normalColorRgb,specialColorRgb;

-(void)dealloc {
    
    self.normalColorImageName = nil;
    self.specialColorImageName = nil;
    self.normalColorRgb=nil;
    self.specialColorRgb=nil;
    
    [super dealloc];
}

@end
