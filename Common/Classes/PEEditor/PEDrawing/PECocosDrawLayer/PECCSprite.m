
//
//  PECCSprite.m
//  testDrawing
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//
//

#import "PECCSprite.h"

@implementation PECCSprite

@synthesize cocosLayer,isControlsVisible,rotateSpr,scaleSpr,isPanning,isRotating,isScaling,touchBeganPoint;

- (id)init {
    self = [super init];
    if (self) {
        
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
    }
    return self;
}

//Setup !!!
-(void)setUPWithLayer:(PECocosLayer *)inLayer
{
    self.cocosLayer = inLayer;

    //Add small Image at top and Bottom to rotate and scale
    
    //Top Middle
    rotateSpr = [CCSprite spriteWithFile:@"rotate.png"];
    rotateSpr.opacity = 0;
    rotateSpr.position = ccp(self.contentSize.width/2,self.contentSize.height);
    [self addChild:rotateSpr];
    
    //Bottom End
    scaleSpr = [CCSprite spriteWithFile:@"scale_bt.png"];
    scaleSpr.opacity = 0;
    scaleSpr.position = ccp(self.contentSize.width,0);
    [self addChild:scaleSpr]; 
    
    self.isControlsVisible = NO;
  //  [self setScale:1.5];
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        [self setScale:0.7];
    }
    else
    {
        [self setScale:0.4];
    }
    
    [self.rotateSpr setScale:1/self.scale];
    [self.scaleSpr setScale:1/self.scale];
    
    [self showControls];
}


#pragma mark - Touches

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{  
    //if(self.cocosLayer.selectedSpriteTag == self.tag||self.cocosLayer.selectedSpriteTag == 0)
    {
        self.touchBeganPoint = [touch locationInView:[touch view]];
        self.touchBeganPoint = [[CCDirector sharedDirector] convertToGL:self.touchBeganPoint];
        
        //Check whether rect is rotate Spr or Scaling
        CGPoint touchtempPoint = [self convertTouchToNodeSpace:touch];
        if([self isTouchOnSprite:rotateSpr withTouchPoint:touchtempPoint])
        {
            self.isRotating = YES;
            self.isPanning = NO;
            self.isScaling = NO;
            
            float angleToRotate = [self getAngleFromCurrentPoint:self.position toPoint:self.touchBeganPoint];
            startingAngle = self.rotation-angleToRotate;
            return YES;
        }
        else if([self isTouchOnSprite:scaleSpr withTouchPoint:touchtempPoint])
        {
            self.isScaling = YES;
            self.isRotating = NO;
            self.isPanning = NO;
            
            
            float distance = ccpDistance([self getTopLeftCornerPosition], self.touchBeganPoint);
            float scale = distance/100;
            
            startingScale = self.scale - scale;
            return YES;
        }
        //Check For Pannin
        else if([self isTouchOnSprite:self withTouchPoint:self.touchBeganPoint]){
            
            self.isPanning = YES;
            self.isScaling = NO;
            self.isRotating = NO;
            
            panningStartPoint = ccpSub(self.position, self.touchBeganPoint);
            return YES;
        }
    }
   // else
    {
        return NO;
    }
    return NO;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchMovedPoint = [touch locationInView:[touch view]];
	touchMovedPoint = [[CCDirector sharedDirector] convertToGL:touchMovedPoint];

    if(self.isPanning)
    {
        self.position = ccpAdd(touchMovedPoint,panningStartPoint);
    }
    else if(self.isRotating)
    {
        float angleToRotate = [self getAngleFromCurrentPoint:self.position toPoint:touchMovedPoint];
        [self setRotation:startingAngle+angleToRotate];
    }
    else if(self.isScaling)
    {
        float distance = ccpDistance([self getTopLeftCornerPosition], touchMovedPoint);
        float scale = distance/100;
    
        float scaleVal = startingScale+scale;
        
        if(scaleVal<0.1)
        {
            scaleVal = 0.1;
        }
        
        [self setScale:scaleVal];
        [self.rotateSpr setScale:1/self.scale];
        [self.scaleSpr setScale:1/self.scale];
    }
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.isPanning = NO;
    self.isScaling = NO;
    self.isRotating = NO;
    
   // [[CCScheduler sharedScheduler] scheduleSelector:@selector(hideControls) forTarget:self interval:4 paused:NO];
    self.cocosLayer.selectedSpriteTag = 0;
    
    NSLog(@"NOOO");
}

-(void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    //[[CCScheduler sharedScheduler] scheduleSelector:@selector(hideControls) forTarget:self interval:4 paused:NO];
    self.cocosLayer.selectedSpriteTag = 0;
}


#pragma mark - Utility Func

-(float) getAngleFromCurrentPoint:(CGPoint )inCurrentPoint toPoint:(CGPoint)inToPoint
{
    CGPoint difference = ccpSub(inToPoint,inCurrentPoint);
    double angle = -1 * (atan2(difference.y, difference.x) * 180 / M_PI + 90) + 180;
    return angle;
}

-(BOOL) isTouchOnSprite:(CCSprite *)inSpr withTouchPoint:(CGPoint)touchPoint
{
    CGRect sprRect = CGRectMake(inSpr.position.x - ((inSpr.contentSize.width/2)*inSpr.scale), inSpr.position.y - ((inSpr.contentSize.height/2)*inSpr.scale), inSpr.contentSize.width*inSpr.scale, inSpr.contentSize.height*inSpr.scale);
    
    if(CGRectContainsPoint(sprRect, touchPoint)) 
	{
        self.cocosLayer.selectedSpriteTag = self.tag;
        return YES;
    }
	return NO;
}

-(CGPoint)getTopLeftCornerPosition
{
    return ccp(self.position.x - self.contentSize.width/2, self.position.y+self.contentSize.height/2);
}

#pragma mark - Show & Hide Controls
-(void)showControls
{
    self.isControlsVisible = YES;
    
    id fadeInAction = [CCFadeIn actionWithDuration:0.5];
    [self.rotateSpr runAction:fadeInAction];
    
    fadeInAction = [CCFadeIn actionWithDuration:0.5];
    [self.scaleSpr runAction:fadeInAction];
    
    //Unschedule Selector
    //[[CCScheduler sharedScheduler] unscheduleSelector:@selector(hideControls) forTarget:self];
}

-(void)hideControls
{
    //Unschedule Selector
    //[[CCScheduler sharedScheduler] unscheduleSelector:@selector(hideControls) forTarget:self];

    id fadeOutAction = [CCFadeOut actionWithDuration:0.5];
    [self.rotateSpr runAction:fadeOutAction];
    
    fadeOutAction = [CCFadeOut actionWithDuration:0.5];
    [self.scaleSpr runAction:fadeOutAction];
    
    self.isControlsVisible = NO;
}

-(void)removeControls
{
    NSLog(@"Remove");
    [self.rotateSpr stopAllActions];
    [self.scaleSpr stopAllActions];
    
    [self removeChild:self.rotateSpr cleanup:YES];
    [self removeChild:self.scaleSpr cleanup:YES];
    
    //Remove touch Delegate
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

#pragma mark - Remove
-(void)remove
{
    [self removeChild:self cleanup:YES];
}

#pragma mark - Dealloc

- (void)dealloc {
    
    NSLog(@"Spl Spr Removed");
    
    [super dealloc];
}

@end
