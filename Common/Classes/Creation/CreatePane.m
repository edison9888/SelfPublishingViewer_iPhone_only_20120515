//
//  CreatePane.m
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/25.
//  Copyright 2011 SAT. All rights reserved.
//

#import "CreatePane.h"
#import "common.h"
#import "ImagePickDialog.h"
#import "AlertDialog.h"
#import "FileUtil.h"
#import "RootPane.h"
#import "BookReaderPane.h"
#import "BookPageCellNib.h"
#import "BookPageCell.h"
#import "TrimPane.h"
#import "LoadingView.h"
#import "ImageUtil.h"
#import "BookFiles.h"
#import "Book.h"
#import "CustomToolBar.h"
#import "AppUtil.h"
#import "NSString_Util.h"
#import "FbGraph.h"
#import "PhotoCategory.h"

@implementation CreatePane
@synthesize book, imagePicker;
@synthesize tableView,cameraButton,albumButton,previewButton,facebookButton;


#pragma mark - CreatePaneとしての機能

// 削除
- (void)deleteFiles {
    [self.book removeAllPages];
}


// カメラを起動して画像を追加
- (IBAction)addImageByCamera:(UIBarButtonItem*)sender {
    if (self.imagePicker.visible) {
        [self.imagePicker dismiss];
        self.imagePicker = nil;
    } else {
        // フォトアルバムから選択する
        self.imagePicker = [ImagePickDialog showCameraPopover:^(UIImage* img) {
            [self.book addPage:img];
            [tableView reloadData];
        }
                                          fromBarButton:sender
                                                 inView:self.view];
    }   
}
// アルバムから画像を追加
- (IBAction)addImageFromAlbum:(UIBarButtonItem*)sender {
    if (self.imagePicker.visible) {
        [self.imagePicker dismiss];
        self.imagePicker = nil;
    } else {
        // フォトアルバムから選択する
        self.imagePicker = [ImagePickDialog showMultiselectPopover:^(UIImage* img) {
            [self.book addPage:img];
            [tableView reloadData];
        }
                                          fromBarButton:sender
                                                 inView:self.view];
    }
}

