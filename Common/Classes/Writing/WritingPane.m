//
//  WritingPane.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/12.
//  Copyright 2011 SAT. All rights reserved.
//

#import "WritingPane.h"
#import "UIView_Effects.h"
#import "CALayer_Effects.h"
#import "RootPane.h"
#import "common.h"
#import "DrawMode.h"
#import "SelectMode.h"
#import "StampMode.h"
#import "MemoMode.h"
#import "EraseMode.h"
#import "UndoBuffer.h"
#import "PageMemo.h"
#import "Book.h"
#import "TouchPanGestureRecognizer.h"
#import "AttachmentPane.h"
#import "AlertDialog.h"
#import "NSString_Util.h"
#import "SettingPane.h"
#include "ZipArchive.h"
#include "ZipEntry.h"
#import "FileUtil.h"
#import "AppUtil.h"
#import "MosaicViewController.h"

// privateっぽいpropertyを実装するための細工
@interface WritingPane()
@property(nonatomic,retain)UITapGestureRecognizer* tapr;
@property(nonatomic,retain)UIPinchGestureRecognizer* pinchr;
@property(nonatomic,retain)TouchPanGestureRecognizer* panr;
@property(nonatomic,retain)UndoBuffer* undoBuffer;
@property(nonatomic,retain)PageMemo* pageMemo;
@property(nonatomic,retain)NSMutableDictionary* loadedModes;



@property (nonatomic, retain, readwrite) UIActionSheet *    actionSheet;
@property (nonatomic, retain, readwrite) UIAlertView *      alertView;


- (void)dismissActionsAndAlerts;




-(void)save;
-(void)merge;

@end


@implementation WritingPane
@synthesize canvas,layer;
@synthesize tapr, pinchr, panr;
@synthesize topBar, bottomBar;
@synthesize undoBuffer;
@synthesize pageMemo;
@synthesize delegate;
@synthesize inDrawing;
@synthesize imageView;
@synthesize loadedModes;
@synthesize initialImage;
@synthesize doneButton,doneButtonBase,showToolbarButton;
@synthesize settingButton,selectButton,stampButton;
@synthesize memoButton,pictureButton,undoButton;
@synthesize redoButton,drawButton,eraseButton,deleteButton;
@synthesize hideButton,undoButton2,contentView;




#pragma mark - 編集操作
// タブバーの選択状態を更新する
-(void)updateTabbarSelection {
    Class mc = [mode class];
    if (mc == [DrawMode class]) {
        topBar.selectedItem = nil;
        bottomBar.selectedItem = drawButton;
        
    } else if (mc == [EraseMode class]) {
        topBar.selectedItem = nil;
        bottomBar.selectedItem = eraseButton;
        
        
    } else if (mc == [MemoMode class]) {
        topBar.selectedItem = memoButton;
        bottomBar.selectedItem = nil;
        
    } else if (mc == [SelectMode class]) {
        topBar.selectedItem = selectButton;
        bottomBar.selectedItem = nil;
        
    } else if (mc == [StampMode class]) {
        topBar.selectedItem = stampButton;
        bottomBar.selectedItem = nil;
        
    } else {
        NSLog(@"unknown mode:%d");
    }
}

// モード
-(BOOL)isMode:(NSString*)modeName {
    NSString* curMode = mode ? NSStringFromClass([mode class]) : nil;
    return [modeName isEqualToString:curMode];
}


