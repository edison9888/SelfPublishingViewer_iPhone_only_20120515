//
//  DropboxPane.h
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/22.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropboxSDK.h"
#import "ProgressDialog.h"
#import "FileSelector.h"
#import "Book.h"
#import "BookExportOperation.h"

@interface DropboxPane : UITableViewController<DBRestClientDelegate> {
    @private
    ProgressDialog* progress;

    FileSelector* fileSelector;
    DBRestClient* restClient;
	NSMutableArray *files;
	NSMutableArray *dirs;
	NSString *dir;
    UIAlertView *exportingMessage;

    UISegmentedControl* seg;
    
    BOOL loading;
    BOOL downloading;
    BOOL exporting;

    BOOL uploading;
    NSString* downloadingRemotePath;
    NSString* downloadingLocalPath;
    Book* uploadingBook;
    
    BookExportOperation *_exportOperation;
    UIActivityIndicatorView *_exportActivity;
      
}

@property(nonatomic,retain) NSString* dir;


@end
