
//
//  PECCRangeSprite.h
//  PhotoEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//
//adding code to commit

#import "cocos2d.h"
#import "PECocosLayer.h"

@interface PECCRangeSprite : CCSprite <CCTargetedTouchDelegate>
{
    //Main Cocos Layer
    PECocosLayer *cocosLayer;
        
    //Controls
    CCSprite *scaleSpr;
    
    //Touch
    CGPoint touchBeganPoint;
    
    //Panning 
    BOOL isPanning;
    CGPoint panningStartPoint;
    
    //Scaling
    BOOL isScaling;
    CGFloat startingScale;
}

//Main Cocos Layer
@property (nonatomic,assign) PECocosLayer *cocosLayer;

//Scaling
@property (nonatomic,assign) CCSprite *scaleSpr;

//Touch
@property (nonatomic,assign) CGPoint touchBeganPoint;

//Translation 
@property (nonatomic,assign) BOOL isPanning;
@property (nonatomic,assign) BOOL isScaling;


-(void)setUPWithLayer:(PECocosLayer *)inLayer;

//Show & Hide Controls
-(void)showControls;
-(void)removeControls;

//Utility
-(BOOL) isTouchOnSprite:(CCSprite *)inSpr withTouchPoint:(CGPoint)touchPoint;
-(CGPoint)getTopLeftCornerPosition;

@end
