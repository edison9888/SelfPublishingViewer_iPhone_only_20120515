//
//  PEPhotoFrameView.m
//  PhotoEditiong
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import "PEPhotoFrameView.h"

@implementation PEPhotoFrameView
@synthesize photFrame;
//@synthesize delegate;

-(void)dealloc {
    [photFrame release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
#pragma mark - 
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    if([self.delegate respondsToSelector:@selector(didFrameSelected:)]){
//        [self.delegate didFrameSelected:self];
//    }
//}
@end
