
//
//  PECocosLayer.m
//  PhotoEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//
#import "PECocosLayer.h"
#import "PECCSprite.h"
#import "PECCRangeSprite.h"
#import "PECCSpriteText.h"
#import "PEUtility.h"
#import "PEDrawing.h"
#import "PEController.h"
#import "PEConfig.h"
#import "PEUtlityFunc.h"
#import <malloc/malloc.h>


#import "PEPensViewController.h"

@implementation PECocosLayer
@synthesize _PEController,_PEDrawing,isDrawing,selectedSpriteTag,undoIndex,maxUndoIndex,addSpecialSpr,isSpecialSprFinalised,isSpecialBrush,frameName;

//Scene Creator
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	PECocosLayer *layer = [PECocosLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


#pragma mark - Init
// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        
        //Intialise Vars
        specialSpriteTag = 111;
        winSize = [[CCDirector sharedDirector]winSize];
        NSLog(@"winSize is %@",NSStringFromCGSize(winSize));
        
        splSpriteName = @"";
        
        //Enable touches
		self.isTouchEnabled = YES;
        
        // create a render texture, this is what we're going to draw into
		target = [[CCRenderTexture renderTextureWithWidth:winSize.width height:winSize.height] retain];
		[target setPosition:ccp(winSize.width/2, winSize.height/2)];
		
		
		// It's possible to modify the RenderTexture blending function by
        [[target sprite] setBlendFunc:(ccBlendFunc) {GL_ONE, GL_ONE_MINUS_SRC_ALPHA}];
		
		// note that the render texture is a CCNode, and contains a sprite of its texture for convience,
		// so we can just parent it to the scene like any other CCNode
		[self addChild:target z:-1];
		
        //Create Brush
        [self createDefaultBrush];
        
        //UNDO
        [self deleteUndoFolder];
        
        [self saveCurrentView];
        
        //Frame
        containsFrame = NO;
        isFramePathName = NO;
        
        NSString *_tempString = [[NSString alloc] initWithString:@""];
        self.frameName = _tempString;
        [_tempString release];
        
        //Create a scheduler to check inactivity
        [[CCScheduler sharedScheduler]scheduleSelector:@selector(saveDrawingInInactivite) forTarget:self interval:0.5 paused:NO];
        inactiveTime = 1.5;
        isPendingToSave = NO;
    }
    return self;
}

-(void)saveDrawingInInactivite
{
    inactiveTime = inactiveTime - 0.5;
    
    if(isPendingToSave)
    {
        if(inactiveTime<=0)
        {
            isPendingToSave = NO;
            [self saveCurrentView];
        }
    }
}

//Create Brush
-(void)createDefaultBrush
{
    // create a brush image to draw into the texture with
    brush = [[CCSprite spriteWithFile:@"color_11.png"] retain];
    [brush setRotation:90];
    
    //set black color
    [brush setColor:ccBLACK];
    
    //Set up defaults for Brush
    [brush setScale:1];
}

-(void)createBrushEdge
{
    //Add Brush Edge
    brushEdge = [[CCSprite spriteWithFile:@"color_Edge.png"]retain];
    brushEdge.visible = YES;
    [brushEdge setColor:ccc3(0, 0, 0)];
    [brushEdge setPosition:ccp(brush.contentSize.width/2, brush.contentSize.height/2)];
    [brush addChild:brushEdge];
}

-(void)creatBrushSprWithImage:(NSString *)brushImageName
{
    brush = [[CCSprite spriteWithFile:brushImageName] retain];
    [brush setRotation:90];
    [brush setScale:0.2];
}


#pragma mark - Drawing and Adding Images Delegate 
//Draw Delegates
-(void)didDrawValuesChangedWith:(PEStandard *)inStandardModel
{
    self.isDrawing = YES;
    self.addSpecialSpr = NO;

    if(self.isSpecialBrush)  // If it was gap brush change it to normal brush
    {        
        self.isSpecialBrush = NO;
    }        
    
    if(isEdgeBrush)
    {
        //remove Edge Brush
        [brushEdge removeFromParentAndCleanup:YES];
        [brushEdge release];
        
        isEdgeBrush = NO;
    }
        
    if([inStandardModel.brushName isEqualToString:@"pen_6_brush.png"])  // It is Edge Brush
    {
        isEdgeBrush = YES;
        
        [brush release];
        [self createDefaultBrush];
        [self createBrushEdge];
    }
    else
    {
        //Set the brush image
        [brush release];
        [self creatBrushSprWithImage:inStandardModel.brushName];
    }
    
    //Process the brush Info
    
    //Brush Size
    float scale = inStandardModel.sizeSliderVal;
    [brush setScale:scale/2];
    
    //Brush Opacity
    [brush setOpacity:inStandardModel.brightnessVal];
    
    //Brush Color
    if([inStandardModel.brushName isEqualToString:@"pen_6_brush.png"])
    {
        [brush setColor:ccWHITE];
        [brushEdge setColor:ccc3(inStandardModel.rSliderVal,inStandardModel.gSliderVal,inStandardModel.bSliderVal)];
    }
    else if(inStandardModel.tag == 999) // No color For special Brush
    {
        [brush setColor:ccc3(inStandardModel.rSliderVal,inStandardModel.gSliderVal,inStandardModel.bSliderVal)];
    }
}


