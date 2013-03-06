//
//  TrimPane.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/07/27.
//  Copyright 2011 SAT. All rights reserved.
//

#import "TrimPane.h"
#import "AlertDialog.h"
#import "ImagePickDialog.h"
#import "RootPane.h"
#import "ImageUtil.h"
#import "common.h"
#import "AppUtil.h"
#import "UIView_Effects.h"
#import "CALayer_Effects.h"

@interface TrimPane()
@property(nonatomic,retain)LoadingView* loadingView;
@end


@implementation TrimPane
@synthesize delegate;
@synthesize item1,item2,item4,item5,item6;
@synthesize loadingView;
@synthesize nw,ne,sw,se,reflectionButton;
@synthesize trimmingView,canvas,scrollView;
@synthesize frameView,contrastSlider,resolutionSlider;
@synthesize monoButton,bwButton,eventView,contrastTitleLabel;
@synthesize contrastLabel,resolutionLabel,resolutionTitleLabel;


#pragma mark - TrimPaneとしての機能


// ボタンの初期位置
- (void)autoLayoutButtons {
    [ne eFitTop:NO];
    [ne eFitRight:NO];
    
    [nw eFitTop:NO];
    [nw eFitLeft:NO];
    
    [se eFitBottom:NO];
    [se eFitRight:NO];
    
    [sw eFitBottom:NO];
    [sw eFitLeft:NO];
}

// 枠を検出してボタンをレイアウトする
- (void)detectFrames {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
    CGPoint points[4];
    if ([ImageUtil findMaxSquare:image result:points]) {
        //CGSize cs = canvas.frame.size;
        CGFloat cw = canvas.width;
        CGFloat ch = canvas.height;
        
        // ne
        if (points[0].x < 0.5) {
            points[0].x = 1;
        } else if (points[0].x > 1) {
            points[0].x = 1;
        }
        if (points[0].y > 0.5) {
            points[0].y = 0;
        } else if (points[0].y < 0) {
            points[0].y = 0;
        }
        [ne eMove:points[0].x * cw - BUTTON_SIZE :points[0].y * ch];
//        ne.frame = CGRectMake(points[0].x * cs.width,
//                              points[0].y * cs.height, 
//                              BUTTON_SIZE, BUTTON_SIZE);
        // se
        if (points[1].x < 0.5) {
            points[1].x = 1;
        } else if (points[1].x > 1) {
            points[1].x = 1;
        }
        if (points[1].y < 0.5) {
            points[1].y = 1;
        } else if (points[1].y > 1) {
            points[1].y = 1;
        }
        [se eMove:points[1].x * cw - BUTTON_SIZE :points[1].y * ch - BUTTON_SIZE];
//        
//        se.frame = CGRectMake(points[1].x * cs.width,
//                              points[1].y * cs.height, 
//                              BUTTON_SIZE, BUTTON_SIZE);
        // sw
        if (points[2].x > 0.5) {
            points[2].x = 0;
        } else if (points[2].x < 0) {
            points[2].x = 0;
        }
        if (points[2].y < 0.5) {
            points[2].y = 1;
        } else if (points[2].y > 1) {
            points[2].y = 1;
        }
        [sw eMove:points[2].x * cw :points[2].y * ch - BUTTON_SIZE];
//        sw.frame = CGRectMake(points[2].x * cs.width,
//                              points[2].y * cs.height, 
//                              BUTTON_SIZE, BUTTON_SIZE);
        // nw
        if (points[3].x > 0.5) {
            points[3].x = 0;
        } else if (points[3].x < 0) {
            points[3].x = 0;
        }
        if (points[3].y > 0.5) {
            points[3].y = 0;
        } else if (points[3].y < 0) {
            points[3].y = 0;
        }
        [nw eMove:points[3].x * cw :points[3].y * ch];
//        nw.frame = CGRectMake(points[3].x * cs.width,
//                              points[3].y * cs.height, 
//                              BUTTON_SIZE, BUTTON_SIZE);
        [frameView setNeedsDisplay];
    }
    [loadingView dismiss];
    self.loadingView = nil;
    [pool release];
}

