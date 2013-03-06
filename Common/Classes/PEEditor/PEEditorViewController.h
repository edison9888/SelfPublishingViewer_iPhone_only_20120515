//
//  PEEditorViewController.h
//  PEEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PEPensViewController.h"
#import "PEStampViewController.h"
#import "PEAddTextViewController.h"
#import "PECocosUIView.h"
#import "PEStampView.h"
#import "PEDrawing.h"
#import "PEPhotoFrameView.h"

//added:
#import "common.h"
#import "PageMemo.h"
#import "FileUtil.h"
#import "MosaicViewController.h"
#import "Viewable.h"
#import "Book.h"
#import "SettingPane.h"
#import "OtherEffectsPane.h"
#import "AttachmentPane.h"

@protocol PEEditorViewControllerDelegate

-(void)writingDone:(UIImage*)img;

@end

@interface PEEditorViewController : UIViewController<PEPenViewControllerDelegate,PEAddTextControllerDelegate,PEStampViewDelegate,PEPenViewControllerDelegate,PEStampViewControllerDelgate,UIActionSheetDelegate, OtherEffectsPaneDelegate, MosaicViewControllerDelegate> {
    UIButton *drawBtn;
    PEPensViewController *penViewController;
    OtherEffectsPane * otherEffects;
    BOOL menuHidden;
    IBOutlet UIButton * closeButton;
    
    //Cocos
    PECocosUIView *cocosView;
}

@property (retain, nonatomic) IBOutlet UIButton *drawBtn;
@property (nonatomic, retain) PEPensViewController *penViewController;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImage;
@property (nonatomic, retain) IBOutlet UIImageView *layersView;
@property (nonatomic, retain) UIImage * img;
@property (nonatomic, retain) UIImage * layers;
@property (nonatomic, retain) NSObject<Viewable>* book;
@property NSInteger page;
@property (nonatomic, retain) UIActionSheet * actionSheet;
@property (nonatomic, retain) NSObject<PEEditorViewControllerDelegate> * delegate;
@property (nonatomic, retain) PageMemo* pageMemo;

//Cocos
@property (nonatomic,retain)IBOutlet PECocosUIView *cocosView;

//range
@property (retain, nonatomic) IBOutlet UIImageView *rangeTopBar;
@property (retain, nonatomic) IBOutlet UILabel *rangeTitleLbl;
@property (retain, nonatomic) IBOutlet UIButton *rangeSaveBtn;
@property (retain, nonatomic) IBOutlet UIButton *rangeCancelBtn;
@property (retain, nonatomic) IBOutlet UIImageView *rangeButtomBar;
@property (retain, nonatomic) IBOutlet UIView *rangeAlertView;
@property (retain, nonatomic) IBOutlet UIImageView *rangeAlertImageView;

//menu buttons
@property (retain, nonatomic) IBOutlet UIButton *drawMenuBtn;
@property (retain, nonatomic) IBOutlet UIButton *eraseMenuBtn;
@property (retain, nonatomic) IBOutlet UIButton *deleteMenuBtn;

//ZoomTextView Controls
@property (retain, nonatomic) IBOutlet UIView *zoomTextView;
@property (retain, nonatomic) IBOutlet UILabel *textPreviewLbl;
@property (retain, nonatomic) IBOutlet UISlider *textZoomSlider;

- (IBAction)textZoomSliderAction:(id)sender;
- (IBAction)textZoomFinishedAction:(id)sender;

//MainActions
- (IBAction)undo:(id)sender;
- (IBAction)redo:(id)sender;
- (IBAction)erase:(id)sender;
- (IBAction)close:(id)sender;
- (IBAction)delete:(id)sender;
- (IBAction)done:(id)sender;

//range Actions
- (IBAction)rangeAlertCancelClicked:(id)sender;
- (IBAction)rangeAlertConfirmClicked:(id)sender;
- (IBAction)rangeSaveCliked:(id)sender;
- (IBAction)rangeCancelClicked:(id)sender;

-(void)showRangeControlls;
-(void)hideRangeControlls;

#pragma mark - Actions
- (IBAction)stampClicked:(id)sender;
- (IBAction)drawClicked:(id)sender;
- (void)saveAsLayer;
- (IBAction)showLayers;
- (IBAction)openOtherEffectsPane;
- (void)openMosaic:(MosaicViewController *)mosaic;
- (void)addMosaicImage:(UIImage *)image;
- (void)showAttachmentPane;
- (IBAction)toggleMenu:(id)sender;

@end
