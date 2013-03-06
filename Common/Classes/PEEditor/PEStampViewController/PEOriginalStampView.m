//
//  PEOriginalStampView.m
//  PhotoEditiong
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import "PEOriginalStampView.h"
#import "PEStampViewController.h"

@implementation PEOriginalStampView
@synthesize deleteBtn;

#pragma mark - Touches

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([self.delegate respondsToSelector:@selector(didSelectOriginalStamp:)])
    {
        [self.delegate didSelectOriginalStamp:self];
    }
}

-(void)dealloc {
    //self.deleteBtn=nil;
    [super dealloc];
}
@end
