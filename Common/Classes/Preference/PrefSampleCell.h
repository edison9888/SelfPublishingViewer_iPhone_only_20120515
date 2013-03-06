//
//  PrefSampleCell.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/25.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PrefSampleCell : UITableViewCell {
    @private
    UILabel* nameLabel;
    UILabel* subLabel;
    UIImageView* sampleImageView;
    UIImageView* checkMark;
}
@property(nonatomic,retain)IBOutlet UILabel* nameLabel;
@property(nonatomic,retain)IBOutlet UILabel* subLabel;
@property(nonatomic,retain)IBOutlet UIImageView* sampleImageView;
@property(nonatomic,retain)IBOutlet UIImageView* checkMark;

+(PrefSampleCell*)createCell;

@end
