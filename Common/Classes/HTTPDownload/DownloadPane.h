//
//  DownloadPane.h
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/28.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgressDialog.h"


@interface DownloadPane : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    NSString* url;
    UITableView* tableView;
    NSMutableArray* bookUrls;
    ProgressDialog* progress;
    NSStringEncoding encoding;
    CGFloat contentSize;
    CGFloat readByte;
    BOOL pageLoading;
    BOOL fileDownloading;
    NSMutableArray* downloadQueue;
    NSURLConnection* downloadConnection;
    NSString* localDownloadPath;
    
}
@property(nonatomic,retain) IBOutlet UITableView* tableView;

- (void)startDownload;

- (void)go:(NSString*)goUrl;

- (void)enterBackground;

- (void)enterForeground;

@end