// モード変更
-(void)changeMode:(NSString*)modeName {  
    if ([self isMode:modeName]) {
        [mode modeAgain];
    } else {
        if (mode) {
            [mode modeUnselected];
            mode = nil;
        }
        mode = [loadedModes valueForKey:modeName];
        if (!mode) {
            if ([modeName isEqualToString:@"DrawMode"]) {
                mode = [[DrawMode alloc]init];
                
            } else if ([modeName isEqualToString:@"EraseMode"]) {
                mode = [[EraseMode alloc]init];
                
            } else if ([modeName isEqualToString:@"MemoMode"]) {
                mode = [[MemoMode alloc]initWithPageMemo:pageMemo];
                
            } else if ([modeName isEqualToString:@"SelectMode"]) {
                mode = [[SelectMode alloc]init];
                
            } else if ([modeName isEqualToString:@"StampMode"]) {
                mode = [[StampMode alloc]init];
                
            } else {
                NSLog(@"unknown mode:%@", modeName);
            }
            if (mode) {
                [loadedModes setObject:mode forKey:modeName];
                [mode release];
            }
            
        }
        if ([modeName eq:@"MemoMode"]) {
            [self undoEnable:NO];
        } else {
            [self undoEnable:YES];
        }
        if (mode) {
            [mode setWritingPane:self];
            [mode modeSelected];
        }
    }
}

// 添付画像
-(void)showAttachmentPane {
    AttachmentPane* p = [[AttachmentPane alloc]init];
    p.editMode = YES;
    p.pageMemo = pageMemo;
    [[RootPane instance]pushPane:p];
    [p release];
}

// 全削除
-(void)deleteAll {
    [AlertDialog confirm:res(@"confirm") 
                 message:res(@"confirmDelete") 
                    onOK:^{
                        [mode completeCurrent];
                        // 空白のUIImageを作る
                        UIGraphicsBeginImageContext(canvas.frame.size);
                        UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();

                        layer.contents = (id)img.CGImage;
                        
                        [undoBuffer push:img];
                    }];
}

-(void)showSetting {
    SettingPane* p = [[SettingPane alloc]init];
    p.pageMemo = pageMemo;
    [[RootPane instance]pushPane:p];
    [p release];
}

#pragma mark - 外部操作

-(void)hideToolbars:(BOOL)absolute {
    if (!topBar.hidden) {
        [topBar eHidetoTop];
        [doneButtonBase eHidetoTop];
        [bottomBar eHidetoBottom];
        if (absolute) {
            undoButton2.hidden = YES;
            showToolbarButton.hidden = YES;
        }
    }
}

-(IBAction)hideToolbars {
    [self hideToolbars:NO];
}
-(IBAction)showToolbars {
    if (topBar.hidden) {
        [topBar eShowFromTop];
        [doneButtonBase eShowFromTop];
        [bottomBar eShowFromBottom];
        undoButton2.hidden = NO;
        showToolbarButton.hidden = NO;
    }
}

// アンドゥ
-(void)undo {
    if ([undoBuffer canUndo]) {
        [mode completeCurrent];
        UIImage* img = [undoBuffer undo];
        layer.contents = (id)img.CGImage;
    }
}

-(void)redo {
    if ([undoBuffer canRedo]) {
        UIImage* img = [undoBuffer redo];
        layer.contents = (id)img.CGImage;
    }
}



-(void)undoEnable:(BOOL)enable {
    undoButton.enabled = enable;
    redoButton.enabled = enable;
    undoButton2.enabled = enable;
}


-(void)setBookPage:(NSObject<Viewable>*)b page:(NSInteger)p {
    book = b;
    page = p;
}

