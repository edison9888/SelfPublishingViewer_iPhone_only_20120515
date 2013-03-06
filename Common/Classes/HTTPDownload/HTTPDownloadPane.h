//
//  HTTPDownloadPane.h
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/28.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadURLs.h"


@interface HTTPDownloadPane : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    @private
     UITextField* urlField;
     UITableView* tableView;
     UIView* inputView;
     UIButton* saveButton;
     UITextView*  help;
     UIButton* btn1;
     UIButton* btn2;
    DownloadURLs* urls;
}
@property(nonatomic,retain) IBOutlet UITextField* urlField;
@property(nonatomic,retain) IBOutlet UITableView* tableView;
@property(nonatomic,retain) IBOutlet UIView* inputView;
@property(nonatomic,retain) IBOutlet UIButton* saveButton;
@property(nonatomic,retain) IBOutlet UITextView*  help;
@property(nonatomic,retain) IBOutlet UIButton* btn1;
@property(nonatomic,retain) IBOutlet UIButton* btn2;


// 今回だけ利用
- (IBAction)useOnetime;
// 保存して利用
- (IBAction)useSaving;

@end
