//
//  OtherEffectsPane.h
//  ForIphone
//
//  Created by Lionel Seidman on 2/29/12.
//  Copyright (c) 2012 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MosaicViewController.h"

@protocol OtherEffectsPaneDelegate <NSObject>

@optional

-(void)showAttachmentPane;
-(void)openMosaic:(MosaicViewController *)mosaic;
-(void)save;

@end

@interface OtherEffectsPane : UIViewController{
    IBOutlet UIBarButtonItem * backButton;
    IBOutlet UIButton * attachmentButton;
    IBOutlet UIButton * mosaicButton;
}

@property (nonatomic, retain) id<OtherEffectsPaneDelegate>writingPane;

-(IBAction)showAttachmentPane:(id)sender;
-(IBAction)openMosaic:(id)sender;

@end
