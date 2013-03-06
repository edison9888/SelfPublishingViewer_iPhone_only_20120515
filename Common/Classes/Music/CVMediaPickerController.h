//
//  CVMediaPickerController.h
//  CommonViewer
//
//  Created by FSCM100301 on 10/08/19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CVConstants.h"


@protocol CVMediaPickerControllerDelegate;


@interface CVMediaPickerController : UIViewController 
<UITableViewDelegate, UITableViewDataSource, UITabBarDelegate> {
	 UINavigationItem *navitem;
	 UIBarButtonItem *doneButton;
	 UIBarButtonItem *cancelButton;
	 UIBarButtonItem *backButton;
	 UITableView *tableview;
	 UITabBar *tabbar;
	
	id<CVMediaPickerControllerDelegate> cvmpDelegate;
	
	CVMPTag mode;
	BOOL inArtist;
	NSInteger selectedArtist;
	
	NSArray *list;
	NSMutableArray *selectedList;
}
@property (nonatomic, retain)IBOutlet UINavigationItem *navitem;
@property (nonatomic, retain)IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, retain)IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain)IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, retain)IBOutlet UITableView *tableview;
@property (nonatomic, retain)IBOutlet UITabBar *tabbar;


@property (assign) id<CVMediaPickerControllerDelegate> cvmpDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil items:(NSArray *)items;

- (void)query;
- (BOOL)existInSelectedList:(MPMediaItem *)item index:(NSInteger *)index;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end


@protocol CVMediaPickerControllerDelegate

@optional
- (void)didSelected:(CVMediaPickerController *)controller collection:(MPMediaItemCollection *)c;
- (void)didCancelled:(CVMediaPickerController *)controller;

@end