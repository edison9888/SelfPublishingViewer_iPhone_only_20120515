//
//  PEEditorViewController.m
//  PEEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import "PEEditorViewController.h"
#import "RootPane.h"


@implementation PEEditorViewController
@synthesize textPreviewLbl;
@synthesize textZoomSlider;
@synthesize zoomTextView;
@synthesize rangeTopBar;
@synthesize rangeTitleLbl;
@synthesize rangeSaveBtn;
@synthesize rangeCancelBtn;
@synthesize rangeButtomBar;
@synthesize rangeAlertView;
@synthesize rangeAlertImageView;
@synthesize drawBtn;
@synthesize penViewController;
@synthesize backgroundImage;
@synthesize img;
@synthesize book;
@synthesize page;
@synthesize cocosView,drawMenuBtn,eraseMenuBtn,deleteMenuBtn;
@synthesize actionSheet;
@synthesize delegate;
@synthesize pageMemo;
@synthesize layersView;
@synthesize layers;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self = [super initWithNibName:@"PEEditorViewController_iPad" bundle:nil];
        } 
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self = [super initWithNibName:@"PEEditorViewController" bundle:nil];
            [self.cocosView setFrame:CGRectMake(0, 20, 320, 460)];
        }
    }
    return self;
}
- (void)dealloc
{   
   //removing rangeImageNotification
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    self.penViewController=nil;
    self.cocosView = nil;
    [drawBtn release];
    [rangeTopBar release];
    [rangeTitleLbl release];
    [rangeSaveBtn release];
    [rangeCancelBtn release];
    [rangeButtomBar release];
    [rangeAlertView release];
    [rangeAlertImageView release];
    [zoomTextView release];
    [textPreviewLbl release];
    [textZoomSlider release];
    
    [otherEffects release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - range notification
-(void)setRangePreviewImage:(id )inRangePreviewImage
{
    //Get range preview Image
    NSLog(@"rangePreviewImage is %@",inRangePreviewImage);
    NSDictionary *userInfo = [inRangePreviewImage valueForKey:@"userInfo"];
    UIImage *rangePreviewImage = [userInfo valueForKey:@"rangePreviewImg"];
    self.rangeAlertImageView.image=rangePreviewImage;
    NSLog(@"rangePreviewImage is %@",rangePreviewImage);
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    backgroundImage.image = img;
    
    //Create a Notification When It gets image of range preview
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(setRangePreviewImage:)
     name:@"setRangePreviewImage"
     object:nil]; 

    self.navigationController.navigationBarHidden=YES;
    PEStampView *_stampView = [[PEStampView alloc] init];
    _stampView.delegate=self;
    [_stampView release];
    
    NSLog(@"Loaded %@",self.cocosView.cocosLayer);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    layersView.image = [pageMemo layeredWritingImage];
    if (self.interfaceOrientation != UIInterfaceOrientationPortrait) {
        UIViewController *viewController = [[UIViewController alloc] init];
        [self presentModalViewController:viewController animated:NO];
        [self dismissModalViewControllerAnimated:NO];
        [viewController release];
    }
}

/*
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
}*/

- (void)viewDidUnload
{
    [self setDrawBtn:nil];
    [self setRangeTopBar:nil];
    [self setRangeTitleLbl:nil];
    [self setRangeSaveBtn:nil];
    [self setRangeCancelBtn:nil];
    [self setRangeButtomBar:nil];
    [self setRangeAlertView:nil];
    [self setRangeAlertImageView:nil];
    [self setZoomTextView:nil];
    [self setTextPreviewLbl:nil];
    [self setTextZoomSlider:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions
- (IBAction)stampClicked:(id)sender {
   
    PEStampViewController *_stampViewController = [[PEStampViewController alloc] initWithNibName:@"PEStampViewController" bundle:nil];
    _stampViewController.editorViewController=self;
    _stampViewController.stampDelgate=self;
    [self.navigationController pushViewController:_stampViewController animated:YES];
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone){
        self.penViewController.view.frame=CGRectMake(0, 480, 320, 418);
    }
    else{
        self.penViewController.view.frame=CGRectMake(0, 1024, 768, 690);
    }


}

- (IBAction)drawClicked:(id)sender {
    if(self.drawMenuBtn.selected==YES){
       self.drawMenuBtn.selected=NO; 
    }
    else{
        self.drawMenuBtn.selected=YES;
    }
    
    self.eraseMenuBtn.selected=NO;
    [self.cocosView.cocosLayer setEraseMode:(BOOL)NO];
    
    if(self.penViewController == nil){
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
            PEPensViewController *_penViewController = [[PEPensViewController alloc] initWithNibName:@"PEPensViewController_iPad" bundle:nil];
            self.penViewController = _penViewController;
            [_penViewController release];
            _penViewController=nil;
        }
        else{
            
            PEPensViewController *_penViewController = [[PEPensViewController alloc] initWithNibName:@"PEPensViewController" bundle:nil];
            self.penViewController = _penViewController;
            [_penViewController release];
            _penViewController=nil;
        }
    }
    
    self.penViewController.delegate=self;
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone){
        self.penViewController.view.frame=CGRectMake(0, 480, 320, 418);
    }
    else{
        self.penViewController.view.frame=CGRectMake(0, 1024, 768, 960);
    }
    //self.penViewController = _penViewController;
    //[_penViewController release];
    //_penViewController=nil;
    [self.view addSubview:self.penViewController.view];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.3];
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone){
        self.penViewController.view.frame=CGRectMake(0, 64, 320, 418);
    }
    else{
        self.penViewController.view.frame=CGRectMake(0, 44, 768, 960);
    } 
    [UIView commitAnimations];

}

