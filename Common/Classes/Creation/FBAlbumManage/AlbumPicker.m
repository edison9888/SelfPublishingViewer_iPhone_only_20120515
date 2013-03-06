//
//  AlbumPicker.m
//  Demo_PhotoApp
//
//  Created by Apple on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AlbumPicker.h"
#import "ImageAdjustMent.h"
#import "ClubView.h"
#import "UIView+NIB.h"
#import "DCImageView.h"
#import "RootPane.h"
#import "ForIphoneAppDelegate.h"

#define XSpace 2.0
#define YSpace 2.0
#define ThumbInRow 4

#define PAGEWIDTH 70.0
#define PAGEHEIGHT 70.0

#define THUMBNAIL_WIDTH 93
#define THUMBNAIL_HEIGHT 93
#define THUMBNAIL_PADDING 10

@implementation AlbumPicker

@synthesize  aaa,photosArray,nextDictprev;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
	
     self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"back", nil) style:UIBarButtonItemStylePlain target:self action:@selector(Back_Btn_Clicked:)];
	
    //photosArray = [[NSMutableArray alloc] initWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"8",nil];   
    selectedPhotos = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view from its nib.
    
    [btnDownload setTitle:NSLocalizedString(@"downLoad", nil) forState:UIControlStateNormal];
    [btnSelectAll setTitle:NSLocalizedString(@"sellectAll", nil) forState:UIControlStateNormal];
    [btnSelectNone setTitle:NSLocalizedString(@"selectNone", nil) forState:UIControlStateNormal];
    
    //NSLog(@"%@",photosArray);
    clubArray = [[NSMutableArray alloc]init];
    [self createView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
// 	[self.navigationController setNavigationBarHidden:YES animated:NO];
//    scrollView.frame = CGRectMake(0, 44, 320, 324);
    
    self.navigationItem.title = NSLocalizedString(@"albumsTitle", nil);
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    progressView = nil;
    [progressView release];
    lableProgress = nil;
    [lableProgress release];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Create Custom ScrollView

-(void)createView {
    
//	if ([self.nextDictprev objectForKey:@"next"] && [photosArray count] >= 25) {
//		nextBtn.hidden = FALSE;
//	}
//	else {
//		nextBtn.hidden = TRUE;
//	}
	
	int THUMBNAILS_IN_ROW = (320 - THUMBNAIL_PADDING) / (THUMBNAIL_WIDTH + THUMBNAIL_PADDING);
	NSInteger iTotalImage = [photosArray count]; 
	NSInteger rows = iTotalImage / THUMBNAILS_IN_ROW;
    if (iTotalImage % THUMBNAILS_IN_ROW > 0) rows++;
	
    CGFloat rowHeight = THUMBNAIL_HEIGHT + THUMBNAIL_PADDING;
	CGFloat colWidth = THUMBNAIL_PADDING + THUMBNAIL_WIDTH;
	
	if (scrollView) {
		[scrollView removeFromSuperview];
		scrollView = nil;
		[scrollView release];
	}
	
	scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, 351)];
	[self.view addSubview:scrollView];
	scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, rows * rowHeight + THUMBNAIL_PADDING);
    
    [clubArray removeAllObjects];
	for(NSInteger partner = 0; partner < iTotalImage; partner++){
		ClubView *clubView = [ClubView loadView];
		clubView.delegate = self;
        
        [clubArray addObject:clubView];
        
		clubView.tag = partner;
		NSInteger row = partner / THUMBNAILS_IN_ROW;
        NSInteger col =partner % THUMBNAILS_IN_ROW;
		clubView.frame = CGRectMake(THUMBNAIL_PADDING + colWidth * col, THUMBNAIL_PADDING + row * rowHeight, THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT);
		[scrollView addSubview:clubView];
		
		[clubView setImageView:[[photosArray objectAtIndex:partner]valueForKey:@"picture"]];
		//NSLog(@"%@",[[photosArray objectAtIndex:partner]valueForKey:@"picture"]);
		
		//imageViewL.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[[photosArray objectAtIndex:partner]valueForKey:@"picture"]]];
		//NSMutableDictionary *partnerDict = [clubArray objectAtIndex:partner];		
		//[clubView startIconDownload:partnerDict];
		//[clubView setLabelName:[clubArray objectAtIndex:partner]];
	}
}

