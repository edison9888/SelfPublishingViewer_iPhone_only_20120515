//
//  BookReaderPane.m
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/01.
//  Copyright 2011 SAT. All rights reserved.
//

#import "BookReaderPane.h"
#import "RootPane.h"
#import "BookControlPane.h"
#import "Book.h"
#import "PageImageView.h"
#import "AlertDialog.h"
#import "URLLink.h"
#import "BookFiles.h"
#import "UIView_Effects.h"
#import "AppUtil.h"

@interface BookReaderPane()
@property(nonatomic,retain)BookControlPane* control;
@end


@implementation BookReaderPane
@synthesize book,previewing,viewerInvalid,control,isFromImageAdjustment;
@synthesize lastPageLabel;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)dealloc
{
    //NSLog(@"%s", __func__);
    [book release];
    self.lastPageLabel = nil;
    self.control = nil;
    [super dealloc];
    
}

// Bookを閉じる
- (void) closeBook {
    [imageView close];
    book.readingPage = imageView.currentPage;
    [book release];
    book = nil;
    RootPane* rp = [RootPane instance];
    [rp popPane];
}
// Bookを開く
- (void) openBook: (NSObject<Viewable>*) bookToOpen {
    [book release];
    book = [bookToOpen retain];
    // 最後に読み込んだBookを覚えておく
    NSUserDefaults* ud = [AppUtil config];

    if ([book isKindOfClass:[Book class]]) {
        Book* bk = (Book*)book;

        [ud setValue:bk.path forKey:@"lastOpenBookPath"];
        [ud setValue:bk.folderName forKey:@"lastOpenBookFolder"];
        [ud synchronize];
    }
}

// 指定したページを開く
- (void) openPage: (NSInteger) page {
    Book *b = (Book *)book;
    if (book) {
        
        if (!b.isImported && !b.isImporting && !b.isPDF) {
            [b startBookImportOperation];
        }
                    
        page = MIN(page, [book pageCount] - 1);
        page = MAX(page, 0);
        NSLog(@"page: %i", page);
        
        if (page < [book pageCount] && page >= 0) {
            if (imageView) {
                [imageView openAt:page forward:YES];

                if (b.isWeirdFlag) {
                    [AlertDialog alert:res(@"error")
                               message:res(@"pageSizeNotSupported")
                                  onOK:^{
                                      return; 
                                  }];

                }
                            
            } else {
                currentPage = page;

                if (b.isWeirdFlag) {
                    [AlertDialog alert:res(@"error")
                               message:res(@"pageSizeNotSupported")
                                  onOK:^{
                                      return; 
                                  }];
                    
                }

            }
        } else {
            [AlertDialog alert:NSLocalizedString(@"error", nil)
                       message:NSLocalizedString(@"pageIsNotOpen", nil)
                          onOK:^(){
                              [self closeBook];
                          }];
        }
    } else {
        //NSLog(@"Book not opend");
    }
}

// 次のページを開く
- (void) nextPage {
    [imageView animateNext];
    Book *b = (Book *)book;
    if (b.isWeirdFlag) {
        [AlertDialog alert:res(@"error")
                   message:res(@"pageSizeNotSupported")
                      onOK:^{
                          return; 
                      }];
        
    }

}
// 前のページを開く
- (void) prevPage {
    [imageView animatePrev];
    Book *b = (Book *)book;
    if (b.isWeirdFlag) {
        [AlertDialog alert:res(@"error")
                   message:res(@"pageSizeNotSupported")
                      onOK:^{
                          return; 
                      }];
        
    }

}

#pragma mark - Viewerからのイベント

- (void) lastLabelTapped {
    [UIView animateWithDuration:0.5 
                     animations:^{
                         lastPageLabel.layer.opacity = 0;
                     }
                     completion:^(BOOL finished) {
                         lastPageLabel.layer.opacity = 1;
                         lastPageLabel.hidden = YES;
                     }];
}

- (void) lastLabelAutoHide {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(lastLabelTapped) object:nil];
    [self performSelector:@selector(lastLabelTapped) withObject:nil afterDelay:3];
}

// ページが開かれたイベント
- (void)pageOpened {
    currentPage = imageView.currentPage;
    if ([imageView isTop]) {
        lastPageLabel.text = NSLocalizedString(@"firstPage", nil);
        lastPageLabel.hidden = NO;
        [self lastLabelAutoHide];
        
        
    } else if ([imageView isLast]) {
        lastPageLabel.text = NSLocalizedString(@"lastPage", nil);
        lastPageLabel.hidden = NO;
        [self lastLabelAutoHide];
        
        
    } else {
        lastPageLabel.hidden = YES;
    }
//    NSLog(@"%d", currentPage);
}

// エラーが発生したイベント
- (void)errorOccured {
    
}

// 左のほうをタップ
-(void) tapLeft {
    if (imageView.leftNext) {
        if ([imageView hasNext]) {
            [imageView animateNext];
        } else {
            [self showControl];
        }
    } else {
        if ([imageView hasPrev]) {
            [imageView animatePrev];
        } else {
            [self showControl];
        }
    }
}
- (void)swipeLeft 
{
    if (imageView.leftNext) {
        [imageView animateNext];
    } else {
        [imageView animatePrev];
    }
}
-(void)swipeRight {

    if (imageView.leftNext) {
        [imageView animateNext];
    } else {
        [imageView animatePrev];
    }    
}