//This delegate will call after pressing close or cross button after entering text
-(void)didCloseClicked;{
    
}

//This delegate will be called after pressing ok button.....
#pragma mark - 
-(void)didDrawingControlClicked:(PEStandard *)inStandard;{
        self.drawMenuBtn.selected=YES;
        self.eraseMenuBtn.selected=NO;
     [self.cocosView.cocosLayer setEraseMode:(BOOL)NO];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.3];
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone){
        self.penViewController.view.frame=CGRectMake(0, 480, 320, 418);
    }
    else{
        self.penViewController.view.frame=CGRectMake(0, 1024, 768, 690);
    }
    [UIView commitAnimations];
    

   // NSLog(@"In standard rSliderVal = %f \n gSliderVal = %f\nbSliderVal = %f\n brightnessVal = %f, sizeSliderVal = %f \n brushName = %@\n is standard tab = %d",inStandard.rSliderVal,inStandard.gSliderVal,inStandard.bSliderVal, inStandard.brightnessVal,inStandard.sizeSliderVal,inStandard.brushName,inStandard.isStandard);
    
    
    //Press Ok in Some Draw View 
    //Send PE STANDARD to cocosView
    [self.cocosView.cocosLayer didDrawValuesChangedWith:inStandard];
      
}
#pragma mark - did stamp selected
-(void)didStampViewSelected:(PEStampView *)inStamp;{
    
}
-(void)didStampSelected:(PEDrawing * )inStampInfo;{
    self.eraseMenuBtn.selected=NO;
    [self.cocosView.cocosLayer setEraseMode:(BOOL)NO];
    //PEDrawing *_drawing = (PEDrawing *)inStampInfo;
    NSLog(@"In PEEditViewController The selected stamp is %@ \n scale is %f",inStampInfo.stampName,inStampInfo.scale);
    NSLog(@"inDrawingController is %@",inStampInfo);
    [self.cocosView.cocosLayer didDrawingSelected:inStampInfo];

}
#pragma mark - did frame selected
-(void)didFrameSelected:(PEPhotoFrameView *)inFrameView;{
    self.eraseMenuBtn.selected=NO;
    [self.cocosView.cocosLayer setEraseMode:(BOOL)NO];
    NSLog(@"phot frame selected");
}
-(void)didRangeSelected;{
    self.eraseMenuBtn.selected=NO;
    [self.cocosView.cocosLayer setEraseMode:(BOOL)NO];
    NSLog(@"range selected");
    [self showRangeControlls];
    [self.cocosView.cocosLayer rangeAction];
}


#pragma mark - Text Selection Delegate methods -
-(void)didStampTextSelected:(NSString *)inSelectedText fontName:(NSString*)inFontName fontColor:(UIColor*)inTextColor;{

    [self.cocosView.cocosLayer didStampTextSelected:inSelectedText fontName:inFontName fontColor:inTextColor];
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        self.zoomTextView.frame=CGRectMake(0, 881, self.zoomTextView.frame.size.width, self.zoomTextView.frame.size.height);
    }
    else{
        self.zoomTextView.frame=CGRectMake(0, 375, self.zoomTextView.frame.size.width, self.zoomTextView.frame.size.height);
    }

    [self.textPreviewLbl setTextColor:inTextColor];
    self.textPreviewLbl.text=inFontName;
    self.textZoomSlider.value=1;
    [self. view addSubview:self.zoomTextView];

}

#pragma mark - range 
- (IBAction)rangeAlertCancelClicked:(id)sender {
    [self.rangeAlertView removeFromSuperview];
}

