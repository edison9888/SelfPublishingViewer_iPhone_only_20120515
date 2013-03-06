//
//  PEStampViewController.m
//  PhotoEditiong
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import "PEStampViewController.h"
#import "PEDrawing.h"
#import "PEPhotoFrameView.h"
#import "PEEditorViewController.h"
#import "UIImage+Resize.h"

@implementation PEStampViewController
@synthesize alertView;
@synthesize alertViewImage;
@synthesize loadFrames;
@synthesize stampBtn;
@synthesize satrStampBtn;
@synthesize ballonStampBtn;
@synthesize penStampBtn;
@synthesize stampTitleLbl;
@synthesize txtButton;
@synthesize pictureBtn;
@synthesize frameBtn;
@synthesize scrollView;
@synthesize originalStampSubView;
@synthesize bottomBarHstView;
@synthesize isEditing;
@synthesize stampDelgate;
@synthesize fontTypesHstView;
@synthesize fontTypeView;
@synthesize fontSizeSlider;
@synthesize addTextViewController;
@synthesize englishFontHstScrl;
@synthesize japaneseFontHstScrl;
@synthesize chineseFontHstScrl;
@synthesize editorViewController;
@synthesize picker;
@synthesize saveImage;

@synthesize sizeSliderHostView;
@synthesize sizeSlider;
@synthesize selectedPalletImgView;
@synthesize selectedStampView;

- (void)dealloc {
    self.editorViewController=nil;
    [stampTitleLbl release];
    [satrStampBtn release];
    [penStampBtn release];
    [ballonStampBtn release];
    [stampBtn release];
    [stampTitleLbl release];
    [penStampBtn release];
    [ballonStampBtn release];
    [satrStampBtn release];
    [stampBtn release];
    [scrollView release];
    [originalStampSubView release];
    
    [fontTypesHstView release];
    [txtButton release];
    [loadFrames release];
    [pictureBtn release];
    [frameBtn release];
    [englishFontHstScrl release];
    [fontSizeSlider release];
    [bottomBarHstView release];
    [sizeSlider release];
    [selectedPalletImgView release];
    [sizeSliderHostView release];
    
    [selectedStampView release];
    selectedStampView = nil;
    [alertView release];
    [alertViewImage release];
    self.saveImage=nil;
    [japaneseFontHstScrl release];
    [chineseFontHstScrl release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self = [super initWithNibName:@"PEStampViewController_ipad" bundle:nil];
        } 
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self = [super initWithNibName:@"PEStampViewController" bundle:nil];
        }
    }
    return self;
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
    [self loadStarStamps:nil];
    self.bottomBarHstView.hidden=YES;
    self.fontTypesHstView.hidden=YES;
   // self.testTextView.text=@"test the HuiFont29 text in";
  }
    // Do any additional setup after loading the view from its nib.

- (void)viewDidUnload
{
    [stampTitleLbl release];
    stampTitleLbl = nil;
    [satrStampBtn release];
    satrStampBtn = nil;
    [penStampBtn release];
    penStampBtn = nil;
    [ballonStampBtn release];
    ballonStampBtn = nil;
    [stampBtn release];
    [scrollView release];
    scrollView=nil;
    [originalStampSubView release];
    originalStampSubView=nil;
    
    [self setFontTypesHstView:nil];
    [self setTxtButton:nil];
    [self setLoadFrames:nil];
    [self setPictureBtn:nil];
    [self setFrameBtn:nil];
    [self setEnglishFontHstScrl:nil];
    [self setFontSizeSlider:nil];
    [self setBottomBarHstView:nil];
    [self setAlertView:nil];
    [self setAlertViewImage:nil];
    [self setJapaneseFontHstScrl:nil];
    [self setChineseFontHstScrl:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - loading stamps
- (IBAction)loadOriginalStamps:(id)sender {
    
    if(nil != self.sizeSliderHostView){
        [self.sizeSliderHostView removeFromSuperview];
    }
    
    self.fontTypesHstView.hidden=YES;
    self.stampTitleLbl.text=@"Original Stamp";
    self.satrStampBtn.selected=NO;
    self.penStampBtn.selected=NO;
    self.ballonStampBtn.selected=NO;
    self.stampBtn.selected=YES;
     self.txtButton.selected=NO;
    self.pictureBtn.selected=YES;
    self.frameBtn.selected=NO;
    
    
    self.originalStampSubView.hidden=NO;
    //removing subviews form scrollview
    
    
    for(PEOriginalStampView *tempview in [self.scrollView subviews]){
        [tempview removeFromSuperview];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *PhotoDir = [documentsDirectory stringByAppendingPathComponent:@"PEPhotos"];
    
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:PhotoDir error:nil];
    
    int WIDTH, HEIGHT,noOFImages,imgWidth,imgHeight;
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        
        WIDTH=140;
        HEIGHT=140;
        noOFImages=5;
        imgWidth=260;
        imgHeight=260;     
        
        self.scrollView.frame=CGRectMake(0, 176, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        
    }
    else{
        WIDTH=90;
        HEIGHT=90;
        noOFImages=3;
        imgHeight=180;
        imgWidth=180;
        self.scrollView.frame=CGRectMake(0, 167, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        
    }
    
    //adding subviews to scrollview 
    int X=15,Y=10;
    for(int i=0; i<[dirContents count];i++){
        if(i>2)
        {
            if(i%noOFImages==0)
            {
                X=15;
            }
            else{
                X=X+WIDTH+10;
            }
            int row=i/noOFImages;
            if(row>0){
                Y=((HEIGHT+10)*row)+10;
            }
        }
        else{
            Y=10;
            if(i>0){
                X=X+WIDTH+10;
            }
        }
        
        PEOriginalStampView *tempView=[[PEOriginalStampView alloc]initWithFrame:CGRectMake(X, Y, WIDTH, HEIGHT)];
        tempView.userInteractionEnabled = YES;
        tempView.delegate=self;
        [tempView setBackgroundColor:[UIColor clearColor]];
      
        UIImageView *picImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, imgWidth, imgHeight)];
        CGRect imgFrame=picImageView.frame;
        imgFrame.origin.x = CGRectGetMidX(tempView.bounds) - CGRectGetMidX(picImageView.bounds);
        imgFrame.origin.y = CGRectGetMidY(tempView.bounds) - CGRectGetMidY(picImageView.bounds);
        picImageView.frame=imgFrame;
        [tempView addSubview:picImageView];
        [picImageView release];
        
        PEDrawing *_draw=[[PEDrawing alloc]init];
        tempView.drawing=_draw;
        [_draw release];
       
        tempView.drawing.stampName=[dirContents objectAtIndex:i];
        tempView.drawing.stampId=i;
        tempView.drawing.typeOfStamp=StampTypeOriginalStamp;
        
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self 
                   action:@selector(deleteBtnAction:)
         forControlEvents:UIControlEventTouchUpInside];
        [btn setFrame:CGRectMake(-10, -10, 32, 32)];
        
        [btn setImage:[UIImage imageNamed:@"close_bt.png"] forState:UIControlStateNormal];
       
        if(self.isEditing){
            btn.hidden=NO;  
        }
        else{
            btn.hidden=YES;
        }
        [tempView addSubview:btn];
        
        tempView.deleteBtn=btn;
        [self.scrollView addSubview:tempView];
       // [tempView release];
//        if( [[UIScreen mainScreen] scale]==1.0f){
        tempView.drawing.stampName=[NSString stringWithFormat:@"%@",[dirContents objectAtIndex:i]];
        tempView.drawing.stampPath=[NSString stringWithFormat:@"%@/%@",PhotoDir,[dirContents objectAtIndex:i]];
//        }
//        else{
//            tempView.drawing.stampName=[NSString stringWithFormat:@"%@@2x",[dirContents objectAtIndex:i]];
//            tempView.drawing.stampPath=[NSString stringWithFormat:@"%@/%@",PhotoDir,[dirContents objectAtIndex:i]];  
//        }
        //
        UIImage *stampImage=[[UIImage alloc]initWithContentsOfFile:_draw.stampPath];
        
        picImageView.image=stampImage;
        [stampImage release];
        //

        NSLog(@"image Frame is %@",NSStringFromCGRect(picImageView.frame));
        tempView.delegate=self;
        [tempView release];
            
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
            [self.scrollView setContentSize:CGSizeMake(0, Y+350)];
        }
        else{
            [self.scrollView setContentSize:CGSizeMake(0, Y+150)];
        }
    }
}

