//
//  AttachmentPane.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/14.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageMemo.h"
#import "ImagePickDialog.h"

@interface AttachmentPane : UIViewController<UIScrollViewDelegate> {
    @private
    PageMemo* pageMemo;
    UIScrollView* scrollView;
    UIImageView* primaryView;
    UIImageView* secondaryView;
    UIToolbar* toolbar;
    UIToolbar* editToolbar;
    UIBarButtonItem* addButton;
    UIBarButtonItem* prevButton;
    UIBarButtonItem* nextButton;
    UIBarButtonItem* prevButton2;
    UIBarButtonItem* nextButton2;
    UIBarButtonItem* removeButton;
    NSInteger current;
    ImagePickDialog* imagePicker;
    BOOL touchLeft;
    BOOL touchRight;
    NSTimeInterval beginTime;
    CGPoint beginPoint;
    BOOL editMode;
}
@property(nonatomic,retain)PageMemo* pageMemo;
@property(nonatomic,assign)BOOL editMode;
@property(nonatomic,retain)IBOutlet UIScrollView* scrollView;
@property(nonatomic,retain)IBOutlet UIImageView* primaryView;
@property(nonatomic,retain)IBOutlet UIImageView* secondaryView;
@property(nonatomic,retain)IBOutlet UIToolbar* toolbar;
@property(nonatomic,retain)IBOutlet UIToolbar* editToolbar;
@property(nonatomic,retain)IBOutlet UIBarButtonItem* addButton;
@property(nonatomic,retain)IBOutlet UIBarButtonItem* prevButton;
@property(nonatomic,retain)IBOutlet UIBarButtonItem* nextButton;
@property(nonatomic,retain)IBOutlet UIBarButtonItem* prevButton2;
@property(nonatomic,retain)IBOutlet UIBarButtonItem* nextButton2;
@property(nonatomic,retain)IBOutlet UIBarButtonItem* removeButton;


-(IBAction)add;
-(IBAction)prev;
-(IBAction)next;
-(IBAction)remove;
-(void)didRotate:(NSNotification *)notification;

@end
