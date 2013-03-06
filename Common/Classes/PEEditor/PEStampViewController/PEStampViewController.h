//
//  PEStampViewController.h
//  PhotoEditiong
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PEStampView.h"
#import "PEUtility.h"
#import "PEOriginalStampView.h"
#import "PETextView.h"
#import "PEAddTextViewController.h"
#import "PEPhotoFrameView.h"
//#import "PEEditorViewController.h"
@class PEEditorViewController;
@protocol PEStampViewControllerDelgate <NSObject>
@optional
-(void)didStampSelected:(id )inStampInfo;
-(void)didRangeSelected;
-(void)didStampTextSelected:(NSString *)inSelectedText fontName:(NSString*)inFontName fontColor:(UIColor*)inTextColor;
-(void)didFrameSelected:(id)inFrameInfo;
@end

@interface PEStampViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate,PEOriginalStampViewDelgate,PETextViewDelegate,PEAddTextControllerDelegate,PEStampViewDelegate>{
    UIPopoverController *popoverController;
    UIView *fontTypesHstView;
    UIButton *txtButton;
    UIButton *pictureBtn;
    UIButton *frameBtn;
    
    //used  to font types after clickin on text stamp....
    PETextView *fontTypeView;
    UISlider *fontSizeSlider;
    
    PEAddTextViewController *addTextViewController;
    UIScrollView *englishFontHstScrl;
    
    PEEditorViewController *editorViewController;
    UIView *bottomBarHstView;
    
    UIView *sizeSliderHostView;
    UISlider *sizeSlider;
    UIImageView *selectedPalletImgView;
    
    //selected stamp view
    PEStampView *selectedStampView;
    
}
 
@property (retain, nonatomic) IBOutlet UIView *sizeSliderHostView;
@property (retain, nonatomic) IBOutlet UISlider *sizeSlider;
@property (retain, nonatomic) IBOutlet UIImageView *selectedPalletImgView;

@property (retain, nonatomic) PEStampView *selectedStampView;

//label
@property (retain, nonatomic) IBOutlet UILabel *stampTitleLbl;
//buttons
@property (retain, nonatomic) IBOutlet UIButton *stampBtn;
@property (retain, nonatomic) IBOutlet UIButton *satrStampBtn;
@property (retain, nonatomic) IBOutlet UIButton *ballonStampBtn;
@property (retain, nonatomic) IBOutlet UIButton *penStampBtn;
@property (retain, nonatomic) IBOutlet UIButton *txtButton;
@property (retain, nonatomic) IBOutlet UIButton *pictureBtn;
@property (retain, nonatomic) IBOutlet UIButton *frameBtn;

//scroll view
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
//this view show shows controls like editing , camera, selected range
@property (retain, nonatomic) IBOutlet UIView *originalStampSubView;
//checking whther originalStamp is in editing mode or not.
@property (retain, nonatomic) IBOutlet UIView *bottomBarHstView;
@property(assign,nonatomic) BOOL isEditing;
@property(nonatomic,assign)UIImagePickerController *picker;

//alert view
@property (retain, nonatomic) IBOutlet UIView *alertView;
@property (retain, nonatomic) IBOutlet UIImageView *alertViewImage;

@property(nonatomic,retain)UIImage *saveImage;
//range controller
@property(nonatomic,assign)id<PEStampViewControllerDelgate> stampDelgate;
@property (retain, nonatomic) IBOutlet UIView *fontTypesHstView;

@property (nonatomic, retain) PETextView *fontTypeView;
@property (retain, nonatomic) IBOutlet UISlider *fontSizeSlider;
@property (nonatomic, retain) PEAddTextViewController *addTextViewController;
@property (retain, nonatomic) IBOutlet UIScrollView *englishFontHstScrl;
@property (retain, nonatomic) IBOutlet UIScrollView *japaneseFontHstScrl;
@property (retain, nonatomic) IBOutlet UIScrollView *chineseFontHstScrl;
@property (nonatomic, retain) PEEditorViewController *editorViewController;

- (IBAction)loadOriginalStamps:(id)sender;
- (IBAction)loadBallonStamps:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)loadStarStamps:(id)sender;
- (IBAction)loadpenStamps:(id)sender;
- (IBAction)fontSizeChange:(id)sender;
- (IBAction)edit:(id)sender;
- (IBAction)selectRange:(id)sender;
- (IBAction)takePicture:(id)sender;
- (IBAction)penClicked:(id)sender;
- (IBAction)photoAlbum:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *loadFrames;
- (IBAction)loadFrames:(id)sender;

//loading english,japanese and chinese fonts
- (IBAction)loadFontTypes:(id)sender;
-(void)loadJapaneseFonts;
-(void)loadChineseFonts;

#pragma mark - Loading font types for ipad
-(void)loadFontTypesForiPad;

//for size slider OK action
- (IBAction)sizeSlider:(id)sender;

//slider Ok action after pen selection (tab 2)
- (IBAction)sliderOkClicked:(id)sender;

//alert actions 
- (IBAction)alertCancel:(id)sender;
- (IBAction)alertConfirm:(id)sender;


@end
