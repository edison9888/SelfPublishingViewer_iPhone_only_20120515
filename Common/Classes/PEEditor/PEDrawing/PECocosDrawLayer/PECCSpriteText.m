//
//  PECCSpriteText.m
//  PEEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import "PECCSpriteText.h"

@implementation PECCSpriteText

@synthesize cocosLayer,isPanning,isControlsVisible,touchBeganPoint;


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
    
    CGSize winSize = [[CCDirector sharedDirector]winSize];
    [self setPosition:ccp(winSize.width/2,winSize.height/2)];
}

-(void)remove
{
    //Remove touch Delegate
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];

}


#pragma mark - Touches

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{  
    self.touchBeganPoint = [touch locationInView:[touch view]];
    self.touchBeganPoint = [[CCDirector sharedDirector] convertToGL:self.touchBeganPoint];
    
    //Check whether rect is rotate Spr or Scaling
   // CGPoint touchtempPoint = [self convertTouchToNodeSpace:touch];
   
    //Check For Pannin
    if([self isTouchOnSprite:self withTouchPoint:self.touchBeganPoint]){
        
        self.isPanning = YES;
              
        panningStartPoint = ccpSub(self.position, self.touchBeganPoint);
        return YES;
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
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.isPanning = NO;
    NSLog(@"NOOO");
}

-(void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
}


-(BOOL) isTouchOnSprite:(CCSprite *)inSpr withTouchPoint:(CGPoint)touchPoint
{
    CGRect sprRect = CGRectMake(inSpr.position.x - ((inSpr.contentSize.width/2)*inSpr.scale), inSpr.position.y - ((inSpr.contentSize.height/2)*inSpr.scale), inSpr.contentSize.width*inSpr.scale, inSpr.contentSize.height*inSpr.scale);
    
    if(CGRectContainsPoint(sprRect, touchPoint)) 
	{
        return YES;
    }
	return NO;
}


- (void)dealloc {
    
    [super dealloc];
}

@end
