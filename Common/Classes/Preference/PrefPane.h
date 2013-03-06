//
//  PrefPane.h
//

#import <UIKit/UIKit.h>

@interface PrefPane : UIViewController<UITableViewDelegate,UITableViewDataSource> {
    @private
    NSArray* boolPrefKeys;
    NSArray* shelfTypeKeys;
    UITableView* tableView;
    UILabel* versionLabel;
    BOOL shelfTypeSelecting;
}

@property(nonatomic,retain) IBOutlet UITableView* tableView;
@property(nonatomic,retain)IBOutlet UILabel* versionLabel;


@end
