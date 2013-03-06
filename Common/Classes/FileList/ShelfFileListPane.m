//
//  ShelfFileListPane.m
//

#import "ShelfFileListPane.h"
#import "FileListPane.h"
#import "BookFiles.h"
#import "Book.h"
#import "RootPane.h"
#import "AlertDialog.h"
#import "UIView_Effects.h"
#import "AppUtil.h"
#import "NSString_Util.h"

@implementation ShelfFileListPane
@synthesize fileListPane;
@synthesize scrollView,contentView;
@synthesize filenameLabelValid;

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
    NSLog(@"%s", __func__);

    [lastMark release];
    [bookIcons release];
    [deleteIcons release];
    
    self.scrollView = nil;
    self.contentView = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (NSArray*) listBooks {
    if (fileListPane.book) {
        return [fileListPane.book folders];
        
    } else {
        BookFiles* bookFiles = [BookFiles bookFiles];
        return [bookFiles books];
    }

}

// Bookを削除する
- (void)deleteBook:(UIButton*)sender {
    [AlertDialog confirm:NSLocalizedString(@"confirm",nil)
                 message:NSLocalizedString(@"confirmDelete",nil)
                    onOK:^{
                        UIButton* icon = (UIButton*)[sender superview];
                        BookFiles* bf = [BookFiles bookFiles];
                        NSInteger idx = [bookIcons indexOfObject:icon];
                        [bf deleteBookAt:idx];
                        [deleteIcons removeObject:sender];
                        [bookIcons removeObject:icon];
                        [icon removeFromSuperview];
                        layoutValid = NO;
                        [self updateLayout];
                    }];
    
}

#pragma mark - View lifecycle

- (void)setEditMode:(BOOL)e {
    if (e) {
        deleteIcons = [[NSMutableArray arrayWithCapacity:[bookIcons count]]retain];
        UIImage* delImg = [UIImage imageNamed:@"delete.png"];

        for (UIButton* b in bookIcons) {
            UIButton* db = [UIButton buttonWithType:UIButtonTypeCustom];
            [db setImage:delImg forState:UIControlStateNormal];
            db.frame = CGRectMake(0, 0, 32, 32);
            db.tag = b.tag;
            [db addTarget:self action:@selector(deleteBook:) forControlEvents:UIControlEventTouchUpInside];
            [b addSubview:db];
            
            UIPanGestureRecognizer* gr = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self 
                                          action:@selector(bookIconDragged:)];
            [b addGestureRecognizer:gr];
            [gr release];
            [deleteIcons addObject:db];
        }
        
    } else {
        for (UIButton* db in deleteIcons) {
            [db removeFromSuperview];
        }
        for (UIButton* b in bookIcons) {
            for (UIGestureRecognizer* gr in [b gestureRecognizers]) {
                if ([gr class] == [UIPanGestureRecognizer class]) {
                    [b removeGestureRecognizer:gr];
                }
            }
        }
        
        [deleteIcons removeAllObjects];
    }
    editing = e;
}

- (BOOL)editMode {
    return editing;
}

- (void)setBackground {
    NSUserDefaults* ud = [AppUtil config];
    NSString* type = [ud valueForKey:@"shelfType"];
    if (!type) {
        type = @"black";
    }
    contentView.backgroundImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", type]];
}

// BookIconの位置と大きさを計算して返す
- (CGRect)bookIconFrame:(NSInteger)i orientation:(BOOL)isPortrait {
    NSInteger mw = isPortrait ? SF_MARGIN_WIDTH_P : SF_MARGIN_WIDTH_L;
    NSInteger iw = isPortrait ? SF_INSET_WIDTH_P : SF_INSET_WIDTH_L;
    //NSInteger pw = self.view.frame.size.width - (SF_INSET_WIDTH * 2) + mw;
    NSInteger cols = isPortrait ? SF_COLS_P : SF_COLS_L;//  pw / (SF_ICON_WIDTH + mw); // １行にいくつ並べられるのか
    NSInteger row = i / cols; // 行
    NSInteger col = i - (cols * row); // 列
    NSInteger x = col * (SF_ICON_WIDTH + mw) + iw;
    NSInteger y = (row + 5) * (SF_ICON_HEIGHT + SF_MARGIN_HEIGHT) + SF_INSET_HEIGHT;
    return CGRectMake(x, y, SF_ICON_WIDTH, SF_ICON_HEIGHT);
}

