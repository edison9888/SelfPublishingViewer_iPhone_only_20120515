//
//  PEAddTextViewController.m
//  PhotoEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import "PEAddTextViewController.h"
#import "PEPensViewController.h"
@implementation PEAddTextViewController
@synthesize addTxtHstView;
@synthesize addTextView;
@synthesize colorsHstScrl;
@synthesize okBtn;
@synthesize closeBtn;
@synthesize selectedColorBtn;
@synthesize isTextColorSelected;
@synthesize textColorHstView;
@synthesize textColors;
@synthesize delegate;
@synthesize fontType;
@synthesize fontSize;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self = [super initWithNibName:@"PEAddTextViewController_iPad" bundle:nil];
        } 
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self = [super initWithNibName:@"PEAddTextViewController" bundle:nil];
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
    self.navigationController.navigationBarHidden=YES;
    [super viewDidLoad];
    self.addTextView.font = [UIFont fontWithName:self.fontType size:self.fontSize];
    [self.addTextView becomeFirstResponder];
    
    NSMutableArray *_arr = [[NSMutableArray alloc] init];
    self.textColors = _arr;
    [_arr release];
    
    //filling model class with colors.......
    
    NSArray *resources = [self getDataWithRGB];
    for(NSDictionary *_dict in resources){
        Textcolor *_textColor = [[Textcolor alloc] init];
        _textColor.colorName = [_dict valueForKey:@"imageName"];
        NSArray *rgbs = [[_dict valueForKey:@"rgb"] componentsSeparatedByString:@","];
        _textColor.red = [[rgbs objectAtIndex:0] floatValue];
        _textColor.green = [[rgbs objectAtIndex:1] floatValue];
        _textColor.blue= [[rgbs objectAtIndex:2] floatValue];
        [self.textColors addObject:_textColor];
        [_textColor release];
        
    }
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self addSubViewsForiPad];
        // [self addSubViewsForiPhone];
    } 
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self addSubViewsForiPhone];
    }
   
}

- (void)viewDidUnload
{
    [self setAddTxtHstView:nil];
    [self setAddTextView:nil];
    [self setColorsHstScrl:nil];
    [self setOkBtn:nil];
    [self setCloseBtn:nil];
    [self setTextColorHstView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)closeClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didCloseClicked)]) {
        [self.delegate didCloseClicked];
    }
}

- (IBAction)okClicked:(id)sender {
    if([self.addTextView.text length]>0){
        if ([self.delegate respondsToSelector:@selector(didStampTextSelected:fontName:fontColor:)]) {
            [self.delegate didStampTextSelected:self.addTextView.text fontName:self.addTextView.font.fontName fontColor:self.addTextView.textColor];
        }
    }
    else {
        UIAlertView *alertViw=[[UIAlertView alloc]initWithTitle:@"Please enter text" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertViw show];
        [alertViw release];
    }
}


-(void)colorsClicked:(UIButton *)inSender;{
    UIButton *_btn = (UIButton *)inSender;
    self.selectedColorBtn = _btn;
    self.isTextColorSelected=YES;
    
    Textcolor *_textColor = [self.textColors objectAtIndex:inSender.tag];
    
    UIImage *_image = self.selectedColorBtn.imageView.image;
    NSLog(@"red green and blue is:%f,%f and %f",_textColor.red,_textColor.green,_textColor.blue);
    UIColor *_color = [UIColor colorWithRed:_textColor.red/255 green:_textColor.green/255 blue:_textColor.blue/255 alpha:1.0];
    NSLog(@"color is:%@",_image.description);
    [self.addTextView setTextColor:_color];
    //self.addTextView.textColor = _color;
    
}

- (IBAction)nextController:(id)sender {
    PEPensViewController *_pensViewController = [[PEPensViewController alloc] initWithNibName:@"PEPensViewController" bundle:nil];
    [self.navigationController pushViewController:_pensViewController animated:YES];
    [_pensViewController release];
}
#pragma mark - text field delegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    
}
- (void)textViewDidEndEditing:(UITextView *)textView;{
    [textView resignFirstResponder];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;{
    self.addTextView=textView;
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
//    if (self.isTextColorSelected) {
//        UIImage *_image = self.selectedColorBtn.imageView.image;
//        UIColor *_color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"s_color_1.png"]];
//        NSLog(@"color is:%@",_image.description);
//        self.addTextView.textColor = _color;//[UIColor colorWithPatternImage:_image]; 
//    }
//    else{
//        self.addTextView.textColor = [UIColor blackColor];
//    }
    return YES;
}
#pragma mark - 
-(void)addSubViewsForiPhone;{
    CGFloat xVal = 0.0f;
    CGFloat yVal = 2.0f;
    CGFloat btnWidth=30.0f;
    CGFloat btnHeight=30.0f;
    for(int i=0;i<[self.textColors count];i++){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        Textcolor *_textColor = [self.textColors objectAtIndex:i];
        btn.frame = CGRectMake(xVal, yVal, btnWidth, btnHeight);
        UIImageView *_btnImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_textColor.colorName]];
        btn.tag = i;
        //UIImageView *colorBgImgView = [[UIImageView alloc] initWithImage:<#(UIImage *)#>
        _btnImgView.center=btn.center;
        [btn setImage:[UIImage imageNamed:_textColor.colorName] forState:UIControlStateNormal];
        xVal = xVal+btnWidth-1.5;
        [btn addTarget:self action:@selector(colorsClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.colorsHstScrl addSubview:btn];
        [_btnImgView release];
    }
    [self.colorsHstScrl setContentSize:CGSizeMake(xVal, yVal)];
}
-(void)addSubViewsForiPad;{
    CGFloat xVal = 30.0f;
    CGFloat yVal = 2.0f;
    CGFloat btnWidth=56.0f;
    CGFloat btnHeight=60.0f;
    for(int i=0;i<[self.textColors count];i++){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        Textcolor *_textColor = [self.textColors objectAtIndex:i];
        btn.frame = CGRectMake(xVal, yVal, btnWidth, btnHeight);
        UIImageView *_btnImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_textColor.colorName]];
        btn.tag = i;
        //UIImageView *colorBgImgView = [[UIImageView alloc] initWithImage:<#(UIImage *)#>
        _btnImgView.center=btn.center;
        NSArray *_arr = [_textColor.colorName componentsSeparatedByString:@"."];
        NSString *imageName = [_arr objectAtIndex:0];
        NSLog(@"imageName:%@",imageName);
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@@2x.png",imageName]] forState:UIControlStateNormal];
        xVal = xVal+btnWidth+2.0;
        [btn addTarget:self action:@selector(colorsClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.colorsHstScrl addSubview:btn];
        [_btnImgView release];
    }
    [self.colorsHstScrl setContentSize:CGSizeMake(xVal, yVal)];
}
- (void)dealloc {
    [textColorHstView release];
    [super dealloc];
}
#pragma mark - Resources from plist
-(NSArray *)getDataWithRGB;{
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PEColorPaleteData" ofType:@"plist"]];
    return array;
}
@end

@implementation Textcolor
@synthesize red,green,blue;
@synthesize colorName;

@end
