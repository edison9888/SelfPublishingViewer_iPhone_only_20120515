//
//  LibraryPane.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/15.
//  Copyright 2011 SAT. All rights reserved.
//

#import "LibraryPane.h"
#import "NSString_Util.h"
#import "UIView_Effects.h"
#import <QuartzCore/QuartzCore.h>
#import "common.h"
#import "ImageUtil.h"
#import "RootPane.h"
#import "AlertDialog.h"


@interface LibraryPane()
@property(nonatomic,retain)StampLibrary* stampLibrary;
@property(nonatomic,retain)NSMutableArray* icons;
@property(nonatomic,retain)NSMutableArray* delButtons;
-(void)layoutIcons;
@end

@implementation LibraryPane
@synthesize stampLibrary,icons,delButtons;
@synthesize delegate;
@synthesize titleLabel,toolBar,editBar,cancelButton;
@synthesize editButton,doneButton,scrollView,contentView;

#pragma mark - private

-(void)iconTapped:(UIButton*)b {
    int idx = [icons indexOfObject:b];
    if (paneMode == Selecting) {
        UIImage* img = [stampLibrary getImageAt:idx];
        [delegate imageSelected:img];
        [self close];
    } else if (paneMode == Deleting) {
        [AlertDialog confirm:res(@"confirm")
                     message:res(@"confirmDelete") 
                        onOK:^{
                            [icons removeObjectAtIndex:idx];
                            [delButtons removeObjectAtIndex:idx];
                            [stampLibrary deleteImageAt:idx];
                            layoutCompleted = NO;
                            [self layoutIcons];
                        }];
        
    }
}


#pragma mark - layout

// アイコンを生成する

/* FIX_LOADING_SPEED */
-(void)loadIcons {
    if (!icons) {
        NSInteger c = [stampLibrary imageCount];
        self.icons = [NSMutableArray arrayWithCapacity:c];
        for (int i = 0; i < c; i++) {
            NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
            UIButton* b = [UIButton buttonWithType:UIButtonTypeCustom];
            [b eSize:LBR_ICON_WIDTH :LBR_ICON_HEIGHT];
            UIImage* img = [ImageUtil shrink:[stampLibrary getImageAt:i] 
                                      toSize:b.frame.size];
            [b setImage:img forState:UIControlStateNormal];
            b.backgroundColor = [UIColor whiteColor];
            [b addTarget:self action:@selector(iconTapped:) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:b];
            [icons addObject:b];
            [pool release];
        }
    }
}

// アイコンを並び替える
-(void)layoutIcons {
    if (icons) {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
        BOOL nowPortrait = [RootPane isPortrait];
        if (isPortrait != nowPortrait || !layoutCompleted) {
            int COLS = nowPortrait ? LBR_COLS_P : LBR_COLS_L;
            int IS = nowPortrait ? LBR_INSET_P : LBR_INSET_L;
            int M = nowPortrait ? LBR_ICON_MARGIN_P : LBR_ICON_MARGIN_L;
            int cnt = [icons count];
            for (int i = 0; i < cnt; i++) {
                int r = i / COLS;
                int c = i % COLS;
                int x = IS + c * (LBR_ICON_WIDTH + M);
                int y = r * (LBR_ICON_HEIGHT + M) + M;
                UIButton* b = [icons objectAtIndex:i];
                [b eMove:x :y];
            }
            int rows = cnt / COLS;
            if (cnt % COLS != 0) {
                rows ++;
            }
            CGFloat height = rows * (LBR_ICON_HEIGHT + M);
            [contentView eSize:scrollView.width :height];
            scrollView.contentSize = contentView.frame.size;
            isPortrait = nowPortrait;
            layoutCompleted = YES;
        }
        [pool release];
    }
}

#pragma mark - public
-(IBAction)close {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[RootPane instance]popPane];
    
}
-(IBAction)startEdit {
    toolBar.hidden = YES;
    editBar.hidden = NO;
    UIImage* delImg = [UIImage imageNamed:@"delete.png"];
    self.delButtons = [NSMutableArray arrayWithCapacity:[icons count]];
    for (UIButton* b in icons) {
        UIImageView* iv = [[UIImageView alloc]initWithImage:delImg];
        [iv eSize:15 :15];
        [b addSubview:iv];
        [iv eFitRight:NO];
        [delButtons addObject:iv];
    }
    paneMode = Deleting;
}
-(IBAction)endEdit {
    for (UIView* iv in delButtons) {
        [iv removeFromSuperview];
    }
    self.delButtons = nil;
    toolBar.hidden = NO;
    editBar.hidden = YES;
    paneMode = Selecting;
}

#pragma mark - rotate event
-(void)didRotate:(NSNotification*)note {
    [LibraryPane cancelPreviousPerformRequestsWithTarget:self selector:@selector(layoutIcons) object:nil];
    [self performSelector:@selector(layoutIcons) withObject:nil afterDelay:0.2];
}


#pragma mark - view event

-(void)viewWillAppear:(BOOL)animated {
    [self loadIcons];
    [self layoutIcons];
}





#pragma mark - object lifecycle

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
    self.stampLibrary = nil;
    self.icons = nil;
    
    self.titleLabel = nil;
    self.toolBar = nil;
    self.editBar = nil;
    self.cancelButton = nil;
    self.editButton = nil;
    self.doneButton = nil;
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    paneMode = Selecting;
    titleLabel.text = res(@"stampLibrary");
    cancelButton.title = res(@"cancel");
    editButton.title = res(@"edit");
    doneButton.title = res(@"done");
    editBar.hidden = YES;
    toolBar.hidden = NO;
    self.stampLibrary = [StampLibrary library];
    [[NSNotificationCenter defaultCenter] 
     addObserver:self
     selector:@selector(didRotate:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.stampLibrary = nil;
    self.icons = nil;
    [[NSNotificationCenter defaultCenter] 
     removeObserver:self];
    self.titleLabel = nil;
    self.toolBar = nil;
    self.editBar = nil;
    self.cancelButton = nil;
    self.editButton = nil;
    self.doneButton = nil;
    self.scrollView = nil;
    self.contentView = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ![RootPane isRotationLocked];
}

@end