- (IBAction)loadBallonStamps:(id)sender {
    
    if(nil != self.sizeSliderHostView){
        [self.sizeSliderHostView removeFromSuperview];
    }
    
    self.fontTypesHstView.hidden=YES;

    NSString *bundle = [[NSBundle mainBundle] pathForResource:@"Images" ofType:@"plist"];
    NSDictionary *dic=[NSDictionary dictionaryWithContentsOfFile:bundle];
    NSDictionary *framesDic=[dic objectForKey:@"Baloons"];
    NSArray *stampArray=[framesDic objectForKey:@"New item"];
    NSLog(@"Array Count is%d",[stampArray count]);
    
    self.stampTitleLbl.text=@"Balloon";
    self.satrStampBtn.selected=NO;
    self.penStampBtn.selected=NO;
    self.stampBtn.selected=NO;
    self.ballonStampBtn.selected=YES;
     self.txtButton.selected=NO;
    self.frameBtn.selected=NO;
    self.pictureBtn.selected=NO;
    //removing subviews form scrollview
    for(PEStampView *tempview in [self.scrollView subviews]){
        [tempview removeFromSuperview];
    }
    
    self.originalStampSubView.hidden=YES;
    int WIDTH, HEIGHT,noOFImages,imgWidth,imgHeight;
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        WIDTH=140;
        HEIGHT=140;
        noOFImages=5;
        imgWidth=130;
        imgHeight=130;      
        self.scrollView.frame=CGRectMake(0, 112, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        
    }
    else{
        WIDTH=90;
        HEIGHT=90;
        noOFImages=3;
        imgWidth=40;
        imgHeight=40;
        self.scrollView.frame=CGRectMake(0, 81, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        
    }
    
    //adding subviews to scrollview 
    int X=15,Y=10;
    for(int i=0; i<[stampArray count];i++){
        if(i>2)
        {
            if(i%noOFImages==0)
            {
                X=15;
            }
            else{
                X=X+WIDTH+10;
            }
            int row=i/noOFImages;
            if(row>0){
                Y=((HEIGHT+10)*row)+10;
            }
        }
        else{
            Y=10;
            if(i>0){
                X=X+WIDTH+10;
            }
        }
        PEStampView *tempView=[[PEStampView alloc]initWithFrame:CGRectMake(X, Y, WIDTH, HEIGHT)];
        tempView.backgroundColor=[UIColor clearColor];
        tempView.delegate=self;
        [self.scrollView addSubview:tempView];
        
        PEDrawing *_draw=[[PEDrawing alloc]init];
        tempView.drawing=_draw;
        tempView.drawing.stampId=i;
        tempView.drawing.typeOfStamp=StampTypeBallon;
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
            _draw.stampName=[NSString stringWithFormat:@"%@200x200",[stampArray objectAtIndex:i]];
            _draw.stampPath=[[NSBundle mainBundle]pathForResource:_draw.stampName ofType:@"png"];
             tempView.drawing.stampName=[NSString stringWithFormat:@"%@200x200.png",[stampArray objectAtIndex:i]];
        }
        else{
            _draw.stampName=[NSString stringWithFormat:@"%@200x200",[stampArray objectAtIndex:i]];
            _draw.stampPath=[[NSBundle mainBundle]pathForResource:_draw.stampName ofType:@"png"];
             tempView.drawing.stampName=[NSString stringWithFormat:@"%@200x200.png",[stampArray objectAtIndex:i]];
        }
        [_draw release];
        
        UIImageView *picImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, imgWidth, imgHeight)];
        CGRect imgFrame=picImageView.frame;
        imgFrame.origin.x = CGRectGetMidX(tempView.bounds) - CGRectGetMidX(picImageView.bounds);
        imgFrame.origin.y = CGRectGetMidY(tempView.bounds) - CGRectGetMidY(picImageView.bounds);
        picImageView.frame=imgFrame;
        
        [tempView addSubview:picImageView];
        [picImageView release];
        picImageView.image=[UIImage imageWithContentsOfFile:_draw.stampPath];
        [tempView release];
        
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(stampAction: shouldReceiveTouch:)];
        tapGesture.numberOfTapsRequired=1;
        [tempView addGestureRecognizer:tapGesture];
        [tapGesture release];
        
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
            [self.scrollView setContentSize:CGSizeMake(0, Y+350)];
        }
        else{
            [self.scrollView setContentSize:CGSizeMake(0, Y+150)];   
        }
    }
}

