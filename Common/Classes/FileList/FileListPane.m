//
//  FileListPane.m
//  ファイルの一覧を表示する画面。
//  実際はこの上にShelfFileListまたはTableFileListが載る。
//

#import "FileListPane.h"
#import "TableFileListPane.h"
#import "ShelfFileListPane.h"
#import "BookFiles.h"
#import "BookReaderPane.h"
#import "RootPane.h"
#import "Book.h"
#import "BluetoothPane.h"
#import "CreatePane.h"
#import "ActionDialog.h"
#import "NewBook.h"
#import "HTTPDownloadPane.h"
#import "DropboxFirstPane.h"
#import "MusicViewController.h"
#import "AppUtil.h"
#import "LoadingView.h"
#import "UIView_Effects.h"
#import "DocumentViewerPane.h"
#import "ForIphoneAppDelegate.h"
#import "PhotoCategory.h"

@implementation FileListPane
@synthesize listView, selectingMode, book;
@synthesize listArea,listChanger,listChanger2,editButton,tabBar,mainToolBar,folderToolBar,selectToolBar,editFileSelectLabel,cancelButton;

// TabBarが選択されたイベント
-(void)tabBar:(UITabBar *)tb didSelectItem:(UITabBarItem *)item {
    [tabBar setSelectedItem:nil];
    if (listView.editMode) {
        [self toggleEdit];
    }
    switch (item.tag) {
        case 1:
            [self showMusicPlayer];
            break;
        case 2:
            [self showCreation];
            break;
        case 3:
            [self showDropbox];
            break;
        case 4:
            [self showShare];
            break;
        case 5:
            [self showConfig];
            break;
        case 6:
            [self showHTTPDownload];
    }
}

-(void)authenticationWithFBAccount
{
    ForIphoneAppDelegate *appDeleg = [[UIApplication sharedApplication]delegate];
    if(!appDeleg.fbGraph)
    {
        // Change FBClient ID AS per your Application a/c
        appDeleg.fbGraph = [[FbGraph alloc] initWithFbClientID:@"130902823636657"];
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


// ファイルを開く
- (void)open: (NSInteger) i {
    if (prepared) {
        prepared = NO;
        Book* b = nil;
        if (book) {
            b = [[book folders]objectAtIndex:i];
        } else {
            b = [[BookFiles bookFiles] bookAtIndex:i];
        }
        if (selectingMode) {
            if (b.isSelfMade) {
                LoadingView* lv = [LoadingView show:nil];
                [self endSelecting];
                CreatePane* cp = [[CreatePane alloc]init];
                [cp.book openBook:b];
                [lv dismiss];
                [[RootPane instance]pushPane:cp];
                [cp release];
//                [self authenticationWithFBAccount];
            }
        } else {
            NSLog(@"book: %@", book);
            NSLog(@"b: %@", b);

            if ([b hasFolders]) {
                FileListPane* p = [[FileListPane alloc]init];
                p.book = b;
                [[RootPane instance]pushPane:p];
                [p release];
            }
            else if (b.isDOC || b.isPPT || b.isXLS){
                NSLog(@"book is office format!!");
                DocumentViewerPane * docViewer = [[DocumentViewerPane alloc] init];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
                    NSURL *url = [[NSURL alloc] initFileURLWithPath:b.path];
                    NSURLRequest *request = [NSURLRequest requestWithURL:url];
                    docViewer.fileURL = b.path;
                    docViewer.isDoc = b.isDOC;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [docViewer.docContent loadRequest:request];      
                    });
                });
                [[RootPane instance] pushPane:docViewer];
            }
            else if (book) {
                BookReaderPane* p = [[BookReaderPane alloc]init];
                [[RootPane instance]pushPane:p];
                [p openBook:b];
                [p openPage:b.readingPage];
                [p release];
                
            } else {
                BookReaderPane* p = [[BookReaderPane alloc]init];
                [p openBook:b];
                [[RootPane instance]pushPane:p];
                //[p openBook:b];
                [p openPage:b.readingPage];
                [p release];
            }
        }
    }
}
// ファイル一覧をリロードする
- (IBAction)reload {
    [listView reload];
}
// ブックマーク画面に遷移する
- (IBAction)showBookmark {
    [[RootPane instance]showBookmarkPane];
}

- (void)startEditState {
    editButton.title = NSLocalizedString(@"done", nil);
    editButton.style = UIBarButtonItemStyleDone;
}

- (void)cancelEditState {
    editButton.title = NSLocalizedString(@"edit", nil);
    editButton.style = UIBarButtonItemStyleBordered;
}