- (void) layoutViews:(UIImage*)img {
    BOOL isPortrait = [RootPane isPortrait];
    BOOL imgWide = (img.size.width > img.size.height);
    
    if (isPortrait && imgWide) {
        [canvas eSize:scrollView.width * 2 :scrollView.height];
    } else if (isPortrait && !imgWide) {
        [canvas eFittoSuperview];
    } else if (!isPortrait && imgWide) {
        [canvas eFittoSuperview];
    } else { // !isPortrait && !imgWide
        [canvas eSize:scrollView.width :scrollView.height * 2];
    }
    [canvas eMove:0 :0];
    [frameView eSameSize:canvas];
    [frameView eMove:0 :0];
    
    [bgLayer eFittoSuperlayer];
    [imageLayer eFittoSuperlayer];
    
    scrollView.contentSize = canvas.frame.size;
    scrollView.contentOffset = CGPointMake(0, 0);
}

// 画像を読み込む
- (void) setImage:(UIImage*)img {
    [image release];
    image = [img retain];
}


#pragma mark - 補正画面

- (void)updateLabels {
    contrastLabel.text = [NSString stringWithFormat:@"%0.2f", contrastSlider.value];
    CGFloat v = resolutionSlider.value;
    CGImageRef imgRef = image.CGImage;
    NSInteger w = CGImageGetWidth(imgRef) * v;
    NSInteger h = CGImageGetHeight(imgRef) * v;
    resolutionLabel.text = [NSString stringWithFormat:@"%d x %d", w, h];
}

- (void)showTrimmingView {
    [self updateLabels];
    trimmingView.alpha = 0;
    trimmingView.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        trimmingView.alpha = 1;
    }];

}


- (void)hideTrimmingView {
    [UIView animateWithDuration:0.5
                     animations:^{
                         trimmingView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         trimmingView.hidden = YES;
                     }];

}

#pragma mark - 画像変換


- (UIImage*)grayscale:(UIImage*)uimg {
    return [ImageUtil grayscale:uimg];}

// コントラスト設定
-(UIImage*)contrast:(UIImage*)uimg value:(float)value {
    if (!uimg) {
        return nil;
    }
    CGImageRef img = uimg.CGImage;
    CGDataProviderRef provider = CGImageGetDataProvider(img);
    CFDataRef dataref = CGDataProviderCopyData(provider);
    
    // ビットマップの処理
    UInt8 *data=(UInt8 *)CFDataGetBytePtr(dataref); 
    int length=CFDataGetLength(dataref); 
    for(int index=0;index <length - 3;index+=3) {
        
        int alphaCount = data[index+0];
        int redCount = data[index+1];
        int greenCount = data[index+2];
        int blueCount = data[index+3];
        
        alphaCount = ((alphaCount-128)*value ) + 128;
        if (alphaCount < 0) {
            alphaCount = 0; 
            if (alphaCount>255) {
                alphaCount =255;  
            }
        }
        data[index+0] = (Byte) alphaCount;
        
        redCount = ((redCount-128)*value ) + 128;
        if (redCount < 0) {
            redCount = 0; 
            if (redCount>255) {
                redCount =255;
            }
        }
        data[index+1] = (Byte) redCount;
        
        greenCount = ((greenCount-128)*value ) + 128;
        if (greenCount < 0) {
            greenCount = 0; 
            if (greenCount>255) {
                greenCount =255;
            }
        }
        data[index+2] = (Byte) greenCount;
        
        blueCount = ((blueCount-128)*value ) + 128;
        if (blueCount < 0) {
            blueCount = 0; 
            if (blueCount>255){ 
                blueCount =255;
            }
        }
        
        data[index+3] = (Byte) blueCount;       
    }
    // 元画像の情報
    size_t width=CGImageGetWidth(img);
    size_t height=CGImageGetHeight(img);
    size_t bitsPerComponent=CGImageGetBitsPerComponent(img);
    size_t bitsPerPixel=CGImageGetBitsPerPixel(img);
    size_t bytesPerRow=CGImageGetBytesPerRow(img);
    CGColorSpaceRef colorspace=CGImageGetColorSpace(img);
    CGBitmapInfo bitmapInfo=CGImageGetBitmapInfo(img);
    
    
    // 新しい画像を生成
    CFDataRef newData=CFDataCreate(NULL,data,length);
    CGDataProviderRef newProvider=CGDataProviderCreateWithCFData(newData);
    CGImageRef newImg=CGImageCreate(width, height, bitsPerComponent, 
                                    bitsPerPixel, bytesPerRow, colorspace,
                                    bitmapInfo, newProvider, NULL, true,
                                    kCGRenderingIntentDefault);
    
    // 返すオブジェクト
    CFRelease(dataref);
    CGDataProviderRelease(newProvider);
    CFRelease(newData);
    CGColorSpaceRelease(colorspace);
    UIImage* ret = [UIImage imageWithCGImage: newImg];
    CGImageRelease(newImg);
    return ret;
}

