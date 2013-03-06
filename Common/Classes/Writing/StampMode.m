//
//  StampMode.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/12.
//  Copyright 2011 SAT. All rights reserved.
//

#import "StampMode.h"
#import "UIView_Effects.h"
#import "ActionDialog.h"
#import "ImagePickDialog.h"
#import "common.h"
#import "StampLibrary.h"
#import "LibraryPane.h"
#import "RootPane.h"


@interface StampMode()
@property(nonatomic,retain)ImagePickDialog* imagePicker;
@property(nonatomic,retain)UIImage* image;
@end

@implementation StampMode
@synthesize imagePicker;
@synthesize image;
#pragma mark - private

// スタンプ実行
-(void)commitStamp:(CGFloat)x :(CGFloat)y :(CGFloat)width :(CGFloat)height {
    if (image) {
        if (!pane.inDrawing) {
            context = [pane beginDrawing];
        }
        CGRect rc = CGRectMake(x, y, width, height);
        [image drawInRect:rc];
        UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
        layer.contents = (id)img.CGImage;
        [pane endDrawing];
        context = NULL;
    }
}

// 選択エリアを作成する
-(void)createArea:(CGPoint) p {
    areaView = [[[SelectAreaView alloc]init]autorelease];
    if (image) {
        areaView.image = image;
        areaView.moveHandle.hidden = YES;
        CGFloat w, h;
        if (image.size.width > image.size.height) {
            h = STP_DEFAULT_SIZE;
            w = h * image.size.width / image.size.height;
        } else {
            w = STP_DEFAULT_SIZE;
            h = w * image.size.height / image.size.width;
        }
        [areaView eSize:w :h];
    } else {
        [areaView eSize:STP_DEFAULT_SIZE :STP_DEFAULT_SIZE];
    }
    [areaView setCenter:p];
    [canvas addSubview:areaView];
}

// 選択エリアが消える瞬間にlayerに書きこむ
-(void)removeArea {
    if (areaView) {
        [self commitStamp:areaView.left :areaView.top :areaView.width :areaView.height];
        [areaView removeFromSuperview];
        areaView = nil;
    }
}

#pragma mark - イベント内部処理
-(void)touchBegin:(CGPoint) p {
    beginPoint = p;
    if (procMode == StampChangable) {
        if (fabs(areaView.right - p.x) < SENSE_RADIUS 
            && fabs(areaView.bottom - p.y) < SENSE_RADIUS) {
            // 右下あたりの場合は変形
            procMode = StampChanging;
        } else if ([areaView eContains:p]) {
            // 画像上であれば移動
            procMode = StampMoving;
        } else {
            // それ以外をタップしたらcommit
            [self removeArea];
            procMode = StampNop;
        }
    } else if (procMode == SelectChangable) {
        if (fabs(areaView.right - p.x) < SENSE_RADIUS 
            && fabs(areaView.bottom - p.y) < SENSE_RADIUS) {
            // 右下あたりの場合は変形
            procMode = SelectChanging;
        } else if (fabs(areaView.left - p.x) < SENSE_RADIUS
                   && fabs(areaView.top - p.y) < SENSE_RADIUS) {
            // 左上は移動
            procMode = SelectMoving;
        } else {
            // それ以外をタップしたらやりなおし
            [self removeArea];
            procMode = SelectNop;
        }
    }

}

-(void)begin:(CGPoint)p {
    if (procMode == Stampable) {
        if (image) {
            [self removeArea];
            [self createArea:p];
            procMode = StampMoving;
        }
    } else if (procMode == Selectable) {
        [self createArea:p];
        [areaView eMove:beginPoint];
        [areaView eSetRight:p.x bottom:p.y minSize:AREA_MINSIZE];
        procMode = SelectChanging;
    }
}