-(void)thumbClickAction:(id)sender{
	
	ClubView *club = (ClubView*)sender;
	//NSLog(@"%d",club.tag);
   
    if(club.btn.selected)
    {    club.btn.selected = NO;
        [selectedPhotos removeObject:[[[[photosArray objectAtIndex:club.tag] valueForKey:@"images"] objectAtIndex:1] valueForKey:@"source"]];
    }
    else
    {
        club.btn.selected = YES;
        [selectedPhotos addObject:[[[[photosArray objectAtIndex:club.tag] valueForKey:@"images"] objectAtIndex:1] valueForKey:@"source"]];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - User Define Methods

-(IBAction)Back_Btn_Clicked:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)selectedTapped:(id)sender {
    
    if([selectedPhotos count]>0)
    {
    
    ForIphoneAppDelegate *appDelegate = (ForIphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.checkFlag=2;
        
    NSString *strTemp = [NSString stringWithFormat:NSLocalizedString(@"downloadMessage", nil),[selectedPhotos count]];
    
    alert = [[[UIAlertView alloc] initWithTitle:strTemp message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
	[alert show];
	
    progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    progressView.center = CGPointMake(alert.bounds.size.width / 2, alert.bounds.size.height - 50);
    [alert addSubview:progressView];
        
        lableProgress = [[UILabel alloc]  initWithFrame:CGRectMake(progressView.frame.size.width + progressView.frame.origin.x +5, progressView.frame.origin.y - 20, 80, 25)];
        lableProgress.backgroundColor = [UIColor clearColor];
        lableProgress.font = [UIFont boldSystemFontOfSize:12.0];
        lableProgress.text = @"0\%";
        lableProgress.textColor = [UIColor whiteColor];
        [alert addSubview:lableProgress];
        
/*        
	UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	
	// Adjust the indicator so it is up a few pixels from the bottom of the alert
	indicator.center = CGPointMake(alert.bounds.size.width / 2, alert.bounds.size.height - 50);
	[indicator startAnimating];
	[alert addSubview:indicator];
	[indicator release];
*/    
        
    [self performSelector:@selector(changeView) withObject:nil afterDelay:0.05];
    }
    else
    {
        UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message", nil) message:NSLocalizedString(@"selectImageAlert", nil) delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert1 show];
        [alert1 release];
    }
}

-(void)changeView
{
    
    [[NSNotificationCenter defaultCenter] 
     addObserver:self
     selector:@selector(goToNextView)
     name:@"goToNextView" 
     object:self.view];
    DCImageView *objDCImage = [[DCImageView alloc] init];
    for (int i=0; i<[selectedPhotos count]; i++)
    {
        NSString *str = [NSString stringWithFormat:@"%@",[selectedPhotos objectAtIndex:i]];
        NSMutableDictionary *dForCell = [photosArray objectAtIndex:i];
    
        if([dForCell valueForKey:@"cell"])
        {
        }
        else 
        {
            
            [objDCImage loadURLImage:str dictionaryRef:dForCell countNumber:[selectedPhotos count] callBackTarget:self];
        }
    }
}

-(void)progressValue:(int)progress
{
    int numberOfPhoto = [selectedPhotos count];
    float progress1 = (progress*100)/numberOfPhoto;
    prog = progress1;
    [self performSelectorInBackground:@selector(showProgress) withObject:nil];
    
}

-(void)showProgress
{
    NSString *percent = @"%";
    lableProgress.text = [NSString stringWithFormat:@"%.0f%@",prog,percent];
    [progressView setProgress:prog/100];
}

-(void)goToNextView
{
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    if (objImageAdj) {
        objImageAdj = nil;
        [objImageAdj release];
    }
    
    objImageAdj = [[ImageAdjustMent alloc] initWithNibName:@"ImageAdjustMent" bundle:nil];
    //    objImageAdj.arrayMyalbum = selectedPhotos;
    [[RootPane instance] pushPane:objImageAdj];
}

- (IBAction)selectAllTapped:(id)sender {

   // NSLog(@"Select All Tapped");
    
    [selectedPhotos removeAllObjects];

    for(int i = 0 ; i < [clubArray count]; i++)
        {
             ClubView *club = (ClubView*)[clubArray objectAtIndex:i];
            club.btn.selected = YES;
            [selectedPhotos addObject:[[[[photosArray objectAtIndex:i] valueForKey:@"images"] objectAtIndex:1] valueForKey:@"source"]];
        }
    
}

- (IBAction)selectNoneTapped:(id)sender {

   // NSLog(@"Select None Tapped");
    
    for(int i = 0 ; i< [clubArray count]; i++)
    {
        ClubView *club = (ClubView*)[clubArray objectAtIndex:i];
        club.btn.selected = NO;
    }
    [selectedPhotos removeAllObjects];
}

-(IBAction)Next_Btn_Clicked:(id)sender
{
	NSString *str = [NSString stringWithFormat:@"%@",[self.nextDictprev objectForKey:@"next"]];
	NSMutableDictionary* dict =  [self getMoreImage:str];
	//NSLog(@"%@",dict);
	
	NSMutableArray *arr = [dict valueForKey:@"data"];
	[photosArray addObjectsFromArray:arr];
	
	self.nextDictprev = [dict valueForKey:@"paging"];
	
	[self createView];
}

-(NSMutableDictionary*)getMoreImage:(NSString*)str
{
	NSString  *urlstring = [NSString stringWithFormat:@"%@",str];
    NSURL *url = [NSURL URLWithString:urlstring];
    //NSLog(@"URL : %@",url);
    NSString  *jsonRes = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    SBJSON *parser = [[SBJSON alloc] init];
    NSMutableDictionary *dict = [parser objectWithString:jsonRes error:nil];
    [parser release];
    return dict;  
}


- (void)dealloc {
    [super dealloc];
    [selectedPhotos release];
    selectedPhotos = nil;
    
    [photosArray release];
    photosArray = nil;
}
@end
