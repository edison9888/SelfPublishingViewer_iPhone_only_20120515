//
//  PrefTableCellNib.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/07/31.
//  Copyright 2011 SAT. All rights reserved.
//

#import "PrefTableCellNib.h"


@implementation PrefTableCellNib
@synthesize cell;

- (id)init {
    self = [super init];
    
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"PrefTableCell" owner:self options:nil];
    }
    return self;
}

- (void)dealloc {
    self.cell = nil;
    [super dealloc];
}

@end
