//
//  PECCSpriteText.h
//  PEEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import "cocos2d.h"

@class PECocosLayer;

@interface PECCSpriteText : CCSprite <CCTargetedTouchDelegate>
{
    //Touch
    CGPoint touchBeganPoint;
    
    //Panning 
    BOOL isPanning;
    CGPoint panningStartPoint;

}

//Main Cocos Layer
@property (nonatomic,assign) PECocosLayer *cocosLayer;

//Controls
@property (nonatomic,assign) BOOL isControlsVisible;

//Touch
@property (nonatomic,assign) CGPoint touchBeganPoint;

//Translation 
@property (nonatomic,assign) BOOL isPanning;


//Setup !!!
-(void)setUPWithLayer:(PECocosLayer *)inLayer;

-(void)remove;

//Utility
-(BOOL) isTouchOnSprite:(CCSprite *)inSpr withTouchPoint:(CGPoint)touchPoint;

@end
