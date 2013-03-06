//
//  BookmarkPane.h
//

#import <UIKit/UIKit.h>

@class BookPageCell;

@interface BookmarkPane : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    @private
    NSArray* records;
     UITableView* tableView;
     UIBarButtonItem* compButton;
     UIBarButtonItem* delAllButton;
     UIToolbar* toolBar;

    BOOL isEditing;
}
@property(nonatomic,retain)IBOutlet UITableView* tableView;
@property(nonatomic,retain)IBOutlet UIBarButtonItem* compButton;
@property(nonatomic,retain)IBOutlet UIBarButtonItem* delAllButton;
@property(nonatomic,retain)IBOutlet UIToolbar* toolBar;
@property(nonatomic,retain) NSArray* records;

@end