// 描画コンテキストを開始する
-(CGContextRef)beginDrawing {
    if (!inDrawing) {
        //UIGraphicsBeginImageContext(canvas.frame.size);
        UIGraphicsBeginImageContextWithOptions(canvas.frame.size, NO, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // アンドゥバッファの現在ポイントを描画する
        UIImage* img = (UIImage*)[undoBuffer current];
        if (img) {
            [img drawInRect:canvas.frame];
        }
        inDrawing = YES;
        return context;
    } else {
        return UIGraphicsGetCurrentContext();
    }
}
// 描画コンテキストを終了する
-(void)endDrawing {
    if (inDrawing) {
        UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
        if (img) {
            [undoBuffer push:img];
        }
        UIGraphicsEndImageContext();
        inDrawing = NO;
    }
}

-(void)save {
    if (pageMemo) {
        UIImage* img = [undoBuffer current];
        [pageMemo setMyWritingImage:img];
    }
    
}


-(void)merge {
    if (pageMemo) {
        
        UIImage *original = imageView.image;
        UIImage *new = (UIImage*)[undoBuffer current];
        
        

        CGSize rectSize = imageView.image.size;
        CGRect canvasRect = CGRectMake(0, 0, rectSize.width, rectSize.height);
        
        
        
        UIGraphicsBeginImageContext(rectSize);
        [original drawInRect:canvasRect];
        [new drawInRect:canvasRect];
        UIImage* merged = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

 
        NSString *fileName  = [(Book *)book getBookPagePath:page];

        
        [FileUtil rm:fileName];
        
        if ([fileName hasSuffix:@"png"]) {
            [UIImagePNGRepresentation(merged) writeToFile:fileName atomically:YES];
            [undoBuffer clear];

        } else {
            [UIImageJPEGRepresentation(merged, 1.0) writeToFile:fileName atomically:YES];
            [undoBuffer clear];

            
        }
                
    }
    
}



#pragma mark - イベント
-(void)layoutViews {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
//    [mode completeCurrent];
    BOOL nowPortrait = [RootPane isPortrait];
    if (!initialized || isPortrait != nowPortrait) {
        contentView.transform = CGAffineTransformIdentity;
        UIImage* bg = imageView.image;
//        if (!bg) {
//            bg = initialImage;
//        }
        CGSize sz = self.view.frame.size;
        CGFloat cw;
        CGFloat ch;
        if ([RootPane isPortrait]) {
            if (bg.size.width > bg.size.height) {
                cw = sz.width * 2;
                ch = sz.height;
            } else {
                cw = sz.width;
                ch = sz.height;
            }
        } else {
            if (bg.size.width > bg.size.height) {
                cw = sz.width;
                ch = sz.height;
            } else {
                cw = sz.width;
                ch = sz.height * 2;
            }
        }
        [contentView eMove:0 :0];
        [contentView eSize:cw :ch];
        [imageView eFittoSuperview];
        [canvas eFittoSuperview];
        isPortrait = nowPortrait;
    }
    [pool release];
}

-(void)didRotate:(NSNotification *)notification {
    [WritingPane cancelPreviousPerformRequestsWithTarget:self selector:@selector(layoutViews) object:nil];
    [self performSelector:@selector(layoutViews) withObject:nil afterDelay:0.2];
}

-(void) addMosaicImage:(UIImage *) img{
    [undoBuffer push:img];
    layer.contents = (id)img.CGImage;
    effectAdded = YES;
}

-(void) initialize {
    if (!initialized) {
        // 最初の一回だけ
        if ([book isKindOfClass:[Book class]]) {
            self.pageMemo = [[[PageMemo alloc]initWithBook:(Book*)book page:page]autorelease];
            imageView.image = [book getPageImage:page];
        }
        [self layoutViews];
        
        UIImage* img = pageMemo ? [pageMemo myWritingImage] : nil;
        if (img) {
            // 保存してある状態
            [undoBuffer push:img];
            layer.contents = (id)img.CGImage;
        } else {
            // 初期状態をpushしておく
            // 空白のUIImageを作る
            UIGraphicsBeginImageContext(canvas.frame.size);
            img = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [undoBuffer push:img];
        }
        if (pageMemo) {
            // ビューアからのメモ
            
        } else {
            // 画像補正からの落書き
            settingButton.enabled = NO;
            settingButton.image = nil;
            settingButton.title = nil;
            memoButton.enabled = NO;
            pictureButton.enabled = NO;
            imageView.image = initialImage;
        }
        initialized = YES;
    }
}

// 戻る（画像補正の時のみ）
-(IBAction)back {
    [mode modeUnselected];
    mode = nil;
    // 回転リスナを解除
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[RootPane instance]popPane];    
}

-(void)saveAsLayer {
    [mode modeUnselected];
    mode = nil;
    UIImage* img = (UIImage*)[undoBuffer current];
    if (delegate) {
        CGSize csz = canvas.frame.size;
        UIGraphicsBeginImageContext(csz);
        [imageView.image drawInRect:CGRectMake(0, 0, csz.width, csz.height)];
        [img drawInRect:CGRectMake(0, 0, csz.width, csz.height)];
        UIImage* img2 = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [delegate writingDone:img2];
    }
    [self save];
    // 回転リスナを解除
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[RootPane instance]popPane];
}