-(void)didDrawingSelected:(PEDrawing *)inDrawingController
{
    if(inDrawingController.typeOfStamp == StampTypePen) //Drawing
    {
        [self addSpecialSprToTarget];
        self.addSpecialSpr = NO;
        
        self.isDrawing = YES;
        
        //Make the edge invisible
        //brushEdge.visible = NO;
        
        [brush release];
        brush = [[CCSprite spriteWithFile:inDrawingController.stampName] retain];
        
        brush.scale = inDrawingController.scale;
        self.isSpecialBrush = YES;
    }
    else // Images Stamp Frame etc
    {
        self.isDrawing = NO;
        if(inDrawingController.typeOfStamp == StampTypeStar)
        {
            splSpriteName = inDrawingController.stampName;
            isSplSpriteImg = NO;
            self.addSpecialSpr = YES;
        }
        else if(inDrawingController.typeOfStamp == StampTypeBallon)
        {
            splSpriteName = inDrawingController.stampName;
            isSplSpriteImg = NO;
            self.addSpecialSpr = YES;
        }
        else if(inDrawingController.typeOfStamp == StampTypeOriginalStamp)
        {
            splSpriteName = inDrawingController.stampPath;
            isSplSpriteImg = YES;
            self.addSpecialSpr = YES;
        }
        else if(inDrawingController.typeOfStamp == StampTypeFrame)
        {
            //Get the frame Name
            [self createFrameWithImage:inDrawingController.stampName];
        }
    }
}


//All Drawing Related
-(void)didControllerSelected:(PEController *)inColorController
{
    self.addSpecialSpr = NO;
    self.isDrawing = YES;
    
    if(self.isSpecialBrush)
    {
        //[brushEdge release];
        [brush release];
        
        [self createDefaultBrush];
        
        self.isSpecialBrush = NO;
    }
    
    [self setRGBForSprite:brush WithRGBString:inColorController.normalColorRgb];
    
    brush.opacity = 255;
    [brush setBlendFunc:(ccBlendFunc) { GL_ONE,GL_ONE_MINUS_SRC_ALPHA }];
      
    //Check for Brush Type
    //    Normal_Pen=1,
    //    Special_Pen,
    //    Errasor
    if(inColorController.brushType == Normal_Pen)
    {
    }
    else if(inColorController.brushType == Special_Pen)
    {
        brush.opacity = 255;
        [brush setBlendFunc:(ccBlendFunc) { GL_ONE,GL_ONE_MINUS_SRC_ALPHA }];
    }
    else if(inColorController.brushType == Errasor)
    {
        [brush setBlendFunc:(ccBlendFunc) { GL_ZERO,GL_ONE_MINUS_SRC_ALPHA }];
		[brush setOpacity:80];
    }
    //Brush Size
    float scale = (float)inColorController.brush_Size/5.0;
    [brush setScale:scale];
}


#pragma mark - Erase
-(void)setEraseMode:(BOOL)inMode
{
    //Enable Drawing Mode
    self.isDrawing = YES;
    self.addSpecialSpr = NO;
    
    float brushScale = brush.scale;
    
    [brush release];
    [self createDefaultBrush];
    
    brush.scale = brushScale;
    
    if(inMode)
    {
        [brush setBlendFunc:(ccBlendFunc) { GL_ONE,GL_ONE_MINUS_SRC_ALPHA }];
		[brush setOpacity:255];
    }
    else
    {
        [brush setBlendFunc:(ccBlendFunc) { GL_ZERO,GL_ONE_MINUS_SRC_ALPHA }];
		[brush setOpacity:255];
    }
}

#pragma mark -  Frames
-(void)createFrameWithImage:(NSString *)inImageName
{
    containsFrame = YES;
    isFramePathName = NO;
    
    //Check whether any old frame is thr !
    CCSprite *_frameSpr = (CCSprite *)[self getChildByTag:kFrameSpriteTag];
    if(_frameSpr)
    {
        [self removeChildByTag:kFrameSpriteTag cleanup:YES];
    }
    
    CCSprite *frameSpr = [CCSprite spriteWithFile:inImageName];
    self.frameName = [NSString stringWithFormat:inImageName];
    
    //Delete Path extension
    self.frameName = [self.frameName stringByDeletingPathExtension];
    
    [frameSpr setTag:kFrameSpriteTag];
    [frameSpr setPosition:ccp(winSize.width/2,winSize.height/2)];
    [self addChild:frameSpr z:50];
}

