//
//  CommentViewNib.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/14.
//  Copyright 2011 SAT. All rights reserved.
//

#import "CommentViewNib.h"

@implementation CommentViewNib
@synthesize view;

-(id)init {
    self = [super init];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"CommentView" owner:self options:nil];

    }
    return self;
}

-(void)dealloc {
    self.view = nil;
    [super dealloc];
}

@end
