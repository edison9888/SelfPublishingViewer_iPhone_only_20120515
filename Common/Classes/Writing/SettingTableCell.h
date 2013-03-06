//
//  SettingTableCell.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/16.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingTableCell : UITableViewCell {
     UIImageView* thumbView;
     UILabel* mainLabel;
     UILabel* displayLabel;
     UISwitch* displaySwitch;
}
@property(nonatomic,retain)IBOutlet UILabel* displayLabel;
@property(nonatomic,retain)IBOutlet UILabel* mainLabel;
@property(nonatomic,retain)IBOutlet UISwitch* displaySwitch;
@property(nonatomic,retain)IBOutlet UIImageView* thumbView;

+(SettingTableCell*)createCell;

@end
