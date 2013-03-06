//
//  TrimFrameView.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/07/27.
//  Copyright 2011 SAT. All rights reserved.
//

#import "TrimFrameView.h"
#import "common.h"
#import "UIView_Effects.h"

@implementation TrimFrameView
@synthesize nw,ne,sw,se;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}




// オーナードロー
- (void)drawRect:(CGRect)rect {
    [[UIColor yellowColor]setStroke];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 2);
    CGContextMoveToPoint(ctx, ne.right, ne.top);
    CGContextAddLineToPoint(ctx, nw.left, nw.top);
    CGContextAddLineToPoint(ctx, sw.left, sw.bottom);
    CGContextAddLineToPoint(ctx, se.right, se.bottom);
    CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
}



- (void)dealloc
{
    self.nw = nil;
    self.ne = nil;
    self.sw = nil;
    self.se = nil;
    [super dealloc];
}



@end
