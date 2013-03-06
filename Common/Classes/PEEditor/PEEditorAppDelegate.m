//
//  PEEditorAppDelegate.m
//  PEEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import "PEEditorAppDelegate.h"

#import "PEEditorViewController.h"

@implementation PEEditorAppDelegate


@synthesize window=_window;
@synthesize addTextViewController;
@synthesize viewController=_viewController;
@synthesize navController;
@synthesize editorViewController;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    PEEditorViewController *_editorController = [[PEEditorViewController alloc] initWithNibName:@"PEEditorViewController" bundle:nil];
    self.editorViewController=_editorController;
    [_editorController release];
    UINavigationController *_navController = [[UINavigationController alloc] initWithRootViewController:self.editorViewController];
    self.navController=_navController;
    [_navController release];
    _navController=nil;
    //self.window.rootViewController = self.viewController;
    [self.window addSubview:self.navController.view];
    [self.window makeKeyAndVisible];
    
    //Current Device resulation
  //  NSLog(@"Current device =%f",[[UIScreen mainScreen] scale]);
    // Get all the fonts on the system
	NSArray *familyNames = [UIFont familyNames];
	for( NSString *familyName in familyNames ){
		printf( "Family: %s \n", [familyName UTF8String] );
		NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
		for( NSString *fontName in fontNames ){
			printf( "\tFont: %s \n", [fontName UTF8String] );
		}
	}
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
