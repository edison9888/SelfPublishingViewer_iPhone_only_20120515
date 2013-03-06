//
//  LibraryPane.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/15.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StampLibrary.h"

@protocol LibraryPaneDelegate

-(void)imageSelected:(UIImage*)img;

@end

@interface LibraryPane : UIViewController {
    @private
     UILabel* titleLabel;
     UIToolbar* toolBar;
     UIToolbar* editBar;
     UIBarButtonItem* cancelButton;
     UIBarButtonItem* editButton;
     UIBarButtonItem* doneButton;
     UIScrollView* scrollView;
     UIView* contentView;
    
    StampLibrary* stampLibrary;
    NSMutableArray* icons;
    NSMutableArray* delButtons;
    BOOL isPortrait;
    BOOL layoutCompleted;
    NSObject<LibraryPaneDelegate>* delegate;
    enum PaneMode {
        Deleting,
        Selecting
    } paneMode;
}
@property(nonatomic,retain) IBOutlet UILabel* titleLabel;
@property(nonatomic,retain)IBOutlet UIToolbar* toolBar;
@property(nonatomic,retain)IBOutlet UIToolbar* editBar;
@property(nonatomic,retain)IBOutlet UIBarButtonItem* cancelButton;
@property(nonatomic,retain)IBOutlet UIBarButtonItem* editButton;
@property(nonatomic,retain)IBOutlet UIBarButtonItem* doneButton;
@property(nonatomic,retain)IBOutlet UIScrollView* scrollView;
@property(nonatomic,retain)IBOutlet UIView* contentView;




@property(nonatomic,assign)NSObject<LibraryPaneDelegate>* delegate;

-(IBAction)close;
-(IBAction)startEdit;
-(IBAction)endEdit;


@end