// Facebookから画像を追加
- (IBAction)addImageFromFacebookAC:(id)sender
{
    
    ForIphoneAppDelegate *appDeleg = [[UIApplication sharedApplication]delegate];
    if(!appDeleg.fbGraph)
    {
        // Change FBClient ID AS per your Application a/c
        appDeleg.fbGraph = [[FbGraph alloc] initWithFbClientID:@"108807705930015"];
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [appDeleg.fbGraph authenticateUserWithCallbackObject:self andSelector:@selector(callBackFB:) andExtendedPermissions:@"user_photos,user_videos,publish_stream,offline_access,user_checkins,friends_checkins,friends_photos,friends_likes"];
}

-(void)callBackFB:(id)sender
{
    NSLog(@"Success") ;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if(!objPhoto)
    {
        objPhoto = nil;
        [objPhoto release];
    } 
    objPhoto = [[[PhotoCategory alloc] initWithNibName:@"PhotoCategory" bundle:nil] autorelease];
   // [self.navigationController pushViewController:objPhoto animated:YES];
    [[RootPane instance] pushPane:objPhoto];
}

// プレビューする
- (IBAction)preview:(UIBarButtonItem*)sender {
    if ([book pageCount] > 0) {
        BookReaderPane* p = [[[BookReaderPane alloc]init]autorelease];
        [[RootPane instance]pushPane:p];
        p.previewing = YES;
        [p openBook:self.book];
        [p openPage:self.book.readingPage];
    }
}

// ファイル名を変更する場合の内部処理
- (void)renameFile:(NSString*)fileName {
    if ([fileName length] == 0) {
        // 空白入力
        [AlertDialog alert:res(@"confirm")
                   message:res(@"inputFileName")
                      onOK:nil];
    } else {
        NSString* path = [AppUtil docPath:[fileName add:@".zip"]];
        if ([FileUtil exists:path]) {
            // ファイルが存在する
            [AlertDialog alert:res(@"confirm")
                       message:res(@"sameFileName")
                          onOK:nil];
        } else {
            // ファイル名を変更して保存
            self.book.name = fileName;
            [book saveMeta];
            [AlertDialog alert:res(@"done")
                       message:res(@"renameCompleted")
                          onOK:nil];
        }
    }
}

// ファイル名を変更する
- (void)rename:(UIBarButtonItem*)sender {
    if ([self.book pageCount] > 0) {
        [AlertDialog prompt:NSLocalizedString(@"degitalbookRename", nil)
                    message:NSLocalizedString(@"inputFileName", nil)
                    initial:self.book.name
                       onOK:^(NSString* str) {
                           [self renameFile:str];
                       }
                    onCancel:nil];
    }
}

// 新規に電子書籍化する場合の内部処理
- (IBAction)saveNew:(NSString*)fileName initial:(NSString*)initial {
    if ([fileName length] == 0) {
        [AlertDialog prompt:NSLocalizedString(@"degitalbookMaking", nil)
                    message:NSLocalizedString(@"inputFileName", nil)
                    initial:initial
                       onOK:^(NSString* str) {
                           [self saveNew:str initial:str];
                       }
                   onCancel:nil];
    } else {
        NSString* path = [AppUtil docPath:[fileName add:@".zip"]];
        if ([FileUtil exists:path]) {
            [AlertDialog alert:NSLocalizedString(@"error", nil)
                       message:NSLocalizedString(@"sameFileName", nil)
                          onOK:^{
                              [self saveNew:@"" initial:fileName];
                          }];
        } else {
            // 保存する
            @try {
                LoadingView* lv = [LoadingView show:self.view];
                [self.book makeZipFile:path];
                [self.book deleteTmpdir];
                [lv dismiss];
                [[RootPane instance]popPane];
                [AlertDialog alert:NSLocalizedString(@"complete", nil)
                           message:NSLocalizedString(@"fileMade", nil)
                              onOK:nil];
            } @catch (NSException* ex) {
                [AlertDialog alert:NSLocalizedString(@"error", nil)
                           message:NSLocalizedString(@"failSaveFile", nil)
                              onOK:nil];
            }
        }
    }
}

// 電子書籍化する
- (IBAction)save:(UIBarButtonItem*)sender {
    if ([self.book pageCount] > 0) {
        if (self.book.name) {
            LoadingView* lv = [LoadingView show:nil];

            NSString* path = [AppUtil docPath:[book.name add:@".zip"]];
            
            [self.book makeZipFile:path];
            [self.book deleteTmpdir];
            Book* existing = [[BookFiles bookFiles]bookAtPath:path];
            [existing invalidate];
            [lv dismiss];
            [[RootPane instance]popPane];
            [AlertDialog alert:NSLocalizedString(@"complete", nil)
                       message:NSLocalizedString(@"fileMade", nil)
                          onOK:nil];
            
        } else {
            [self saveNew:@"" initial:@""];
        }
    }
}


#pragma mark - TrimPaneのイベント

// 補正完了で入れ替える
- (void)imageSaved:(UIImage *)img {
    [self.book changeImage:img atPage:trimmingImageIndex];
    [tableView reloadData];
}

// 画像補正画面
- (void)showTrimPane:(UIButton*)button {
    TrimPane* p = [[TrimPane alloc]init];
    [p setImage:[self.book getPageImage:button.tag]];
    p.delegate = self;
    trimmingImageIndex = button.tag;
    [[RootPane instance]pushPane:p];
    [p release];
}


#pragma mark - Object lifecycle

- (id)init {
    self = [super init];
    self.book = [[[NewBook alloc]init]autorelease];
    return self;
}


- (void)dealloc
{
    //NSLog(@"%s", __func__);
    self.tableView = nil;
    self.cameraButton = nil;
    self.albumButton = nil;
    self.previewButton = nil;
    self.book = nil;
    self.imagePicker = nil;
    self.facebookButton = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    //NSLog(@"%s", __func__);
    [BookFiles purge];
    [AlertDialog alert:res(@"warning") message:res(@"memoryAlert") onOK:nil];    
    
//    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem* saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"makeDegitalBook", @"makeDegitalBook")
                                   style:UIBarButtonItemStyleDone
                                   target:self action:@selector(save:)];
//    self.navigationItem.rightBarButtonItem = saveButton;
    if (self.book.name != nil) {
        UIBarButtonItem* renameButton = [[UIBarButtonItem alloc]
                                         initWithTitle:NSLocalizedString(@"renameDegitalBook", nil)
                                         style:UIBarButtonItemStyleDone
                                         target:self action:@selector(rename:)];
        renameButton.style = UIBarButtonItemStyleBordered;
        UIToolbar *toolbar = [[CustomToolBar alloc] initWithFrame:CGRectMake(0, 0, 200, 50)]; 
        toolbar.backgroundColor = [UIColor clearColor];
        toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        toolbar.items = [NSArray arrayWithObjects:renameButton, saveButton, nil];
        toolbar.barStyle = UIBarStyleBlackTranslucent;
        UIBarButtonItem *toolbarBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
        [toolbar release];
        
        [saveButton release];
        [renameButton release];
        
        self.navigationItem.rightBarButtonItem = toolbarBarButtonItem;
    }else{
        self.navigationItem.rightBarButtonItem = saveButton;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [languages objectAtIndex:0];

    NSLog(@"%@",currentLanguage);
    
    [cameraButton setTitle:NSLocalizedString(@"camera", nil) forState:UIControlStateNormal];
    [facebookButton setTitle:NSLocalizedString(@"addByFacebook", nil) forState:UIControlStateNormal];
    [previewButton setTitle:NSLocalizedString(@"priview", nil) forState:UIControlStateNormal];
    [albumButton setTitle:NSLocalizedString(@"album", nil) forState:UIControlStateNormal];
    
    [cameraButton setTitle:NSLocalizedString(@"camera", nil) forState:UIControlStateSelected];
    [facebookButton setTitle:NSLocalizedString(@"addByFacebook", nil) forState:UIControlStateSelected];
    [previewButton setTitle:NSLocalizedString(@"priview", nil) forState:UIControlStateSelected];
    [albumButton setTitle:NSLocalizedString(@"album", nil) forState:UIControlStateSelected];
    
//    if([currentLanguage isEqualToString:@"ja"])
//    {
//        [facebookButton setTitlePositionAdjustment:UIOffsetMake(0, 5) forBarMetrics:UIBarMetricsDefault];
//        [cameraButton setTitlePositionAdjustment:UIOffsetMake(0, 5) forBarMetrics:UIBarMetricsDefault];
//        [albumButton setTitlePositionAdjustment:UIOffsetMake(0, 5) forBarMetrics:UIBarMetricsDefault];
//        [previewButton setTitlePositionAdjustment:UIOffsetMake(0, 5) forBarMetrics:UIBarMetricsDefault];
//    }
    
//    facebookButton.title = NSLocalizedString(@"addByFacebook", nil);
//    cameraButton.title = NSLocalizedString(@"addByCamera", nil);
//    albumButton.title = NSLocalizedString(@"addByAlbum", nil);
//    previewButton.title = NSLocalizedString(@"preview", nil);
}

- (void)viewDidUnload
{
    //NSLog(@"%s", __func__);
    [super viewDidUnload];
    self.tableView = nil;
    self.cameraButton = nil;
    self.albumButton = nil;
    self.previewButton = nil;
    self.book = nil;
    self.imagePicker = nil;
    self.facebookButton = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [tableView setEditing:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ![RootPane isRotationLocked];
}

#pragma mark - Table view data source
// 行の高さ
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CM_ROW_HEIGHT;
}
// 行数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
// セクション数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.book pageCount];
}

