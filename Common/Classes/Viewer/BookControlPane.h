//
//  BookControlPane.h
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/01.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "common.h"
#import "ImagePickDialog.h"
#import "ControlScroller.h"
#import "PEEditorViewController.h"
#import "PEAddTextViewController.h"

@class BookReaderPane;

@interface BookControlPane : UIViewController <UIActionSheetDelegate,UITabBarDelegate,ControlScrollerDelegate, UIGestureRecognizerDelegate, PEEditorViewControllerDelegate> {
@private
    BookReaderPane* reader;
    UISlider* pageSlider;
    UILabel* pageLabel;
    UILabel* pageCountLabel;
    UIButton* closeButton;
    UITabBarItem* bookmarkButton;
    UITabBarItem* lockButton;
    UITabBarItem* coverButton;
    UITabBarItem* prefButton;
    UITabBarItem* writeButton;
    UITabBarItem* dupButton;
    ImagePickDialog* imagePicker;
    ControlScroller* controlScroller;
    BOOL leftNext;
}
@property(nonatomic,retain)IBOutlet UISlider* pageSlider;
@property(nonatomic,retain)IBOutlet UILabel* pageLabel;
@property(nonatomic,retain)IBOutlet UILabel* pageCountLabel;
@property(nonatomic,retain)IBOutlet UIButton* closeButton;

@property(nonatomic,retain)IBOutlet UITabBarItem* bookmarkButton;
@property(nonatomic,retain)IBOutlet UITabBarItem* lockButton;
@property(nonatomic,retain)IBOutlet UITabBarItem* coverButton;
@property(nonatomic,retain)IBOutlet UITabBarItem* prefButton;
@property(nonatomic,retain)IBOutlet UITabBarItem* writeButton;
@property(nonatomic,retain)IBOutlet UITabBarItem* dupButton;

@property(nonatomic,retain)IBOutlet ControlScroller* controlScroller;
@property(nonatomic,assign) BookReaderPane* reader;

// 閉じるボタン
-(IBAction)closeBookReader:(id)sender;
// ページ選択つまみ
-(IBAction)pageSliderChanged:(id)sender;
// 閉じるときに後始末として呼ぶこと。
-(void)onClose;

@end