-(void)mergeLayers 
{
    Book *b = (Book *)book;
    if (!b.isImported) {
        [self saveAsLayer];
        return;
    } 
    [mode modeUnselected];
    mode = nil;

    [self merge];
    [pageMemo setMyWritingImage:nil];
    // 回転リスナを解除
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[RootPane instance]popPane];
}

-(void)openMosaic{
    if (!mosaic) {
        mosaic = [[MosaicViewController alloc] init];
        mosaic.delegate = self;
    }
    NSLog(@"imageView.image size 1: %f %f", imageView.image.size.width, imageView.image.size.height);
    
    UIImage *original = imageView.image;
    UIImage *new = [undoBuffer current];
    CGSize rectSize = imageView.image.size;
    CGRect canvasRect = CGRectMake(0, 0, rectSize.width, rectSize.height);
    
    
    UIGraphicsBeginImageContext(rectSize);
    [original drawInRect:canvasRect];
    [new drawInRect:canvasRect];
    UIImage* merged = UIGraphicsGetImageFromCurrentImageContext();
    
    NSLog(@"imageView.image size 1: %f %f", merged.size.width, merged.size.height);
    UIGraphicsEndImageContext();
    
    [mosaic useImage:merged];
}


-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item == settingButton) {
        [self save];
        [self showSetting];
        
    } else if (item == selectButton) {
        
        [self changeMode:@"SelectMode"];
    } else if (item == stampButton) {
        [self save];
        [self changeMode:@"StampMode"];
    } else if (item == memoButton) {
        
        [self changeMode:@"MemoMode"];
        
    } else if (item == pictureButton) {
        if (!otherEffects) {
            otherEffects = [[OtherEffectsPane alloc] init];
            otherEffects.writingPane = self;
        }
        [[self navigationController] pushViewController:otherEffects animated:YES];
    } else if (item == undoButton) {
        [self undo];
    } else if (item == redoButton) {
        [self redo];
    } else if (item == drawButton) {
        [self changeMode:@"DrawMode"];
        
    } else if (item == eraseButton) {
        [self changeMode:@"EraseMode"];
        
    } else if (item == deleteButton) {
        [self deleteAll];
        
    } else if (item == hideButton) {
        [self hideToolbars];
    }
    if (tabBar == topBar) {
        bottomBar.selectedItem = nil;
    } else {
        topBar.selectedItem = nil;
    }
    [self performSelector:@selector(updateTabbarSelection) withObject:nil afterDelay:0.1];
//    [self updateTabbarSelection];
}

#pragma mark - gestureイベント

-(void)restrictContentView {
    if (contentView.top > 0) {
        [contentView eFitTop:NO];
    } else if (contentView.bottom < self.view.height) {
        [contentView eFitBottom:NO];
    }
    if (contentView.left > 0) {
        [contentView eFitLeft:NO];
    } else if (contentView.right < self.view.width) {
        [contentView eFitRight:NO];
    }    
}

// 拡大縮小
-(void)pinched:(UIPinchGestureRecognizer*)gr {
    if (gr.state == UIGestureRecognizerStateBegan) {
        if (!scrolling) {
//            NSLog(@"zooming begin");
            zooming = YES;
            beginScale = lastScale ? lastScale : 1;
            zoomCenter = CGPointMake((self.view.center.x - contentView.left) / contentView.width, 
                                     (self.view.center.y - contentView.top) / contentView.height);
        }            
    } else if (gr.state == UIGestureRecognizerStateChanged) {
        if (zooming) {
//            NSLog(@"zooming change");
            CGFloat sc = gr.scale * beginScale;
            if (canvas.height * sc > self.view.height * 3) {
                sc = self.view.height * 3 / canvas.height;
            } else if (canvas.height * sc < self.view.height) {
                sc = self.view.height / canvas.height;
            }
            if (sc < 1) {
                sc = 1;
            }
            CGAffineTransform tr = CGAffineTransformMakeScale(sc, sc);
            contentView.layer.anchorPoint = zoomCenter;
            contentView.transform = tr;
            lastScale = sc;
            [self restrictContentView];
        }
        
    } else if (gr.state == UIGestureRecognizerStateEnded) {
//        NSLog(@"zooming end");
        zooming = NO;
    }
    
}

