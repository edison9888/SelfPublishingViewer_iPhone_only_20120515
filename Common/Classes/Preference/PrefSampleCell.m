//
//  PrefSampleCell.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/25.
//  Copyright 2011 SAT. All rights reserved.
//

#import "PrefSampleCell.h"


@implementation PrefSampleCell
@synthesize nameLabel, subLabel, sampleImageView, checkMark;

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

- (void)dealloc
{
    self.nameLabel = nil;
    self.subLabel = nil;
    self.sampleImageView = nil;
    self.checkMark = nil;
    [super dealloc];
}

+(PrefSampleCell*)createCell {
    NSArray* arr = [[NSBundle mainBundle] loadNibNamed:@"PrefSampleCell" owner:nil options:nil];
    for (NSObject* obj in arr) {
        if ([obj isKindOfClass:[PrefSampleCell class]]) {
            return (PrefSampleCell*)obj;
        }
    }
    return nil;

}

@end
