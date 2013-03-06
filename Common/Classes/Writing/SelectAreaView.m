//
//  SelectAreaView.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/13.
//  Copyright 2011 SAT. All rights reserved.
//

#import "SelectAreaView.h"
#import "UIView_Effects.h"
#import <QuartzCore/QuartzCore.h>


@implementation SelectAreaView

@synthesize image;
@synthesize moveHandle;

- (id)init {
    self = [super init];
    if (self) {
        moveHandle = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"move_handle.png"]];
        [self addSubview:moveHandle];
        [moveHandle eSize:30 :30];
        
        resizeHandle = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"resize_handle.png"]];
        [self addSubview:resizeHandle];
        [resizeHandle eSize:30 :30];
        
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
        | UIViewAutoresizingFlexibleHeight
        | UIViewAutoresizingFlexibleLeftMargin
        | UIViewAutoresizingFlexibleRightMargin
        | UIViewAutoresizingFlexibleTopMargin
        | UIViewAutoresizingFlexibleWidth;
        
    }
    return self;
}

- (void)layoutSubviews {
    [moveHandle eFitTop:NO];
    [moveHandle eFitLeft:NO];
    [resizeHandle eFitRight:NO];
    [resizeHandle eFitBottom:NO];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 背景画像の描画
    if (image) {
        [image drawInRect:rect];
    }
    CGContextSetStrokeColorWithColor(ctx, [UIColor blueColor].CGColor);
    CGContextSetLineWidth(ctx, 2);
    CGContextAddRect(ctx, rect);
    CGContextStrokePath(ctx);
}


- (void)dealloc
{
    self.image = nil;
    [super dealloc];
}

@end
