//
//  BookControlPane.m
//  ForIPad
//  BookReaderPaneに半透明で重なるView
//  Created by 藤田正訓 on 11/07/01.
//  Copyright 2011 SAT. All rights reserved.
//

#import "BookControlPane.h"
#import "BookReaderPane.h"
#import "RootPane.h"
#import "Viewable.h"
#import "AlertDialog.h"
#import "Bookmarks.h"
#import "PrefPane.h"
#import "AppUtil.h"
#import "BookFiles.h"
#import "Book.h"
#import "WritingPane.h"
#import "NSString_Util.h"
#import "FileUtil.h"
#import "LoadingView.h"

enum  {
    ActionSheetTagCoverMenu = 1,
} ActionSheetTag;

@implementation BookControlPane
@synthesize reader, controlScroller;
@synthesize bookmarkButton, lockButton, coverButton, prefButton, writeButton, dupButton;
@synthesize pageCountLabel,pageLabel,pageSlider,closeButton;

#pragma mark - 状態変化

-(void)updateButtonState {
    RootPane* rp = [RootPane instance];
    NSString* imName = rp.rotationLock ? @"rotation_lock.png" : @"rotation.png";
    lockButton.image = [UIImage imageNamed:imName];
    
    NSString* bimName = [reader.book isBookmarked:reader.currentPage]
    ? @"bookmark_lock.png" : @"newbookmark.png";
    bookmarkButton.image = [UIImage imageNamed:bimName];
}

#pragma mark - Control機能


// 閉じるボタン
-(IBAction)closeBookReader:(id)sender {
    if (reader) {
//        [reader hideControl];
        [reader performSelectorOnMainThread:@selector(closeBook) withObject:Nil waitUntilDone:YES];
    }
}

// 表紙設定
-(IBAction)coverSet {
    // 表紙設定
    UIActionSheet* as;
    if (reader.book.isInFolder) {
        // フォルダの中
        as = [[UIActionSheet alloc]
              initWithTitle:NSLocalizedString(@"cover",nil)
              delegate:self 
              cancelButtonTitle:NSLocalizedString(@"cancel", nil)
              destructiveButtonTitle:nil
              otherButtonTitles:NSLocalizedString(@"coverbook", nil),
              NSLocalizedString(@"coverphotobook", nil),
              NSLocalizedString(@"coverfile", nil),
              NSLocalizedString(@"coverphotofile", nil),
              nil ];
        as.tag = 2;
    } else {
        // フォルダの外
        as = [[UIActionSheet alloc]
              initWithTitle:NSLocalizedString(@"cover",nil)
              delegate:self 
              cancelButtonTitle:NSLocalizedString(@"cancel", nil)
              destructiveButtonTitle:nil
              otherButtonTitles:NSLocalizedString(@"coverthis", nil),
              NSLocalizedString(@"coverphoto", nil),
              nil ];
        as.tag = 1;
    }
    [as showInView:self.view];
    [as release];    
    
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // 表紙設定の選択肢選択イベント
    if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
            // このページを表紙にする
            NSObject<Viewable>* book = reader.book;
            [book setCoverImage:[book getPageImage:reader.currentPage]];
            
            // テスト用
            //            UIImageWriteToSavedPhotosAlbum([book getPageImage:0], nil, nil, nil);
            
            [AlertDialog alert:NSLocalizedString(@"complete",nil)
                       message:NSLocalizedString(@"coversetCompleted",nil)
                          onOK:nil];
            
        } else if (buttonIndex == 1) {
            // フォトアルバムから選択する
            if (imagePicker) {
                [imagePicker dismiss];
                imagePicker = nil;
            }
            imagePicker = [[ImagePickDialog showPopover:^(UIImage* img) {
                NSObject<Viewable>* book = reader.book;
                [book setCoverImage:img];
                [imagePicker dismiss];
                imagePicker = nil;
                [AlertDialog alert:NSLocalizedString(@"complete",nil)
                           message:NSLocalizedString(@"coversetCompleted",nil)
                              onOK:nil];
            }
                                               fromRect:self.view.frame
                                                 inView:self.view]retain];
            
        }
    } else if (actionSheet.tag == 2) {
        // フォルダの中
        if (![reader.book isKindOfClass:[Book class]]) {
            return;
        }
        Book* book = (Book*)reader.book;
        BOOL setcover = NO;
        UIImage* img = [book getPageImage:reader.currentPage];
        if (buttonIndex == 0) {
            // 本の表紙
            setcover = YES;
            
        } else if (buttonIndex == 1) {
            // 本の表紙を選択する
            
        } else if (buttonIndex == 2) {
            // ファイルの表紙
            setcover = YES;
            book = [[BookFiles bookFiles]bookAtPath:book.path];
            
        } else if (buttonIndex == 3) {
            // ファイルの表紙を選択する
            book = [[BookFiles bookFiles]bookAtPath:book.path];
            
        } else {
            // キャンセル
            return;
        }
        if (setcover) {
            // この本の表紙
            [book setCoverImage:img];
            [AlertDialog alert:NSLocalizedString(@"complete",nil)
                       message:NSLocalizedString(@"coversetCompleted",nil)
                          onOK:nil];
            
        } else {
            // フォトアルバムから選択する
            if (imagePicker) {
                [imagePicker dismiss];
                imagePicker = nil;
            }
            imagePicker = [[ImagePickDialog showPopover:^(UIImage* img) {
                [book setCoverImage:img];
                [imagePicker dismiss];
                imagePicker = nil;
                [AlertDialog alert:NSLocalizedString(@"complete",nil)
                           message:NSLocalizedString(@"coversetCompleted",nil)
                              onOK:nil];
            }
                                               fromRect:self.view.frame
                                                 inView:self.view]retain];
        }
    }
}



