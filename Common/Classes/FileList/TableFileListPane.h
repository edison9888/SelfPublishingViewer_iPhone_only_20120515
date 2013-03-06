//
//  TableFileListPane.h
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "common.h"
#import "FileListDelegate.h"
@class FileListPane;

@interface TableFileListPane : UITableViewController<FileListDelegate> {
    @private
    FileListPane* fileListPane;
    NSTimeInterval updatedTime;
    BOOL filenameLabelValid; // 使わない
}


@end