// 解像度を変更する
- (UIImage*) resolution:(UIImage*)img value:(CGFloat)value {
    if (!img) {
        return nil;
    }
    CGSize size = CGSizeMake(img.size.width * value, img.size.height * value);
    return [ImageUtil shrink:img toSize:size];
}

// 白背景にする
- (UIImage*) whiteBack:(UIImage*)img {
    if (!img) {
        return nil;
    }
    UIGraphicsBeginImageContext(CGSizeMake(img.size.width, img.size.height));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, img.size.width, img.size.height));
    [img drawInRect:CGRectMake(0, 0, img.size.width, img.size.height)];
    UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();  
    
    UIGraphicsEndImageContext();
    return ret;
}

// 回転する
- (UIImage*) rotateImage:(UIImage*)img {
    if (!img) {
        return nil;
    }
    CGImageRef imgRef = [img CGImage];
    CGContextRef context;
    
    switch (rotationAngle % 4) {
        case 1:
            UIGraphicsBeginImageContext(CGSizeMake(img.size.height, img.size.width));
            context = UIGraphicsGetCurrentContext();
            CGContextTranslateCTM(context, img.size.height, img.size.width);
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextRotateCTM(context, M_PI_2);
            break;
        case 2:
            UIGraphicsBeginImageContext(CGSizeMake(img.size.width, img.size.height));
            context = UIGraphicsGetCurrentContext();
            CGContextTranslateCTM(context, img.size.width, 0);
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextRotateCTM(context, -M_PI);
            break;
        case 3:
            UIGraphicsBeginImageContext(CGSizeMake(img.size.height, img.size.width));
            context = UIGraphicsGetCurrentContext();
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextRotateCTM(context, -M_PI_2);
            break;
        default:
            NSLog(@"you can select an angle of 90, 180, 270");
            return nil;
    }  
    
    CGContextDrawImage(context, CGRectMake(0, 0, img.size.width, img.size.height), imgRef);
    UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();  
    
    UIGraphicsEndImageContext();
    return ret;
}

// canvas上での中心座標を返す
-(CGPoint)buttonCenterOnCanvas:(UIButton*)b {
    return b.frame.origin;
}

-(UIImage*)clip:(UIImage*)img {
    CGFloat magx = img.size.width / canvas.frame.size.width;
    CGFloat magy = img.size.height / canvas.frame.size.height;
    
    CGPoint nwp = CGPointMake(nw.left * magx, nw.top * magy);
    CGPoint swp = CGPointMake(sw.left * magx, sw.bottom * magy);
    CGPoint sep = CGPointMake(se.right * magx, se.bottom * magy);
    CGPoint nep = CGPointMake(ne.right * magx, ne.top * magy);
    return [ImageUtil homography:img nw:nwp ne:nep sw:swp se:sep];
}

// 画像に補正を入れる
-(UIImage*) makeUpdatedImage {
    // コントラスト
    UIImage* newImg = [self contrast:image value:contrastSlider.value];
    // 白黒
    if (monoButton.selected) {
        newImg = [self grayscale:newImg];
    }
    // 白背景
    if (bwButton.selected) {
        newImg = [self whiteBack:newImg];
    }
    // 回転
    if (rotationAngle % 4 != 0) {
        newImg = [self rotateImage:newImg];
    }
    // 解像度
    newImg = [self resolution:newImg value:resolutionSlider.value];
    return newImg;
}


