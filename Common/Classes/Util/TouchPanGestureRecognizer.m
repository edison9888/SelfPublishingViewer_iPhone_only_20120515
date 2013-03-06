//
//  TouchPanRecognizer.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/13.
//  Copyright 2011 SAT. All rights reserved.
//

#import "TouchPanGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>


@implementation TouchPanGestureRecognizer
@synthesize beginPoint, touchState;

// タッチ開始時のイベント
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    touchState = TouchPanGestureRecognizerStateBegin;
    [super touchesBegan:touches withEvent:event];
    if (touchTarget && touchSelector) {
        [touchTarget performSelector:touchSelector withObject:self];
    }
    touchState = TouchPanGestureRecognizerStateChanging;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    touchState = TouchPanGestureRecognizerStateEnd;
    [super touchesEnded:touches withEvent:event];
    if (touchTarget && touchSelector) {
        [touchTarget performSelector:touchSelector withObject:self];
    }
}

- (void)setTouchTarget:(id)target selector:(SEL)selector {
    touchSelector = selector;
    touchTarget = target;
}
@end