// 二本指でスクロール
-(void)dragged:(TouchPanGestureRecognizer*)gr {
    if (gr.touchState == TouchPanGestureRecognizerStateBegin) {
        scrolling = NO;
//        NSLog(@"touch begin");
    }
    if (gr.state == UIGestureRecognizerStateBegan) {
        if ([gr numberOfTouches] == 2) {
            if (!zooming) {
//                NSLog(@"scrolling begin");
                grabPoint = [gr locationInView:self.view];
                beginLocation = contentView.frame.origin;
                scrolling = YES;
            }
        }
    } else if (gr.state == UIGestureRecognizerStateChanged) {
        if (scrolling) {
//            NSLog(@"scrolling change");
            CGPoint p = [gr locationInView:self.view];
            [contentView eMove:p.x - grabPoint.x + beginLocation.x
                              :p.y - grabPoint.y + beginLocation.y];
            [self restrictContentView];
        }
    }
    if (!scrolling && !zooming) {
        //NSLog(@"%d/%d", gr.state, gr.touchState);
//        NSLog(@"mode dragged");
        [mode dragged:gr];
    }
}

-(void)tapped:(UITapGestureRecognizer*)gr {
    [mode tapped:gr];
}


#pragma mark - viewイベント
-(void)viewWillAppear:(BOOL)animated {
    if (pageMemo && ![pageMemo myWritingExists] && !effectAdded) {
        layer.contents = nil;
        [undoBuffer clear];
        // 空白のUIImageをpushしておく
        UIGraphicsBeginImageContext(canvas.frame.size);
        UIImage* empty = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [undoBuffer push:empty];

    }
    [self initialize];
    CGRect rc = [UIScreen mainScreen].bounds;
    if ([RootPane isPortrait]) {
        self.view.frame = rc;
    } else {
        self.view.frame = CGRectMake(0, 0, rc.size.height, rc.size.width);
    }
    
    
}


#pragma mark * Actions

@synthesize actionSheet = _actionSheet;
@synthesize alertView   = _alertView;

- (void)dismissActionsAndAlerts
{
    if (self.actionSheet != nil) {
        [self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:NO];
        assert(self.actionSheet == nil);
    }
    if ( (self.alertView != nil) && (self.alertView.numberOfButtons != 1) ) {
        [self.alertView dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:NO];
        assert(self.alertView == nil);
    }
}

