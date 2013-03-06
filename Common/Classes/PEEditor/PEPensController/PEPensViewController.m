//
//  PEPensViewController.m
//  PEEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import "PEPensViewController.h"
#import "PESpecialView.h"

#define xOffset 0.0f;
#define yOffset 0.0f;
#define viewWidth 0.0f;
#define viewHeight 0.0f; 

@implementation PEPensViewController
@synthesize pensParentView;
@synthesize specialHstView;
@synthesize stdHstView;
@synthesize stdBtn;
@synthesize specialBtn;
@synthesize selectedPenImgView;
@synthesize selectedPenName;
@synthesize showPensBtn;
@synthesize brightnessSlider;
@synthesize rSlider;
@synthesize gSlider;
@synthesize bSlider;
@synthesize pensHstView;

@synthesize colorView;
@synthesize penView;
@synthesize isStandardSelected;
@synthesize brightnessVal;
@synthesize rVal;
@synthesize gVal;
@synthesize bVal;

@synthesize colors;
@synthesize selectedPalletImgView;
@synthesize specialView;
@synthesize sizeSlider;
@synthesize selectedView;
@synthesize pensHstScrl;
@synthesize spclHstScrl;
@synthesize standardObj;
@synthesize delegate;
@synthesize currentFrame;
@synthesize colorPalletsRGBVals;
@synthesize selectedBrush;
@synthesize isSpecialSelected;
@synthesize colorViewNew,currentModifiedColorView,lastSelectedColorView,lastSelectedSpecialView;


