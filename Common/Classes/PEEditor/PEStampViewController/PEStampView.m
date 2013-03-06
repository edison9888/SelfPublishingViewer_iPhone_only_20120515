//
//  PEStampView.m
//  PhotoEditiong
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import "PEStampView.h"

@implementation PEStampView
@synthesize drawing;
@synthesize delegate;
-(void)dealloc {
   // self.drawing=nil;
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
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if([self.delegate respondsToSelector:@selector(didStampViewSelected:)]){
        [self.delegate didStampViewSelected:self];
    }
}

@end