- (void)showHTTPDownload {
    HTTPDownloadPane* hp = [[[HTTPDownloadPane alloc]init]autorelease];
    [[RootPane instance]pushPane:hp];
}

// 編集モードを切り替える
- (IBAction)toggleEdit {
    RootPane* rp = [RootPane instance];
    if (!rp.navigationLock) {
        rp.navigationLock = YES;
        listView.editMode = !listView.editMode;
        if (listView.editMode) {
            [self startEditState];
        } else {
            [self cancelEditState];
        }
        rp.navigationLock = NO;
    }
}

- (void)createNew {
    CreatePane* cp = [[[CreatePane alloc]init]autorelease];
    [cp deleteFiles];
    cp.book.name = nil;
    [[RootPane instance]pushPane:cp];

 //   [self authenticationWithFBAccount];
    
}

- (void)editExisting {
    CreatePane* cp = [[[CreatePane alloc]init]autorelease];
    [[RootPane instance]pushPane:cp];
}

- (void)back {
    [[RootPane instance]popPane];
}

// 選択モードを開始する
- (void)startSelecting {
    selectToolBar.hidden = NO;
    mainToolBar.hidden = YES;
    selectingMode = YES;
    for (UITabBarItem* item in tabBar.items) {
        item.enabled = NO;
    }
    [listView startSelection];
}

// 選択モードを解除する
- (IBAction)endSelecting {
    selectToolBar.hidden = YES;
    mainToolBar.hidden = NO;
    selectingMode = NO;
    for (UITabBarItem* item in tabBar.items) {
        item.enabled = YES;
    }
    [listView endSelection];
}



// カメラで自炊機能を開始する
- (IBAction)showCreation {
    NSMutableArray* buttons = [NSMutableArray array];
    BOOL fileExists = [NewBook fileExists];
    if (fileExists) {
        [buttons addObject:NSLocalizedString(@"underTheEditFileAndNewMakes", nil)];
        [buttons addObject:NSLocalizedString(@"editContinue", nil)];
        [buttons addObject:NSLocalizedString(@"editedFileSelect", nil)];
    } else {
        [buttons addObject:NSLocalizedString(@"newMakeing", nil)];
        [buttons addObject:NSLocalizedString(@"editedFileSelect", nil)];
    }
    ActionDialog* ad = [[ActionDialog alloc]
                        initWithTitle:NSLocalizedString(@"create", nil)
                        callback:^(NSInteger idx) {
                            if (fileExists) {
                                if (idx == 0) {
                                    [self createNew];
                                } else if (idx == 1) {
                                    [self editExisting];
                                } else if (idx == 2) {
                                    [self startSelecting];
                                }
                                
                            } else {
                                if (idx == 0) {
                                    [self createNew];
                                } else if (idx == 1) {
                                    [self startSelecting];
                                }
                            }
                        }
                        otherButtonTitles:buttons];
    [ad showFromTabBar:tabBar];
    [ad release];
    
}

- (IBAction)showMusicPlayer {
    @synchronized(musicViewController) {
        if (musicViewController == nil) {
            musicViewController = [[MusicViewController alloc] init];
        }
    }
    
    RootPane* rp = [RootPane instance];
    if ([AppUtil isForIpad]) {
        // iPadではPopoverで表示する        
        musicPopover = [[UIPopoverController alloc]initWithContentViewController:musicViewController];
        [musicPopover presentPopoverFromRect:musicViewController.view.bounds
                              inView:tabBar
            permittedArrowDirections:UIPopoverArrowDirectionDown
                            animated:YES];
    } else {
        [rp pushPane:musicViewController];
//        [rp presentModalViewController:musicViewController animated:YES];
    }
}

// 共有画面に遷移する
- (IBAction)showShare {
    BluetoothPane* bp = [[[BluetoothPane alloc]init]autorelease];
    [[RootPane instance]pushPane:bp];
}

// Dropbox画面を表示する
- (IBAction)showDropbox {
    DropboxFirstPane* dbfp = [[[DropboxFirstPane alloc]init]autorelease];
    [[RootPane instance]pushPane:dbfp];
}

// 設定画面を表示する
- (IBAction)showConfig {
    listView.filenameLabelValid = NO;
    [[RootPane instance]showConfigPane];
}