//Only Called First
-(void)WithUIImagePath:(NSString *)framePath
{
    isFramePathName = YES;
    self.frameName = framePath;
    
    
    UIImage *framePathImage = [[UIImage alloc]initWithContentsOfFile:framePath];
    
    CCSprite *frameSpr = [CCSprite spriteWithCGImage:[framePathImage CGImage] key:nil];
    [framePathImage release];
    
    [frameSpr setTag:kFrameSpriteTag];
    [frameSpr setPosition:ccp(winSize.width/2,winSize.height/2)];
    [self addChild:frameSpr z:50];
}

-(void)setImage:(UIImage *)img{
    
    undoIndex++;
    maxUndoIndex = undoIndex;
        
    [target clear:0 g:0 b:0 a:0];
      
    /*
    CCSprite *undoSpr = [CCSprite spriteWithCGImage:[img CGImage] key:nil];  
    [undoSpr setPosition:ccp(winSize.width/2,winSize.height/2)];
    */
    
    CGFloat width = 320;
    CGFloat height = 480;
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0)) {
        width *= 2.0;
        height *= 2.0;
    }
    
    CCSprite *frameSpr = [CCSprite spriteWithCGImage:[img CGImage] key:nil];
    
    [frameSpr setTag:kFrameSpriteTag];
    [frameSpr setScaleX:width / img.size.width];
    [frameSpr setScaleY:height / img.size.height];
    [frameSpr setPosition:ccp(winSize.width/2,winSize.height/2)];
    //[img release];
    
    [target begin];
    [frameSpr visit];
    [target end];
    
    NSString *path = [NSString stringWithFormat:@"saveBuffer%d.png", undoIndex];
    NSString *writeToFilePath = [NSString stringWithFormat:@"%@",path];
	writeToFilePath = [undoDocumentsPath stringByAppendingPathComponent:writeToFilePath];
    
    [target saveBuffer:writeToFilePath format:kCCImageFormatPNG];

    
    
    /*
    
    
    CCSprite *frameSpr = [CCSprite spriteWithCGImage:[img CGImage] key:nil];
    
    [frameSpr setTag:kFrameSpriteTag];
    //[frameSpr setPosition:CGPointMake(160, 240)];
    //[frameSpr setContentSize:CGSizeMake(320, 480)];
    //CGFloat scale = MAX(640 / img.size.width, 960 / img.size.height);
    [frameSpr setScaleX:640 / img.size.width];
    [frameSpr setScaleY:960 / img.size.height];
    [img release];
    
    //[frameSpr setScale:scale];
    [frameSpr setPosition:ccp(winSize.width/2,winSize.height/2)];
    [self addChild:frameSpr z:50];
    [self saveCurrentView];
     */
}

-(void)removeFrame
{
    containsFrame = NO;
    self.frameName = @"";
    [self removeChildByTag:kFrameSpriteTag cleanup:YES];
}



#pragma mark - Special Sprite
-(void)createPECCSpriteWithImage:(NSString *)inImageName atPos:(CGPoint)sprPos
{
    //Check any spr is not finalised
    [self addSpecialSprToTarget];
    
    specialSpriteTag ++;
    
    PECCSprite *testSpr = [PECCSprite spriteWithFile:inImageName];
    [testSpr setPosition:sprPos];
    testSpr.scale = 0.8;
    testSpr.tag = specialSpriteTag;
    [self addChild:testSpr];
    
    self.isSpecialSprFinalised = NO;
    
    [testSpr setUPWithLayer:self];
}

-(void)createPECCSpriteWithUIImage:(NSString *)inImagePath atPos:(CGPoint)sprPos
{
    //Check any spr is not finalised
    [self addSpecialSprToTarget];
    
    specialSpriteTag ++;
    
    UIImage *photoPathImage = [[UIImage alloc]initWithContentsOfFile:inImagePath];
    
    PECCSprite *testSpr = [PECCSprite spriteWithCGImage:[photoPathImage CGImage] key:nil];
    [photoPathImage release];
    
    [testSpr setPosition:sprPos];
    testSpr.tag = specialSpriteTag;
    [self addChild:testSpr];
    [testSpr setUPWithLayer:self];
    
    testSpr.scale = 0.8;
    [testSpr.rotateSpr setScale:1/testSpr.scale];
    [testSpr.scaleSpr setScale:1/testSpr.scale];
    
    
    self.isSpecialSprFinalised = NO;
}