// 位置から順序を計算する
- (NSInteger)bookIconOrder:(CGPoint) p {
    BOOL isPortrait = layoutPortrait;
    NSInteger mw = isPortrait ? SF_MARGIN_WIDTH_P : SF_MARGIN_WIDTH_L;
    NSInteger iw = isPortrait ? SF_INSET_WIDTH_P : SF_INSET_WIDTH_L;
    
    NSInteger pw = self.view.frame.size.width - (iw * 2) + mw;
    NSInteger cols = pw / (SF_ICON_WIDTH + mw); // １行にいくつ並べられるのか
    NSInteger rh = SF_ICON_HEIGHT + SF_MARGIN_HEIGHT;
    NSInteger row = (p.y - SF_INSET_HEIGHT) / rh - 5;
    NSInteger col = (p.x - iw) / (SF_ICON_WIDTH + mw);
    return cols * row + col;
}

// BookIconタップイベント
-(void)bookSelected: (UIButton*)sender {
    if (!editing) {
        [fileListPane open:sender.tag];
    }
}

// BookIconドラッグイベント
- (void)bookIconDragged: (UIPanGestureRecognizer*)gr {
    if (editing){
        UIView* b = gr.view;
        if (gr.state == UIGestureRecognizerStateBegan) {
            b.layer.zPosition = 99;
            b.layer.shadowOffset = CGSizeMake(3, 3);
            b.layer.shadowColor = [UIColor blackColor].CGColor;
            b.layer.shadowRadius = 2;
            grabbing = [self bookIconOrder:[gr locationInView:contentView]];
            
        } else if (gr.state == UIGestureRecognizerStateChanged) {
            CGPoint p = [gr locationInView:contentView];
            [b setCenter:p];
            
        } else if (gr.state == UIGestureRecognizerStateEnded) {
            NSInteger moveTo = [self bookIconOrder:[gr locationInView:contentView]];
            BookFiles* bf = [BookFiles bookFiles];
            [bf changeBookOrder:grabbing to:moveTo];
            UIButton* obj = [bookIcons objectAtIndex:grabbing];
            [bookIcons removeObjectAtIndex:grabbing];
            if (moveTo < [bookIcons count]) {
                [bookIcons insertObject:obj atIndex:moveTo];
            } else {
                [bookIcons addObject:obj];
            }
            layoutValid = NO;
            [self updateLayout];
    
        } else {
        }
    }
}


