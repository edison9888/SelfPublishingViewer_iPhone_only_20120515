//
//  AppUtil.h
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/22.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AppUtil : UIView {

}


// 一番上にあるControllerを返す
+(UIViewController*)rootViewController;
// Windowを返す
+(UIWindow*)window;

// 向きを返す
+(BOOL)isPortrait;
// iPad向けかどうかを返す
+(BOOL)isForIpad;

// 位置ずれを治す
+(void)setOrigin;
// リソースのパスを返す
+(NSString*)resPath:(NSString*)subPath;
// ドキュメントディレクトリのパスを返す
+(NSString*)docPath:(NSString*)subPath;
// キャッシュディレクトリのパスを返す
+(NSString*)cachePath:(NSString*)subPath;
// テンポラリディレクトリのパスを返す
+(NSString*)tmpPath:(NSString*)subPath;

+(BOOL)isIOSFive;
+(void)stampInit;
// UDIDを返す
+(NSString*)udid;
+(NSString*)sid;
+(NSString*)iokitid;

// 設定値を返す
/* Transition to WiFi MAC address SHA1 */
+(NSString*)sid;

+(NSUserDefaults*)config;

+(NSString *)documentsPath;
+(NSString *)libraryPath;

+(NSString *)extractionPath;
+(NSString *)bookRootDir;
+(NSString *)bookExportDir;

+ (void) updateSIDStatus ;
+ (void) removeCacheGarbage;

+(BOOL) sidHasMigrated;


@end