- (IBAction)rangeAlertConfirmClicked:(id)sender {
    [self.rangeAlertView removeFromSuperview];
    [self hideRangeControlls];
     [self.cocosView.cocosLayer getTheRangeRect];
    //
}

- (IBAction)rangeSaveCliked:(id)sender {
    [self.view addSubview:self.rangeAlertView];
    [self.cocosView.cocosLayer rangeShowPreview];
}

- (IBAction)rangeCancelClicked:(id)sender {
     [self.rangeAlertView removeFromSuperview];
    [self hideRangeControlls];
    [self.cocosView.cocosLayer rangeCancel];
}

-(void)showRangeControlls {
    self.rangeTopBar.hidden=NO;
    self.rangeButtomBar.hidden=NO;
    self.rangeCancelBtn.hidden=NO;
    self.rangeSaveBtn.hidden=NO;
    self.rangeTitleLbl.hidden=NO;
    
    [self.view insertSubview:self.rangeTopBar atIndex:100];
    [self.view insertSubview:self.rangeButtomBar atIndex:100];
    [self.view insertSubview:self.rangeCancelBtn atIndex:100];
    [self.view insertSubview:self.rangeSaveBtn atIndex:100];
    [self.view insertSubview:self.rangeTitleLbl atIndex:100]; 
}
-(void)hideRangeControlls {
    self.rangeTopBar.hidden=YES;
    self.rangeButtomBar.hidden=YES;
    self.rangeCancelBtn.hidden=YES;
    self.rangeSaveBtn.hidden=YES;
    self.rangeTitleLbl.hidden=YES;
}

- (IBAction)undo:(id)sender {
    [self.cocosView.cocosLayer undo];
}

- (IBAction)redo:(id)sender {
    [self.cocosView.cocosLayer redo];
}

- (IBAction)erase:(id)sender {
    self.drawMenuBtn.selected=NO;
    if(self.eraseMenuBtn.selected==YES){
        self.eraseMenuBtn.selected=NO;
        [self.cocosView.cocosLayer setEraseMode:(BOOL)YES];
    }
    else {
         self.eraseMenuBtn.selected=YES;
         [self.cocosView.cocosLayer setEraseMode:(BOOL)NO];
    }
}

- (IBAction)close:(id)sender {
}

- (IBAction)toggleMenu:(id)sender{
    
    [UIView beginAnimations:Nil context:Nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    
    for (UIView * v in [self.view subviews]) {
        if (v != closeButton) {
            CGFloat shift = 0;
            if (v.center.y > 400) {
                shift = 50.0f;
            }
            if (v.center.y < 80) {
                shift = -50.0f;
            }
            if (menuHidden) {
                shift *= - 1;
            }
            v.center = CGPointMake(v.center.x, v.center.y + shift);
        }
    }
    
    CGFloat angle = menuHidden ? 0 : 180;
    closeButton.transform = CGAffineTransformMakeRotation(angle * M_PI / 180.0);

    [UIView commitAnimations];
    
    menuHidden = !menuHidden;
}

- (IBAction)delete:(id)sender {
    [self.cocosView.cocosLayer clearCurrentDrawing];
    
    self.eraseMenuBtn.selected=NO;
     self.drawMenuBtn.selected=NO;
    [self.cocosView.cocosLayer setEraseMode:(BOOL)NO];
}

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
    switch (buttonIndex) {
        case 0: {
            
            [self saveAsLayer];

            
        } break;
        case 1: {
            Book *b = (Book *)book;
            if (b.isImported) {
                [self mergeLayers];
            }else {
                
            }
        } break;
            
        default:
            assert(NO);
        case 2: {
            
        } break;
    }
    
    self.actionSheet = nil;
}

-(void)mergeLayers 
{
    Book *b = (Book *)book;
    if (!b.isImported) {
        [self saveAsLayer];
        return;
    }
    
    [self merge];
    [pageMemo setMyWritingImage:nil];
    // 回転リスナを解除
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[RootPane instance]popPane];
}

-(void)saveAsLayer {
    
    UIImage * writingImage = [self.cocosView.cocosLayer getScreenShotFromGLview];
    NSLog(@"writingImage: %@", writingImage);
    //[delegate writingDone:writingImage];

    if (pageMemo) {
        [pageMemo setMyWritingImage:writingImage];
    }
    else {
        [delegate writingDone:writingImage];
    }
        
    // 回転リスナを解除
    
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[RootPane instance]popPane];
}


