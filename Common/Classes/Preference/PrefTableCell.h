//
//  PrefTableCell.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/07/31.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PrefTableCell : UITableViewCell {
    UILabel* label;
     UISegmentedControl* segmentControl;
     UISwitch* onOffSwitch;
}

@property(nonatomic,retain)IBOutlet UILabel* label;
@property(nonatomic,retain)IBOutlet UISegmentedControl* segmentControl;
@property(nonatomic,retain)IBOutlet UISwitch* onOffSwitch;
@end
