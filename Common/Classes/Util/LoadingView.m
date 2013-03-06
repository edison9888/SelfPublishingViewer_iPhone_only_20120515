//
//  LoadingView.m
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/31.
//  Copyright 2011 SAT. All rights reserved.
//

#import "LoadingView.h"
#import "AppUtil.h"
#import "UIView_Effects.h"

@implementation LoadingView
@synthesize indicator;

- (id)init {
    self = [super init];
    if (self) {
        indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self addSubview:indicator];
        [indicator release];
    }
    return self;
}

- (void)start:(UIView*)inView {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
    [inView addSubview:self];
    [self eFittoSuperview];
    [indicator eCenter:self.center];
    [indicator startAnimating];
    [pool release];
}

// 表示する
+ (LoadingView*)show: (UIView*)inView {
    return [self show:inView membrane:YES];
}

+ (LoadingView*)show:(UIView *)inView membrane:(BOOL)membraneVisible {
    if (inView == nil) {
        inView = [AppUtil window];
    }
    LoadingView* lv = [[LoadingView alloc]init];
    if (membraneVisible) {
        lv.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
        [lv.indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    } else {
        lv.backgroundColor = [UIColor clearColor];
        [lv.indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    }
    [lv performSelectorInBackground:@selector(start:) withObject:inView];
    [NSThread sleepForTimeInterval:0.05];
    return [lv autorelease];
}


// 削除する
- (void)dismiss {
    [indicator stopAnimating];
    indicator = nil;
    [self removeFromSuperview];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    [self dismiss];
    [super dealloc];
}

@end