// 現在のページをブックマークする
-(IBAction)bookmark {
    if ([reader.book isBookmarked:reader.currentPage]) {
        Bookmarks* bm = [Bookmarks bookmarks];
        [bm remove:(Book*)reader.book page:reader.currentPage];
        [AlertDialog alert:NSLocalizedString(@"complete", nil) 
                   message:NSLocalizedString(@"bookmarkDeleted", nil)
                      onOK:nil];
    } else {

        [reader.book addToBookmark:reader.currentPage];
        [AlertDialog alert:NSLocalizedString(@"complete", nil) 
                   message:NSLocalizedString(@"bookmarkCompleted", nil)
                      onOK:nil];
    }
    [self updateButtonState];
}

// 回転ロックを切り替える
-(IBAction)lockRotation {
    RootPane* rp = [RootPane instance];
    rp.rotationLock = !rp.rotationLock;
    [self updateButtonState];
}

// 設定画面
-(IBAction)showPref {
    PrefPane* p = [[PrefPane alloc]init];
    [[RootPane instance]pushPane:p];
    [p release];
    [reader hideControl];
    reader.viewerInvalid = YES;
}

// 書き込み画面
-(void)showWriting {
    //WritingPane* p = [[WritingPane alloc]init];
    //[p setBookPage:reader.book page:reader.currentPage];

    PEEditorViewController *_editorController = [[PEEditorViewController alloc] initWithNibName:@"PEEditorViewController" bundle:nil];

    _editorController.img = [reader.book getPageImage:reader.currentPage];
    _editorController.delegate = self;
    _editorController.book = reader.book;
    _editorController.page = reader.currentPage;
    _editorController.pageMemo = [[[PageMemo alloc]initWithBook:(Book *)reader.book page:reader.currentPage]autorelease];
    
    [[RootPane instance]pushPane:_editorController];
    [_editorController release];
    
    [reader hideControl];
    reader.viewerInvalid = YES;
}



