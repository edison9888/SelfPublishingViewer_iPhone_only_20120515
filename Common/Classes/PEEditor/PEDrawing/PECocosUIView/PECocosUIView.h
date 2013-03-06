//
//  PECocosSceneCreator.h
//  PhotoEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PECocosLayer.h"

@class RootViewController;

@interface PECocosUIView : UIView
{
    //Game Vars
    RootViewController	*viewController;
    
    PECocosLayer *cocosLayer;
}

//Cocos
@property(nonatomic,assign) PECocosLayer *cocosLayer;

//Cocos 
- (void) removeStartupFlicker;
@end