// ブックアイコンの画像を読み込む
- (void)loadBookIconImages {
    if (!iconImageUpdating) {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
        NSLog(@"%s", __func__);
        iconImageUpdating = YES;
        
        BookFiles* bookFiles = [BookFiles bookFiles];
        @synchronized(bookFiles) {
            NSArray* books = nil;
            NSInteger c;
            if (fileListPane.book) {
                books = [fileListPane.book folders];
                c = [books count];
            } else {
                c = [bookFiles bookCount];
                books = [bookFiles books];
            }
            NSLog(@"bookfiles: %i", c);
            for (NSInteger i = 0; i < c; i++) {
                Book* bk = [books objectAtIndex:i];
                UIButton* b = [bookIcons objectAtIndex:i];
                CGSize sz = b.frame.size;
                NSLog(@"size: %f, %f", sz.width, sz.height);
                
                CGFloat scaleH = 1.4;
                CGFloat scaleV = 1.3;
                
                UIImageView * paperStack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paper_stack.png"]];
                if (paperStack) {
                    paperStack.frame = CGRectMake((70 - 70 * scaleH) / 2, (94 - 94 * scaleV) / 2, 70 * scaleH, 94 * scaleV);
                    [b insertSubview:paperStack atIndex:0];
                }
                [paperStack release];
                
                CGFloat scale2 = 0.8;
                
                UIImageView * coverImage = [[UIImageView alloc] initWithImage:[bk getCoverImage:sz]];
                if (coverImage) {
                    coverImage.frame = CGRectMake((70 - 70 * scale2) / 2, 2 + (94 - 94 * scale2) / 2, 70 * scale2, 94 * scale2);
                    [b addSubview:coverImage];
                }
                [coverImage release];
                
                //[b setImage:[bk getCoverImage:sz] forState:UIControlStateNormal];
            }
            iconImageUpdating = NO;
        }
        [pool release];
    }
}

// ブックアイコンの画像読み込みスレッドを開始する
- (void)startLoadBookIconImages {
    if (!iconImageUpdating && bookIcons) {
        NSLog(@"%s", __func__);
        [NSThread detachNewThreadSelector:@selector(loadBookIconImages) 
                             toTarget:self 
                           withObject:nil];
    }
}



// Bookアイコンを並べなおす
- (void)layoutBookIcons:(BOOL)isPortrait {
    //NSLog(@"%s", __func__);
    if (bookIcons) {
        NSLog(@"アイコン並べ直し %s", __func__);
        NSInteger c;
        if (fileListPane.book) {
            NSArray* folderBooks = [fileListPane.book folders];
            c = [folderBooks count];
        } else {
            BookFiles* bookFiles = [BookFiles bookFiles];
            c = [bookFiles bookCount];
        }

        [UIView beginAnimations:Nil context:Nil];
        [UIView setAnimationDuration:0.3f];
        
        for (NSInteger i = 0; i < c; i++) {
            UIView* b = [bookIcons objectAtIndex:i];
            b.frame = [self bookIconFrame:i orientation:isPortrait];
            b.tag = i;
        }
        
        [UIView commitAnimations];

        layoutPortrait = isPortrait;
        // 本棚背景の計算
        NSInteger cols = isPortrait ? SF_COLS_P : SF_COLS_L;// pw / (SF_ICON_WIDTH + mw); // １行にいくつ並べられるのか
        NSInteger rh = SF_ICON_HEIGHT + SF_MARGIN_HEIGHT; // １行の高さ
        NSInteger rows = c / cols; // アイコンの並ぶ行数
        if (c % cols != 0) {
            rows ++;
        }

        CGFloat mw = isPortrait ? SF_MARGIN_WIDTH_P : SF_MARGIN_WIDTH_L;
        CGFloat iw = isPortrait ? SF_INSET_WIDTH_P : SF_INSET_WIDTH_L;
        CGFloat width = iw * 2 + cols * (SF_ICON_WIDTH + mw) - mw; 
//        NSLog(@"width:%0.0f", width);
        
        contentView.frame = CGRectMake(0, -5 * rh, width,
                                       rh * (rows + 10) + SF_INSET_HEIGHT);
        NSInteger ch = MAX(scrollView.frame.size.height + 1, rh * rows + SF_INSET_HEIGHT);
        scrollView.contentSize = CGSizeMake(width, ch);
        [contentView setNeedsDisplay];
    }
}