// 複製
-(void)doDuplicate:(NSString*)basename {
    Book* book = (Book*)reader.book;

    NSString *extension = [book.path pathExtension];
    
    [AlertDialog 
     prompt:res(@"fileDuplication")
     message:res(@"inputFileName")
     initial:basename
     onOK:^(NSString* str){
         NSString* path = [AppUtil docPath:[str stringByAppendingPathExtension:extension]];
         if ([str length] == 0) {
             [AlertDialog alert:res(@"confirm")
                        message:res(@"inputFileName")
                           onOK:^{
                               [self doDuplicate:[book dupFilenameCandidate]]; 
                           }];
         } else if (![FileUtil isValidFilename:str]) {
             [AlertDialog alert:res(@"confirm")
                        message:res(@"fileNameIsNotCorrect")
                           onOK:^{
                               [self doDuplicate:[book dupFilenameCandidate]]; 
                           }];

         } else if ([FileUtil exists:path]) {
             [AlertDialog alert:res(@"confirm") 
                        message:res(@"sameFileName") 
                           onOK:^{
                               [self doDuplicate:[book dupFilenameCandidate]];
                           }];
         } else {
             LoadingView* lv = [LoadingView show:nil];
             @try {
                 [book duplicateTo:path];
                 [lv dismiss];
                 [AlertDialog alert:res(@"complete") 
                            message:res(@"completeDuplicate")
                               onOK:nil];
             } @catch (NSException* ex) {
                 [lv dismiss];
                 //NSLog(@"%@/%@", [ex name], ex);
                 [AlertDialog alert:res(@"fileDuplication")
                            message:[res(@"faileDuplicate") add:[ex reason]]
                               onOK:nil];
             }
         }
     }
     onCancel:nil];
}

-(void)duplicate {
    Book* book = (Book*)reader.book;
    if (book.isRAR) {
        [AlertDialog alert:res(@"confirm")
                   message:res(@"cantDuplicate")
                      onOK:nil];
    } else {
        NSUserDefaults* ud = [AppUtil config];
        if (![ud boolForKey:@"duplicate.message.omit"]) {
            [AlertDialog confirm:res(@"fileDuplication")
                         message:res(@"dupMessage") 
                            onOK:^{
                                [ud setBool:YES forKey:@"duplicate.message.omit"];
                                [self doDuplicate:[book dupFilenameCandidate]];
                            } 
                        onCancel:^{
                            [self doDuplicate:[book dupFilenameCandidate]];
                        }];
        } else {
            [self doDuplicate:[book dupFilenameCandidate]];
        }
    }
}


#pragma mark - ページ送り関係
// スクロール位置が変更になった
-(void)controlScroller:(ControlScroller*)cs scrolled:(NSInteger)page {
//    NSLog(@"%s", __func__);
//    pageSlider.value = page;
}

// 選択された
-(void)controlScroller:(ControlScroller *)cs selected:(NSInteger)page {
    [reader openPage:page];
    [reader hideControl];
//    [reader performSelectorInBackground:@selector(hideControl) withObject:nil];
}

// 現在ページ
- (NSInteger)currentPage {
    return reader.currentPage;
}


// ページ選択つまみ
-(IBAction)pageSliderChanged:(id)sender {
//    NSLog(@"%s", __func__);
    NSInteger pageNum = (NSInteger)pageSlider.value;
    pageLabel.text = intStr(pageNum + 1);
    [controlScroller updateScroll:pageNum];
}

// タップで閉じる
- (void) paneTapped {
    if (reader.currentPage != pageSlider.value) {
        [reader openPage:pageSlider.value];
    }
    [reader hideControl];
}

#pragma mark - タブバーイベント

// タブバーのイベント
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    tabBar.selectedItem = nil;
    if (item == coverButton) {
        [self coverSet];
    } else if (item == bookmarkButton) {
        [self bookmark];
    } else if (item == lockButton) {
        [self lockRotation];
        
    } else if (item == prefButton) {
        [self showPref];
    } else if (item == writeButton) {
        [self showWriting];
    } else if (item == dupButton) {
        [self duplicate];
    }
}



