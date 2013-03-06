//
//  BookCellNib.m
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/26.
//  Copyright 2011 SAT. All rights reserved.
//

#import "BookPageCellNib.h"


@implementation BookPageCellNib
@synthesize cell;

-(id)init {
    self = [super init];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"BookPageCell" owner:self options:nil];
    }
    return self;
}

- (void)dealloc {
    self.cell = nil;
    [super dealloc];
}


@end