-(void)change:(CGPoint)p {
    if (procMode == StampMoving) {
        // 移動
        [areaView eCenter:p.x :p.y];
    } else if (procMode == StampChanging) {
        // 変形
        [areaView eSetRight:p.x + AREA_MARGIN bottom:p.y + AREA_MARGIN minSize:AREA_MINSIZE];
        [areaView setNeedsLayout];
        [areaView setNeedsDisplay];
    } else if (procMode == SelectMoving) {
        // 移動
        [areaView eMove:p.x - AREA_MARGIN :p.y - AREA_MARGIN];
        
    } else if (procMode == SelectChanging) {
        // 選択範囲の変形中
        [areaView eSetRight:p.x + AREA_MARGIN bottom:p.y + AREA_MARGIN minSize:AREA_MINSIZE];
        [areaView setNeedsLayout];
        [areaView setNeedsDisplay];
    }
}

-(void)end:(CGPoint)p {
    if (procMode == Stampable) {
        if (image) {
            [self removeArea];
            [self createArea:p];
            procMode = StampChangable;
        }
    } else if (procMode == StampMoving) {
        procMode = StampChangable;
    } else if (procMode == StampChanging) {
        procMode = StampChangable;
    } else if (procMode == StampNop) {
        procMode = Stampable;
    } else if (procMode == SelectMoving) {
        procMode = SelectChangable;
    } else if (procMode == SelectChanging) {
        procMode = SelectChangable;
    } else if (procMode == SelectNop) {
        procMode = Selectable;
    }
}

#pragma mark - 画面遷移




-(void)endSelectingMode {
    [topBar removeFromSuperview];
    topBar = nil;
    [bottomBar removeFromSuperview];
    bottomBar = nil;
    [pane showToolbars];
    [pane.imageView eFadein];
    [self removeArea];
    procMode = Stampable;
}


-(UIBarButtonItem*)createFlex {
    return [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]autorelease];
}

-(void)saveSelectedArea {
    // 選択範囲のimageを切り取る
    CGImageRef allImg = (CGImageRef)layer.contents;
    CGImageRef clipImg = CGImageCreateWithImageInRect(allImg, areaView.frame);
    UIImage* img = [UIImage imageWithCGImage:clipImg];
    CGImageRelease(clipImg);

    StampLibrary* sl = [StampLibrary library];
    [sl addImage:img];
    
    [self endSelectingMode];
}

-(void)startSelectingMode {
    [pane hideToolbars:YES];
    [pane.imageView eFadeout];
    CGRect barRect = CGRectMake(0, 0, 100, 40);
    // 上側のツールバー
    topBar = [[[UIToolbar alloc]initWithFrame:barRect]autorelease];
    NSString* titleText = NSLocalizedString(@"selectAreaToLibrary", nil);
    CGRect rc;
    UIFont* font = [UIFont boldSystemFontOfSize:14];
    rc.size = [titleText sizeWithFont:font];
    UILabel* tl = [[[UILabel alloc]initWithFrame:rc]autorelease];
    tl.backgroundColor = [UIColor clearColor];
    tl.textAlignment = UITextAlignmentCenter;
    tl.textColor = [UIColor whiteColor];
    tl.shadowColor = [UIColor blackColor];
    tl.shadowOffset = CGSizeMake(0, -1);
    tl.font = font;
    tl.text = NSLocalizedString(@"selectAreaToLibrary", nil);
    UIBarButtonItem* title = [[[UIBarButtonItem alloc]
                               initWithCustomView:tl]autorelease];
    [topBar setItems:[NSArray arrayWithObjects:[self createFlex],
                      title,
                      [self createFlex], nil]];
    topBar.autoresizingMask = UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleBottomMargin;
    [pane.view addSubview:topBar];
    [topBar eFitTop:YES];
    
    // 下側のツールバー
    bottomBar = [[[UIToolbar alloc]initWithFrame:barRect]autorelease];
    UIBarButtonItem* cancel = [[UIBarButtonItem alloc]
                               initWithTitle:NSLocalizedString(@"cancel", nil)
                               style:UIBarButtonItemStyleBordered
                               target:self
                               action:@selector(endSelectingMode)];
    UIBarButtonItem* done = [[UIBarButtonItem alloc]
                             initWithTitle:NSLocalizedString(@"save", nil)
                             style:UIBarButtonItemStyleDone
                             target:self
                             action:@selector(saveSelectedArea)];
    [bottomBar setItems:[NSArray 
                         arrayWithObjects:[self createFlex],
                         cancel, 
                         done, 
                         [self createFlex], nil]];
    bottomBar.autoresizingMask = UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleTopMargin;
    [pane.view addSubview:bottomBar];
    [bottomBar eFitBottom:YES];
}

