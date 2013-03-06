
//
//  PECCRangeSprite.m
//  PhotoEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//
//
#import "PECCRangeSprite.h"
#import "PEConfig.h"

@implementation PECCRangeSprite

@synthesize cocosLayer,scaleSpr,isScaling,isPanning,touchBeganPoint;

- (id)init {
    self = [super init];
    if (self) {
     
        //Dispatcher
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];

    }
    return self;
}

-(void)setUPWithLayer:(PECocosLayer *)inLayer
{
    self.cocosLayer = inLayer;
    
    self.tag = kRangeSprTag;
    
    //Bottom End
    scaleSpr = [CCSprite spriteWithFile:@"scale_bt.png"];
    scaleSpr.opacity = 0;
    scaleSpr.position = ccp(self.contentSize.width,0);
    [self addChild:scaleSpr]; 
    
    [self.scaleSpr setScale:1/self.scale];
    
    [self showControls];
}

#pragma mark - Show & Hide Controls
-(void)showControls
{
    id fadeInAction = [CCFadeIn actionWithDuration:0.5];
    [self.scaleSpr runAction:fadeInAction];
}

-(void)removeControls
{
    NSLog(@"Remove");
    [self.scaleSpr stopAllActions];
    
    [self removeChild:self.scaleSpr cleanup:YES];
    
    //Remove touch Delegate
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}


#pragma mark - Touches 
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.touchBeganPoint = [touch locationInView:[touch view]];
    self.touchBeganPoint = [[CCDirector sharedDirector] convertToGL:self.touchBeganPoint];
    
    //Check whether rect is rotate Spr or Scaling
    CGPoint touchtempPoint = [self convertTouchToNodeSpace:touch];
    
    if([self isTouchOnSprite:scaleSpr withTouchPoint:touchtempPoint])
    {
        self.isScaling = YES;
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
        
        panningStartPoint = ccpSub(self.position, self.touchBeganPoint);
        return YES;
    }
    return NO;
}

// touch updates:
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchMovedPoint = [touch locationInView:[touch view]];
	touchMovedPoint = [[CCDirector sharedDirector] convertToGL:touchMovedPoint];
    
    if(self.isPanning)
    {
        self.position = ccpAdd(touchMovedPoint,panningStartPoint);
    }
    else if(self.isScaling)
    {
        float distance = ccpDistance([self getTopLeftCornerPosition], touchMovedPoint);
        float scale = distance/100;
        
        [self setScale:startingScale+scale];
        [self.scaleSpr setScale:1/self.scale];
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.isPanning = NO;
    self.isScaling = NO;
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

#pragma mark - Utility
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



#pragma mark - dealloc
- (void)dealloc {
    
    NSLog(@"Range Spr Removed");
    [super dealloc];
}

@end