- (IBAction)loadStarStamps:(id)sender {
    
    if(nil != self.sizeSliderHostView){
        [self.sizeSliderHostView removeFromSuperview];
    }
    
    self.fontTypesHstView.hidden=YES;

    NSString *bundle = [[NSBundle mainBundle] pathForResource:@"Images" ofType:@"plist"];
    NSDictionary *dic=[NSDictionary dictionaryWithContentsOfFile:bundle];
    NSDictionary *framesDic=[dic objectForKey:@"Stamps"];
    NSArray *stampArray=[framesDic objectForKey:@"New item"];
    NSLog(@"Array Count is%d",[stampArray count]);
    
    self.stampTitleLbl.text=@"Stamp";
    self.stampBtn.selected=NO;
    self.penStampBtn.selected=NO;
    self.ballonStampBtn.selected=NO;
     self.txtButton.selected=NO;
    self.satrStampBtn.selected=YES;
    self.frameBtn.selected=NO;
    self.pictureBtn.selected=NO;
    
    self.originalStampSubView.hidden=YES;
    
    //removing subviews form scrollview
    for(PEStampView *tempview in [self.scrollView subviews]){
        [tempview removeFromSuperview];
    }
    int WIDTH, HEIGHT,noOFImages,imgWidth,imgHeight;
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        WIDTH=140;
        HEIGHT=140;
        noOFImages=5;
        imgWidth=130;
        imgHeight=130;      
        self.scrollView.frame=CGRectMake(0, 112, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        
    }
    else{
        WIDTH=90;
        HEIGHT=90;
        noOFImages=3;
        imgWidth=40;
        imgHeight=40;
        self.scrollView.frame=CGRectMake(0, 81, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        
    }
    
    //adding subviews to scrollview 
    int X=15,Y=10;
    for(int i=0; i<[stampArray count];i++){
        if(i>2)
        {
            if(i%noOFImages==0)
            {
                X=15;
            }
            else{
                X=X+WIDTH+10;
            }
            int row=i/noOFImages;
            if(row>0){
                Y=((HEIGHT+10)*row)+10;
            }
        }
        else{
            Y=10;
            if(i>0){
                X=X+WIDTH+10;
            }
        }
        PEStampView *tempView=[[PEStampView alloc]initWithFrame:CGRectMake(X, Y, WIDTH, HEIGHT)];
        tempView.backgroundColor=[UIColor clearColor];
        [self.scrollView addSubview:tempView];
        
        PEDrawing *_draw=[[PEDrawing alloc]init];
        tempView.drawing=_draw;
        tempView.drawing.stampId=i;
        tempView.drawing.typeOfStamp=StampTypeStar;
        
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
            _draw.stampName=[NSString stringWithFormat:@"%@200x200",[stampArray objectAtIndex:i]];
            _draw.stampPath=[[NSBundle mainBundle]pathForResource:_draw.stampName ofType:@"png"];
             tempView.drawing.stampName=[NSString stringWithFormat:@"%@200x200.png",[stampArray objectAtIndex:i]];
        }
        else{
            _draw.stampName=[NSString stringWithFormat:@"%@200x200",[stampArray objectAtIndex:i]];
            _draw.stampPath=[[NSBundle mainBundle]pathForResource:_draw.stampName ofType:@"png"];
             tempView.drawing.stampName=[NSString stringWithFormat:@"%@200x200.png",[stampArray objectAtIndex:i]];
        }
        [_draw release];
        
        UIImageView *picImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, imgWidth, imgHeight)];
        CGRect imgFrame=picImageView.frame;
        imgFrame.origin.x = CGRectGetMidX(tempView.bounds) - CGRectGetMidX(picImageView.bounds);
        imgFrame.origin.y = CGRectGetMidY(tempView.bounds) - CGRectGetMidY(picImageView.bounds);
        picImageView.frame=imgFrame;
        
        [tempView addSubview:picImageView];
        [picImageView release];
        picImageView.image=[UIImage imageWithContentsOfFile:_draw.stampPath];
        picImageView.layer.shadowColor = [UIColor colorWithWhite:0.3 alpha:1.0].CGColor;
        picImageView.layer.shadowRadius = 1.5f;
        picImageView.layer.shadowOpacity = 1.0f;
        picImageView.layer.shadowOffset = CGSizeMake(0, 2);
        [tempView release];
        
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(stampAction: shouldReceiveTouch:)];
        tapGesture.numberOfTapsRequired=1;
        [tempView addGestureRecognizer:tapGesture];
        [tapGesture release];
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
            [self.scrollView setContentSize:CGSizeMake(0, Y+350)];
        }
        else{
            [self.scrollView setContentSize:CGSizeMake(0, Y+150)];   
        }
    }
}