// セルの内容
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"BookPageCell";
    
    BookPageCell* cell = (BookPageCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        BookPageCellNib* nib = [[BookPageCellNib alloc]init];
        cell = nib.cell;
        cell.button.hidden = NO;
        cell.pathLabel.hidden = YES;
        [cell.button addTarget:self action:@selector(showTrimPane:) forControlEvents:UIControlEventTouchUpInside];
        [nib release];
    }
    UIImage* img = [self.book getThumbnailImage:indexPath.row];
    cell.coverView.image = img;
    cell.mainLabel.text = @"";
    cell.pathLabel.text = @"";
    [cell.button setTitle:NSLocalizedString(@"imageCompensation", nil) forState:UIControlStateNormal];
    cell.button.tag = indexPath.row;
    return cell;
}

// 編集可能
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// 変更時イベント
- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 削除イベント
        [AlertDialog confirm:NSLocalizedString(@"confirm", nil)
                   message:NSLocalizedString(@"confirmDelete", nil)
                   onOK:^() {
                       [self.book removePageAt:indexPath.row];
                       [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                       [tableView reloadData];
                   }];        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // 挿入イベント？
    }  
}

// 並べ替え
- (void)tableView:(UITableView *)tv moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    [self.book movePage:fromIndexPath.row to:toIndexPath.row];
    [tableView reloadData];
}

// 
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - Table view delegate
// 選択イベント
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