#pragma mark - object lifecycle

- (void)dealloc
{
    NSLog(@"%s", __func__);
    [imagePicker release];
    self.controlScroller = nil;
    
    self.bookmarkButton = nil;
    self.lockButton = nil;
    self.coverButton = nil;
    self.prefButton = nil;
    self.writeButton = nil;
    self.dupButton = nil;
    
    self.pageSlider = nil;
    self.pageLabel = nil;
    self.pageCountLabel = nil;
    self.closeButton = nil;
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)viewDidAppear:(BOOL)animated {
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    [imagePicker release];
    imagePicker = nil;
    self.controlScroller = nil;
    
    self.bookmarkButton = nil;
    self.lockButton = nil;
    self.coverButton = nil;
    self.prefButton = nil;
    self.writeButton = nil;
    self.dupButton = nil;
    
    self.pageSlider = nil;
    self.pageLabel = nil;
    self.pageCountLabel = nil;
    self.closeButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ![RootPane isRotationLocked];
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}


- (void)onClose {
    [controlScroller onClose];
    controlScroller.delegate = nil;
    controlScroller.dataSource = nil;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view == self.view) {
        return YES;
    } else {
        return NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 何も無い場所のタップで閉じる
    UITapGestureRecognizer* tapr = [[UITapGestureRecognizer alloc]
                                    initWithTarget:self
                                    action:@selector(paneTapped)];
//    tapr.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tapr];
    tapr.delegate = self;
    [tapr release];
    
    [self updateButtonState];
    
    // ページ数の表示
    pageLabel.text = [NSString stringWithFormat:@"%d", reader.currentPage + 1];
    pageCountLabel.text = [NSString stringWithFormat:@"%d Pages", reader.pageCount];
    pageSlider.maximumValue = reader.pageCount - 1;
    pageSlider.minimumValue = 0;
    pageSlider.contentScaleFactor = 1;
    pageSlider.continuous = YES;
    pageSlider.value = reader.currentPage;
    // 左向きの場合ひっくり返す
    NSUserDefaults* ud = [AppUtil config];
    leftNext = [ud boolForKey:@"leftNext"];
    if (leftNext) {
        // 180度回転
        pageSlider.transform = CGAffineTransformMakeRotation(M_PI);
    }
    
    if (reader.previewing) {
        bookmarkButton.enabled = NO;
        coverButton.enabled = NO;
        prefButton.enabled = NO;
    }
    
    controlScroller.dataSource = reader.book;
    controlScroller.delegate = self;
    
    closeButton.layer.borderColor = [UIColor orangeColor].CGColor;
    closeButton.layer.cornerRadius = 10;
    closeButton.layer.borderWidth = 3;

    if (![reader.book isKindOfClass:[Book class]]) {
        bookmarkButton.enabled = NO;
        prefButton.enabled = NO;
        writeButton.enabled = NO;
        dupButton.enabled = NO;
    }
    
    
    
    [closeButton setTitle:NSLocalizedString(@"backToShelf", nil) forState:UIControlStateNormal];
    if (reader.previewing) {
        [closeButton setTitle:NSLocalizedString(@"return", nil) forState:UIControlStateNormal];
    }
    if (reader.isFromImageAdjustment)
    {
        [closeButton setTitle:NSLocalizedString(@"backToImageAdjustment", nil) forState:UIControlStateNormal];
    }
    [coverButton setTitle:NSLocalizedString(@"cover", nil)];
    [bookmarkButton setTitle:NSLocalizedString(@"bookmark", nil)];
    [lockButton setTitle:NSLocalizedString(@"lock", nil)];
    [prefButton setTitle:NSLocalizedString(@"preference", nil)];
    [writeButton setTitle:NSLocalizedString(@"writing", nil)];
    [dupButton setTitle:res(@"duplicate")];
}

@end
