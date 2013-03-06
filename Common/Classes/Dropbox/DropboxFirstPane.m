//
//  DropboxFirstPane.m
//  ForIPad
//
//  Created by 川口主税 on 11/08/04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DropboxFirstPane.h"
#import "RootPane.h"
//#import <DropboxSDK.h>

#import "DBLoginController.h"
#import "DropboxPane.h"
#import "ShareExplanation.h"


@implementation DropboxFirstPane

@synthesize useDbButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// ボタンを初期化する
- (void)initializeButtons {
    [useDbButton setTitle:NSLocalizedString(@"useDb", nil) forState:UIControlStateNormal];
}

// Dropboxに正常にログインできた
- (void)loginControllerDidLogin:(DBLoginController *)controller {
	//NSLog(@"login");
	
	// 新しいビューでルートディレクトリを表示
	DropboxPane *dp = [[[DropboxPane alloc]initWithStyle:UITableViewStylePlain]autorelease];
    dp.dir = @"/";
    [[RootPane instance]pushPane:dp];
}

// Dropboxにログインをキャンセル
- (void)loginControllerDidCancel:(DBLoginController *)controller {
	NSLog(@"cancel");
}

// Dropbox画面を表示する
- (IBAction)showDropbox {
    // 一度ログインしたセッション情報が残っているならログイン画面はスルー
    if([[DBSession sharedSession]isLinked]) {
        [self loginControllerDidLogin:nil];
    } else {
        // Dropboxのログイン画面へ
        DBLoginController *dbcontroller;
        dbcontroller = [[DBLoginController new]autorelease];
        dbcontroller.delegate = self;
        [dbcontroller presentFromController:self];
    }
    [self initializeButtons];
}

-(void)showExplanation:(UIBarButtonItem*)sender {
    ShareExplanation* se = [[ShareExplanation alloc] init];
    [se setExplanationType:sender.tag];
    [[RootPane instance] pushPane:se];
    [se release];
}

- (void)dealloc
{
    self.useDbButton = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Dropboxのヘルプ画面への遷移ボタンを追加
    UIBarButtonItem* toHelpButton = [[UIBarButtonItem alloc]
                                     initWithTitle:NSLocalizedString(@"explanation", nil)
                                     style:UIBarButtonItemStyleDone
                                     target:self action:@selector(showExplanation:)];
    toHelpButton.tag = 1;
    toHelpButton.style = UIBarButtonItemStyleBordered;
    self.navigationItem.rightBarButtonItem = toHelpButton;
    
    [self initializeButtons];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.useDbButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ![RootPane isRotationLocked];
}

@end
