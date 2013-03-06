//
//  AppUtil.m
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/22.
//  Copyright 2011 SAT. All rights reserved.
//
#import "AppUtil.h"

#import "UIDevice+Genetics.h"
//  #import "ForIphoneAppDelegate.h"
#import "NSString_Util.h"
#import "FileUtil.h"


@implementation AppUtil


// 一番上にあるControllerを返す
+(UIViewController*)rootViewController {
    UIApplication* app = [UIApplication sharedApplication];
	UIWindow* window = app.keyWindow;
    return window.rootViewController;
//	UINavigationController* navi = (UINavigationController*) window.rootViewController;
//    return navi.topViewController;
}

+(UIWindow*)window {
    return [UIApplication sharedApplication].keyWindow;
}


+ (BOOL) isPortrait {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait
        || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return YES;
    } else {
        return NO;
    }
}

// iPad向けかどうかを返す
+(BOOL)isForIpad {
    NSString* model = [[UIDevice currentDevice]model];
    return [model hasPrefix:@"iPad"];
}



// 位置ずれを治す
+(void)setOrigin {
    UIViewController* rp = [self rootViewController];
    CGRect r = rp.view.frame;
    //r.size = CGSizeMake(r.origin.x + r.size.width, r.origin.y + r.size.height);
    r.origin = CGPointMake(0, 0);
    rp.view.frame = r;
}
// リソースのパスを返す
+(NSString*)resPath:(NSString*)subPath {
    return [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:subPath];
}
// ドキュメントディレクトリのパスを返す
+(NSString*)docPath:(NSString*)subPath {
    return [[NSHomeDirectory() 
             stringByAppendingPathComponent:@"Documents"]
            stringByAppendingPathComponent:subPath];
}

// Documents Path
+(NSString*)documentsPath
{    
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
}


+(NSString*)libraryPath
{    
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
}

+(NSString*)extractionPath
{    
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
}


+(NSString*)bookRootDir
{    
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/Books"];
}

+(NSString*)bookExportDir
{    
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/Exports"];
}





// キャッシュディレクトリのパスを返す
+(NSString*)cachePath:(NSString*)subPath {
    return [[NSHomeDirectory()
             stringByAppendingPathComponent:@"Library/Caches"]
            stringByAppendingPathComponent:subPath];
    
}
// テンポラリディレクトリのパスを返す
+(NSString*)tmpPath:(NSString*)subPath {
    return [[NSHomeDirectory()
             stringByAppendingPathComponent:@"tmp"]
            stringByAppendingPathComponent:subPath];
}



+ (void) updateSIDStatus 
{
    if ([self sidHasMigrated]) {
        return;
    } else {
        NSString *dir = [self libraryPath];
        NSDirectoryEnumerator *de = [[NSFileManager defaultManager] enumeratorAtPath:dir];
        
        NSString *file;
        while ((file = [de nextObject])) {
            if ([file contains:[self iokitid]]) {
                NSString *dst = [file stringByReplacingOccurrencesOfString:[self iokitid] withString:[self sid]];
                NSString *source = [[self libraryPath] stringByAppendingPathComponent:file];
                NSString *destination = [[self libraryPath] stringByAppendingPathComponent:dst];
                [FileUtil mv:source  toPath:destination];
                
            }
            
            if ([file contains:@".plist"]) {
                
                NSString *path = [[self libraryPath] stringByAppendingPathComponent:file];
                NSMutableDictionary *plist = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
                for (NSString *IOKitKey in plist) {
                    if ([IOKitKey contains:[self iokitid]] ) {

                        NSNumber *oldValue = [plist objectForKey:IOKitKey];
                        NSString *sidKey = [IOKitKey stringByReplacingOccurrencesOfString:[self iokitid] withString:[self sid]];
                        //NSLog(@"IOKIT udid FOUND !!! will replace %@ with %@", IOKitKey, sidKey);

                        [plist setValue:oldValue forKey:sidKey];
                        [plist removeObjectForKey:IOKitKey];
                        
                    }
                }
                [plist writeToFile:path atomically:YES];
                [plist release];
                
            }
        }
        NSUserDefaults *ud = [self config];
        [ud setValue:[NSNumber numberWithBool:YES] forKey:@"sidDidMigrate"];
       

        [ud synchronize];
        
    }
}

