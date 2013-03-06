//
//  PECocosSceneCreator.m
//  PhotoEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import "PECocosUIView.h"
#import "cocos2d.h"
#import "RootViewController.h"
#import "PECocosLayer.h"

@implementation PECocosUIView

@synthesize cocosLayer;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
                
        // Try to use CADisplayLink director
        // if it fails (SDK < 3.1) use the default director
        if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
            [CCDirector setDirectorType:kCCDirectorTypeDefault];
        
        
        CCDirector *director = [CCDirector sharedDirector];
        
        // Init the View Controller
        viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
        viewController.wantsFullScreenLayout = YES;
        
        //
        // Create the EAGLView manually
        //  1. Create a RGB565 format. Alternative: RGBA8
        //	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
        //
        //
        
        EAGLView *glView = [EAGLView viewWithFrame:self.frame
                                       pixelFormat:kEAGLColorFormatRGBA8	// kEAGLColorFormatRGBA8
                                       depthFormat:0						// GL_DEPTH_COMPONENT16_OES
                            ];
        
        glView.opaque = NO;
        
        // attach the openglView to the director
        
        NSLog(@" Rect= %@",NSStringFromCGRect(glView.frame));
        [director setOpenGLView:glView];
        
        [glView setMultipleTouchEnabled:YES];
        
        //	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
        if( ! [director enableRetinaDisplay:YES] )
            CCLOG(@"Retina Display Not supported");
        
        
        //
        // VERY IMPORTANT:
        // If the rotation is going to be controlled by a UIViewController
        // then the device orientation should be "Portrait".
        //
        // IMPORTANT:
        // By default, this template only supports Landscape orientations.
        // Edit the RootViewController.m file to edit the supported orientations.
        //
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
        [director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
        [director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
        
        [director setAnimationInterval:1.0/60];
        [director setDisplayFPS:YES];
        
        
        // make the OpenGLView a child of the view controller
        [viewController setView:glView];
        
        // make the View Controller a child of the main window
        [self addSubview: viewController.view];
        
        // Default texture format for PNG/BMP/TIFF/JPEG/GIF images
        // It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
        // You can change anytime.
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        
        
        // Removes the startup flicker
        [self removeStartupFlicker];
        
        
        // Run the intro Scene
        // 'scene' is an autorelease object.
       // CCScene *scene = [CCScene node];
        
        // 'layer' is an autorelease object.
       // cocosLayer = [PECocosLayer node];
        
        // 'scene' is an autorelease object.
        CCScene *scene = [CCScene node];
        
        // 'layer' is an autorelease object.
        cocosLayer = [PECocosLayer node];
        
        // add layer as a child to scene
        [scene addChild: cocosLayer];

        [[CCDirector sharedDirector] runWithScene:scene];
    }
    return self;
}


#pragma mark -  Cocos 2d Default
- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	
	//	CC_ENABLE_DEFAULT_GL_STATES();
	//	CCDirector *director = [CCDirector sharedDirector];
	//	CGSize size = [director winSize];
	//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
	//	sprite.position = ccp(size.width/2, size.height/2);
	//	sprite.rotation = -90;
	//	[sprite visit];
	//	[[director openGLView] swapBuffers];
	//	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Dealloc

- (void)dealloc {
    
    NSLog(@"Dealloc in Cocos Scene Creator");
    [[CCDirector sharedDirector] end];

    [super dealloc];
}

@end
