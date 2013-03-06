//
//  PEEditorAppDelegate.h
//  PEEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PEAddTextViewController.h"
@class PEEditorViewController;

@interface PEEditorAppDelegate : NSObject <UIApplicationDelegate> {
    PEAddTextViewController *addTextViewController;
    UINavigationController *navController;
    
    PEEditorViewController *editorViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) PEAddTextViewController *addTextViewController;
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) IBOutlet PEEditorViewController *viewController;

@property (nonatomic, retain) PEEditorViewController *editorViewController;
@end