// ブックアイコンを生成する
- (void)loadBookIcons {
    NSLog(@"%s", __func__);

    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];

    if (bookIcons) {
        for (UIButton* icon in bookIcons) {
            if (icon.superview) {
                [icon removeFromSuperview];
            }
        }
        [bookIcons release];
        bookIcons = nil;
    }
    NSInteger c;
    NSArray* books;
    if (fileListPane.book) {
        books = [fileListPane.book folders];
        c = [books count];
    } else {

        BookFiles* bookFiles = [BookFiles bookFiles];

        c = [bookFiles bookCount];

        books = [bookFiles books];
    }

    bookIcons = [[NSMutableArray arrayWithCapacity:c]retain];
    BOOL isPortrait = [RootPane isPortrait];
    UIImage* folImg = [UIImage imageNamed:@"icon_folder.png"];
    for (NSInteger i = 0; i < c; i++) {

        UIButton* b = [[UIButton alloc]initWithFrame:[self bookIconFrame:i orientation:isPortrait]];
        [b addTarget:self action:@selector(bookSelected:) forControlEvents:UIControlEventTouchUpInside];
        [b setBackgroundColor:[UIColor clearColor]];
        b.tag = i;
        [contentView addSubview:b];
        [bookIcons addObject:b];
        Book* bk = [books objectAtIndex:i];
        if ([bk hasFolders]) {
            //フォルダアイコンを追加する
            UIImageView * iv = [[UIImageView alloc] initWithImage:folImg];
            [b addSubview:iv];
            [iv eMove:b.width - iv.width 
                     :b.height - iv.height - SF_LABEL_FONTSIZE - 4];
            [iv release];
        }
        [b release];
    }
//    [self layoutBookIcons:isPortrait];
    [self startLoadBookIconImages];

    filenameLabelValid = NO;
    [pool release];
}

-(void)updateFilenameLabel {
    const NSInteger TAG = 103;
    NSUserDefaults* ud = [AppUtil config];
    BOOL show = [ud boolForKey:@"shelfFilename"];
    if (!filenameLabelValid || filenameLabelsVisible != show) {
        filenameLabelValid = YES;
        if (bookIcons) {
            if (show) {
                NSArray* books;
                if (fileListPane.book) {
                    books = [fileListPane.book folders];
                } else {
                    BookFiles* bookFiles = [BookFiles bookFiles];
                    books = [bookFiles books];
                }
                for (int i = 0; i < [bookIcons count]; i++) {
                    UIButton* b = [bookIcons objectAtIndex:i];
                    Book* bk = [books objectAtIndex:i];
                    UILabel* lb = [[UILabel alloc]init];
                    lb.textColor = [UIColor whiteColor];
                    lb.backgroundColor = [UIColor blackColor];
                    lb.font = [UIFont systemFontOfSize:SF_LABEL_FONTSIZE];
                    lb.textAlignment = UITextAlignmentCenter;
                    lb.text = [bk.name basename];
                    lb.tag = TAG;
                    [lb eSize:b.width :SF_LABEL_FONTSIZE + 4];
                    [b addSubview:lb];
                    [lb eFitBottom:YES];
                    lb.center = CGPointMake(lb.center.x, lb.center.y + 18);
                    UIView * greyShadow = [[UIView alloc] initWithFrame:lb.frame];
                    [greyShadow setBackgroundColor:[UIColor colorWithWhite:0.65 alpha:1.0]];
                    greyShadow.center = CGPointMake(greyShadow.center.x + 1, greyShadow.center.y + 1);
                    [b insertSubview:greyShadow belowSubview:lb];
                    [lb release];
                    [greyShadow release];
                }
            } else {
                for (UIButton* b in bookIcons) {
                    for (UIView* v in b.subviews) {
                        if ([v isKindOfClass:[UILabel class]]
                            && v.tag == TAG) {
                            [v removeFromSuperview];
                        }
                    }
                }
            }
        }
        filenameLabelsVisible = show;
        
    }
}

