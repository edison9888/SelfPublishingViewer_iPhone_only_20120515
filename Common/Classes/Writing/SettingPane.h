//
//  SettingPane.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/16.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageMemo.h"

@interface SettingPane : UIViewController<UITableViewDelegate, UITableViewDataSource> {
     UIButton* helpButton;
     UITableView* tableView;
    PageMemo* pageMemo;
}

@property(nonatomic,retain) IBOutlet UIButton* helpButton;
@property(nonatomic,retain)IBOutlet UITableView* tableView;


@property(nonatomic,assign)PageMemo* pageMemo;

-(IBAction)showHelp;

@end
