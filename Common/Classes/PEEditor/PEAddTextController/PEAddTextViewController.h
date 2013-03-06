//
//  PEAddTextViewController.h
//  PhotoEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PEAddTextControllerDelegate<NSObject>
-(void)didCloseClicked;
-(void)didStampTextSelected:(NSString *)inSelectedText fontName:(NSString*)inFontName fontColor:(UIColor*)inTextColor;

@end

@interface PEAddTextViewController : UIViewController {
    UIView *addTxtHstView;
    UITextView *addTextView;
    UIScrollView *colorsHstScrl;
    UIButton *okBtn;
    UIButton *closeBtn;
    
    UIButton *selectedColorBtn;
    BOOL isTextColorSelected;
    UIView *textColorHstView;
    
    //Holds text colors....
    NSMutableArray *textColors;
    
    id<PEAddTextControllerDelegate> delegate;
    
    NSString *fontType;
    CGFloat fontSize;
}


@property (retain, nonatomic) IBOutlet UIView *addTxtHstView;
@property (retain, nonatomic) IBOutlet UITextView *addTextView;
@property (retain, nonatomic) IBOutlet UIScrollView *colorsHstScrl;
@property (retain, nonatomic) IBOutlet UIButton *okBtn;
@property (retain, nonatomic) IBOutlet UIButton *closeBtn;
@property (nonatomic, retain) UIButton *selectedColorBtn;
@property (nonatomic, assign) BOOL isTextColorSelected;
@property (retain, nonatomic) IBOutlet UIView *textColorHstView;
@property (nonatomic, retain) NSMutableArray *textColors;

@property (nonatomic, assign) id<PEAddTextControllerDelegate> delegate;
@property (nonatomic,retain) NSString *fontType;
@property (nonatomic,assign) CGFloat fontSize;

#pragma mark - 
#pragma mark - Actions
- (IBAction)closeClicked:(id)sender;
- (IBAction)okClicked:(id)sender;
-(void)colorsClicked:(UIButton *)inSender;
- (IBAction)nextController:(id)sender;
#pragma mark - 
-(void)addSubViewsForiPhone;
-(void)addSubViewsForiPad;

#pragma mark - Resources from plist
-(NSArray *)getDataWithRGB;

@end

@interface Textcolor : NSObject {
    
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    
    NSString *colorName;
}
@property (nonatomic, assign)CGFloat red;
@property (nonatomic, assign)CGFloat green;
@property (nonatomic, assign)CGFloat blue;

@property (nonatomic, retain) NSString *colorName;
@end
