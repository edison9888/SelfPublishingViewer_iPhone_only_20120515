//
//  ForIphoneAppDelegate.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/07/21.
//  Copyright 2011 SAT. All rights reserved.
//

#import "ForIphoneAppDelegate.h"
#import "RootPane.h"
#import "FileUtil.h"
#import "AlertDialog.h"
#import "BookFiles.h"
#import "FileListPane.h"
#import "BookReaderPane.h"
#import "Book.h"
#import "DownloadPane.h"
#import "AppUtil.h"
#import "Reachability.h"

@implementation ForIphoneAppDelegate


@synthesize window=_window;
@synthesize  onWiFi;
@synthesize  onCelular;
@synthesize fbGraph;
@synthesize checkFlag;

- (void) configureReachability:(Reachability*) curReach
{
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    BOOL connectionRequired= [curReach connectionRequired];
    NSString* statusString= @"";
    onWiFi = FALSE;
    onCelular = FALSE;
    switch (netStatus)
    {
        case NotReachable:
        {
            onWiFi = FALSE;
            onCelular = FALSE;

            connectionRequired= NO;  
            break;
        }
            
        case ReachableViaWWAN:
        {
            onCelular = TRUE;
            break;
        }
        case ReachableViaWiFi:
        {

            onWiFi = TRUE;
            break;
        }
    }
  
}

- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    if(curReach == hostReach)
	{
		[self configureReachability:curReach];
        NetworkStatus netStatus = [curReach currentReachabilityStatus];
        BOOL connectionRequired= [curReach connectionRequired];
        
        if(connectionRequired)
        {
            NSLog(@"Cellular available - routed through 3G upon established connection");
        }
        else
        {
            NSLog(@"Cellular active - routed through 3G");
        }
    }
	if(curReach == internetReach)
	{	
		[self configureReachability:curReach];
	}
	if(curReach == wifiReach)
	{	
		[self configureReachability:curReach];
	}
}

+ (BOOL) isRoutingViaWWan 
{
    return NO;
}

+ (BOOL) isRoutingViaWiFi 
{
    return NO;
}


//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateInterfaceWithReachability: curReach];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   
    [AppUtil updateSIDStatus];
    [AppUtil removeCacheGarbage];
    if (![FileUtil exists:[AppUtil bookRootDir]]) {
        [FileUtil mkdir:[AppUtil bookRootDir]];

    }
    if (![FileUtil exists:[AppUtil bookExportDir]]) {
        [FileUtil mkdir:[AppUtil bookExportDir]];
        
    }
    
    [AppUtil stampInit];
    
    
    // method "reachabilityChanged" will be called. 
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    //Change the host name here to change the server your monitoring
	hostReach = [[Reachability reachabilityWithHostName: @"www.google.com"] retain];
	[hostReach startNotifier];
	[self updateInterfaceWithReachability: hostReach];
	
    internetReach = [[Reachability reachabilityForInternetConnection] retain];
	[internetReach startNotifier];
	[self updateInterfaceWithReachability: internetReach];
    
    wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
	[wifiReach startNotifier];
	[self updateInterfaceWithReachability: wifiReach];


    RootPane* rp = [[RootPane alloc]init];
    UINavigationController* navi = [[UINavigationController alloc]initWithRootViewController:rp];
    navi.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.window.rootViewController = navi;
    [navi release];
    [rp release];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSString* path = [url path];
    if ([path hasSuffix:@".zip"] || [path hasSuffix:@".pdf"] || [path hasSuffix:@".jpg"] || [path hasSuffix:@".png"]) {
        NSString* fileName = [url lastPathComponent];
        NSString* newPath = [NSHomeDirectory() stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"Documents/%@", fileName]];
        if ([FileUtil exists:newPath]) {
            newPath = [FileUtil unexistingPath:path];
        }
        [FileUtil copy:path:newPath];
        [[BookFiles bookFiles] checkReload];
        RootPane* rp = [RootPane instance];
        [rp showListPane];
        Book* b = [[BookFiles bookFiles] bookAtPath:newPath];
        if ([b hasFolders]) {
            FileListPane* p = [[[FileListPane alloc]init]autorelease];
            p.book = b;
            [[RootPane instance]pushPane:p];
        } else {
            BookReaderPane* p = [[[BookReaderPane alloc]init]autorelease];
            [[RootPane instance]pushPane:p];
            [p openBook:b];
            [p openPage:b.readingPage];
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

- (void)applicationDidEnterBackground:(UIApplication *)application {
    RootPane* rp = [RootPane instance];
    NSArray* controllers = rp.navi.viewControllers;
    for (UIViewController* c in controllers) {
        if ([c isKindOfClass:[DownloadPane class]]) {
            DownloadPane* dp = ((DownloadPane*)c);
            [dp enterBackground];
        }
    }    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    RootPane* rp = [RootPane instance];
    NSArray* controllers = rp.navi.viewControllers;
    for (UIViewController* c in controllers) {
        if ([c isKindOfClass:[DownloadPane class]]) {
            DownloadPane* dp = ((DownloadPane*)c);
            [dp performSelector:@selector(enterForeground) withObject:nil afterDelay:0.5];
            //[dp enterForeground];
        }
    }    
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
    [super dealloc];
}

@end