-(void)merge {
    if (pageMemo) {
        
        UIImage *original = backgroundImage.image;
        UIImage *layersImage = layersView.image;
        UIImage *new = [self.cocosView.cocosLayer getScreenShotFromGLview];
        
        NSLog(@"original size: %f by %f", original.size.height, original.size.width);

        NSLog(@"new size: %f by %f", new.size.height, new.size.width);
        
        CGSize rectSize = backgroundImage.image.size;
        CGRect canvasRect = CGRectMake(0, 0, rectSize.width, rectSize.height);
        
        NSLog(@"canvasrect: %@", NSStringFromCGRect(canvasRect));
        
        //UIGraphicsBeginImageContextWithOptions(rectSize, NO, 2.0);
        
        UIGraphicsBeginImageContext(rectSize);
        [original drawInRect:canvasRect];
        [layersImage drawInRect:canvasRect];
        [new drawInRect:canvasRect];
        UIImage* merged = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSLog(@"image size: %f by %f", merged.size.height, merged.size.width);
        
        NSString *fileName  = [(Book *)book getBookPagePath:page];
        
        
        [FileUtil rm:fileName];
        
        if ([fileName hasSuffix:@"png"]) {
            [UIImagePNGRepresentation(merged) writeToFile:fileName atomically:YES];
            
        } else {
            [UIImageJPEGRepresentation(merged, 1.0) writeToFile:fileName atomically:YES];
        }
        
    }
    
}

-(IBAction)showLayers {
    SettingPane* p = [[SettingPane alloc]init];
    p.tableView.alwaysBounceVertical = YES;
    p.pageMemo = pageMemo;
    [[RootPane instance]pushPane:p];
    [p release];
}


- (IBAction)done:(id)sender {
    [[RootPane instance] popPane];
}

-(IBAction)openOtherEffectsPane{
    if (!otherEffects) {
        otherEffects = [[OtherEffectsPane alloc] init];
        otherEffects.writingPane = self;
    }
    [[self navigationController] pushViewController:otherEffects animated:YES];
}

-(void)openMosaic:(MosaicViewController *)mosaic{
    
    mosaic.delegate = self;
    
    UIImage * original = backgroundImage.image;
    UIImage * layersImg = layersView.image;
    UIImage * new = [self.cocosView.cocosLayer getScreenShotFromGLview];
    
    NSLog(@"o: %@, li: %@, n: %@", original, layersImg, new);
    
    //NSLog(@"original size: %f by %f", original.size.height, original.size.width);
    
    NSLog(@"new size: %f by %f", new.size.height, new.size.width);
    
    CGSize rectSize = CGSizeMake(640, 640 * original.size.height / original.size.width);
    CGRect canvasRect = CGRectMake(0, 0, rectSize.width, rectSize.height);
    
    //NSLog(@"canvasrect: %@", NSStringFromCGRect(canvasRect));
    
    //UIGraphicsBeginImageContextWithOptions(rectSize, NO, 2.0);
    
    UIGraphicsBeginImageContext(rectSize);
    [original drawInRect:canvasRect];
    if (![[NSString stringWithFormat:@"%@",layersImg] isEqualToString:@"(null)"]) {
        NSLog(@"L1");
        [layersImg drawInRect:canvasRect];
    }
    if (![[NSString stringWithFormat:@"%@",new] isEqualToString:@"(null)"]) {
        NSLog(@"L2");
        [new drawInRect:canvasRect];
    }
    UIImage* merged = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
        
    NSLog(@"merged: %@", merged);
    
    [mosaic useImage:merged];
}

-(void)addMosaicImage:(UIImage *)mosaicImage{
    NSLog(@"image dimensions: %f %f", mosaicImage.size.width, mosaicImage.size.height);
    
    UIImage * drawingLayer = [self.cocosView.cocosLayer getScreenShotFromGLview];
    
    CGRect imgRect = CGRectMake(0, 0, drawingLayer.size.width, drawingLayer.size.height);
    
    UIGraphicsBeginImageContextWithOptions(drawingLayer.size, NO, 1.0);
    [drawingLayer drawInRect:imgRect];
    [mosaicImage drawInRect:imgRect];
    UIImage* merged = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.cocosView.cocosLayer setImage:merged];
}

-(void)showAttachmentPane {
    AttachmentPane* p = [[AttachmentPane alloc]init];
    p.editMode = YES;
    p.pageMemo = pageMemo;
    [[RootPane instance]pushPane:p];
    [p release];
}


- (IBAction)textZoomSliderAction:(id)sender {
    UISlider *_slider = (UISlider *)sender;
    CGFloat _sliderVal = _slider.value;
    [self.cocosView.cocosLayer textSize:_sliderVal];
}

- (IBAction)textZoomFinishedAction:(id)sender {
    [self.zoomTextView removeFromSuperview];
    [self.cocosView.cocosLayer textZoomingFinished];
}
@end