- (IBAction)loadpenStamps:(id)sender {
    
    self.fontTypesHstView.hidden=YES;
    
    if(nil == self.sizeSliderHostView.superview){
        CGRect rect = self.sizeSliderHostView.frame;
        rect.origin.y = 1+(CGRectGetHeight(self.view.frame)-CGRectGetHeight(rect));
        self.sizeSliderHostView.frame = rect;
        [self.view addSubview:self.sizeSliderHostView];
    }

    NSString *bundle = [[NSBundle mainBundle] pathForResource:@"Images" ofType:@"plist"];
    NSDictionary *dic=[NSDictionary dictionaryWithContentsOfFile:bundle];
    NSDictionary *framesDic=[dic objectForKey:@"Pens"];
    NSArray *stampArray=[framesDic objectForKey:@"New item"];
    NSLog(@"Array Count is%d",[stampArray count]);
    
    self.stampTitleLbl.text=@"Wheel Stamp";
    self.satrStampBtn.selected=NO;
    self.stampBtn.selected=NO;
    self.ballonStampBtn.selected=NO;
    self.penStampBtn.selected=YES;
    self.txtButton.selected=NO;
    self.frameBtn.selected=NO;
    self.pictureBtn.selected=NO;
    
    self.originalStampSubView.hidden=YES;
    
    //removing subviews form scrollview
    for(PEStampView *tempview in [self.scrollView subviews]){
        [tempview removeFromSuperview];
    }
    
    int WIDTH, HEIGHT, noOFImages,imgWidth,imgHeight;
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        WIDTH=140;
        HEIGHT=140;
        noOFImages=5;
        imgWidth=130;
        imgHeight=130;      
        self.scrollView.frame=CGRectMake(0, 112, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    }
    else{
        WIDTH=90;
        HEIGHT=90;
        noOFImages=3;
        imgWidth=40;
        imgHeight=40;
        self.scrollView.frame=CGRectMake(0, 81, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    }
    
    //adding subviews to scrollview 
    int X=15,Y=10;
    for(int i=0; i<[stampArray count];i++){
        if(i>2)
        {
            if(i%noOFImages==0)
            {
                X=15;
            }
            else{
                X=X+WIDTH+10;
            }
            int row=i/noOFImages;
            if(row>0){
                Y=((HEIGHT+10)*row)+10;
            }
        }
        else{
            Y=10;
            if(i>0){
                X=X+WIDTH+10;
            }
        }
        PEStampView *tempView=[[PEStampView alloc]initWithFrame:CGRectMake(X, Y, WIDTH, HEIGHT)];
        tempView.backgroundColor=[UIColor clearColor];
        [self.scrollView addSubview:tempView];
        
        PEDrawing *_draw=[[PEDrawing alloc]init];
        tempView.drawing=_draw;
        tempView.drawing.stampId=i;
        tempView.drawing.typeOfStamp=StampTypePen;
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
            _draw.stampName=[NSString stringWithFormat:@"%@200x200",[stampArray objectAtIndex:i]];
            _draw.stampPath=[[NSBundle mainBundle]pathForResource:_draw.stampName ofType:@"png"];
             tempView.drawing.stampName=[NSString stringWithFormat:@"%@200x200.png",[stampArray objectAtIndex:i]];
        }
        else{
            _draw.stampName=[NSString stringWithFormat:@"%@200x200",[stampArray objectAtIndex:i]];
            _draw.stampPath=[[NSBundle mainBundle]pathForResource:_draw.stampName ofType:@"png"];
             tempView.drawing.stampName=[NSString stringWithFormat:@"%@200x200.png",[stampArray objectAtIndex:i]];
        }
        [_draw release];
        
        UIImageView *picImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, imgWidth, imgHeight)];
        CGRect imgFrame=picImageView.frame;
        imgFrame.origin.x = CGRectGetMidX(tempView.bounds) - CGRectGetMidX(picImageView.bounds);
        imgFrame.origin.y = CGRectGetMidY(tempView.bounds) - CGRectGetMidY(picImageView.bounds);
        picImageView.frame=imgFrame;
        [tempView addSubview:picImageView];
        [picImageView release];
       // [picImageView setBackgroundColor:[UIColor clearColor]];
        picImageView.image=[UIImage imageWithContentsOfFile:_draw.stampPath];
        picImageView.layer.shadowColor = [UIColor colorWithWhite:0.3 alpha:1.0].CGColor;
        picImageView.layer.shadowRadius = 1.5f;
        picImageView.layer.shadowOpacity = 1.0f;
        picImageView.layer.shadowOffset = CGSizeMake(0, 2);
        [tempView release];
        
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(stampAction: shouldReceiveTouch:)];
        tapGesture.numberOfTapsRequired=1;
        [tempView addGestureRecognizer:tapGesture];
        [tapGesture release];
        [picImageView setBackgroundColor:[UIColor clearColor]];
        
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
            [self.scrollView setContentSize:CGSizeMake(0, Y+350)];
        }
        else{
            [self.scrollView setContentSize:CGSizeMake(0, Y+150)];   
        }
        if(i==4){
            self.selectedStampView=tempView;
            self.selectedStampView.drawing.scale=1.0;
        }
    }
}