// しおりアイコンを付け直す
-(void)updateLastMark {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
    if (bookIcons) {
        [lastMark removeFromSuperview];
        NSArray* books;
        if (fileListPane.book) {
            books = [fileListPane.book folders];
        } else {
            BookFiles* bf = [BookFiles bookFiles];
            
            books = [bf books];
            if ([books count] != [bookIcons count]) {
                [bf checkReload];
            }
            books = [bf books];
        }
        NSLog(@"bookIcons: %@", bookIcons);
        
        for (int i = 0; i < [bookIcons count]; i++) {
            UIButton* b = [bookIcons objectAtIndex:i];
            Book* bk = [books objectAtIndex:i];
            if (bk.isLastOpened) {
                if (!lastMark) {
                    UIImage* img = [UIImage imageNamed:@"shiori.png"];
                    lastMark = [[UIImageView alloc]initWithImage:img];
                    lastMark.frame = CGRectMake(b.frame.size.width - img.size.width, 9, img.size.width / 2, img.size.height / 2);
                }
                //[b addSubview:lastMark];
                [b insertSubview:lastMark atIndex:5];
            }
        }
    }
    [pool release];
}

// 再描画する
-(void)updateLayout {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
    if (!layoutValid || layoutPortrait != [RootPane isPortrait]) {
        [self.view eFittoSuperview];
        [self layoutBookIcons:[RootPane isPortrait]];
        layoutValid = YES;
    }

    [pool release];
}


- (void)startSelection {
    BookFiles* bf = [BookFiles bookFiles];
    for (NSInteger i = 0; i < [bf bookCount]; i++) {
        Book* bk = [bf bookAtIndex:i];
        UIButton* bt = [bookIcons objectAtIndex:i];
        bt.enabled = bk.isSelfMade;
        if (!bt.enabled) {
            [UIView beginAnimations:Nil context:Nil];
            [UIView setAnimationDuration:0.5];
            bt.alpha = 0.15f;
            [UIView commitAnimations];
        }
    }
}

- (void)endSelection {
    if (bookIcons) {
        for (UIButton* icon in bookIcons) {
            icon.enabled = YES;
            [UIView beginAnimations:Nil context:Nil];
            [UIView setAnimationDuration:0.5];
            icon.alpha = 1.0f;
            [UIView commitAnimations];
        }
    }    
}


- (void)viewWillAppear:(BOOL)animated {
//    [self.view eFittoSuperview];
    layoutValid = NO;

    if (bookIcons) {
        [self reload];
    } else {
        [self loadBookIcons];
        updatedTime = [NSDate timeIntervalSinceReferenceDate];
    }
    [self setBackground];
    [contentView setNeedsDisplay];
    [self updateLayout];
    [self updateLastMark];
    [self updateFilenameLabel];
    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)reload {
    NSArray* books = [self listBooks];
    if (fileListPane.book) {
        // folder一覧
        for (Book* bk in books) {
            if ([bk isCoverModifiedSince:updatedTime]) {
                NSLog(@"アイコン画像だけ再読み込み / %s", __func__);
                [self startLoadBookIconImages];
                updatedTime = [NSDate timeIntervalSinceReferenceDate];
                break;
            }
        }
    } else {
        // ファイル一覧
        BookFiles* bf = [BookFiles bookFiles];
        @synchronized(bf) {
            if ([books count] != [bookIcons count] || [bf checkReload]) {
                NSLog(@"アイコン全部再読み込み / %s", __func__);
                [self loadBookIcons];
                filenameLabelValid = NO;
                updatedTime = [NSDate timeIntervalSinceReferenceDate];
            } else if ([bf isCoverModifiedSince:updatedTime]) {
                NSLog(@"アイコン画像だけ再読み込み / %s", __func__);
                [self startLoadBookIconImages];
                updatedTime = [NSDate timeIntervalSinceReferenceDate];
            }
        }
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] 
     removeObserver:self];
    
    [lastMark release];
    lastMark = nil;
    [bookIcons release];
    bookIcons = nil;
    [deleteIcons release];
    deleteIcons = nil;
    
    self.scrollView = nil;
    self.contentView = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ![RootPane isRotationLocked];
}

@end