// 決定、画面に反映
-(IBAction) updateImage:(UIButton*)sender {
    [self hideTrimmingView];
    UIImage* uimg = [self makeUpdatedImage];
    imageLayer.contents = (id)uimg.CGImage;
    [self layoutViews:uimg];
}


#pragma mark - イベント
- (void)writingDone:(UIImage *)img {
    [self setImage:img];
}


// 補正完了
- (void) save {
    UIImage* img = [self makeUpdatedImage];
    // 切り抜き
    img = [self clip:img];
    
    if (!img) {
        [AlertDialog alert:NSLocalizedString(@"error", nil)
                   message:NSLocalizedString(@"compensationError", nil)
                      onOK:nil];
        return;
    }
    [[RootPane instance]popPane];
    [delegate imageSaved:img];
}

// 回転する
- (void) rotate: (NSInteger) angle {
    NSLog(@"%@", canvas);
    CATransform3D tr = canvas.layer.transform;
    tr = CATransform3DRotate(tr, angle * M_PI_2, 0, 0, 1);
    canvas.layer.transform = tr;
    [canvas eMove:0 :0];
    [frameView eSameSize:canvas];
    [frameView eMove:0 :0];


    CGFloat w = frameView.width;
    CGFloat h = frameView.height;
    if (angle == 1) {
        // 右回転
        CGPoint wk = CGPointMake(ne.left, ne.bottom);
        // ne <- nw
        [ne eMove:w - nw.bottom :nw.left];
        // nw <- sw
        [nw eMove:w - sw.bottom :sw.left];
        // sw <- se
        [sw eMove:w - se.bottom :se.left];
        // se <- ne
        [se eMove:w - wk.y :wk.x];
    } else {
        // 左回転
        CGPoint wk = CGPointMake(ne.right, ne.top);
        // ne <- se
        [ne eMove:se.top :h - se.right];
        // se <- sw
        [se eMove:sw.top :h - sw.right];
        // sw <- nw
        [sw eMove:nw.top :h - nw.right];
        // nw <- ne
        [nw eMove:wk.y :h - wk.x];
    }
    [frameView setNeedsDisplay];
    scrollView.contentOffset = CGPointMake(0, 0);
    scrollView.contentSize = canvas.frame.size;
}



// タブバーのイベント
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    tabBar.selectedItem = nil;
    switch (item.tag) {
        case 1: // 右回転
            [self rotate:1];
            rotationAngle --;
            if (rotationAngle < 0) {
                rotationAngle += 4;
            }
            break;
            
        case 2: // 左回転
            [self rotate:-1];
            rotationAngle ++;
            if (rotationAngle > 4) {
                rotationAngle -= 4;
            }
            break;
                        
        case 4: // 再撮影
            if (ipd) {
                [ipd dismiss];
                [ipd release];
                ipd = nil;
            } else {
                ipd = [[ImagePickDialog showCameraPopover:^(UIImage* img){
                    [self setImage:img];
                    imageLayer.contents = (id)img.CGImage;
                }
                                           fromBarButton:nil
                                                  inView:self.view]retain];
            }
            
            break;
            
        case 5: // 調整
            if (trimmingView.hidden) {
                [self showTrimmingView];
            } else {
                [self hideTrimmingView];
            }
            
        
            break;
            
        case 6: // 枠検出
            
            if (!loadingView) {
                self.loadingView = [LoadingView show:nil];
                [NSThread detachNewThreadSelector:@selector(detectFrames) toTarget:self withObject:nil];
            }
            break;
    }
}

#pragma mark - トリミング範囲

