//
//  TouchableScrollView.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/14.
//  Copyright 2011 SAT. All rights reserved.
//

#import "TouchableScrollView.h"


@implementation TouchableScrollView

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s", __func__);
    [[self nextResponder]touchesBegan:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s", __func__);
    [[self nextResponder]touchesEnded:touches withEvent:event];
    [super touchesEnded:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s", __func__);
    [[self nextResponder]touchesCancelled:touches withEvent:event];
    [super touchesCancelled:touches withEvent:event];
}

@end
