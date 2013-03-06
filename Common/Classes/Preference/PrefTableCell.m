//
//  PrefTableCell.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/07/31.
//  Copyright 2011 SAT. All rights reserved.
//

#import "PrefTableCell.h"
#import "common.h"

@implementation PrefTableCell
@synthesize label, segmentControl, onOffSwitch;

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = segmentControl.bounds;
    bounds.size.height = 27;
    [segmentControl setBounds:bounds];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    self.label = nil;
    self.segmentControl = nil;
    self.onOffSwitch = nil;
    [super dealloc];
}

@end
