
//
//  PECocosLayer.h
//  PhotoEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.

#import <Foundation/Foundation.h>
#import "cocos2d.h"

//Drawing
#import "PEController.h"
#import "PEDrawing.h"
#import "PEUtility.h"

@class PEStandard;


@interface PECocosLayer : CCLayer
{
    //Self Size
    CGSize winSize;
    
    //Render to texture 
    CCRenderTexture* target;
    CGPoint startPoint;
    
    //Brushes
	CCSprite* brush;
    CCSprite* brushEdge;
    
    //Current Drawing Obj
    PEController * _PEController;
    PEDrawing * _PEDrawing;
    
    //Draw Bools
    BOOL isDrawing;
    BOOL isSpecialBrush;
    BOOL addSpecialSpr;
    BOOL isSpecialSprFinalised;
    BOOL isSplSpriteImg;
    BOOL isEdgeBrush;
    
    //Special Sprite
    int specialSpriteTag;
    int selectedSpriteTag;
    
    NSString *splSpriteName;
    
    //Undo
    int undoIndex;
    
    //Saving
    NSString *undoDocumentsPath;
    
    //Range
    BOOL isRangeAction;
    
    //Frame 
    BOOL containsFrame;
    BOOL isFramePathName;
    NSString *frameName;
    
    //Text
    BOOL isTextAdded;
    CCSprite *tempTextSprite;
    
    float inactiveTime;
    BOOL isPendingToSave;
}
//Func !!!
// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

//Current Drawing OBj
@property (nonatomic,retain)PEController * _PEController;
@property (nonatomic,retain)PEDrawing * _PEDrawing;


//Draw variables
@property (nonatomic,assign)BOOL isDrawing;

@property (nonatomic,assign)int selectedSpriteTag;

@property (nonatomic,assign)BOOL isSpecialBrush;
@property (nonatomic,assign)BOOL addSpecialSpr;
@property (nonatomic,assign)BOOL isSpecialSprFinalised;

//Undo
@property (nonatomic,assign)int undoIndex;
@property (nonatomic,assign)int maxUndoIndex;

//Frame
@property (nonatomic,retain)NSString *frameName;

//Create Brush
-(void)createDefaultBrush;
-(void)createBrushEdge;
-(void)creatBrushSprWithImage:(NSString *)brushImageName;

//------
-(void)didDrawValuesChangedWith:(PEStandard *)inStandardModel;
-(void)didDrawingSelected:(PEDrawing *)inDrawingController;
-(void)didControllerSelected:(PEController *)inColorController;

//Utility
-(float)getAngleFromCurrentPoint:(CGPoint )inCurrentPoint toPoint:(CGPoint)inToPoint;
-(void)setRGBForSprite:(CCSprite *)inSpr WithRGBString:(NSString *)rgbStr;

//Create Frame
-(void)createFrameWithImage:(NSString *)inImageName;
-(void)createFrameWithUIImagePath:(NSString *)framePath;
-(void)setImage:(UIImage *)img;
-(void)removeFrame;

//Special Sprite
-(void)createPECCSpriteWithImage:(NSString *)inImageName atPos:(CGPoint)sprPos;
-(void)createPECCSpriteWithUIImage:(NSString *)inImageName atPos:(CGPoint)sprPos;
-(void)addSpecialSprToTarget;

//Erase
-(void)setEraseMode:(BOOL)inMode;

//Undo
-(void)deleteUndoFolder;
-(void)saveCurrentView;
-(void)undo;
-(void)redo;

//Rect Snap Shot
-(BOOL)saveBuffer:(NSString*)fileName withRect:(CGRect)snapShotRect;
-(NSData*)getUIImageAsDataFromBuffer:(int) format withRect:(CGRect )scrRect;
-(UIImage *)getRectImageWithRect:(CGRect)snapShotRect;

//RangeSelect
-(void)rangeAction;
-(void)rangeShowPreview;
-(void)rangeInitialCancel;
-(void)rangeCancel;
-(void)getTheRangeRect;

//New
-(void)createNewDrawing;

//Open
-(void)openDrawingAtPath:(NSString *)inDrawingPath;

//Saving 
-(void)saveCurrentDrawingAtPath:(NSString *)inDrawingPath;
- (UIImage *) getScreenShotFromGLview ;

//Clear
-(void)clearCurrentDrawing;

#pragma mark - textZooming

-(void)didStampTextSelected:(NSString *)inSelectedText fontName:(NSString*)inFontName fontColor:(UIColor*)inTextColor;
-(void)getRGBComponents:(CGFloat [3])components forColor:(UIColor *)color;
-(void)textSize:(float)zoomSize;
-(void)textZoomingFinished;
-(void)addTextToTarget;

@end