// ボタンのドラッグ開始: scrollViewのスクロールをできなくしてPanGestureが届くようにする
-(void) startDragPoint:(UIButton*)b {
    if (!draggingButton) {
        CGRect rc = canvas.frame;
        CGRect frc = frameView.frame;
        CGPoint ofs = scrollView.contentOffset;
        rc.origin.x -= ofs.x;
        rc.origin.y -= ofs.y;
        frc.origin.x -= ofs.x;
        frc.origin.y -= ofs.y;
        canvas.frame = rc;
        frameView.frame = frc;
        scrollView.contentSize = scrollView.frame.size;
        draggingButton = b;
    }
}
// ドラッグ終了: scrollViewを解放する
-(void) endDragPoint {
    if (draggingButton) {
        CGRect rc = canvas.frame;
        CGRect frc = frameView.frame;
        // contentOffsetを復元する
        CGPoint ofs = CGPointMake(-frc.origin.x, -frc.origin.y);
        // canvas, frameViewの位置を復元する
        rc.origin.x += ofs.x;
        rc.origin.y += ofs.y;
        frc.origin.x = 0;
        frc.origin.y = 0;
        canvas.frame = rc;
        frameView.frame = frc;
        
        scrollView.contentSize = frc.size;
        scrollView.contentOffset = ofs;
        draggingButton = nil;
    }
}

// 中心位置をポイントにあわせる
-(void)move:(CGPoint)p main:(UIView*)main subx:(UIView*)subx suby:(UIView*)suby {
    CGRect r = main.frame;
    r.origin.x = p.x - r.size.width / 2;
    r.origin.y = p.y - r.size.height / 2;
    main.frame = r;
    
    CGRect rsx = subx.frame;
    rsx.origin.x = r.origin.x;
    subx.frame = rsx;
    
    CGRect rsy = suby.frame;
    rsy.origin.y = r.origin.y;
    suby.frame = rsy;
}

- (CGPoint)pointInFrame:(CGPoint)p {
    CGRect fr = frameView.frame;
    if (p.x  < BUTTON_SIZE / 2) {
        p.x = BUTTON_SIZE / 2;
    } else if (p.x > fr.size.width - BUTTON_SIZE / 2) {
        p.x = fr.size.width - BUTTON_SIZE / 2;
    }
    
    if (p.y < BUTTON_SIZE / 2) {
        p.y = BUTTON_SIZE / 2;
    } else if (p.y > fr.size.height - BUTTON_SIZE / 2) {
        p.y = fr.size.height - BUTTON_SIZE / 2;
    }
    return p;
}

// ドラッグ
-(void)buttonDragged:(UIPanGestureRecognizer*)gr {
    if (draggingButton) {
        if (gr.state == UIGestureRecognizerStateChanged) {
            CGPoint p = [gr locationInView:frameView];
            CGRect fr = frameView.frame;
            CGPoint center = CGPointMake(fr.size.width / 2, fr.size.height / 2);
            
            if (draggingButton == ne) {
                if (p.x > center.x && p.y < center.y) {
                    [draggingButton setCenter:[self pointInFrame:p]];
                }
            } else if (draggingButton == nw) {
                if (p.x < center.x && p.y < center.y) {
                    [draggingButton setCenter:[self pointInFrame:p]];
                }
            } else if (draggingButton == se) {
                if (p.x > center.x && p.y > center.y) {
                    [draggingButton setCenter:[self pointInFrame:p]];
                }
            } else if (draggingButton == sw) {
                if (p.x < center.x && p.y > center.y) {
                    [draggingButton setCenter:[self pointInFrame:p]];
                }
            }
            [frameView setNeedsDisplay];
        } else if (gr.state == UIGestureRecognizerStateEnded) {
            [self endDragPoint];
        }
    }
}

// ボタンの選択アクション
-(IBAction) toggleSelect:(UIButton*)sender {
    sender.selected = !sender.selected;
}



#pragma mark - Object lifecycle