// FileListViewを表示する
- (BOOL)showFileListView: (BOOL) typeTable {
    Class listViewClass = [listView class];
    Class argClass = typeTable ? [TableFileListPane class] : [ShelfFileListPane class];
    if (listView == nil || listViewClass != argClass) {
        NSUserDefaults* ud = [AppUtil config];
        [ud setBool:typeTable forKey:@"fileListType"];
        [ud synchronize];

        if (self.listView) {
            [listView.view removeFromSuperview];
            self.listView = nil;
        }

        UIViewController<FileListDelegate>* lp;
        if (typeTable) {
            lp = [[[TableFileListPane alloc]init]autorelease];
        } else {
            lp = [[[ShelfFileListPane alloc]init]autorelease];
        }
        lp.fileListPane = self;
        self.listView = lp;

        [listArea addSubview:listView.view];
        [listView.view eFittoSuperview];
        [listView viewWillAppear:NO];
        [listView viewDidAppear:NO];
        return YES;
    } else {
        return NO;
    }
}

// ファイル一覧ビューを切り替える
- (IBAction)changeFileListView: (UISegmentedControl*) sender {
    NSInteger sent = sender.selectedSegmentIndex;
    [self showFileListView:sent];
    [self cancelEditState];
}

-(void)updateLayout {
    [listView updateLayout];
    if ([AppUtil isForIpad]) {
        if (musicViewController) {
            if (musicPopover.popoverVisible) {
                [musicPopover dismissPopoverAnimated:NO];
                [musicPopover 
                 presentPopoverFromRect:musicViewController.view.bounds
                 inView:tabBar
                 permittedArrowDirections:UIPopoverArrowDirectionDown
                 animated:NO];
            }
        }
    }
}


-(void)didRotate:(NSNotification*)note {
    RootPane* rp = [RootPane instance];
    if ([rp isTop:rp] || [rp isTop:self]) {
        [FileListPane cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateLayout) object:nil];
        [self performSelector:@selector(updateLayout) withObject:nil afterDelay:0.05];    
    }
}


#pragma mark - View lifecycle

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];

    self.listView = nil;
    self.book = nil;
    
    self.listArea = nil;
    self.listChanger = nil;
    self.listChanger2 = nil;
    self.editButton = nil;
    self.tabBar = nil;
    self.folderToolBar = nil;
    self.selectToolBar = nil;
    self.editFileSelectLabel = nil;
    self.cancelButton = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidAppear:(BOOL)animated {
    [listView viewDidAppear:animated];
    prepared = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.book) {
        mainToolBar.hidden = YES;
        folderToolBar.hidden = NO;
    } else {
        mainToolBar.hidden = NO;
        folderToolBar.hidden = YES;
    }
    // もし変更になってたら表示を変える必要がある
    NSUserDefaults* ud = [AppUtil config];
    BOOL confTypeTable = [ud boolForKey:@"fileListType"];
    listChanger.selectedSegmentIndex = confTypeTable ? 1 : 0;
    listChanger2.selectedSegmentIndex = confTypeTable ? 1 : 0;
    if (![self showFileListView:confTypeTable]) {
        [listView viewWillAppear:animated];
    }
    [self didRotate:nil];
    //NSLog(@"FileListPane Will Appear");
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    editButton.title = NSLocalizedString(@"edit", nil);
    
    UITabBarItem* item = [[tabBar items]objectAtIndex:0];
    item.title = NSLocalizedString(@"musicplayer", nil);
    item = [[tabBar items]objectAtIndex:1];
    item.title = NSLocalizedString(@"creation", nil);
    item = [[tabBar items]objectAtIndex:2];
    item.title = NSLocalizedString(@"dropbox", nil);
    item = [[tabBar items]objectAtIndex:3];
    item.title = NSLocalizedString(@"bluetooth", nil);
    item = [[tabBar items]objectAtIndex:4];
    item.title = NSLocalizedString(@"httpdownload", nil);    
    item = [[tabBar items]objectAtIndex:5];
    item.title = NSLocalizedString(@"preference", nil);
    editFileSelectLabel.text = NSLocalizedString(@"editFileSelect", nil);
    cancelButton.title = NSLocalizedString(@"cancel", nil);

    [[NSNotificationCenter defaultCenter] 
     addObserver:self
     selector:@selector(didRotate:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.listView = nil;
    self.book = nil;
    
    self.listArea = nil;
    self.listChanger = nil;
    self.listChanger2 = nil;
    self.editButton = nil;
    self.tabBar = nil;
    self.folderToolBar = nil;
    self.selectToolBar = nil;
    self.editFileSelectLabel = nil;
    self.cancelButton = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
    NSLog(@"autorotating");
    return ![RootPane isRotationLocked];
}



@end
