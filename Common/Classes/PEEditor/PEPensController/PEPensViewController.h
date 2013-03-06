//
//  PEPensViewController.h
//  PEEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//
#import <UIKit/UIKit.h>
@interface PEStandard : NSObject {
  
    
    NSString *brushName;
    CGFloat rSliderVal;
    CGFloat gSliderVal;
    CGFloat bSliderVal;
    CGFloat brightnessVal;
    
    CGFloat sizeSliderVal;
    
    BOOL isStandard;
    int tag;
    
}

@property (nonatomic,assign) CGFloat rSliderVal;
@property (nonatomic,assign) CGFloat gSliderVal;
@property (nonatomic,assign) CGFloat bSliderVal;
@property (nonatomic, retain) NSString *brushName;
@property (nonatomic, assign) CGFloat brightnessVal;
@property (nonatomic, assign) CGFloat sizeSliderVal;
@property (nonatomic, assign) BOOL isStandard;
@property (nonatomic, assign)int tag;

@end
#import <UIKit/UIKit.h>
#import "PEColorView.h"
#import "PEPenView.h"
#import "PESpecialView.h"
#import "PEDrawing.h"
//#import "PEStandard.h"
@class PEStandard;

@protocol  PEPenViewControllerDelegate <NSObject>

-(void)didDrawingControlClicked:(PEStandard *)inStandard;

@end

@interface PEPensViewController : UIViewController<PEColorViewDelgate,PESpecialViewDelegate,PEPenViewDelgate> {
    
    UIButton *stdBtn;
    UIButton *specialBtn;
    UIImageView *selectedPenImgView;
    UILabel *selectedPenName;
    UIButton *showPensBtn;
    UISlider *brightnessSlider;
    UISlider *rSlider;
    UISlider *gSlider;
    UISlider *bSlider;
    UIView *pensHstView;
    UIView *pensParentView;
    UIView *specialHstView;
    UIView *stdHstView;
    
    PEColorView *colorView;
    //for view with no color;
    PEColorView *colorViewNew;
    PEColorView *currentModifiedColorView;
    PEPenView *penView;
    PESpecialView *specialView;
    UISlider *sizeSlider;
    
    BOOL isStandardSelected;
    UILabel *brightnessVal;
    UILabel *rVal;
    UILabel *gVal;
    UILabel *bVal;
    
    //This array holds all colors....
    NSMutableArray *colors;
    UIImageView *selectedPalletImgView;
    
    id selectedView;
    UIScrollView *pensHstScrl;
    UIScrollView *spclHstScrl;
    
    PEStandard *standardObj;
    
    //Delegate after ok clicked
    id<PEPenViewControllerDelegate> delegate;
    
    //to get current selected pallet frame....
    CGRect currentFrame;
    
    //This array holds color pallets rgb...
    NSMutableArray *colorPalletsRGBVals;
    
    NSString *selectedBrush;
    BOOL isSpecialSelected;
    
    IBOutlet UIImageView *sliderHostImageView;
    
    //State Save
    PEColorView *lastSelectedColorView;
    float lastStandardSliderVal;
    PESpecialView *lastSelectedSpecialView;
    float lastSpecialSliderVal;
    CGRect lastStandradFrame,lastSpecialFrame;
    
    //default brushes
    NSString *selectedSpecialBrush, *selectedStandradBrush;

}
@property (nonatomic, retain) IBOutlet UIView *pensParentView;
@property (nonatomic, retain) IBOutlet UIView *specialHstView;
@property (nonatomic, retain) IBOutlet UIView *stdHstView;

@property (nonatomic,retain) PEColorView *colorView;
@property (nonatomic,retain) PEColorView *colorViewNew;
@property (nonatomic,retain) PEColorView *currentModifiedColorView;
@property (nonatomic,retain) PEPenView *penView;

@property (nonatomic, retain) IBOutlet UIButton *stdBtn;
@property (nonatomic, retain) IBOutlet UIButton *specialBtn;
@property (nonatomic, retain) IBOutlet UIImageView *selectedPenImgView;
@property (nonatomic, retain) IBOutlet UILabel *selectedPenName;
@property (nonatomic, retain) IBOutlet UIButton *showPensBtn;

@property (nonatomic, retain) IBOutlet UISlider *brightnessSlider;
@property (nonatomic, retain) IBOutlet UISlider *rSlider;
@property (nonatomic, retain) IBOutlet UISlider *gSlider;
@property (nonatomic, retain) IBOutlet UISlider *bSlider;
@property (nonatomic, retain) IBOutlet UIView *pensHstView;
@property (nonatomic, assign) BOOL isStandardSelected;
@property (retain, nonatomic) IBOutlet UILabel *brightnessVal;
@property (retain, nonatomic) IBOutlet UILabel *rVal;
@property (retain, nonatomic) IBOutlet UILabel *gVal;
@property (retain, nonatomic) IBOutlet UILabel *bVal;

@property (nonatomic, retain) NSMutableArray *colors;
@property (retain, nonatomic) IBOutlet UIImageView *selectedPalletImgView;
@property (nonatomic, retain) PESpecialView *specialView;

@property (retain, nonatomic) IBOutlet UISlider *sizeSlider;

@property (nonatomic, retain) id selectedView;
@property (retain, nonatomic) IBOutlet UIScrollView *pensHstScrl;
@property (retain, nonatomic) IBOutlet UIScrollView *spclHstScrl;
@property (nonatomic, retain) PEStandard *standardObj;

@property (nonatomic, assign) id<PEPenViewControllerDelegate> delegate;

@property (nonatomic, assign) CGRect currentFrame;

@property (nonatomic, retain)  NSMutableArray *colorPalletsRGBVals;
@property (nonatomic, retain) NSString *selectedBrush;
@property (nonatomic, assign) BOOL isSpecialSelected;

//State Save
@property (nonatomic, retain)PEColorView *lastSelectedColorView;
@property (nonatomic, retain)PESpecialView *lastSelectedSpecialView;


#pragma mark - Actions
- (IBAction)showMeMyPens:(id)sender;
- (IBAction)specialClicked:(id)sender;
- (IBAction)standardClicked:(id)sender;
- (IBAction)okclicked:(id)sender;

#pragma mark - slider value changed
- (IBAction)brightnessChange:(id)sender;
- (IBAction)rValChange:(id)sender;
- (IBAction)gValChange:(id)sender;
- (IBAction)bValChange:(id)sender;
- (IBAction)sizeChange:(id)sender;

#pragma mark - load color pallets
-(void)loadColorPallets;


#pragma mark - 
-(void)loadColorsView;
-(void)loadPensView;
-(void)loadSpecialView;

#pragma mark - load pen,special and color view for iPad
-(void)loadColorsviewForiPad;
-(void)loadPensViewForiPad;
-(void)loadSpecialViewForiPad;

#pragma mark - cutomize slider for iphone
-(void)customizeSliderForiPhoneAndiPad:(NSString *)inType;



#pragma mark - 
- (UIImage*)imageWithImage:(UIImage*)image 
              scaledToSize:(CGSize)newSize;

#pragma mark - Fill color pallets.....
-(void)fillColorViewWithNewColor:(UIColor *)inColor;

@end