#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self = [super initWithNibName:@"PEPensViewController_iPad" bundle:nil];
        } 
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self = [super initWithNibName:@"PEPensViewController" bundle:nil];
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
    
    //assing deafult values to Standrad and special brushes;
    selectedSpecialBrush=@"special_1.png";
    selectedStandradBrush=@"pen_1_brush.png";
    //Allocating standard model class object......
    PEStandard *_obj = [[PEStandard alloc] init];
    self.standardObj = _obj;
    [_obj release];
    
    
    [self loadColorPallets];
       
    self.isStandardSelected=YES;
    
    self.stdBtn.selected=self.isStandardSelected;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self customizeSliderForiPhoneAndiPad:@"@2x"];
    }
    else{
        [self customizeSliderForiPhoneAndiPad:@""];
    }
    
    
    self.currentFrame = CGRectMake(self.selectedPalletImgView.frame.origin.x, self.selectedPalletImgView.frame.origin.y, self.selectedPalletImgView.frame.size.width, self.selectedPalletImgView.frame.size.height);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //Loading colors view for pen....
        [self loadColorsviewForiPad];
        //Loading pens style .....
        [self loadPensViewForiPad];
        //to load special view.....
        [self loadSpecialViewForiPad];
    } 
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        //Loading colors view for pen....
        [self loadColorsView];
        //Loading pens style .....
        [self loadPensView];
        //to load special view.....
        [self loadSpecialView];
    }
    
    
      
    self.pensHstView.alpha=0.0;;
    [self.pensParentView addSubview:self.stdHstView];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setStdBtn:nil];
    [self setSpecialBtn:nil];
    [self setSelectedPenImgView:nil];
    [self setSelectedPenName:nil];
    [self setShowPensBtn:nil];
    [self setBrightnessSlider:nil];
    [self setRSlider:nil];
    [self setGSlider:nil];
    [self setBSlider:nil];
    [self setPensParentView:nil];
    [self setSpecialHstView:nil];
    [self setStdHstView:nil];
    [self setPensHstView:nil];
    [self setBrightnessVal:nil];
    [self setRVal:nil];
    [self setGVal:nil];
    [self setBVal:nil];
    [self setSelectedPalletImgView:nil];
    [self setSizeSlider:nil];
    [self setPensHstScrl:nil];
    [self setSpclHstScrl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - cutomize slider for iphone
-(void)customizeSliderForiPhoneAndiPad:(NSString *)inType;{
    UIImage *sliderLeftTrackImage ;
    UIImage *sliderRightTrackImage ;
    //for red slider.....
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
      sliderLeftTrackImage = [[UIImage imageNamed: [NSString stringWithFormat:@"slide_hvr_red%@.png",inType]] stretchableImageWithLeftCapWidth: 18 topCapHeight: 0];
        sliderRightTrackImage = [[UIImage imageNamed:[NSString stringWithFormat:@"slide_hvr_b%@.png",inType]] stretchableImageWithLeftCapWidth: 18 topCapHeight: 0];
        [self.rSlider setMinimumTrackImage: sliderLeftTrackImage forState: UIControlStateNormal];
        [self.rSlider setMaximumTrackImage: sliderRightTrackImage forState: UIControlStateNormal];   
    }
    else{
        sliderLeftTrackImage = [[UIImage imageNamed: [NSString stringWithFormat:@"slide_hvr_red%@.png",inType]] stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
        sliderRightTrackImage = [[UIImage imageNamed:[NSString stringWithFormat:@"slide_hvr_b%@.png",inType]] stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
        [self.rSlider setMinimumTrackImage: sliderLeftTrackImage forState: UIControlStateNormal];
        [self.rSlider setMaximumTrackImage: sliderRightTrackImage forState: UIControlStateNormal]; 
    }
    //for green slider.....
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        sliderLeftTrackImage = [[UIImage imageNamed: [NSString stringWithFormat:@"slide_hvr_green%@.png",inType]] stretchableImageWithLeftCapWidth: 18 topCapHeight: 0];
        sliderRightTrackImage = [[UIImage imageNamed: [NSString stringWithFormat:@"slide_hvr_b%@.png",inType]] stretchableImageWithLeftCapWidth: 18 topCapHeight: 0];
        [self.gSlider setMinimumTrackImage: sliderLeftTrackImage forState: UIControlStateNormal];
        [self.gSlider setMaximumTrackImage: sliderRightTrackImage forState: UIControlStateNormal];  
    }
    else{
        sliderLeftTrackImage = [[UIImage imageNamed: [NSString stringWithFormat:@"slide_hvr_green%@.png",inType]] stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
        sliderRightTrackImage = [[UIImage imageNamed: [NSString stringWithFormat:@"slide_hvr_b%@.png",inType]] stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
        [self.gSlider setMinimumTrackImage: sliderLeftTrackImage forState: UIControlStateNormal];
        [self.gSlider setMaximumTrackImage: sliderRightTrackImage forState: UIControlStateNormal];  
    }
    //for green slider.....
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        sliderLeftTrackImage = [[UIImage imageNamed: [NSString stringWithFormat:@"slide_hvr_blue%@.png",inType]] stretchableImageWithLeftCapWidth: 18 topCapHeight: 0];
        sliderRightTrackImage = [[UIImage imageNamed: [NSString stringWithFormat:@"slide_hvr_b%@.png",inType]] stretchableImageWithLeftCapWidth: 18 topCapHeight: 0];
        [self.bSlider setMinimumTrackImage: sliderLeftTrackImage forState: UIControlStateNormal];
        [self.bSlider setMaximumTrackImage: sliderRightTrackImage forState: UIControlStateNormal];
    }
    else{
        sliderLeftTrackImage = [[UIImage imageNamed: [NSString stringWithFormat:@"slide_hvr_blue%@.png",inType]] stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
        sliderRightTrackImage = [[UIImage imageNamed: [NSString stringWithFormat:@"slide_hvr_b%@.png",inType]] stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
        [self.bSlider setMinimumTrackImage: sliderLeftTrackImage forState: UIControlStateNormal];
        [self.bSlider setMaximumTrackImage: sliderRightTrackImage forState: UIControlStateNormal];
    }
    //for brightness slider.....
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        sliderLeftTrackImage = [[UIImage imageNamed: [NSString stringWithFormat:@"slide%@.png",inType]] stretchableImageWithLeftCapWidth: 18 topCapHeight: 0];
        sliderRightTrackImage = [[UIImage imageNamed: [NSString stringWithFormat:@"slide_hvr_b%@.png",inType]] stretchableImageWithLeftCapWidth: 18 topCapHeight: 0];
        [self.brightnessSlider setMinimumTrackImage: sliderLeftTrackImage forState: UIControlStateNormal];
        [self.brightnessSlider setMaximumTrackImage: sliderRightTrackImage forState: UIControlStateNormal];  
    }
    else{
        sliderLeftTrackImage = [[UIImage imageNamed: [NSString stringWithFormat:@"slide%@.png",inType]] stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
        sliderRightTrackImage = [[UIImage imageNamed: [NSString stringWithFormat:@"slide_hvr_b%@.png",inType]] stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
        [self.brightnessSlider setMinimumTrackImage: sliderLeftTrackImage forState: UIControlStateNormal];
        [self.brightnessSlider setMaximumTrackImage: sliderRightTrackImage forState: UIControlStateNormal];   
    }
    //for size slider.....
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        self.sizeSlider.backgroundColor = [UIColor clearColor];
        sliderLeftTrackImage = [[UIImage imageNamed: [NSString stringWithFormat:@"slide_blck_b%@.png",inType]] stretchableImageWithLeftCapWidth: 18 topCapHeight: 0];
        sliderRightTrackImage = [[UIImage imageNamed:[NSString stringWithFormat:@"slide_hvr_b%@.png",inType]] stretchableImageWithLeftCapWidth: 18 topCapHeight: 0];
        [self.sizeSlider setMinimumTrackImage: sliderLeftTrackImage forState: UIControlStateNormal];
        [self.sizeSlider setMaximumTrackImage: sliderRightTrackImage forState: UIControlStateNormal];     
    }
    else{
        self.sizeSlider.backgroundColor = [UIColor clearColor];
        sliderLeftTrackImage = [[UIImage imageNamed: [NSString stringWithFormat:@"slide_blck_b%@.png",inType]] stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
        sliderRightTrackImage = [[UIImage imageNamed:[NSString stringWithFormat:@"slide_hvr_b%@.png",inType]] stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
        [self.sizeSlider setMinimumTrackImage: sliderLeftTrackImage forState: UIControlStateNormal];
        [self.sizeSlider setMaximumTrackImage: sliderRightTrackImage forState: UIControlStateNormal];     
    }

  
}

#pragma mark - Actions
- (IBAction)showMeMyPens:(id)sender {
    self.showPensBtn.selected=!self.showPensBtn.selected;
    if (self.showPensBtn.selected) {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            //Loading pens style .....
            [self loadPensViewForiPad];
        } 
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            //Loading pens style .....
            [self loadPensView];
            
        }
        self.pensHstView.alpha=1.0;
        [self.stdHstView insertSubview:self.pensHstView aboveSubview:self.stdHstView];
    }
    else{
        self.pensHstView.alpha=0.0;
    }
}

- (IBAction)specialClicked:(UIButton*)sender {
    
    //Make Special Selected YES
    self.isSpecialSelected=YES;
    //storing special slider value
    lastStandardSliderVal=self.sizeSlider.value;
    lastStandradFrame=self.selectedPalletImgView.frame;

    self.selectedPalletImgView.backgroundColor = [UIColor clearColor];
    //self.sizeSlider.value=0.0f;
    self.sizeSlider.value=lastSpecialSliderVal;
    sender.selected=YES;
    self.stdBtn.selected = NO;
    for(id childView in self.pensParentView.subviews){
        [childView removeFromSuperview];
    }
    [self.pensParentView addSubview:self.specialHstView];
    
    //Add Image to selectedPalletImgView
    if(self.lastSelectedSpecialView)
    {
        NSLog(@"self.lastSelectedSpecialView.specialImageView.image is %@",self.lastSelectedSpecialView.specialImageView.image);
        [self.selectedPalletImgView setBackgroundColor:[UIColor clearColor]];
        self.selectedPalletImgView.image = self.lastSelectedSpecialView.specialImageView.image;
        if(self.lastSelectedSpecialView.specialImageView.image){
            self.selectedPalletImgView.frame=lastSpecialFrame;
        }
    }
}

- (IBAction)standardClicked:(UIButton*)sender {
   
    //Make Special Selected NO
    self.isSpecialSelected=NO;
    
    //storing special slider value
    lastSpecialSliderVal=self.sizeSlider.value;
    lastSpecialFrame=self.selectedPalletImgView.frame;
    
    self.selectedPalletImgView.image = nil;
    self.colorView.colorImgView.image=nil;
    //self.sizeSlider.value=0.0f;
    self.sizeSlider.value=lastStandardSliderVal;
    sender.selected=YES;
    //self.stdBtn.highlighted=YES;
    self.specialBtn.selected=NO;
    //self.specialBtn.highlighted=NO;
    for(id childView in self.pensParentView.subviews){
        [childView removeFromSuperview];
    }
    [self.pensParentView addSubview:self.stdHstView];
    
    //Add Image to selectedPalletImgView
    if( self.lastSelectedColorView)
    {
        self.selectedPalletImgView.backgroundColor = self.lastSelectedColorView.backgroundColor;
         self.selectedPalletImgView.frame=lastStandradFrame;
    }
}

- (IBAction)okclicked:(id)sender {
    UIColor *color = self.colorView.backgroundColor; //line 1
    CGColorRef colorRef = [color CGColor];
    int _countComponents = CGColorGetNumberOfComponents(colorRef);
    if (_countComponents == 4) {
        const CGFloat *_components = CGColorGetComponents(colorRef);
        
        self.standardObj.rSliderVal = self.rSlider.value;
        self.standardObj.gSliderVal = self.gSlider.value;
        self.standardObj.bSliderVal = self.bSlider.value;
        self.standardObj.brightnessVal = self.brightnessSlider.value;
        self.standardObj.sizeSliderVal = self.sizeSlider.value;
        
        if (self.isSpecialSelected == NO) {
            self.standardObj.isStandard=YES;
        }
        else{
            self.standardObj.isStandard=NO;
        }
        // self.standardObj.brushName = self.selectedBrush;
        if (self.standardObj.isStandard == YES) {
            self.standardObj.tag=999;
            self.standardObj.brushName=selectedStandradBrush;
        }
        else{
            self.standardObj.tag=888;
             self.standardObj.brushName=selectedSpecialBrush;
        }

       
        
        if(_components[0]*255==self.rSlider.value &&_components[1]*255==self.gSlider.value && _components[2]*255==self.bSlider.value)
        {
            //Its same 
        }
        else
        {
            [self fillColorViewWithNewColor:self.selectedPalletImgView.backgroundColor];
        }
        
        //Send Delegate
        if ([self.delegate respondsToSelector:@selector(didDrawingControlClicked:)]) {
            [self.delegate didDrawingControlClicked:self.standardObj];
            NSLog(@"brushName=%@",self.standardObj.brushName);
            NSLog(@"sizeSliderVal=%f",self.standardObj.sizeSliderVal);
            NSLog(@"rSliderVal %f=",self.standardObj.rSliderVal);
            NSLog(@"gSliderVal %f=",self.standardObj.gSliderVal);
            NSLog(@"bSliderVal %f=",self.standardObj.bSliderVal);
            NSLog(@"brightnessVal %f=",self.standardObj.brightnessVal);
            NSLog(@"isStandard %d=",self.standardObj.isStandard);
            //NSLog(@"tag %d=",self.standardObj.tag);
        }
    }
}


#pragma mark - slider value changed
- (IBAction)brightnessChange:(id)sender {
    UISlider *_slider = (UISlider *)sender;
    self.brightnessVal.text = [NSString stringWithFormat:@"%d",(int)_slider.value];
    self.selectedPalletImgView.backgroundColor = [UIColor colorWithRed:[self.rVal.text floatValue]/255 green:[self.gVal.text floatValue]/255 blue:[self.bVal.text floatValue]/255 alpha:[self.brightnessVal.text floatValue]/255];
}

- (IBAction)rValChange:(id)sender {
    UISlider *_slider = (UISlider *)sender;
    self.rVal.text = [NSString stringWithFormat:@"%d",(int)_slider.value];
    self.selectedPalletImgView.backgroundColor = [UIColor colorWithRed:[self.rVal.text floatValue]/255 green:[self.gVal.text floatValue]/255 blue:[self.bVal.text floatValue]/255 alpha:[self.brightnessVal.text floatValue]/255];
}

- (IBAction)gValChange:(id)sender {
    UISlider *_slider = (UISlider *)sender;
    self.gVal.text = [NSString stringWithFormat:@"%d",(int)_slider.value];
    self.selectedPalletImgView.backgroundColor = [UIColor colorWithRed:[self.rVal.text floatValue]/255 green:[self.gVal.text floatValue]/255 blue:[self.bVal.text floatValue]/255 alpha:[self.brightnessVal.text floatValue]/255];
}

- (IBAction)bValChange:(id)sender {
    UISlider *_slider = (UISlider *)sender;
    self.bVal.text = [NSString stringWithFormat:@"%d",(int)_slider.value];
    self.selectedPalletImgView.backgroundColor = [UIColor colorWithRed:[self.rVal.text floatValue]/255 green:[self.gVal.text floatValue]/255 blue:[self.bVal.text floatValue]/255 alpha:[self.brightnessVal.text floatValue]/255];
}

- (IBAction)sizeChange:(id)sender {
    if(nil != self.selectedView){
        UIView *_selectedView = (UIView *)self.selectedView;
        UISlider *_slider = (UISlider *)sender;
        CGFloat _sliderVal = _slider.value;
        
        self.standardObj.sizeSliderVal = _sliderVal;
        
        CGPoint _center = self.selectedPalletImgView.center;
        
        CGFloat newWidth = ((_selectedView.frame.size.width*_sliderVal)*(CGRectGetHeight(sliderHostImageView.frame)-16))/(2*_selectedView.frame.size.width);
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
           self.selectedPalletImgView.frame = CGRectMake(self.selectedPalletImgView.frame.origin.x, self.selectedPalletImgView.frame.origin.y, newWidth-5,newWidth-15); 
        }
        else{
            self.selectedPalletImgView.frame = CGRectMake(self.selectedPalletImgView.frame.origin.x, self.selectedPalletImgView.frame.origin.y, newWidth,newWidth);
        }
        self.selectedPalletImgView.center=_center;
        self.currentFrame = self.selectedPalletImgView.frame;
    }  
}

#pragma mark - load color pallets
-(void)loadColorPallets;{
    //Allocating array which holds different colors rgbs for pallets....
    NSMutableArray *_rgbs = [[NSMutableArray alloc] initWithObjects:@"189,4,0",@"255,193,0",@"144,210,79",@"0,179,238",@"0,36,93",@"0,4,0",@"255,4,0",@"255,255,0",@"0,175,75",@"0,112,192",@"109,52,158",@"255,255,255" ,nil];
    NSMutableArray *_arr = [[NSMutableArray alloc] init];
    self.colorPalletsRGBVals = _arr;
    [_arr release];
   
    for(NSString *rgbVal in _rgbs){
        PalletColor *_palletColor = [[PalletColor alloc] init];
        NSArray *arr = [rgbVal componentsSeparatedByString:@","];
        CGFloat _rVal = [[arr objectAtIndex:0] floatValue];
        CGFloat _gVal = [[arr objectAtIndex:1] floatValue];
        CGFloat _bVal = [[arr objectAtIndex:2] floatValue];
        
        _palletColor.redVal = _rVal/255;
        _palletColor.greenVal = _gVal/255;
        _palletColor.blueVal = _bVal/255;
        [self.colorPalletsRGBVals addObject:_palletColor];
        [_palletColor release];
    }
    [_rgbs release];
}

#pragma mark - 
-(void)loadColorsView
{
    self.pensHstView.alpha=0.0;
    CGFloat xVal = 20.0f;
    CGFloat yVal = 60.0f;
    CGFloat colorViewWidth=32.0f;
    CGFloat colorViewHeight=30.0f;
    for(int i=1;i<13;i++){
        if(xVal>200){
            xVal = 20.0f;
            yVal = yVal+colorViewHeight+2;

        }
        PEColorView *_colorView = [[PEColorView alloc] init];
        self.colorViewNew=_colorView;
        _colorView.isViewWithColor=YES;
        _colorView.delegate=self;
        _colorView.tag=i;
         
        PalletColor *_colorObj= [self.colorPalletsRGBVals objectAtIndex:i-1];
        UIColor *_color = [UIColor colorWithRed:_colorObj.redVal green:_colorObj.greenVal  blue:_colorObj.blueVal  alpha:1.0];
        _colorView.backgroundColor =_color;
        
        if(nil == self.selectedView)
        {
            self.colorView=_colorView;
            self.selectedView = _colorView;
            self.selectedPalletImgView.backgroundColor = _colorView.backgroundColor;
            
            UIColor *color = _colorView.backgroundColor;
            CGColorRef colorRef = [color CGColor];
            int _countComponents = CGColorGetNumberOfComponents(colorRef);
            if (_countComponents == 4)
            {
                const CGFloat *_components = CGColorGetComponents(colorRef);
                self.rSlider.value = _components[0]*255;
                self.rVal.text = [NSString stringWithFormat:@"%d",(int)self.rSlider.value];
                self.gSlider.value = _components[1]*255;
                self.gVal.text = [NSString stringWithFormat:@"%d",(int)self.gSlider.value];
                self.bSlider.value = _components[2]*255;
                self.bVal.text = [NSString stringWithFormat:@"%d",(int)self.bSlider.value];
                self.brightnessSlider.value = _components[3]*255;
                self.brightnessVal.text = [NSString stringWithFormat:@"%d",(int)self.brightnessSlider.value];
            }
        }
        
        _colorView.frame = CGRectMake(xVal, yVal, colorViewWidth, colorViewHeight);
        xVal=xVal+colorViewWidth+2;
        [self.stdHstView insertSubview:_colorView belowSubview:self.pensHstView];
        [_colorView setNeedsLayout];
        [_colorView release];
        _colorView=nil;
        
        if(i==1)
        {
            self.lastSelectedColorView = self.colorView;
        }
    }

    xVal = 235;
    yVal  = 60;
    int j=200;//To assign tag..
    for(int i=1;i<5;i++){
        if(xVal>280){
            xVal = 235.0f;
            yVal = yVal+colorViewHeight+2;
            
        }
        PEColorView *_colorView = [[PEColorView alloc] init];
        self.colorViewNew=_colorView;
        _colorView.isViewWithColor=NO;
        _colorView.delegate=self;
        _colorView.tag=j++;
        _colorView.backgroundColor=[UIColor whiteColor];
        _colorView.frame = CGRectMake(xVal, yVal, colorViewWidth, colorViewHeight);
        xVal=xVal+colorViewWidth+2;
        [self.stdHstView insertSubview:_colorView belowSubview:self.pensHstView];
        [_colorView setNeedsLayout];
        [_colorView release];
        _colorView=nil;
    }
}

-(void)loadPensView;{
    //This array holds pen names.....
    NSMutableArray *_penNames = [[NSMutableArray alloc] initWithObjects:@"Brush",@"Crayon",@"Default",@"Double line",@"Highlight",@"Inner White",@"Spray",nil];
    
    NSArray *subViews=[self.pensHstScrl subviews];
    for(UIView *subView in subViews){
        if([subView isKindOfClass:[PEPenView class]]){
        [subView removeFromSuperview];
        }
    }
    CGFloat xVal = 4.0f;
    CGFloat yVal = 6.0f;
    CGFloat penViewWidth=268.0f;
    CGFloat penViewHeight=45.0f; 
    
    
    for(int i=1;i<8;i++){
        PEPenView *_penView = [[PEPenView alloc] init];
        _penView.delegate=self;
        _penView.tag=i;
        _penView.backgroundColor = [UIColor clearColor];
        _penView.penImgName = [NSString stringWithFormat:@"pen_%d.png",i];
        _penView.penName = [_penNames objectAtIndex:i-1];
        _penView.penImgForDrawing = [NSString stringWithFormat:@"pen_%d_brush.png",i];
        if (i==1) {
            self.selectedPenImgView.image = [UIImage imageNamed:_penView.penImgName];
            self.selectedPenName.text = _penView.penName;
            self.standardObj.brushName = _penView.penImgForDrawing;
            selectedStandradBrush=_penView.penImgForDrawing;
        }
        self.penView=_penView;
        self.penView.frame = CGRectMake(xVal, yVal, penViewWidth, penViewHeight);
        yVal = yVal+penViewHeight+1.0;
        
        [self.pensHstScrl addSubview:_penView];
        [_penView setNeedsLayout];
        [_penView release];
        _penView=nil;
    }
    [self.pensHstScrl setContentSize:CGSizeMake(penViewWidth, yVal+20)];
    [_penNames release];
    _penNames=nil;
}

-(void)loadSpecialView{
    CGFloat xVal = 0.0f;
    CGFloat yVal = 0.0f;
    CGFloat specialViewWidth=55.0f;
    CGFloat specialViewHeight=55.0f;
    for(int i=1;i<43;i++){
        if (i!=1) {
            if(i%6 == 0){
                xVal = 0.0f;
                yVal = yVal+specialViewHeight+20;
            }
        }
        
        PESpecialView *_specialView = [[PESpecialView alloc] init];
        _specialView.delegate=self;
        _specialView.tag=i;
        self.specialView=_specialView;
        self.specialView.colorName=[NSString stringWithFormat:@"special_%d.png",i];
        //_colorView.backgroundColor = [UIColor clearColor];
        _specialView.frame = CGRectMake(xVal, yVal, specialViewWidth, specialViewHeight);
        xVal=xVal+specialViewWidth+10;
        //[self.stdHstView insertSubview:self._specialView belowSubview:self.pensHstView];
        self.specialHstView.backgroundColor=[UIColor blackColor];
       
        [self.spclHstScrl addSubview:self.specialView];
        [self.specialView setNeedsLayout];
        [_specialView release];
        _specialView=nil;
        
        if(i==1)  // Initially Make first as selected
        {
            self.lastSelectedSpecialView =  self.specialView;
        }
    }
    [self.spclHstScrl setContentSize:CGSizeMake(xVal, yVal+50)];
}

#pragma mark - load pen,special and color view for iPad
-(void)loadColorsviewForiPad;{
    self.pensHstView.alpha=0.0;
    CGFloat xVal = 102.0f;
    CGFloat yVal = 154.0f;
    CGFloat colorViewWidth=64.0f;
    CGFloat colorViewHeight=60.0f;
    for(int i=1;i<13;i++){
        if(xVal>500){
            xVal = 102.0f;
            yVal = yVal+colorViewHeight+2;
            
        }
        PEColorView *_colorView = [[PEColorView alloc] init];
        _colorView.delegate=self;
        _colorView.tag=i;
        self.colorViewNew=_colorView;
        _colorView.isViewWithColor=YES;
        
            PalletColor *_colorObj= [self.colorPalletsRGBVals objectAtIndex:i-1];
            UIColor *_color = [UIColor colorWithRed:_colorObj.redVal green:_colorObj.greenVal  blue:_colorObj.blueVal  alpha:1.0];
            _colorView.backgroundColor =_color;
        //_colorView.backgroundColor = [UIColor clearColor];
        if(nil == self.selectedView)
        {
            self.colorView=_colorView;
            self.selectedView = _colorView;
            self.selectedPalletImgView.backgroundColor = _colorView.backgroundColor;
            
            UIColor *color = _colorView.backgroundColor;
            CGColorRef colorRef = [color CGColor];
            int _countComponents = CGColorGetNumberOfComponents(colorRef);
            if (_countComponents == 4)
            {
                const CGFloat *_components = CGColorGetComponents(colorRef);
                self.rSlider.value = _components[0]*255;
                self.rVal.text = [NSString stringWithFormat:@"%d",(int)self.rSlider.value];
                self.gSlider.value = _components[1]*255;
                self.gVal.text = [NSString stringWithFormat:@"%d",(int)self.gSlider.value];
                self.bSlider.value = _components[2]*255;
                self.bVal.text = [NSString stringWithFormat:@"%d",(int)self.bSlider.value];
                self.brightnessSlider.value = _components[3]*255;
                self.brightnessVal.text = [NSString stringWithFormat:@"%d",(int)self.brightnessSlider.value];
            }
        }

        _colorView.frame = CGRectMake(xVal, yVal, colorViewWidth, colorViewHeight);
        xVal=xVal+colorViewWidth+4;
        [self.stdHstView insertSubview:_colorView belowSubview:self.pensHstView];  
        [self.colorView setNeedsLayout];
        [_colorView release];
        _colorView=nil;
        if(i==1)
        {
            self.lastSelectedColorView = self.colorView;
        }
    }
    xVal = 534;
    yVal  = 156;
    int j=200;//To assign tag..

    for(int i=1;i<5;i++){
        if(xVal>656){
            xVal = 534;
            yVal = yVal+colorViewHeight+1;
            
        }
        PEColorView *_colorView = [[PEColorView alloc] init];
        _colorView.delegate=self;
        _colorView.isViewWithColor=NO;
        self.colorViewNew=_colorView;
        self.colorViewNew.tag=j++;
        _colorView.backgroundColor=[UIColor whiteColor];
        //_colorView.backgroundColor = [UIColor clearColor];
        _colorView.frame = CGRectMake(xVal, yVal, colorViewWidth, colorViewHeight);
        xVal=xVal+colorViewWidth+2;
        [self.stdHstView insertSubview:_colorView belowSubview:self.pensHstView];
        [self.colorView setNeedsLayout];
        [_colorView release];
        _colorView=nil;
    }
}

-(void)loadPensViewForiPad;{
    //This array holds pen names.....
    NSMutableArray *_penNames = [[NSMutableArray alloc] initWithObjects:@"Brush",@"Cryon",@"Default",@"Double line",@"Highlight",@"innerwhite",@"Spray",nil];
    
    NSArray *subViews=[self.pensHstScrl subviews];
    for(UIView *subView in subViews){
        if([subView isKindOfClass:[PEPenView class]]){
            [subView removeFromSuperview];
        }
    }

    CGFloat xVal = 4.0f;
    CGFloat yVal = 70.0f;
    CGFloat penViewWidth=468.0f;
    CGFloat penViewHeight=45.0f; 
    for(int i=1;i<8;i++){
        PEPenView *_penView = [[PEPenView alloc] init];
        _penView.delegate=self;
        _penView.tag=i;
        _penView.backgroundColor = [UIColor clearColor];
        _penView.penImgName = [NSString stringWithFormat:@"pen_%d@2x.png",i];
        _penView.penName = [_penNames objectAtIndex:i-1];
        _penView.penImgForDrawing = [NSString stringWithFormat:@"pen_%d_brush-hd.png",i];
        if (i==1) {
            self.selectedPenImgView.image = [UIImage imageNamed:_penView.penImgName];
            self.selectedPenName.text = _penView.penName;
            self.standardObj.brushName = _penView.penImgForDrawing;
            selectedStandradBrush=_penView.penImgForDrawing;
        }
        self.penView=_penView;
        self.penView.frame = CGRectMake(xVal, yVal, penViewWidth, penViewHeight);
        yVal = yVal+penViewHeight+20.0;
        
        [self.pensHstScrl addSubview:_penView];
        [_penView setNeedsLayout];
        [_penView release];
        _penView=nil;
    }
    [self.pensHstScrl setContentSize:CGSizeMake(penViewWidth, yVal)];
    [_penNames release];
    _penNames=nil;
}

-(void)loadSpecialViewForiPad;{
    CGFloat xVal = 10.0f;
    CGFloat yVal = 30.0f;
    CGFloat specialViewWidth=110.0f;
    CGFloat specialViewHeight=110.0f;
    for(int i=1;i<43;i++){
        if (i!=1) {
            if(i%7 == 0){
                xVal = 10.0f;
                yVal = yVal+specialViewHeight+30;
                
            }
        }
        
        PESpecialView *_specialView = [[PESpecialView alloc] init];
        _specialView.delegate=self;
        _specialView.tag=i;
        self.specialView=_specialView;
        self.specialView.colorName=[NSString stringWithFormat:@"special_%d@2x.png",i];
        _specialView.frame = CGRectMake(xVal, yVal, specialViewWidth, specialViewHeight);
        xVal=xVal+specialViewWidth+10;
        self.specialHstView.backgroundColor=[UIColor blackColor];
        [self.spclHstScrl addSubview:self.specialView];
        [self.specialView setNeedsLayout];
        [_specialView release];
        _specialView=nil;
        if(i==1)  // Initially Make first as selected
        {
            self.lastSelectedSpecialView =  self.specialView;
        }

    }
    [self.spclHstScrl setContentSize:CGSizeMake(xVal, yVal+100)];
    
}

#pragma mark - Color view delegate
-(void)didColorSelected:(PEColorView *)inView andTag:(int)inTag;{
    
    self.selectedPalletImgView.image=nil;
    self.colorView.colorImgView.image = nil;
    
    //To set is filled with color for modified view
    self.currentModifiedColorView.isViewWithColor = YES;
    inView.colorImgView.image = [UIImage imageNamed:@"s_color_hvr.png"];
    self.colorView = inView;
    self.selectedView = inView;
    self.isSpecialSelected=NO;

    self.selectedPalletImgView.frame=self.currentFrame;
    
    self.selectedPalletImgView.backgroundColor = inView.backgroundColor;
    
    UIColor *color = inView.backgroundColor; //line 1
   
    CGColorRef colorRef = [color CGColor];
    int _countComponents = CGColorGetNumberOfComponents(colorRef);
    
    if (_countComponents == 4) {
        const CGFloat *_components = CGColorGetComponents(colorRef);
        self.rSlider.value = _components[0]*255;
        self.rVal.text = [NSString stringWithFormat:@"%d",(int)self.rSlider.value];
        self.gSlider.value = _components[1]*255;
        self.gVal.text = [NSString stringWithFormat:@"%d",(int)self.gSlider.value];
        self.bSlider.value = _components[2]*255;
        self.bVal.text = [NSString stringWithFormat:@"%d",(int)self.bSlider.value];
    }
    
    CGPoint _center = self.selectedPalletImgView.center;
    
    UIView *view = (UIView*)self.selectedView;
    
    CGFloat newWidth = ((view.frame.size.width*1.0)*(CGRectGetHeight(sliderHostImageView.frame)-16))/(2*view.frame.size.width);
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
     self.selectedPalletImgView.frame = CGRectMake(self.selectedPalletImgView.frame.origin.x, self.selectedPalletImgView.frame.origin.y, newWidth-5,newWidth-15);    
    }
    else{
       self.selectedPalletImgView.frame = CGRectMake(self.selectedPalletImgView.frame.origin.x, self.selectedPalletImgView.frame.origin.y, newWidth,newWidth);  
    }

   
    
    self.selectedPalletImgView.center=_center;
    self.sizeSlider.value = 1.0;
    
    //Make it selected
    self.lastSelectedColorView = inView;
}

#pragma mark - Fill color pallets
-(void)fillColorViewWithNewColor:(UIColor *)inColor;{
    BOOL isViewBlank=NO;
    for(UIView *view in self.stdHstView.subviews){
        if(view.tag>=200 && view.tag<204){
            PEColorView *view1=(PEColorView*)view;
            if(view1.isViewWithColor==NO && [view1 isKindOfClass:[PEColorView class]]){
                isViewBlank = YES;
                self.currentModifiedColorView = view1;
                view1.backgroundColor = inColor;
                return;
            }
        }
    }
    
    //If all four views are colored...
    if(isViewBlank==NO){
        //To insert new color at index...
        PEColorView *view1=(PEColorView*)[self.stdHstView viewWithTag:200];
        PEColorView *view2=(PEColorView*)[self.stdHstView viewWithTag:201];
        PEColorView *view3=(PEColorView*)[self.stdHstView viewWithTag:202];
        PEColorView *view4=(PEColorView*)[self.stdHstView viewWithTag:203];
        view4.backgroundColor = view3.backgroundColor;
        view3.backgroundColor = view2.backgroundColor;
        view2.backgroundColor = view1.backgroundColor;
        view1.backgroundColor = inColor;
        view1.isViewWithColor = NO;
        [self fillColorViewWithNewColor:inColor];
    }
}

#pragma mark - special view delegate
-(void)didSpecialSelected:(PESpecialView *)inView andTag:(int)inTag;{
    
    //Make previous Selection NO
    if(self.lastSelectedSpecialView)
    {
        self.lastSelectedSpecialView.specialImageView.hidden = NO;
        self.lastSelectedSpecialView.selectedSpecialImgView.hidden = YES;
    }
    brightnessSlider.value=255.0f;
    inView.selectedSpecialImgView.image=nil;
    inView.selectedSpecialImgView.image = [UIImage imageNamed:@"special_hvr.png"];
    
    //Make it Visible
    inView.specialImageView.hidden = NO;
    inView.selectedSpecialImgView.hidden = NO;
   
    self.standardObj.brushName = inView.colorName;
    selectedSpecialBrush= inView.colorName;
    
    self.selectedView = inView;
    self.isSpecialSelected=YES;
   // self.selectedPalletImgView.frame=self.currentFrame;
    self.selectedPalletImgView.backgroundColor = [UIColor clearColor];
    self.selectedPalletImgView.image = inView.specialImageView.image;
    self.selectedBrush = inView.colorName;
    self.selectedPalletImgView.frame=self.currentFrame;
    CGPoint _center = self.selectedPalletImgView.center;
    UIView *view = (UIView*)self.selectedView;
    
    CGFloat newWidth = ((view.frame.size.width*1.0)*(CGRectGetHeight(sliderHostImageView.frame)))/(2*view.frame.size.width);
    self.selectedPalletImgView.frame = CGRectMake(self.selectedPalletImgView.frame.origin.x, self.selectedPalletImgView.frame.origin.y, newWidth,newWidth);
    
    self.selectedPalletImgView.center=_center;
    self.sizeSlider.value = 1.0;

    
    //Make it selected
    self.lastSelectedSpecialView = inView;
}

#pragma mark - Pen view delegate
-(void)didPenStyleSelected:(PEPenView *)inView andTag:(int)inTag;{
    
    //First Hide the Pen View
    self.pensHstView.alpha=0.0;
    self.showPensBtn.selected=!self.showPensBtn.selected;

    self.standardObj.brushName = inView.penImgForDrawing;
    //storing selected brush.
    selectedStandradBrush=inView.penImgForDrawing;
    NSLog(@"selectedStandradBrush: %@", selectedStandradBrush);
    if([selectedStandradBrush isEqualToString:@"pen_5_brush.png"]){
        brightnessSlider.value=10.0f;
        self.brightnessVal.text=@"10";
    }
    else{
        brightnessSlider.value=255.0f;
        self.brightnessVal.text=@"255";
    }
    self.penView=inView;
    self.selectedBrush = inView.penName;

    self.selectedPenImgView.image = inView.penImgView.image;
    self.selectedPenName.text = inView.penStyleNameLbl.text;
}

#pragma mark - 
- (UIImage*)imageWithImage:(UIImage*)image  scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - Dealloc
- (void)dealloc
{
    self.currentModifiedColorView = nil;
    self.colorView=nil;
    self.colorViewNew=nil;
    self.penView=nil;
    self.specialView=nil;
    self.selectedView=nil;
    self.colorPalletsRGBVals=nil;
    
    self.lastSelectedColorView = nil;
    self.lastSelectedSpecialView = nil;
    
    [stdBtn release];
    [specialBtn release];
    [selectedPenImgView release];
    [selectedPenName release];
    [showPensBtn release];
    [brightnessSlider release];
    [rSlider release];
    [gSlider release];
    [bSlider release];
    [pensParentView release];
    [specialHstView release];
    [stdHstView release];
    [pensHstView release];
    [brightnessVal release];
    [rVal release];
    [gVal release];
    [bVal release];
    [selectedPalletImgView release];
    [sizeSlider release];
    [pensHstScrl release];
    [spclHstScrl release];
    [super dealloc];
}


@end

#pragma mark - PEStandard
@implementation PEStandard

@synthesize rSliderVal,gSliderVal,bSliderVal,brightnessVal,sizeSliderVal;
@synthesize brushName;
@synthesize isStandard,tag;

- (void)dealloc {
    
    [super dealloc];
}

@end