// 右のほうをタップ
-(void) tapRight {
    if (imageView.leftNext) {
        if ([imageView hasPrev]) {
            [imageView animatePrev];
        } else {
            [self showControl];
        }
    } else {
        if ([imageView hasNext]) {
            [imageView animateNext];
        } else {
            [self showControl];
        }
    }
}
// 真ん中あたりをタップ
-(void) tapCenter {
    [self showControl];
}
-(void)performPressLeftEnd {
    [imageView openAt:currentPage forward:imageView.leftNext];    
}
// 左のほうを長押ししている間連続して呼ばれる
-(void) pressLeft: (BOOL)end {
    if (!end) {
        NSInteger p = currentPage;
        if (imageView.leftNext) {
            if (p < [book pageCount] - 1) {
                p++;
            }
        } else {
            if (p > 0) {
                p--;
            }
        }
        if (currentPage != p) {
            [imageView highSpeedAnimateLeft];
            currentPage = p;
        }
        //NSLog(@"page:%d", currentPage);
    } else {
        [self performSelectorOnMainThread:@selector(performPressLeftEnd) withObject:nil waitUntilDone:NO];
    }
}
-(void)performPressRightEnd {
    [imageView openAt:currentPage forward:!imageView.leftNext];    
}

// 右のほうを長押ししている間連続して呼ばれる
-(void) pressRight: (BOOL)end {
    if (!end) {
        NSInteger p = currentPage;
        if (imageView.leftNext) {
            if (p > 0) {
                p--;
            }
        } else {
            if (p < [book pageCount] - 1) {
                p++;
            }
        }
        if (currentPage != p) {
            [imageView highSpeedAnimateRight];
            currentPage = p;
        }
        //NSLog(@"page:%d", currentPage);
    } else {
        [self performSelectorOnMainThread:@selector(performPressRightEnd) withObject:nil waitUntilDone:NO];
//        [imageView openAt:currentPage forward:!imageView.leftNext];
    }
}
// ページ数を返す
-(NSInteger) pageCount {
    return [book pageCount];
}

// 現在のページを返す
-(NSInteger) currentPage {
    return currentPage;
}

-(UIImage*) highResImageAt: (NSInteger)page{
    if (book.isPDF){
        return [book getHighResPDFImage:page];
    }
    else {
        return nil;
    }
}

// ページの画像を返す
-(UIImage*) imageAt: (NSInteger)page {
    //@try {
        return [book getPageImage:page];
    /*}
    @catch (NSException* ex) {
        if (!isInError) {
            isInError = YES;
            NSLog(@"ERROR: %@ %s", [ex description], __func__);
            UIAlertView* al = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"error", nil)    
                                                         message:NSLocalizedString(@"pageDidNotOpen", nil)
                                                        delegate:nil 
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [al show];
            [al release];
            [self showControl];
        }
    }
    return nil;*/
}

-(UIImage*) thumbnailAt:(NSInteger)page {
    @try {
        return [book getThumbnailImage:page];
    }
    @catch (NSException * ex) {
        NSLog(@"ERROR: %@ %s", [ex description], __func__);
        return nil;
    }
}

// キャッシュさせる
-(void)fetchCache:(NSInteger)page size:(CGSize)size {
    [self.book fetchCache:page size:size];
}

- (NSArray*)urlLinks:(NSInteger)page {
    NSArray* links = [self.book getPageLinks:page];
    return links;
}

-(PageMemo*)getPageMemo:(NSInteger)page {
    if ([book isKindOfClass:[Book class]]) {
        Book* bk = (Book*)book;
        return [[[PageMemo alloc]initWithBook:bk page:page]autorelease];
    } else {
        return nil;
    }
}


// Controlを表示する
- (void) showControl {
    if (!control) {
        control = [[BookControlPane alloc]init];
        control.reader = self;
        [self.view addSubview:control.view];
        [control.view eFittoSuperview];
    } else{
        control.view.alpha = 1.0f;
    }
}

// Controlを消す
- (void) hideControl {
    if (control) {
        [control onClose];
        control.view.alpha = 0.0f;
        self.control = nil;
    }
}


- (void)didReceiveMemoryWarning
{
    [BookFiles purge];
    //NSLog(@"%s", __func__);
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    currentPage = -1;
    lastPageLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    lastPageLabel.layer.borderWidth = 2;
    lastPageLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    lastPageLabel.layer.shadowOffset = CGSizeMake(2, 2);
    lastPageLabel.layer.shadowRadius = 1;
    lastPageLabel.layer.shadowOpacity = 0.9;
    lastPageLabel.layer.cornerRadius = 3;
    lastPageLabel.layer.masksToBounds = NO;
    UITapGestureRecognizer* tapr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(lastLabelTapped)];
    [lastPageLabel addGestureRecognizer:tapr];
    [tapr release];
}

- (void)createImageView {
    if (imageView) {
        [imageView close];
        [imageView removeFromSuperview];
        imageView = nil;
    }
    // 全画面表示する
    CGRect rc = self.view.frame;
    rc.origin.x = rc.origin.y = 0;
    imageView = [[PageImageView alloc]initWithFrame:rc];
    if (book.isPDF) {
        CATiledLayer * tiles = [CATiledLayer layer];
        //tiles.contentsScale = 1.0f;
        [imageView.contentView.layer addSublayer:tiles];
    }
    imageView.delegate = self;
    imageView.dataSource = self;
    imageView.autoresizingMask = UIViewAutoresizingNone;
    [self.view insertSubview:imageView atIndex:0];
    
    [imageView openAt:currentPage forward:YES];
    [imageView release];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGRect rc = [UIScreen mainScreen].bounds;
    if ([RootPane isPortrait]) {
        self.view.frame = rc;
    } else {
        self.view.frame = CGRectMake(0, 0, rc.size.height, rc.size.width);
    }
    if (!imageView) {
        // 初回表示
        [self createImageView];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (imageView && viewerInvalid) {
        // 設定画面から戻ってきたとき
        [self createImageView];
    }    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ![RootPane isRotationLocked];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    [book release];
    self.lastPageLabel = nil;
    self.control = nil;
    book = nil;
}


@end