- (void)dealloc
{
    NSLog(@"%s", __func__);
    [image release];
    image = nil;
    
    self.nw = nil;
    self.ne = nil;
    self.sw = nil;
    self.se = nil;
    self.reflectionButton = nil;
    self.trimmingView = nil;
    self.canvas = nil;
    self.scrollView = nil;
    self.frameView = nil;
    self.contrastSlider = nil;
    self.resolutionSlider = nil;
    self.resolutionSlider = nil;
    self.monoButton = nil;
    self.bwButton = nil;
    self.eventView  =nil;
    self.contrastTitleLabel = nil;
    self.contrastLabel = nil;
    self.resolutionTitleLabel = nil;
    self.resolutionLabel = nil;
    
    self.item1 = nil;
    self.item2 = nil;
    self.item4 = nil;
    self.item5 = nil;
    self.item6 = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)roundRect:(UIButton*) b {
    b.backgroundColor = [UIColor whiteColor];
    b.layer.cornerRadius = 15;
    b.layer.borderColor = [UIColor grayColor].CGColor;
    b.layer.borderWidth = 1;
    b.layer.shadowRadius = 1;
    b.layer.shadowColor = [UIColor grayColor].CGColor;
    b.layer.shadowOffset = CGSizeMake(1, 1);
    b.layer.shadowOpacity = 1;
    b.layer.masksToBounds = YES;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // canvasの位置合わせ（あとでlayoutViewsでやりなおす）
    [canvas eFittoSuperview];
    [frameView eFittoSuperview];
    
    // canvasにかぶせるレイヤー
    bgLayer = [CALayer layer];
    [canvas.layer addSublayer:bgLayer];
    [bgLayer eFittoSuperlayer];
    
    imageLayer = [CALayer layer];
    [canvas.layer addSublayer:imageLayer];
    [bgLayer eFittoSuperlayer];
    
    scrollView.contentSize = scrollView.frame.size;
    
    frameView.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem* saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"complete", nil)
                                   style:UIBarButtonItemStyleDone
                                   target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton release];
    
    // イベントリスナを登録
    UIPanGestureRecognizer* gr = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(buttonDragged:)];
    [eventView addGestureRecognizer:gr];
    
    // ボタン
    NSArray* buttons = [NSArray arrayWithObjects:ne, nw, se, sw, nil];
    for (UIButton* b in buttons) {
        [b addTarget:self action:@selector(startDragPoint:) forControlEvents:UIControlEventTouchDown];
        b.layer.zPosition = 99;
        b.autoresizingMask = UIViewAutoresizingNone;
        [b eSize:BUTTON_SIZE :BUTTON_SIZE];
    }
    [gr release];
    
    [item1 setTitle:NSLocalizedString(@"rightRotation", nil)];
    [item2 setTitle:NSLocalizedString(@"leftRotation", nil)];
    [item4 setTitle:NSLocalizedString(@"rephotograph", nil)];
    [item5 setTitle:NSLocalizedString(@"adjustment", nil)];
    [item6 setTitle:NSLocalizedString(@"detectFrame", nil)];
    
    [reflectionButton setTitle:NSLocalizedString(@"reflection", nil) forState:UIControlStateNormal];
    contrastTitleLabel.text = NSLocalizedString(@"contrast", nil);
    resolutionTitleLabel.text = NSLocalizedString(@"resolution", nil);
    
    [bwButton setTitle:NSLocalizedString(@"whiteBackground", nil) forState:UIControlStateNormal];
    [monoButton setTitle:NSLocalizedString(@"monochromeImage", nil) forState:UIControlStateNormal];
    [self roundRect:bwButton];
    [self roundRect:monoButton];
    
    [cancelButton setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    if (image) {
        imageLayer.contents = (id)image.CGImage;
        [self layoutViews:image];
        [self autoLayoutButtons];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    NSUserDefaults* ud = [AppUtil config];
    if (![ud boolForKey:@"trimPaneShow"]) {
        [AlertDialog confirm:NSLocalizedString(@"AboutImgCompensation", nil)
                   message:NSLocalizedString(@"trimNotice", nil)
                      onOK:^(){
                          [ud setBool:YES forKey:@"trimPaneShow"]; 
                          [ud synchronize];
                      }];
        
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [image release];
    image = nil;
    self.nw = nil;
    self.ne = nil;
    self.sw = nil;
    self.se = nil;
    self.reflectionButton = nil;
    self.trimmingView = nil;
    self.canvas = nil;
    self.scrollView = nil;
    self.frameView = nil;
    self.contrastSlider = nil;
    self.resolutionSlider = nil;
    self.resolutionSlider = nil;
    self.monoButton = nil;
    self.bwButton = nil;
    self.eventView  =nil;
    self.contrastTitleLabel = nil;
    self.contrastLabel = nil;
    self.resolutionTitleLabel = nil;
    self.resolutionLabel = nil;
    self.item1 = nil;
    self.item2 = nil;
    self.item4 = nil;
    self.item5 = nil;
    self.item6 = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ![RootPane isRotationLocked];
}

@end