-(void)addSpecialSprToTarget
{
    if(self.isSpecialSprFinalised == NO)
    {
        //Get the latest Spr added !
        PECCSprite *latestSprAdded = (PECCSprite *)[self getChildByTag:specialSpriteTag];
        [latestSprAdded removeControls];
        
        //Add to render to texture !
        [target begin];
        [latestSprAdded visit];
        [target end];
        
        [self removeChildByTag:specialSpriteTag cleanup:YES];
        
        self.isSpecialSprFinalised = YES;
        
        [self saveCurrentView];
    }
}


#pragma mark - Touches 

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    startPoint = touchPoint;
    
    inactiveTime = 1.0;
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint start = [touch locationInView: [touch view]];	
	start = [[CCDirector sharedDirector] convertToGL: start];
    
    CGPoint end = [touch previousLocationInView:[touch view]];
	end = [[CCDirector sharedDirector] convertToGL:end];
	
    if(self.isDrawing)
    {
        inactiveTime = 1.0;
        float angle = [self getAngleFromCurrentPoint:start toPoint:end];
        [brush setRotation:angle];
        // begin drawing to the render texture
        [target begin];
        
        float distance = ccpDistance(start, end);
        
        // for extra points, we'll draw this smoothly from the last position and vary the sprite's
        // scale/rotation/offset
        if(self.isSpecialBrush)
        {
            {
                float difx = (end.x - start.x);
                float dify = (end.y - start.y);
                float delta = (float)1 / distance;
                
                if(difx<0 && dify<0 ){
                    
                    CGPoint _point=ccp(start.x + (difx * delta), start.y + (dify * delta));
                    
                    if(!CGRectContainsPoint(CGRectMake(startPoint.x, startPoint.y,20,20), _point))
                    {
                        startPoint=_point;
                        [brush setPosition:ccp(start.x + (difx * delta), start.y + (dify * delta))];
                        [brush visit];
                    }
                }
                else if(difx<0 && dify>0 ){
                    
                    CGPoint _point=ccp(start.x - (difx * delta), start.y - (dify * delta));
                    if(!CGRectContainsPoint(CGRectMake(startPoint.x, startPoint.y-20,20,20), _point))
                    {
                        startPoint=_point;
                        [brush setPosition:ccp(start.x - (difx * delta), start.y - (dify * delta))];
                        [brush visit];
                    }
                }
                else if(difx>0 && dify>0 )
                {
                    CGPoint _point=ccp(start.x - (difx * delta), start.y - (dify * delta));
                    if(!CGRectContainsPoint(CGRectMake(startPoint.x-20, startPoint.y-20,20,20), _point))
                    {
                        startPoint=_point;
                        [brush setPosition:ccp(start.x - (difx * delta), start.y - (dify * delta))];
                        [brush visit];
                    }
                }
                else if(difx>0 && dify<0 )
                {
                    CGPoint _point=ccp(start.x - (difx * delta), start.y - (dify * delta));
                    if(!CGRectContainsPoint(CGRectMake(startPoint.x-20, startPoint.y,20,20), _point))
                    {
                        startPoint=_point;
                        [brush setPosition:ccp(start.x - (difx * delta), start.y - (dify * delta))];
                        [brush visit];
                    }
                }
            }
        }
        else
        {
            if (distance > 1)
            {
                int d = (int)distance;
                
                for (int i = 0; i < d; i++)
                {
                    float difx = end.x - start.x;
                    float dify = end.y - start.y;
                    float delta = (float)i / distance;
                    [brush setPosition:ccp(start.x + (difx * delta), start.y + (dify * delta))];
                    [brush visit];
                }
            }
        }
        // finish drawing and return context back to the screen
        [target end];	
    }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    
    if(self.isSpecialSprFinalised == NO)
    {
        [self addSpecialSprToTarget];
    }
    else if(self.addSpecialSpr == YES)
    {
        if(isSplSpriteImg)
        {
            [self createPECCSpriteWithUIImage:splSpriteName atPos:touchPoint];
            return;
        }
        else
        {
            [self createPECCSpriteWithImage:splSpriteName atPos:touchPoint];
            return;
        }
    }
    
    if(self.isDrawing)
    {
        isPendingToSave = YES;
    }
}


#pragma mark - Undo

-(void)deleteUndoFolder
{
    self.undoIndex = 0;
    maxUndoIndex = undoIndex;
    
    undoDocumentsPath = [PEUtlityFunc getDocumentsDirectoryPath];
    undoDocumentsPath = [[undoDocumentsPath stringByAppendingString:@"/UndoFolder"]retain];
    
    //Remove Undo Folder
    [[NSFileManager defaultManager] removeItemAtPath:undoDocumentsPath error:nil];
    
    //Create Undo Folder 
    [[NSFileManager defaultManager]createDirectoryAtPath:undoDocumentsPath withIntermediateDirectories:NO attributes:nil error:nil];
}