- (void)showErrorMessage:(NSString *)message
// Shows an alert view containing the specified error message.
{
    assert(self.alertView == nil);
    self.alertView = [[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Drat!", nil] autorelease];
    assert(self.alertView != nil);
    
    self.alertView.cancelButtonIndex = 0;
    self.alertView.delegate = self;
    
    [self.alertView show];
}

enum {
    kActionSheetButtonIndexLayer  = 0,
    kActionSheetButtonIndexMerge   = 1,
    kActionSheetButtonIndexCancel = 2,
};

- (IBAction)doneSelect:(id)sender
{
#pragma unused(sender)
    Book *b = (Book *)book;
    if (b.isPDF) {
        self.actionSheet = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save As Layer", nil] autorelease];

    } else {
    
    self.actionSheet = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save As Layer", @"Merge Layers Permanently", nil] autorelease];
    }

    assert(self.actionSheet != nil);
    
    [self.actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
#pragma unused(actionSheet)
    assert(actionSheet == self.actionSheet);
    
    switch (buttonIndex) {
        case kActionSheetButtonIndexMerge: {
                        
            assert(self.alertView == nil);
            Book *b = (Book *)book;
            if (b.isImported) {
                 self.alertView = [[[UIAlertView alloc] initWithTitle:@"Merge Changes Permanently ?" message:@"Are you sure you want to overwrite the originals?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Merge", nil] autorelease];
            }else {
                 self.alertView = [[[UIAlertView alloc] initWithTitle:@"Apologies !!!" message:@"The Page you are trying to merge changes with is still not being imported! " delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save layer and try again later", nil] autorelease];
            }
           
            assert(self.alertView != nil);
            
            self.alertView.delegate = self;
            
            [self.alertView show];
            
        } break;
        case kActionSheetButtonIndexLayer: {
            [self saveAsLayer];
        } break;
        
        default:
            assert(NO);
        case kActionSheetButtonIndexCancel: {
            
        } break;
    }
    
    self.actionSheet = nil;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    assert(alertView == self.alertView);
#pragma unused(alertView)
    
    if (buttonIndex != self.alertView.cancelButtonIndex) {
        [self mergeLayers];
    }
    
    self.alertView = nil;
}


#pragma mark - Object lifecycle

-(id)init{
    self = [super init];
    if (self) {
        self.undoBuffer = [[[UndoBuffer alloc]initWithLimit:10]autorelease];
        self.loadedModes = [NSMutableDictionary dictionary];
    }
    return self;
}




- (void)dealloc
{
    NSLog(@"%s", __func__);
    self.tapr = nil;
    self.pinchr = nil;
    self.panr = nil;
    self.undoBuffer = nil;
    self.loadedModes = nil;
    
    self.topBar = nil;
    self.bottomBar = nil;
    self.doneButton = nil;
    self.doneButtonBase = nil;
    self.showToolbarButton = nil;
    self.settingButton = nil;
    self.selectButton = nil;
    self.stampButton = nil;
    self.memoButton = nil;
    self.pictureButton = nil;
    self.undoButton2 = nil;
    self.undoButton = nil;
    self.redoButton = nil;
    self.drawButton = nil;
    self.eraseButton = nil;
    self.deleteButton = nil;
    self.hideButton = nil;
    self.contentView = nil;
    self.imageView = nil;
    self.canvas = nil;
    self.initialImage = nil;
    
    
    self.actionSheet = nil;
    self.alertView = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    doneButton.layer.cornerRadius = 5;
    doneButton.layer.masksToBounds = YES;
    
    [imageView setContentMode:UIViewContentModeScaleToFill];
    
    self.pinchr = [[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinched:)]autorelease];
    self.tapr = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)]autorelease];
    self.panr = [[[TouchPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragged:)]autorelease];
    [panr setTouchTarget:self selector:@selector(dragged:)];
    panr.delaysTouchesBegan = NO;
    [canvas addGestureRecognizer:pinchr];
    [canvas addGestureRecognizer:tapr];
    [canvas addGestureRecognizer:panr];
    
    layer = canvas.layer;
    [[NSNotificationCenter defaultCenter] 
     addObserver:self
     selector:@selector(didRotate:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
    
    
    [self changeMode:@"DrawMode"];
    [self updateTabbarSelection];
    
    [doneButton setTitle:res(@"done") forState:UIControlStateNormal];
}

- (void)viewDidUnload
{
    NSLog(@"%s", __func__);
    [super viewDidUnload];
    [self changeMode:nil];
    self.tapr = nil;
    self.pinchr = nil;
    self.panr = nil;

    self.topBar = nil;
    self.bottomBar = nil;
    self.doneButton = nil;
    self.doneButtonBase = nil;
    self.showToolbarButton = nil;
    self.settingButton = nil;
    self.selectButton = nil;
    self.stampButton = nil;
    self.memoButton = nil;
    self.pictureButton = nil;
    self.undoButton2 = nil;
    self.undoButton = nil;
    self.redoButton = nil;
    self.drawButton = nil;
    self.eraseButton = nil;
    self.deleteButton = nil;
    self.hideButton = nil;
    self.contentView = nil;
    self.imageView = nil;
    self.canvas = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ![RootPane isRotationLocked];
}

@end
