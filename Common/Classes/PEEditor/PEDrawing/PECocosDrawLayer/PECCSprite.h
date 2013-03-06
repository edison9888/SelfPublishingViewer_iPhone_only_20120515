
//  PECCSprite.h
//  testDrawing
// testDrawing
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "PECocosLayer.h"



@interface PECCSprite :  CCSprite <CCTargetedTouchDelegate>
{
       //Main Cocos Layer
    PECocosLayer *cocosLayer; 
    
    //Controls
    BOOL isControlsVisible;
    CCSprite *rotateSpr;
    CCSprite *scaleSpr;
    
    //Touch
    CGPoint touchBeganPoint;
    
    //Translation 
    
    //Panning 
    BOOL isPanning;
    CGPoint panningStartPoint;
    
    //Scaling
    BOOL isScaling;
    CGFloat startingScale;
    
    //Rotating
    BOOL isRotating;
    CGFloat startingAngle;
}

//Main Cocos Layer
@property (nonatomic,assign) PECocosLayer *cocosLayer;

//Controls
@property (nonatomic,assign) BOOL isControlsVisible;
@property (nonatomic,assign) CCSprite *rotateSpr;
@property (nonatomic,assign) CCSprite *scaleSpr;

//Touch
@property (nonatomic,assign) CGPoint touchBeganPoint;

//Translation 
@property (nonatomic,assign) BOOL isPanning;
@property (nonatomic,assign) BOOL isScaling;
@property (nonatomic,assign) BOOL isRotating;

//Setup !!!
-(void)setUPWithLayer:(PECocosLayer *)inLayer;

//Remove
-(void)remove;

//Utility
-(BOOL) isTouchOnSprite:(CCSprite *)inSpr withTouchPoint:(CGPoint)touchPoint;
-(CGPoint)getTopLeftCornerPosition;
-(float) getAngleFromCurrentPoint:(CGPoint )inCurrentPoint toPoint:(CGPoint)inToPoint;

-(void)showControls;
-(void)hideControls;
-(void)removeControls;



@end