-(void)saveCurrentView
{
    undoIndex ++;
    maxUndoIndex = undoIndex;
    
    NSString *path = [NSString stringWithFormat:@"saveBuffer%d.png",undoIndex];
    NSString *writeToFilePath = [NSString stringWithFormat:@"%@",path];
	writeToFilePath = [undoDocumentsPath stringByAppendingPathComponent:writeToFilePath];
    
    [target saveBuffer:writeToFilePath format:kCCImageFormatPNG];
}

-(void)redo
{
    if (undoIndex >= maxUndoIndex) {
        return;
    }
    //Check any spr is not finalised
    [self addSpecialSprToTarget];
    [self addTextToTarget];

    
    //Go to Current state
    int tempUndoIndex = undoIndex;
    tempUndoIndex ++;
    
    NSLog(@"tempUndoIndex is %d",tempUndoIndex);
    
    //Get the current state image from saved buffer
    NSString *path = [NSString stringWithFormat:@"saveBuffer%d.png",tempUndoIndex];
    NSString *filePathToRetrive = [NSString stringWithFormat:@"%@",path];
    filePathToRetrive = [undoDocumentsPath stringByAppendingPathComponent:filePathToRetrive];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePathToRetrive])
    {
        //Clear the current target
        [target clear:0 g:0 b:0 a:0];
    
        //render it to view !
        UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:filePathToRetrive];
        
        CCSprite *undoSpr = [CCSprite spriteWithCGImage:[savedImage CGImage] key:nil];  
        [undoSpr setPosition:ccp(winSize.width/2,winSize.height/2)];
        
        [target begin];
        [undoSpr visit];
        [target end];
        
        undoIndex = tempUndoIndex;
    }
}

-(void)undo
{
    //Check any spr is not finalised
    [self addSpecialSprToTarget];
    [self addTextToTarget];

    //Go to Current state
    
    //Handle some errors
    if(undoIndex <= 0)
    {
        return;
    }
    
    undoIndex --;
    NSLog(@"undoIndex is %d", undoIndex);

    
    //Clear the current target
    [target clear:0 g:0 b:0 a:0];
    
    //Get the current state image from saved buffer
    NSString *path = [NSString stringWithFormat:@"saveBuffer%d.png",undoIndex];
    NSString *filePathToRetrive = [NSString stringWithFormat:@"%@",path];
    filePathToRetrive = [undoDocumentsPath stringByAppendingPathComponent:filePathToRetrive];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePathToRetrive])
    {
        //render it to view !
        UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:filePathToRetrive];
        
        CCSprite *undoSpr = [CCSprite spriteWithCGImage:[savedImage CGImage] key:nil];  
        [undoSpr setPosition:ccp(winSize.width/2,winSize.height/2)];
        
        [target begin];
        [undoSpr visit];
        [target end];
    }
}


#pragma mark - Utility
-(float) getAngleFromCurrentPoint:(CGPoint )inCurrentPoint toPoint:(CGPoint)inToPoint
{
    CGPoint difference = ccpSub(inToPoint,inCurrentPoint);
    double angle = -1 * (atan2(difference.y, difference.x) * 180 / M_PI + 90) + 180;
    return angle;
}

-(void)setRGBForSprite:(CCSprite *)inSpr WithRGBString:(NSString *)rgbStr
{
    //Set the Brush Image
    NSArray *rgbArr = [rgbStr componentsSeparatedByString:@","];
    float red,green,blue;
    
    red = [[rgbArr objectAtIndex:0]floatValue]*255;
    green = [[rgbArr objectAtIndex:1]floatValue]*255;
    blue = [[rgbArr objectAtIndex:2]floatValue]*255;
    
    NSLog(@"red %f %f %f",red,green,blue);
    [inSpr setColor:ccc3(red, green, blue)];
}

#pragma mark - RangeSelect
-(void)rangeAction
{
    [self addSpecialSprToTarget];
    [self addTextToTarget];
    
    self.addSpecialSpr = NO;
    self.isDrawing = NO;
    
    NSLog(@"rangeAction");
    
    isRangeAction = YES;
    
    PECCRangeSprite *_rangeRect = [PECCRangeSprite spriteWithFile:@"rangeFrame.png"];
    [_rangeRect setUPWithLayer:self];
    
    [_rangeRect setPosition:ccp(100,300)];
    [self addChild:_rangeRect];
}

