//
//  CustomCellImageAdjustCell.m
//  ForIphone
//
//  Created by Jayneel Patel on 6/29/12.
//  Copyright (c) 2012 SAT. All rights reserved.
//

#import "CustomCellImageAdjustCell.h"

@implementation CustomCellImageAdjustCell
@synthesize imageView;
@synthesize btnAdjustment;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [imageView release];
    [btnAdjustment release];
    [super dealloc];
}
@end
