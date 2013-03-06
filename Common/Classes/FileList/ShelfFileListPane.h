//
//  ShelfFileListPane.h
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "common.h"
#import "FileListDelegate.h"
#import "TileView.h"

@class FileListPane;

@interface ShelfFileListPane : UIViewController<UIScrollViewDelegate,FileListDelegate,UIAlertViewDelegate> {
    
@private
    FileListPane* fileListPane;
     UIScrollView* scrollView;
     TileView* contentView;
    NSMutableArray* bookIcons;
    NSMutableArray* deleteIcons;
    BOOL editing;
    NSTimeInterval updatedTime;
    BOOL iconImageUpdating;
    UIView* movingView;
    NSInteger grabbing;
    // しおりアイコン
    UIImageView* lastMark;
    // 今現在アイコンをレイアウトしている向き
    BOOL layoutPortrait;
    BOOL layoutValid;
    BOOL filenameLabelValid;
    BOOL filenameLabelsVisible;
}

@property(nonatomic,retain) IBOutlet UIScrollView* scrollView;
@property(nonatomic,retain)IBOutlet TileView* contentView;

@end