-(void)imageSelected:(UIImage *)img {
    self.image = img;
}

-(void)showLibrary {
    LibraryPane* p = [[LibraryPane alloc]init];
    p.delegate = self;
    [[RootPane instance]pushPane:p];
    [p release];
}

-(void)showCamera {
    self.imagePicker = [ImagePickDialog 
                        showCameraPopover:^(UIImage* img) {
                            self.image = img;
                        }
                        fromRect:pane.topBar.frame
                        inView:pane.view];
    
}

-(void)showAlbum {
    self.imagePicker = [ImagePickDialog 
                        showPopover:^(UIImage* img) {
                            self.image = img;
                        }
                        fromRect:pane.topBar.frame
                        inView:pane.view];
}

-(void)showMenu {
    [self removeArea];
    NSString* dtitle = NSLocalizedString(@"addToLibrary", nil);
    NSArray* buttons = [NSArray arrayWithObjects:NSLocalizedString(@"selectByLibrary", nil),
                        NSLocalizedString(@"selectByCamera", nil),
                        NSLocalizedString(@"selectByAlbum", nil),
                        nil];
    ActionDialog* ad = [[ActionDialog alloc]
                        initWithTitle:@""
                        callback:^(NSInteger idx) {
                            if (idx == 0) {
                                self.image = nil;
                                [self startSelectingMode];
                                procMode = Selectable;
                            } else if (idx == 1) {
                                self.image = nil;
                                procMode = Stampable;
                                [self showLibrary];
                            } else if (idx == 2) {
                                self.image = nil;
                                procMode = Stampable;
                                [self showCamera];
                            } else if (idx == 3) {
                                self.image = nil;
                                procMode = Stampable;
                                [self showAlbum];
                            }
                        }
                        cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                        destructiveButtonTitle:dtitle
                        otherButtonTitles:buttons];
    [ad showFromTabBar:pane.bottomBar];
    [ad release];
}


#pragma mark - オーバーライド
-(void)completeCurrent {
    [self removeArea];
    procMode = Stampable;
}

-(void)dragged:(TouchPanGestureRecognizer *)gr {
    CGPoint p = [gr locationInView:canvas];
    if (gr.touchState == TouchPanGestureRecognizerStateBegin) {
        [self touchBegin:p];
    } else if (gr.state == UIGestureRecognizerStateBegan) {
        [self begin:p];
    } else if (gr.state == UIGestureRecognizerStateChanged) {
        [self change:p];
    } else if (gr.state == UIGestureRecognizerStateEnded
               || gr.state == UIGestureRecognizerStateCancelled
               || gr.state == UIGestureRecognizerStateFailed
               || gr.touchState == TouchPanGestureRecognizerStateEnd) {
        [self end:p];
    }
}

-(void)modeSelected {
    procMode = Stampable;
    [self showMenu];
}

-(void)modeAgain {
    [self removeArea];
    procMode = Stampable;
    [self showMenu];
}

-(void)modeUnselected {
    [self removeArea];
}


#pragma mark - object lifecycle

-(void)dealloc {
    [self removeArea];
    [super dealloc];
}



@end