- (IBAction)fontSizeChange:(id)sender {
    UISlider *_slider = (UISlider *)sender;
    
    CGFloat fontSize=self.fontTypeView.fontSize;
    fontSize = self.fontTypeView.fontSize*_slider.value;
    [self.fontTypeView.fontTypeLbl setFont:[UIFont fontWithName:self.fontTypeView.fontType size:fontSize]];
    
}
- (IBAction)loadFrames:(id)sender {
    
    if(nil != self.sizeSliderHostView){
        [self.sizeSliderHostView removeFromSuperview];
    }
    self.stampTitleLbl.text=@"Template";
    self.fontTypesHstView.hidden=YES;
    self.txtButton.selected=NO;
    self.satrStampBtn.selected=NO;
    self.penStampBtn.selected=NO;
    self.ballonStampBtn.selected=NO;
    self.stampBtn.selected=NO;
    self.frameBtn.selected=YES;
    self.pictureBtn.selected=NO;
    
    NSString *bundle = [[NSBundle mainBundle] pathForResource:@"Images" ofType:@"plist"];
    NSDictionary *dic=[NSDictionary dictionaryWithContentsOfFile:bundle];
    NSDictionary *framesDic=[dic objectForKey:@"Frames"];
    NSArray *stampArray=[framesDic objectForKey:@"New item"];
    NSLog(@"Array Count is%d",[stampArray count]);
    
    
    //removing subviews form scrollview
    for(PEPhotoFrameView *tempview in [self.scrollView subviews]){
        [tempview removeFromSuperview];
    }
    int WIDTH, HEIGHT,noOFImages,imgWidth,imgHeight;
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        WIDTH=245;
        HEIGHT=320;
        noOFImages=3;
        imgWidth=245;
        imgHeight=320;
    }
    else{
        WIDTH=70;
        HEIGHT=96;
        noOFImages=4;
        imgWidth=64;
        imgHeight=96;
        self.scrollView.frame=CGRectMake(0, 81, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    }
    
    //adding subviews to scrollview 
    int X=8,Y=10;
    
    for(int i=0; i<[stampArray count] ;i++){
        if(i>noOFImages-1)
        {
            if(i%noOFImages==0)
            {
                X=8;
            }
            else{
                X=X+WIDTH+8;
            }
            int row=i/noOFImages;
            if(row>0){
                Y=((HEIGHT+10)*row)+10;
            }
        }
        else{
            Y=10;
            if(i>0){
                X=X+WIDTH+8;
            }
        }
        
        PEPhotoFrameView *tempView=[[PEPhotoFrameView alloc]initWithFrame:CGRectMake(X, Y, WIDTH, HEIGHT)];
        //tempView.delegate=self;
        tempView.backgroundColor=[UIColor clearColor];
        [self.scrollView addSubview:tempView];
        PEDrawing *_PhotoFrame=[[PEDrawing alloc]init];
        tempView.drawing=_PhotoFrame;
        tempView.drawing.stampId=i;
        tempView.drawing.typeOfStamp=StampTypeFrame;
        
        
        
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
            tempView.drawing.stampName=[NSString stringWithFormat:@"%@200x200",[stampArray objectAtIndex:i]];
            tempView.drawing.stampPath=[[NSBundle mainBundle]pathForResource: tempView.drawing.stampName ofType:@"png"];
            tempView.drawing.stampName=[NSString stringWithFormat:@"%@200x200_ipad.png",[stampArray objectAtIndex:i]];
        }
        else
        {
            tempView.drawing.stampName=[NSString stringWithFormat:@"%@200x200",[stampArray objectAtIndex:i]];
            tempView.drawing.stampPath=[[NSBundle mainBundle]pathForResource:tempView.drawing.stampName ofType:@"png"];
            tempView.drawing.stampName=[NSString stringWithFormat:@"%@200x200.png",[stampArray objectAtIndex:i]];
        }
        
        [_PhotoFrame release];

        UIImageView *picImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, imgWidth, imgHeight)];
        CGRect imgFrame=picImageView.frame;
        imgFrame.origin.x = CGRectGetMidX(tempView.bounds) - CGRectGetMidX(picImageView.bounds);
        imgFrame.origin.y = CGRectGetMidY(tempView.bounds) - CGRectGetMidY(picImageView.bounds);
        picImageView.frame=imgFrame;
        [tempView addSubview:picImageView];
        [picImageView release];
        picImageView.image=[UIImage imageWithContentsOfFile:tempView.drawing.stampPath];
        
        
//        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(photoFrameAction: shouldReceiveTouch:)];
//        tapGesture.numberOfTapsRequired=1;
//        [tempView addGestureRecognizer:tapGesture];
//        [tapGesture release];
//        [tempView release];
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(stampAction: shouldReceiveTouch:)];
        tapGesture.numberOfTapsRequired=1;
        [tempView addGestureRecognizer:tapGesture];
        [tapGesture release];
        [tempView release];

        
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
            [self.scrollView setContentSize:CGSizeMake(0, Y+450)];
        }
        else{
            [self.scrollView setContentSize:CGSizeMake(0, Y+200)];
        }
    }
}

#pragma mark - GestureRecognizer method
-(void)photoFrameAction:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touchView {
    
  /*  if([self.photoFrameDelegate respondsToSelector:@selector(didStampSelected:)])
    {
        PEPhotoFrameView *view=(PEPhotoFrameView *)gestureRecognizer.view;
        if([self.photoFrameDelegate respondsToSelector:@selector(didPhotFrameSelected:)]){
            [self.photoFrameDelegate didPhotFrameSelected:view.photFrame];
            self.isPhotoFrameSeleted=YES;
            //[self.view removeFromSuperview];
            [self dismissModalViewControllerAnimated:YES];
        }
    }*/
}



