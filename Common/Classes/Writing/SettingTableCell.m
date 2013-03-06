//
//  SettingTableCell.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/16.
//  Copyright 2011 SAT. All rights reserved.
//

#import "SettingTableCell.h"
#import "NSString_Util.h"


@implementation SettingTableCell
@synthesize mainLabel, displaySwitch, thumbView, displayLabel;

-(void)dealloc {
    self.displayLabel = nil;
    self.mainLabel = nil;
    self.displayLabel = nil;
    self.thumbView = nil;
    
    [super dealloc];
}

+(SettingTableCell *)createCell {
    NSArray* arr = [[NSBundle mainBundle] loadNibNamed:@"SettingTableCell" owner:nil options:nil];
    for (NSObject* obj in arr) {
        if ([obj isKindOfClass:[SettingTableCell class]]) {
            return (SettingTableCell*)obj;
        }
    }
    return nil;
}

@end