-(void)rangeShowPreview
{
    // Get the preview Image
    
    PECCRangeSprite *rangeSpr = (PECCRangeSprite *) [self getChildByTag:kRangeSprTag];
    
    //Get the top Point
    CGPoint topPoint = ccp(rangeSpr.positionInPixels.x - rangeSpr.contentSize.width*rangeSpr.scaleX/2, rangeSpr.positionInPixels.y - rangeSpr.contentSizeInPixels.height*rangeSpr.scaleY/2);
    
    UIImage *rangePreviewImage = [self getRectImageWithRect:CGRectMake(topPoint.x, topPoint.y, rangeSpr.contentSizeInPixels.width*rangeSpr.scaleX, rangeSpr.contentSizeInPixels.height*rangeSpr.scaleY)];
    
    NSMutableDictionary *dictRangePreviewPicture = [[NSMutableDictionary alloc]init];
    [dictRangePreviewPicture setValue:rangePreviewImage forKey:@"rangePreviewImg"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setRangePreviewImage" object:self userInfo:dictRangePreviewPicture]; 
    [dictRangePreviewPicture release];
}

-(void)rangeInitialCancel
{
    
}

//Remove Range Rect !
-(void)rangeCancel
{
    PECCRangeSprite *rangeSpr = (PECCRangeSprite *) [self getChildByTag:kRangeSprTag];
    [self removeChild:rangeSpr cleanup:YES];
    
    isRangeAction = NO;
}

-(void)getTheRangeRect
{
    PECCRangeSprite *rangeSpr = (PECCRangeSprite *) [self getChildByTag:kRangeSprTag];
    
    //Create or Check for Range Folder
    NSString *documentsDir = [PEUtlityFunc getDocumentsDirectoryPath];
    
    NSString *peRangeDir = [documentsDir stringByAppendingPathComponent:@"PEPhotos"];
    
    //If dir is nt thr create it !
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:peRangeDir])
        [[NSFileManager defaultManager] createDirectoryAtPath:peRangeDir withIntermediateDirectories:NO attributes:nil error:&error ]; 
    
    
    peRangeDir = [NSString stringWithFormat:@"%@/%@.png",peRangeDir,[[NSDate date]description]];
    
    //Get the top Point
    CGPoint topPoint = ccp(rangeSpr.positionInPixels.x - rangeSpr.contentSizeInPixels.width*rangeSpr.scaleX/2, rangeSpr.positionInPixels.y - rangeSpr.contentSizeInPixels.height*rangeSpr.scaleY/2);
    [rangeSpr removeControls];
    
    [self saveBuffer:peRangeDir withRect:CGRectMake(topPoint.x, topPoint.y, rangeSpr.contentSizeInPixels.width*rangeSpr.scaleX, rangeSpr.contentSizeInPixels.height*rangeSpr.scaleY)];
    
    [self removeChild:rangeSpr cleanup:YES];
    
    isRangeAction = NO;
}



#pragma mark - Rect Snap Shot
-(BOOL)saveBuffer:(NSString*)fileName withRect:(CGRect)snapShotRect
{
    NSString *fullPath = [CCFileUtils fullPathFromRelativePath:fileName];
	
	NSData *data = [self getUIImageAsDataFromBuffer:kCCImageFormatPNG withRect:snapShotRect];
	
	return [data writeToFile:fullPath atomically:YES];
}

-(UIImage *)getRectImageWithRect:(CGRect)snapShotRect
{
    NSData *data = [self getUIImageAsDataFromBuffer:kCCImageFormatPNG withRect:snapShotRect];
    UIImage *rangeImage = [[UIImage alloc] initWithData:data];
    [rangeImage autorelease];
    
    return rangeImage;
}

-(NSData*)getUIImageAsDataFromBuffer:(int) format withRect:(CGRect )scrRect
{	
	CGSize s = scrRect.size;
	int tx = s.width;
	int ty = s.height;
	
	int bitsPerComponent=8;			
	int bitsPerPixel=32;				
	
	int bytesPerRow					= (bitsPerPixel/8) * tx;
	NSInteger myDataLength			= bytesPerRow * ty;
	
	GLubyte *buffer	= malloc(sizeof(GLubyte)*myDataLength);
	GLubyte *pixels	= malloc(sizeof(GLubyte)*myDataLength);
	
	if( ! (buffer && pixels) ) {
		CCLOG(@"cocos2d: CCRenderTexture#getUIImageFromBuffer: not enough memory");
		free(buffer);
		free(pixels);
		return nil;
	}
	
	[target begin];
	glReadPixels(scrRect.origin.x,scrRect.origin.y,tx,ty,GL_RGBA,GL_UNSIGNED_BYTE, buffer);
	[target end];
	
	int x,y;
	
	for(y = 0; y <ty; y++) {
		for(x = 0; x <tx * 4; x++) {
			pixels[((ty - 1 - y) * tx * 4 + x)] = buffer[(y * 4 * tx + x)];
		}
	}
	
	NSData* data;
	
	if (format == kCCImageFormatRawData)
	{
		free(buffer);
		//data frees buffer when it is deallocated
		data = [NSData dataWithBytesNoCopy:pixels length:myDataLength];
		
	} else {
		
		/*
		 CGImageCreate(size_t width, size_t height,
		 size_t bitsPerComponent, size_t bitsPerPixel, size_t bytesPerRow,
		 CGColorSpaceRef space, CGBitmapInfo bitmapInfo, CGDataProviderRef provider,
		 const CGFloat decode[], bool shouldInterpolate,
		 CGColorRenderingIntent intent)
		 */
		// make data provider with data.
		CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault;
		CGDataProviderRef provider		= CGDataProviderCreateWithData(NULL, pixels, myDataLength, NULL);
		CGColorSpaceRef colorSpaceRef	= CGColorSpaceCreateDeviceRGB();
		CGImageRef iref					= CGImageCreate(tx, ty,
														bitsPerComponent, bitsPerPixel, bytesPerRow,
														colorSpaceRef, bitmapInfo, provider,
														NULL, false,
														kCGRenderingIntentDefault);
		
		UIImage* image					= [[UIImage alloc] initWithCGImage:iref];
		
		CGImageRelease(iref);	
		CGColorSpaceRelease(colorSpaceRef);
		CGDataProviderRelease(provider);
        
		if (format == kCCImageFormatPNG)
			data = UIImagePNGRepresentation(image);
		else
			data = UIImageJPEGRepresentation(image, 1.0f);
		
		[image release];
		
		free(pixels);
		free(buffer);
	}
	
	return data;
}