- (IBAction)loadFontTypes:(id)sender {
    
    if(nil != self.sizeSliderHostView){
        [self.sizeSliderHostView removeFromSuperview];
    }
    
    self.fontTypesHstView.hidden=NO;
    self.txtButton.selected=YES;
    self.satrStampBtn.selected=NO;
    self.penStampBtn.selected=NO;
    self.ballonStampBtn.selected=NO;
    self.stampBtn.selected=NO;
    self.pictureBtn.selected=NO;
    self.frameBtn.selected=NO;
    NSArray *familyNames = [[NSArray alloc] initWithArray:[NSArray arrayWithObjects:@"Arial",@"Verdana",@"Courier",@"Courier New",@"Helvetica",@"Helvetica Neue",@"Optima",@"Times New Roman",@"Arial Hebrew", nil]];
    NSLog(@"familyNames:%@",familyNames);
    
    
    NSArray *fontNames=nil;
    for(id childView in self.englishFontHstScrl.subviews){
        [childView removeFromSuperview];
    }
    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        [self loadFontTypesForiPad];
//    }
//    else{
        CGFloat xVal = 5.0;
        CGFloat yVal = 0.0;
        CGFloat fontViewWidth = 100.f;
        CGFloat fontViewHeight = 60.0f;
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
       
         fontViewWidth = 200;
         fontViewHeight = 80.0f;   
    }
    else{
        
    }

        int i=0;
        int columns = 0;
        for(NSString *str in familyNames){
            columns += [[UIFont fontNamesForFamilyName:str] count];
        }
        columns = columns/2;
        int countOfColumn = 0;
        for(NSString *str in familyNames){
            fontNames = [[NSArray alloc] initWithArray:[UIFont fontNamesForFamilyName:str]];
            for(NSString *fontName in fontNames){
                
                PETextView *_fontView = [[PETextView alloc] init];
                if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
                   _fontView.fontSize=20.0;  
                }
                else{
                   _fontView.fontSize=12.0;  
                }
                _fontView.fontType = fontName;
                _fontView.fontName=str;
                _fontView.delegate=self;
                _fontView.backgroundColor = [UIColor clearColor];
                _fontView.tag = i;
                
                if (countOfColumn >= columns) {
                    xVal = 5.0;
                    yVal = yVal+fontViewHeight;
                    countOfColumn = 0;
                }
                countOfColumn++;
                _fontView.frame = CGRectMake(xVal, yVal, fontViewWidth, fontViewHeight);
                xVal = xVal+fontViewWidth+10;
                i++;
                self.fontTypeView = _fontView;
                [self.englishFontHstScrl addSubview:_fontView];
                [self.fontTypeView setNeedsLayout];
                [_fontView release];
            }
            
            [fontNames release];
        }
        [self.englishFontHstScrl setContentSize:CGSizeMake((columns)*(fontViewWidth+10), self.englishFontHstScrl.contentSize.height)];
   // }
    
    [self loadJapaneseFonts];
    [self loadChineseFonts];
    [familyNames release];    
}

-(void)loadJapaneseFonts {
        CGFloat xVal = 5.0;
        CGFloat yVal = 0.0;
        CGFloat fontViewWidth = 200.0f;
        CGFloat fontViewHeight = 60.0f;
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        fontViewWidth = 400.0f;
        fontViewHeight = 80.0f;   
    }
        int i=0;
   
    NSArray *fontFamilyNames=[[NSArray alloc] initWithObjects:@"Hiragino Kaku Gothic ProN",@"HuiFont", nil];
    for(NSString *str in fontFamilyNames){
         NSArray  * fontNames = [[NSArray alloc] initWithArray:[UIFont fontNamesForFamilyName:str]];
            for(NSString *fontName in fontNames){
                          
                NSLog(@"FontName in Japnaeese %@",fontName);
                PETextView *_fontView = [[PETextView alloc] init];
                if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
                 _fontView.fontSize=20.0;   
                }
                else{
                 _fontView.fontSize=12.0;   
                }
                _fontView.fontType = fontName;
                _fontView.fontName=str;
                _fontView.delegate=self;
                _fontView.backgroundColor = [UIColor clearColor];
                _fontView.tag = i;
                
                _fontView.frame = CGRectMake(xVal, yVal, fontViewWidth, fontViewHeight);
                xVal = xVal+fontViewWidth+10;
                i++;
                self.fontTypeView = _fontView;
                [self.japaneseFontHstScrl addSubview:_fontView];
                [self.fontTypeView setNeedsLayout];
                [_fontView release];
            }
    }
            
        [self.japaneseFontHstScrl setContentSize:CGSizeMake((i)*(fontViewWidth+10), self.japaneseFontHstScrl.contentSize.height)];
    
}

-(void)loadChineseFonts {
    NSArray *familyNames = [[NSArray alloc] initWithArray:[NSArray arrayWithObjects:@"Heiti SC",@"Heiti TC", nil]];
    NSLog(@"familyNames:%@",familyNames);

      NSArray *fontNames=nil;
        CGFloat xVal = 5.0;
        CGFloat yVal = 0.0;
        CGFloat fontViewWidth = 100.f;
        CGFloat fontViewHeight = 60.0f;
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        fontViewWidth = 120;
        fontViewHeight = 80.0f;   
    }
        int i=0;
        for(NSString *str in familyNames){
           // columns += [[UIFont fontNamesForFamilyName:str] count];
        }
       // columns = columns/2;
       // int countOfColumn = 0;
        for(NSString *str in familyNames){
            NSLog(@"font types Chinese:%@",str);

            fontNames = [[NSArray alloc] initWithArray:[UIFont fontNamesForFamilyName:str]];
            for(NSString *fontName in fontNames){
                
                PETextView *_fontView = [[PETextView alloc] init];
                if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
                    _fontView.fontSize=20.0;
                }
                else{
                  _fontView.fontSize=12.0;  
                }

                _fontView.fontType = fontName;
                _fontView.fontName=str;
                _fontView.delegate=self;
                _fontView.backgroundColor = [UIColor clearColor];
                _fontView.tag = i;
                
//                if (countOfColumn >= columns) {
//                    xVal = 5.0;
//                    yVal = yVal+fontViewHeight;
//                    countOfColumn = 0;
//                }
//                countOfColumn++;
                _fontView.frame = CGRectMake(xVal, yVal, fontViewWidth, fontViewHeight);
                xVal = xVal+fontViewWidth+10;
                i++;
                self.fontTypeView = _fontView;
                [self.chineseFontHstScrl addSubview:_fontView];
                [self.fontTypeView setNeedsLayout];
                [_fontView release];
            }
            
            [fontNames release];
        }
        [self.chineseFontHstScrl setContentSize:CGSizeMake((4)*(fontViewWidth+10), self.chineseFontHstScrl.contentSize.height)];
    
}
#pragma mark - Loading font types for ipad
-(void)loadFontTypesForiPad;{
    self.fontTypesHstView.hidden=NO;
    self.txtButton.selected=YES;
    self.satrStampBtn.selected=NO;
    self.penStampBtn.selected=NO;
    self.ballonStampBtn.selected=NO;
    self.stampBtn.selected=NO;
    self.pictureBtn.selected=NO;
    self.frameBtn.selected=NO;

    CGFloat xVal = 30.0;
    CGFloat yVal = 10.0;
    CGFloat fontViewWidth = 200.f;
    CGFloat fontViewHeight = 200.0f;
    for(int i=0;i<10;i++){
        PETextView *_fontView = [[PETextView alloc] init];
        _fontView.delegate=self;
        _fontView.backgroundColor = [UIColor clearColor];
        _fontView.tag = i;
        if (i!=0) {
            if (i%3 == 0) {
                xVal = 30.0;
                yVal = yVal+fontViewHeight;
            }
            
        }
        _fontView.frame = CGRectMake(xVal, yVal, fontViewWidth, fontViewHeight);
        xVal = xVal+fontViewWidth+10;
        self.fontTypeView = _fontView;
        [self.fontTypesHstView addSubview:_fontView];
        [self.fontTypeView setNeedsLayout];
        [_fontView release];
        _fontView=nil;
        
    }
}
#pragma mark -
- (IBAction)edit:(id)sender {
    if(isEditing){
        isEditing=NO;
        for(PEOriginalStampView *view in [self.scrollView subviews]){
            view.deleteBtn.hidden=YES;
        }
    }
    else{
        isEditing=YES;
        for(PEOriginalStampView *view in [self.scrollView subviews]){
            view.deleteBtn.hidden=NO;
        }
    }
}

