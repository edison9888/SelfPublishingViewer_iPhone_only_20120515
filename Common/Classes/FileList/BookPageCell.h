//
//  BookPageCell.h
//

#import <UIKit/UIKit.h>


@interface BookPageCell : UITableViewCell {
     UIImageView* coverView;
     UIImageView* badgeView;
     UILabel* mainLabel;
     UILabel* pathLabel;
     UIButton* button;
}
@property(nonatomic,retain)IBOutlet UIImageView* coverView;
@property(nonatomic,retain)IBOutlet UIImageView* badgeView;
@property(nonatomic,retain)IBOutlet UILabel* mainLabel;
@property(nonatomic,retain)IBOutlet UILabel* pathLabel;
@property(nonatomic,retain)IBOutlet UIButton* button;

@end
