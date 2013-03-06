//
//  RootPane.m
//  LiverliveRecipe
//
//  Created by 藤田正訓 on 11/06/21.
//  Copyright 2011 SAT. All rights reserved.
//

#import "RootPane.h"
#import "FileListPane.h"
#import "PrefPane.h"
#import "BookmarkPane.h"
#import "BookReaderPane.h"
#import "AppUtil.h"
#import "WritingPane.h"
#import "common.h"
#import "UIView_Effects.h"
#import "DropboxSDK.h"
#import "LibraryPane.h"
#import "AlertDialog.h"
#import "NSString_Util.h"
#import "AttachmentPane.h"
#import "PEEditorViewController.h"

@interface RootPane()
@property(nonatomic,retain)FileListPane* fileListPane;
@end

@implementation RootPane
@synthesize navi, navigationLock;
@synthesize fileListPane;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

// RootPaneインスタンスを返す
+(RootPane*)instance {
	UIApplication* app = [UIApplication sharedApplication];
	UIWindow* window = [app.windows objectAtIndex:0];
    UINavigationController* navi = (UINavigationController*)window.rootViewController;
    return (RootPane*)[navi.viewControllers objectAtIndex:0];
}
// 現在トップかどうかを返す
-(BOOL)isTop:(UIViewController*)pane {
    return pane == navi.topViewController;
}

/**
 * ナビゲーション直前のイベント
 */
-(void)navigationController:(UINavigationController *)navigationController 
	 willShowViewController:(UIViewController *)vc
				   animated:(BOOL)animated {
    
	Class vcc = [vc class];
	vc.navigationItem.title = vc.title;
    if (vcc == [BookReaderPane class]
        || vcc == [WritingPane class]
        || vcc == [PEEditorViewController class]
        || vcc == [PEStampViewController class]
        || vcc == [OtherEffectsPane class]
        || vcc == [MosaicViewController class]){
        [UIApplication sharedApplication].statusBarHidden = YES;
        navi.navigationBarHidden = YES;
	} else if (vcc == [RootPane class]
               || vcc == [FileListPane class]
               || vcc == [LibraryPane class]) {
        [UIApplication sharedApplication].statusBarHidden = NO;
		navi.navigationBarHidden = YES;
	} else if (vcc == [SettingPane class]){
        [UIApplication sharedApplication].statusBarHidden = YES;
        navi.navigationBarHidden = NO;
    } else {
        [UIApplication sharedApplication].statusBarHidden = NO;
        navi.navigationBarHidden = NO;
    }
}


/**
 * ナビゲーション完了のイベント
 */
-(void)navigationController:(UINavigationController *)navigationController 
	  didShowViewController:(UIViewController *)vc
				   animated:(BOOL)animated	{
    navigationLock = NO;
}


// ブックマーク画面を表示する
-(void)showBookmarkPane {
    BookmarkPane* p = [[[BookmarkPane alloc]init]autorelease];
    [self pushPane:p];
}

/**
 * 設定画面へ
 */
-(void)showConfigPane {
    PrefPane* p = [[[PrefPane alloc]init]autorelease];
    [self pushPane:p];
}

/**
 * トップ画面へ
 */
-(void)showListPane {
	[navi popToRootViewControllerAnimated:NO];
}
// アニメーションでトップ画面へ
-(void)rewindToListPane {
    [navi popToRootViewControllerAnimated:YES];
}
/**
 * 次の画面へ進む
 */
-(void)pushPane:(UIViewController *)nextPane {
    if (!navigationLock) {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
        navigationLock = YES;
        [navi pushViewController:nextPane animated:YES];
        self.navi.navigationBar.backItem.title = NSLocalizedString(@"back", nil);
        [pool release];
    }
}

// 前の画面に戻る
-(void)popPane {
    if (!navigationLock) {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
        navigationLock = YES;
        [navi popViewControllerAnimated:YES];
        [pool release];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return !_rotationLock;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

+ (BOOL) isPortrait {
    return [AppUtil isPortrait];
}

// iPad向けかどうかを返す
+(BOOL)isForIpad {
    NSString* model = [[UIDevice currentDevice]model];
    return [model hasPrefix:@"iPad"];
}

-(BOOL)rotationLock {
    return _rotationLock;
}

-(void)setRotationLock:(BOOL)b {
    _rotationLock = b;
    NSUserDefaults* ud = [AppUtil config];
    [ud setBool:!b forKey:@"rotation"];
    [ud synchronize];
}


- (void)viewWillAppear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarHidden = NO;
    navi.navigationBarHidden = YES;
    [super viewWillAppear:animated];
    [self.view eFittoSuperview];
    [fileListPane viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [fileListPane viewDidAppear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    navi = nil;
}

-(id)init {
    self = [super init];
    if (self) {
        // 設定値を復元
        NSUserDefaults* ud = [AppUtil config];
        _rotationLock = ![ud boolForKey:@"rotation"];
        
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}

+ (BOOL)isRotationLocked {
    RootPane* rp = [self instance];
    return rp.rotationLock;
}

-(void)didRotate:(NSNotification *)notification {
    UIViewController* vc = navi.topViewController;
    if ([vc class] == [AttachmentPane class]) {
        [((AttachmentPane*)vc)didRotate:notification];
    }
}


// View初期化
- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    UIApplication* app = [UIApplication sharedApplication];
	UIWindow* window = app.keyWindow;
    navi = (UINavigationController*)window.rootViewController;
    navi.delegate = self;
    self.fileListPane = [[[FileListPane alloc]init]autorelease];
    [self.view addSubview:fileListPane.view];
    
    // consumerkeyとconsumersecretはアプリ固有。DropboxのDeveropersサイトから取得する
    DBSession *dbsession = [[[DBSession alloc]initWithConsumerKey:@"btebsywqdsc62da" consumerSecret:@"z9o6xywgrayk81e"]autorelease];
    [DBSession setSharedSession:dbsession];
    
    [[NSNotificationCenter defaultCenter] 
     addObserver:self
     selector:@selector(didRotate:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
    
    
}



@end