- (IBAction)selectRange:(id)sender {
    self.fontTypesHstView.hidden=YES;

        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
            if([self.stampDelgate respondsToSelector:@selector(didRangeSelected)])
            {
                [self.stampDelgate didRangeSelected];
                 [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else{
            if([self.stampDelgate respondsToSelector:@selector(didRangeSelected)])
            {
                [self.stampDelgate didRangeSelected];
                  [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }

- (IBAction)takePicture:(id)sender {
    self.fontTypesHstView.hidden=YES;

    if ( (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
	{	
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Camera" message:@"Camera Not Available" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        return;
    }
    picker=[[UIImagePickerController alloc]init];
    self.picker.delegate=self;
    picker.sourceType=UIImagePickerControllerSourceTypeCamera;
    [self presentModalViewController:self.picker animated:YES];
    [self.picker release];

}

- (IBAction)penClicked:(id)sender {
    [self.addTextViewController.view removeFromSuperview];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        PEAddTextViewController *_addTextViewController = [[PEAddTextViewController alloc] initWithNibName:@"PEAddTextViewController_iPad" bundle:nil];
        _addTextViewController.delegate=self;
        _addTextViewController.view.frame = CGRectMake(0, 48, 768, 1004);
        self.addTextViewController=_addTextViewController;
        [_addTextViewController release];
        _addTextViewController=nil;
        [self.view addSubview:self.addTextViewController.view];
        NSLog(@"font type selected");
    }
    else{
        PEAddTextViewController *_addTextViewController = [[PEAddTextViewController alloc] initWithNibName:@"PEAddTextViewController" bundle:nil];
        _addTextViewController.delegate=self;
        _addTextViewController.fontType = self.fontTypeView.fontType;
        _addTextViewController.fontSize=self.fontTypeView.fontSize;
        _addTextViewController.view.frame = CGRectMake(0, 30, 320, 230);
        self.addTextViewController=_addTextViewController;
        [_addTextViewController release];
        _addTextViewController=nil;
        [self.view addSubview:self.addTextViewController.view];
        NSLog(@"font type selected"); 
    }
 
}

- (IBAction)photoAlbum:(id)sender {
    self.fontTypesHstView.hidden=YES;

    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        picker = [[UIImagePickerController alloc] init]; 
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; 
        picker.delegate = self; 
        
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
        popoverController=popover;
        popover.delegate = self;
        [popover presentPopoverFromRect:CGRectMake(539, 180, 300, 300)
                                 inView:self.view
               permittedArrowDirections:UIPopoverArrowDirectionAny
                               animated:YES];
        
        [self.picker release];
        
    }
    else{
        picker=[[UIImagePickerController alloc]init];
        self.picker.delegate=self;
        picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:self.picker animated:YES];
        [self.picker release];
        
    }
}



- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    //[self.view removeFromSuperview];
    //need to handle memory mgt.
}

#pragma  mark - PEOriginalStampViewDelegate
-(void)didSelectOriginalStamp:(PEOriginalStampView *)originalStamp{
    if(isEditing){
        //[self loadOriginalStamps:nil];
    }
    else{
        if([self.stampDelgate respondsToSelector:@selector(didStampSelected:)])
        {
            [self.stampDelgate didStampSelected:originalStamp.drawing];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
#pragma mark - tapGestures for PEStampView
-(void)stampAction:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
   
    PEStampView *view=(PEStampView *)gestureRecognizer.view;
    self.selectedStampView = view;
    
    if(self.selectedStampView.drawing.typeOfStamp != StampTypePen){
        
        if([self.stampDelgate respondsToSelector:@selector(didStampSelected:)]){
            [self.stampDelgate didStampSelected:view.drawing];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        self.sizeSlider.value =1.0;
        self.selectedStampView.drawing.scale=1.0f;
        self.selectedPalletImgView.image = [UIImage imageWithContentsOfFile:self.selectedStampView.drawing.stampPath];
        
        CGPoint _center = self.selectedPalletImgView.center;
        CGFloat newWidth = ((self.selectedStampView.frame.size.width*1.0)*(CGRectGetHeight(self.sizeSliderHostView.frame)-12))/(2*self.selectedStampView.frame.size.width);
        self.selectedPalletImgView.frame = CGRectMake(self.selectedPalletImgView.frame.origin.x, self.selectedPalletImgView.frame.origin.y, newWidth,newWidth);
        
        self.selectedPalletImgView.center=_center;
    }
    
    NSLog(@"stampAction");
}

#pragma mark - pickerviewDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInf
{   
    [self.picker dismissModalViewControllerAnimated:YES];
    [popoverController dismissPopoverAnimated:YES];
    self.isEditing=NO;//seting editing mode to false
    // [popoverController release];
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
    UIImage *reducedimage;
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        reducedimage = [img resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(768, 1024) interpolationQuality:kCGInterpolationDefault];   
    }
    else{
       reducedimage = [img resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(320, 480) interpolationQuality:kCGInterpolationDefault]; 
    }
    
    self.alertViewImage.image=reducedimage;
    self.saveImage=reducedimage;
    [self.view addSubview:self.alertView];
    [pool release];
}

#pragma mark - Delete button action
-(void)deleteBtnAction:(UIButton *)inParm {
    NSLog(@"delete");
    PEOriginalStampView *view=(PEOriginalStampView *)[inParm superview];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:view.drawing.stampPath error:nil];
    [view removeFromSuperview];
    [self loadOriginalStamps:nil];
}

#pragma  mark - popoverController delegate
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)inPopoverController{
    return YES;
}

#pragma mark - TextView Delegate
#pragma mark - Called after selecting on of the font type
-(void)didFontTypeSelected:(PETextView *)selectedFontType andTag:(int)inTag;{
    self.fontTypeView = selectedFontType;
    self.fontSizeSlider.value=0.0; 
    PEAddTextViewController *_addTextViewController ;
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        _addTextViewController = [[PEAddTextViewController alloc] initWithNibName:@"PEAddTextViewController_ipad" bundle:nil];

    }
    else{
      _addTextViewController = [[PEAddTextViewController alloc] initWithNibName:@"PEAddTextViewController" bundle:nil];
 
    }

    _addTextViewController.delegate=self;
    _addTextViewController.fontType =self.fontTypeView.fontType;// @"Hiragana";//
    _addTextViewController.fontSize=self.fontTypeView.fontSize;
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        _addTextViewController.view.frame = CGRectMake(0, 46, 768, 1004);
    }
    else{
        _addTextViewController.view.frame = CGRectMake(0, 34, 320, 224);
    }

    self.addTextViewController=_addTextViewController;
    [_addTextViewController release];
    _addTextViewController=nil;
    [self.view addSubview:self.addTextViewController.view];
}

#pragma mark - TextViewcontroller delegate- called after pressing cross or ok button
-(void)didStampTextSelected:(NSString *)inSelectedText fontName:(NSString*)inFontName fontColor:(UIColor*)inTextColor;{
    NSLog(@"In StampViewController The selectedt text is %@",inSelectedText);
    
    [self.addTextViewController.view removeFromSuperview];
    
    if ([self.stampDelgate respondsToSelector:@selector(didStampTextSelected:fontName:fontColor:)]) {
        [self.stampDelgate didStampTextSelected:inSelectedText fontName:inFontName fontColor:inTextColor];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)didCloseClicked;{
    [self.addTextViewController.view removeFromSuperview];
}

#pragma mark - didFrame selected
-(void)didFrameSelected:(PEPhotoFrameView *)inFrameView;{
    NSLog(@"frame is selected"); 
    if ([self.stampDelgate respondsToSelector:@selector(didFrameSelected:)]) {
        [self.stampDelgate didFrameSelected:inFrameView.photFrame];
        
    }
}

#pragma mark -
- (IBAction)sizeSlider:(id)sender;{
    
    UIView *_selectedView = (UIView *)self.selectedStampView;
    UISlider *_slider = (UISlider *)sender;
    CGFloat _sliderVal = _slider.value;
    
    self.selectedStampView.drawing.scale = _sliderVal;
       
    CGPoint _center = self.selectedPalletImgView.center;
    
    CGFloat newWidth = ((_selectedView.frame.size.width*_sliderVal)*(CGRectGetHeight(self.sizeSliderHostView.frame)-12))/(2*_selectedView.frame.size.width);
    self.selectedPalletImgView.frame = CGRectMake(self.selectedPalletImgView.frame.origin.x, self.selectedPalletImgView.frame.origin.y, newWidth,newWidth);
    
    self.selectedPalletImgView.center=_center;

}

- (IBAction)sliderOkClicked:(id)sender;{
    if([self.stampDelgate respondsToSelector:@selector(didStampSelected:)]){
        NSLog(@"pen scale %f",self.selectedStampView.drawing.scale);

        [self.stampDelgate didStampSelected:self.selectedStampView.drawing];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)alertCancel:(id)sender {
    [self.alertView removeFromSuperview];
    self.alertViewImage.image =nil;
}

- (IBAction)alertConfirm:(id)sender {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *PhotoDir = [documentsDirectory stringByAppendingPathComponent:@"PEPhotos"];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:PhotoDir])
        [[NSFileManager defaultManager] createDirectoryAtPath:PhotoDir withIntermediateDirectories:NO attributes:nil error:&error ]; 
    UIImage *thumbFrameImage;
  //  UIImage *thumbFrameRetinaImage;

    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
       thumbFrameImage  = [self.saveImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(140, 140) interpolationQuality:kCGInterpolationDefault];
      //  thumbFrameRetinaImage= [self.saveImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(280, 280) interpolationQuality:kCGInterpolationDefault];
    }
    else{
       thumbFrameImage  = [self.saveImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(120, 120) interpolationQuality:kCGInterpolationDefault];
       // thumbFrameRetinaImage= [self.saveImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(240, 240) interpolationQuality:kCGInterpolationDefault];
    }

     NSData *imageData = UIImagePNGRepresentation(thumbFrameImage);
    //NSData *imageRetinaData=UIImagePNGRepresentation(thumbFrameRetinaImage);
    if (imageData != nil) {
        NSString  *dateDes=[[NSDate date]description] ;
        [imageData writeToFile:[NSString stringWithFormat:@"%@/%@.png",PhotoDir,dateDes] atomically:YES];
       //  [imageRetinaData writeToFile:[NSString stringWithFormat:@"%@/%@@2x.png",PhotoDir,dateDes] atomically:YES];
        //        [thumbImage release];
        //        NSLog(@"thumb image retain count %d",[thumbImage retainCount]);
    }
    [self.alertView removeFromSuperview];
    self.alertViewImage.image=nil;
    [self loadOriginalStamps:nil];

}
@end
