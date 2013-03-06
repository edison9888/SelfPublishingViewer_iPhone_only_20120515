//
//  PalettePane.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/16.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PalettePaneDelegate
-(void)palettePaneDisposed;
-(void)widthSet:(CGFloat)width;
@optional
-(void)colorSelected:(UIColor*)color point:(CGPoint)point;
-(void)hilightSet:(BOOL)hilighted;
@end


@interface PalettePane : UIViewController {
     UILabel* hlLabel;
     UIImageView* colorPalette;
     UISlider* slider;
     UIView* previewView;
     UIView* paletteHolder;
     UIView* widthHolder;
     UISwitch* hlSwitch;
    UIImageView* selector;
    UIColor* color;
    CGFloat width;
    NSObject<PalettePaneDelegate>* delegate;
    BOOL colorMode;
    BOOL hilighted;
    CGPoint selectorPoint;
}

@property(nonatomic,retain) IBOutlet UILabel* hlLabel;
@property(nonatomic,retain)IBOutlet UIImageView* colorPalette;
@property(nonatomic,retain)IBOutlet UISlider* slider;
@property(nonatomic,retain)IBOutlet UIView* previewView;
@property(nonatomic,retain)IBOutlet UIView* paletteHolder;
@property(nonatomic,retain)IBOutlet UIView* widthHolder;
@property(nonatomic,retain)IBOutlet UISwitch* hlSwitch;



@property(nonatomic,assign)BOOL colorMode;
@property(nonatomic,assign)BOOL hilighted;

@property(nonatomic,assign)NSObject<PalettePaneDelegate>* delegate;

@property(nonatomic,assign)CGPoint selectorPoint;
@property(nonatomic,retain)UIColor* color;
@property(nonatomic,assign)CGFloat width;

-(IBAction)widthChanged:(UISlider*)sl;
-(IBAction)hilightChanged:(UISwitch*)sw;

-(void)dispose;


@end