+ (void) removeCacheGarbage
{
    NSString *dir = [self libraryPath];
    NSDirectoryEnumerator *de = [[NSFileManager defaultManager] enumeratorAtPath:dir];
    
    NSString *file;
    while ((file = [de nextObject])) {
        if ([file contains:@"DS_Store"] || [file contains:@"Thumb.db"]) {
            //NSLog(@"Found Garbage %@ so I will remove it", file);
            NSString *garbage = [[self libraryPath] stringByAppendingPathComponent:file];
            [FileUtil rm:garbage];
        }
    }
}

+(BOOL)isIOSFive;
{
    NSString *sysVersion = [[UIDevice currentDevice] systemVersion];
    //NSLog(@"iosVersion : %@", sysVersion);
    
    double ver = [sysVersion doubleValue];
    
    if (ver >= 5.0) {
        return TRUE;
    }
    return FALSE;
}

+(NSString*)udid 
{
    if ([self sidHasMigrated]) {
        return [self sid];
    }
    return [self iokitid];
}

+(NSString*)iokitid; 
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *iokit = [ud objectForKey:@"IOKitUniqueIdentifier"];
    if (iokit) {
        return iokit;
        
    }
    [ud setValue:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"IOKitUniqueIdentifier"];
    [ud synchronize];
    return [[UIDevice currentDevice] uniqueIdentifier];
}

// Since depreciated udid will be replaced with a custom sha1(wifi)

+(NSString*)sid 
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *smartebook = [ud objectForKey:@"SmartebookUniqueIdentifier"];
    if (smartebook) {
        
        return smartebook;
    }
    [ud setValue:[[UIDevice currentDevice] deviceIdentifier] forKey:@"SmartebookUniqueIdentifier"];
    [ud synchronize];
    return [[UIDevice currentDevice] deviceIdentifier];
}

+(BOOL)sidHasMigrated
{
    NSUserDefaults *ud = [self config];
    NSNumber *migrationStatus = [ud objectForKey:@"sidDidMigrate"];
    if (migrationStatus) {
        return  [migrationStatus boolValue]; ;

    }

    return FALSE;
}


+(void)stampInit 
{
    NSString *destPath = [NSHomeDirectory()stringByAppendingPathComponent:@"Library/Caches/stamps"];    
    NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Samples/stamps"];
    
    if (![FileUtil exists:destPath]) {
        [FileUtil mkdir:destPath];
    }
    NSString *imageFilter = @"self ENDSWITH '.png' OR self ENDSWITH '.PNG'";
    
    
    NSPredicate *imageFilterPredicate = [NSPredicate predicateWithFormat:imageFilter];
    NSArray *stampDir = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourcePath error:nil];
    
    
    NSArray *stampImages = [stampDir filteredArrayUsingPredicate:imageFilterPredicate];
    
    NSError *error = nil;
    NSFileManager *mgm = [NSFileManager defaultManager];
    

    for (NSString *stampFileName in stampImages) {

        NSString *destFileName = [destPath stringByAppendingPathComponent:stampFileName];
        NSString *sourceFileName = [sourcePath stringByAppendingPathComponent:stampFileName];

        if (![FileUtil exists:destFileName]) {
            [mgm copyItemAtPath:sourceFileName toPath:destFileName error:&error];
            /*
            if([mgm copyItemAtPath:sourceFileName toPath:destFileName error:&error]){
                //NSLog(@"Stamp file successfully copied over.");
            } else {
                //NSLog(@"Error description-%@", [error localizedDescription]);
               // NSLog(@"Error reason-%@", [error localizedFailureReason]);
            }
             */
        }
    }
}



// 設定値を返す
+(NSUserDefaults*)config {
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* def = [NSMutableDictionary dictionary];
    [def setObject:[NSNumber numberWithBool:YES] forKey:@"rotation"];
    [def setObject:[NSNumber numberWithBool:YES] forKey:@"shelfFilename"];
    [ud registerDefaults:def];
    return ud;
}


@end