#pragma mark - New
-(void)createNewDrawing
{
    [self clearCurrentDrawing];
}

#pragma mark - Open
-(void)openDrawingAtPath:(NSString *)inDrawingPath
{
    [self clearCurrentDrawing];
    
    NSString *frontImageName = [inDrawingPath stringByAppendingPathComponent:@"frontImage.png"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:frontImageName])
    {
        //render it to view !
        UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:frontImageName];
        
        CCSprite *undoSpr = [CCSprite spriteWithCGImage:[savedImage CGImage] key:nil];
        [undoSpr setPosition:ccp(winSize.width/2,winSize.height/2)];
        
        [target begin];
        [undoSpr visit];
        [target end];
        
        [savedImage release];
    }
    
    NSString *frameImagePath = [inDrawingPath stringByAppendingPathComponent:@"frameImage.png"];
    if([[NSFileManager defaultManager] fileExistsAtPath:frameImagePath])
    {
        //render it to view !
        UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:frontImageName];
        [self createFrameWithUIImagePath:frameImagePath];
        [savedImage release];
    }
}

#pragma mark - Clear
-(void)clearCurrentDrawing
{
    //Check any spr is not finalised
    [self addSpecialSprToTarget];   
    
    //Clear the draw view
    [target clear:0 g:0 b:0 a:0];
    
    //Remove the frame if available 
    [self removeFrame];
    
    //Remove Range If Available
    PECCRangeSprite *rangeSpr = (PECCRangeSprite *) [self getChildByTag:kRangeSprTag];
    [self removeChild:rangeSpr cleanup:YES];
    
    //Delete Undo Folder
    [self deleteUndoFolder];
}

#pragma mark - Saving 
-(void)saveCurrentDrawingAtPath:(NSString *)inDrawingPath
{
    NSString *frontImageName = [inDrawingPath stringByAppendingPathComponent:@"frontImage.png"];
    [target saveBuffer:frontImageName format:kCCImageFormatPNG];
    
    NSString *frameImageName = [inDrawingPath stringByAppendingPathComponent:@"frameImage.png"];
    if(containsFrame)
    {        
        //Get The path Dir
        NSString *imagePath = nil;
        if(isFramePathName)
        {
            imagePath = self.frameName;
        }
        else {
            imagePath = [PEUtlityFunc getBundlePathForFileName:self.frameName forType:@"png"];
        }
        
        UIImage *frameImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
        
        NSData *frameImageData = UIImagePNGRepresentation(frameImage);
        [frameImageData writeToFile:frameImageName atomically:YES];
        [frameImage release];
    }
}

- (UIImage *) getScreenShotFromGLview {
    
    
    int kValue=4;
    CGRect rect;
    
    BOOL hasHighResScreen = NO;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        CGFloat scale = [[UIScreen mainScreen] scale];
            if (scale > 1.0) {
              hasHighResScreen = YES;
          }
      }
      
      if(hasHighResScreen){
          rect= CGRectMake(0, 0, 640, 960);
          //kValue=4;
      }
      else{
          rect= CGRectMake(0, 0,320, 480);
          //kValue=4;
      }
    
    int width = rect.size.width;
    
    int height = rect.size.height;
    
    NSInteger myDataLength = width * height * kValue;
    
    GLubyte *buffer = (GLubyte *) malloc(myDataLength);
    
    __block GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
    
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    
    glClearColor(0, 0, 0, 0);
    
    for(int y = 0; y <height; y++) 
        
    { 
        
        for(int x = 0; x <width * kValue; x++)
            
        {
            
            int leftIndex = ((height - 1 - y) * width * kValue + x);
            
            int rightIndex = (y * kValue * width + x);
            
            buffer2[leftIndex] = buffer[rightIndex];
            
        }
        
    }
    
    free(buffer);
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL,buffer2,myDataLength,NULL);
    
    NSLog(@"sizeof(provider): %zd", malloc_size(provider));
    
    NSLog(@"sizeof(buffer2): %zd", malloc_size(buffer2));

    //free(buffer2);
    
    int bitsPerComponent = 8;
    
    int bitsPerPixel = 32;
    
    int bytesPerRow = kValue * width;
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    // Make the image as png transparent one 
    
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast;
    
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent,bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO,renderingIntent);
    
    NSLog(@"sizeof(imageRef): %zd", malloc_size(imageRef));

    
    CGColorSpaceRelease(colorSpaceRef);
    
    CGDataProviderRelease(provider);
    
    UIImage *mCurrentScreenshotImage = [UIImage imageWithCGImage:imageRef];
    
    NSLog(@"sizeof(mCurrentScreenshotImage): %zd", malloc_size(mCurrentScreenshotImage));
    
    CGImageRelease(imageRef);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
        free(buffer2);
    });
    
    return mCurrentScreenshotImage;
}


#pragma mark - TEXT

-(void)didStampTextSelected:(NSString *)inSelectedText fontName:(NSString*)inFontName fontColor:(UIColor*)inTextColor {
    
    //Add old text to target if available
    [self addTextToTarget];

    //Add any images to target if available
    [self addSpecialSprToTarget];

    
    NSLog(@"In PEEditViewController The selectedt text is %@ \n font name is %@ \n and color is %@",inSelectedText,inFontName,inTextColor);
        
    isTextAdded = YES;
    
    CGSize maxSize = { 200, 200 };
	CGSize actualSize = [inSelectedText sizeWithFont:[UIFont fontWithName:inFontName size:20.0]
							 constrainedToSize:maxSize
								 lineBreakMode:UILineBreakModeWordWrap];
    
	CGSize containerSize = { actualSize.width, actualSize.height };

    
    //CCTexture2D *_texture=[[CCTexture2D alloc] initWithString:inSelectedText fontName:inFontName fontSize:20.0];  
    CCTexture2D *_texture = [[CCTexture2D alloc] initWithString:inSelectedText dimensions:containerSize alignment:UITextAlignmentCenter lineBreakMode:UILineBreakModeWordWrap fontName:inFontName fontSize:20.0];
    CGFloat components[3];
  
    [self getRGBComponents:components forColor:inTextColor];
    
    PECCSpriteText *_sprite=[PECCSpriteText spriteWithTexture:_texture];
    [_sprite setColor:ccc3(components[0]*255,components[1]*255, components[2]*255)];
    [_sprite setUPWithLayer:self];
    [self addChild:_sprite z:10];
    
    tempTextSprite = _sprite;
    
//    [_sprite setPosition:ccp(winSize.width/2,winSize.height/2)];
//
//    [target begin];
//    [_sprite setColor:ccc3(components[0]*255,components[1]*255, components[2]*255)];
//    [_sprite visit];
//    
//    [target end];
    [_texture release];
}

- (void)getRGBComponents:(CGFloat [3])components forColor:(UIColor *)color {
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    unsigned char resultingPixel[4];
    
    CGContextRef context = CGBitmapContextCreate(&resultingPixel,1,1,8,4,rgbColorSpace,kCGImageAlphaNoneSkipLast);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    
    for (int component = 0; component < 3; component++) {
        
        components[component] = resultingPixel[component] / 255.0f;
    }
}

-(void)textSize:(float)zoomSize {
    NSLog(@"textSize:(float)zoomSize %f",zoomSize);
    
    tempTextSprite.scale = zoomSize;
}

-(void)textZoomingFinished {
    NSLog(@"textZoomingFinished");
    
    [self addTextToTarget];
}

-(void)addTextToTarget
{
    //Add Temp Text to Scene
    if(isTextAdded)
    {
        [target begin];
        [tempTextSprite visit];
        [target end];
        
        [tempTextSprite removeAllChildrenWithCleanup:YES];
        [tempTextSprite removeFromParentAndCleanup:YES];
        
        isTextAdded = NO;
        
        [self saveCurrentView];

    }
}

#pragma mark - Dealloc

- (void)dealloc {
    
    NSLog(@"Dealloc in Cocos Layer");
    self._PEController = nil;
    self._PEDrawing = nil;
    self.frameName = nil;
    
    [brush release];
    //[brushEdge release];
    
    [undoDocumentsPath release];
    
    //Cocos Release
    [[CCTextureCache sharedTextureCache]removeUnusedTextures];
    [[CCTextureCache sharedTextureCache]removeAllTextures];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
    
    [super dealloc];
}
@end
