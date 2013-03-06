//
//  GroupListView.m
//  Demo_PhotoApp
//
//  Created by apple on 6/23/12.
//  Copyright 2012 fgbfg. All rights reserved.
//

#import "GroupListView.h"
#import "AlertHandler.h"
#import "ImageAdjustMent.h"
#import "RootPane.h"
#import "DCImageView.h"
#import "AppUtil.h"

@implementation GroupListView

@synthesize valueArray;
@synthesize imageDownloadsInProgress;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


#pragma mark -
#pragma  mark View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"back", nil) style:UIBarButtonItemStylePlain target:self action:@selector(Back_Btn_Clicked:)];

	appDeleg =(ForIphoneAppDelegate *)[[UIApplication sharedApplication]delegate];
}

-(void)viewWillAppear:(BOOL)animated
{
	self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
	[myTitleLbl setText:[NSString stringWithFormat:@"%@",[[[self.valueArray objectAtIndex:0]valueForKey:@"from"]valueForKey:@"name"]]];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.navigationItem.title = [NSString stringWithFormat:@"%@",[[[self.valueArray objectAtIndex:0]valueForKey:@"from"]valueForKey:@"name"]];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark
#pragma mark UITableView Datasource Method

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	
	return [self.valueArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 80;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    isdidSelect = YES;
	NSString *cellIdentifire = @"Cell0";
        	
	PhotoCategoryCell *cell = (PhotoCategoryCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifire];
	
	
	if (cell == nil) {			
		NSArray *nib = nil;		
		
		nib = [[NSBundle mainBundle] loadNibNamed:@"PhotoCategoryCell" owner:nil options:nil];
		cell = [nib objectAtIndex:0];	
		
	}
    
    [cell.btnDownload addTarget:self action:@selector(btnDownloadClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnDownload setTag:indexPath.row];

	[cell.cellBGImage setImage:[UIImage imageNamed:@"albumBg_img.png"]];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
		NSMutableDictionary *dict = [self.valueArray objectAtIndex:indexPath.row];
		cell.nameLbl.text = [dict valueForKey:@"name"];
		cell.countLbl.text = [NSString stringWithFormat:@"%@ Photos",[dict valueForKey:@"count"]];
	
		//NSLog(@"%@",[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=album&access_token=%@",[dict valueForKey:@"id"],appDeleg.fbGraph.accessToken]);
		
		if (![dict objectForKey:@"IconImage"])
		{
			if (myTable.dragging == NO && myTable.decelerating == NO)
			{
				[self getImage:dict forIndexPath:indexPath];
			}
			cell.imgView.image = [UIImage imageNamed:@"placeholder.png"];                
		}
		else
		{
			cell.imgView.image = [dict objectForKey:@"IconImage"];
		}
        return cell;
}

#pragma mark UITableView Delegate Method

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
    isdidSelect = YES;
    [self performSelectorInBackground:@selector(callLoadingAlertView) withObject:nil];
	NSMutableDictionary *dict = (NSMutableDictionary*)[self.valueArray objectAtIndex:indexPath.row];
	//NSLog(@"list :: %@",dict);
	
	NSMutableDictionary *mydict = [self getFriendAlbum:[NSString stringWithFormat:@"%@",[dict valueForKey:@"id"]]];
	
	if (arrayValue) {
		arrayValue = nil;
		[arrayValue release];
	}
	if (nextDictprev) {
		nextDictprev = nil;
		[nextDictprev release];
	}
	
	arrayValue = [[NSMutableArray alloc]init];
	nextDictprev = [[NSMutableDictionary alloc]init];
	
	PhotoArr = [mydict objectForKey:@"data"];
	
//	for (int i = 0; i < [arrr count]; i++) {
//		[PhotoArr addObject:[arrr objectAtIndex:i]];
//	}
	
    //obj.photosArray = [mydict objectForKey:@"data"];
    nextDictprev = [mydict objectForKey:@"paging"];
    
//    AlbumPicker *obj = [[AlbumPicker alloc]init];
//    obj.photosArray = arrayValue;
//    obj.nextDictprev = nextDictprev;
//    NSLog(@"%d",[arrayValue count]);
//    [self.navigationController pushViewController:obj animated:YES];
//    [obj release];

	NSString *str = [NSString stringWithFormat:@"%@",[nextDictprev objectForKey:@"next"]];
	[self getMoreImage:str];
	//NSLog(@"%@",dict);
	
}

#pragma mark -
#pragma mark UIAlertView Delegate Method

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 3) {
        if(buttonIndex == 1)
        {
            //NSLog(@"Download Tapped");
            //[AlertHandler showAlertForProcess];
            
            NSString *strTemp = [NSString stringWithFormat:NSLocalizedString(@"downloadMessage", nil),totalCount];
            alert = [[[UIAlertView alloc] initWithTitle:strTemp message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
            progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
            //            progressView.center = CGPointMake(alert.bounds.size.width / 2, alert.bounds.size.height - 50);
            progressView.frame = CGRectMake(30, 90, progressView.frame.size.width + 50, progressView.frame.size.height);
            
            lableProgress = [[UILabel alloc]  initWithFrame:CGRectMake(progressView.frame.size.width + progressView.frame.origin.x +5, progressView.frame.origin.y - 20, 80, 25)];
            lableProgress.backgroundColor = [UIColor clearColor];
            lableProgress.font = [UIFont boldSystemFontOfSize:12.0];
            lableProgress.text = @"0\%";
            lableProgress.textColor = [UIColor whiteColor];
            
            [alert addSubview:progressView];
            [alert addSubview:lableProgress];
            [alert show];
            
            [self performSelector:@selector(changeView) withObject:nil afterDelay:0.05];
        }
        else
        {
        }
    }
    else if(alertView.tag == 4) {
        if(buttonIndex == 0)
        {
            NSLog(@"Cancle Tapped :");
        }
        else if(buttonIndex == 1)
        {
            NSLog(@"OK Tapped :");   
            
            NSString *zipname = txtAlbumName.text;
            [self ZipAllImages:zipname];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    else if(alertView.tag == 5)
    {
        if(buttonIndex == 1)
        {
            NSLog(@"Edit Called");
            if (objImageAdj) {
                objImageAdj = nil;
                [objImageAdj release];
            }
            
            objImageAdj = [[ImageAdjustMent alloc] initWithNibName:@"ImageAdjustMent" bundle:nil];
            [[RootPane instance] pushPane:objImageAdj];
        }
        else
        {
            [self saveTapped:nil];
            NSLog(@"Save Called");
        }
    }
    
    
}


#pragma mark -
#pragma mark User Define Methods

-(void)btnDownloadClick:(UIButton*)sender
{
    totalCount = [[[valueArray objectAtIndex:sender.tag] valueForKey:@"count"] integerValue];
    isdidSelect = NO;
    btnTag = sender.tag;
    UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"downloadAllMessage", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"downloadBtn", nil), nil];
    alert1.tag =3;
    [alert1 show];
    [alert1 release];
}

-(void)ZipAllImages:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"ZipFolder"];
    
    NSString* bookDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/MyFolder"];
    NSMutableArray *arryTemp  = [[NSMutableArray alloc] initWithArray:[FileUtil files:bookDir  extensions:[NSArray arrayWithObjects: @"png",nil]]];
    
    // Code For Zip Files ::    
    
    NewBook *book = [[[NewBook alloc] init] autorelease];
    for(int i = 0;i< [arryTemp count]; i++)
    {
        [book addPage:[UIImage imageWithContentsOfFile:[arryTemp objectAtIndex:i]]];
    }
    
    if ([book pageCount] > 0)
    {
        book.name = name;
        NSString* path = [AppUtil docPath:[book.name add:@".zip"]];
        [book makeZipFile:path];
        [book deleteTmpdir];
    }
    
    BOOL isDir=NO;
    NSArray *subpaths;
    NSString *exportPath = dataPath;
    NSFileManager *fileManager = [NSFileManager defaultManager];    
    if ([fileManager fileExistsAtPath:exportPath isDirectory:&isDir] && isDir){
        subpaths = [fileManager subpathsAtPath:exportPath];
    }
    
    NSString *archivePath = [dataPath stringByAppendingString:@".zip"];
    NSLog(@"Success");
    NSString *filePath2 = [documentsDirectory 
                           stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip",name]];
    NSError *error1;
    // Attempt the move
    if ([fileManager moveItemAtPath:archivePath toPath:filePath2 error:&error1] != YES)
        NSLog(@"Unable to move file: %@", [error1 localizedDescription]);
    
    // Show contents of Documents directory
    NSLog(@"Documents directory: %@",[fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error1]);
    
    [fileManager removeItemAtPath:archivePath error:&error1];
    [fileManager removeItemAtPath:dataPath error:&error1];
    
    NSString *dataPath1 = [documentsDirectory stringByAppendingPathComponent:@"MyFolder"];//[NSString stringWithFormat:@"%@",name]];
    [fileManager removeItemAtPath:dataPath1 error:&error1];
    
    
}


-(void)saveTapped:(id)sender
{
    UIAlertView* alertAddTestName = [[UIAlertView alloc] init];
    alertAddTestName.tag=4;
    [alertAddTestName setDelegate:self];
    [alertAddTestName setTitle:NSLocalizedString(@"createAlbumTitle", nil)];
    [alertAddTestName setMessage:@" "];
    [alertAddTestName addButtonWithTitle:NSLocalizedString(@"cancel", nil)];
    [alertAddTestName addButtonWithTitle:NSLocalizedString(@"save", nil)];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [languages objectAtIndex:0];
    
    if ([currentLanguage isEqualToString:@"ja"]) {
        
        txtAlbumName = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 60.0, 245.0, 25.0)];
    }    
    else {
        txtAlbumName = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 45.0, 245.0, 25.0)];
    }
    
    [txtAlbumName setBackgroundColor:[UIColor whiteColor]];
    
    [alertAddTestName addSubview:txtAlbumName];
    
    [alertAddTestName show];
    [alertAddTestName release];
    [txtAlbumName release];
}


-(void)progressValue:(int)progress
{
    int numberOfPhoto = [PhotoArr count];
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

-(NSMutableDictionary*)getFriendAlbum:(NSString*)str
{
    fbResponce = [appDeleg.fbGraph doGraphGet:[NSString stringWithFormat:@"%@/photos",str] withGetVars:nil];
    SBJSON *parser = [[SBJSON alloc] init];
    NSMutableDictionary *facebook_response = [parser objectWithString:fbResponce.htmlResponse error:nil];
	//NSLog(@"Friends Album list :: %@",facebook_response);
    [parser release];
    [AlertHandler hideAlert];
    //NSLog(@"Friends Album list :: %@",facebook_response);
    return facebook_response;  
}

-(void)changeView
{  
    appDeleg.checkFlag=3;
    
    NSMutableDictionary *dict = (NSMutableDictionary*)[self.valueArray objectAtIndex:btnTag];
    
    NSDictionary *myDict = [self getFriendAlbum:[NSString stringWithFormat:@"%@",[dict valueForKey:@"id"]]];
    nextDictprev = [myDict objectForKey:@"paging"];
    PhotoArr = [myDict objectForKey:@"data"];
    
    if ([nextDictprev objectForKey:@"next"] && [PhotoArr count] >= 25)
    {
        NSString *str = [NSString stringWithFormat:@"%@",[nextDictprev objectForKey:@"next"]];
        [self getMoreImage:str];
	}
	else 
    {
        if (isdidSelect==YES)
        {
            AlbumPicker *obj = [[AlbumPicker alloc]init];
            [AlertHandler hideAlert];
            
            obj.photosArray = PhotoArr;
            NSLog(@"list :: %@",obj.photosArray);
            obj.nextDictprev =   nextDictprev;
            [[RootPane instance] pushPane:obj];
            [obj release];
        }
        else
        {
            DCImageView *objDCImage = [[DCImageView alloc] init];
            for (int i=0; i<[PhotoArr count]; i++)
            {
                NSString *str = [[[[PhotoArr objectAtIndex:i] valueForKey:@"images"] objectAtIndex:1] valueForKey:@"source"];
                NSMutableDictionary *dForCell = [dict objectForKey:@"data"];
                [objDCImage loadURLImage:str dictionaryRef:dForCell countNumber:[PhotoArr count] callBackTarget:self];
            }
            
            [alert dismissWithClickedButtonIndex:0 animated:YES];
//            if (objImageAdj) {
//                objImageAdj = nil;
//                [objImageAdj release];
//            }
//
//            objImageAdj = [[ImageAdjustMent alloc] initWithNibName:@"ImageAdjustMent" bundle:nil];
//            [self.navigationController pushViewController:objImageAdj animated:YES];

            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"downloadComplete", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"save", nil) otherButtonTitles:NSLocalizedString(@"edit", nil), nil];
            alertView.tag = 5;
            [alertView show];

            
        }
	}
}

-(void)getMoreImage:(NSString*)str
{
    NSString  *urlstring = [NSString stringWithFormat:@"%@",str];

    NSURL *url = [NSURL URLWithString:urlstring];
    NSString  *jsonRes = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"%@",jsonRes);
    
    SBJSON *parser = [[SBJSON alloc] init];
    NSMutableDictionary *facebook_response = [parser objectWithString:jsonRes error:nil];
    
    [self second_search_data:facebook_response];
    
	//NSLog(@"Friends Album list :: %@",facebook_response);
    [parser release];
	//NSLog(@"%@",urlstring);
}

-(void)second_search_data:(NSDictionary*)dictionary{
	
	//beinspired_detail_view
	//NSLog(@"%@",dictionary);	
	NSMutableArray *arr = [dictionary objectForKey:@"data"];
	for (int i = 0; i < [arr count]; i++) {
		[PhotoArr addObject:[arr objectAtIndex:i]];
	}

	nextDictprev = [[dictionary objectForKey:@"paging"] retain];
//	NSLog(@"%@",nextDictprev);
	if ([nextDictprev objectForKey:@"next"]) {
		NSString *str = [NSString stringWithFormat:@"%@",[nextDictprev objectForKey:@"next"]];
		[self getMoreImage:str];
	}
	else {
//        NSLog(@"Done");
//
//		AlbumPicker *obj = [[AlbumPicker alloc]init];
//		obj.photosArray = arrayValue;
//		NSLog(@"%d",[arrayValue count]);
//		[self.navigationController pushViewController:obj animated:YES];
//		[obj release];

        NSLog(@"Final Count In FB Photo Array :: %d",[PhotoArr count]);
        if (isdidSelect==YES)
        {
            AlbumPicker *obj = [[AlbumPicker alloc]init];
            [AlertHandler hideAlert];
            
            obj.photosArray = PhotoArr;
            NSLog(@"list :: %@",obj.photosArray);
            obj.nextDictprev =   nextDictprev;
            [[RootPane instance] pushPane:obj];
            [obj release];
        }
        else
        {
            DCImageView *objDCImage = [[DCImageView alloc] init];
            for (int i=0; i<[PhotoArr count]; i++)
            {
                NSString *str = [[[[PhotoArr objectAtIndex:i] valueForKey:@"images"] objectAtIndex:1] valueForKey:@"source"];
                NSMutableDictionary *dForCell = [dictionary objectForKey:@"data"];
                [objDCImage loadURLImage:str dictionaryRef:dForCell countNumber:[PhotoArr count] callBackTarget:self];
            }
            
            [AlertHandler hideAlert];
            
            if (objImageAdj) {
                objImageAdj = nil;
                [objImageAdj release];
            }
            
            objImageAdj = [[ImageAdjustMent alloc] initWithNibName:@"ImageAdjustMent" bundle:nil];
            [self.navigationController pushViewController:objImageAdj animated:YES];
            
        }

        
    }
}

-(IBAction)Back_Btn_Clicked:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)callLoadingAlertView
{
    [AlertHandler showAlertForProcess];		
}


#pragma mark Image Caching Methods

- (void) getImage:(NSMutableDictionary*)appRecord forIndexPath:(NSIndexPath *)indexPath
{
	NSString *ImageURLString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=album&access_token=%@",[appRecord valueForKey:@"id"],appDeleg.fbGraph.accessToken];
	
	//NSLog(@"%@",ImageURLString);
	
	NSMutableString *tmpStr = [NSMutableString stringWithString:ImageURLString];
	[tmpStr replaceOccurrencesOfString:@"/" withString:@"-" options:1 range:NSMakeRange(0, [tmpStr length])];
	
	NSString *filename = [NSString stringWithFormat:@"%@",tmpStr];
	//NSString *uniquePath = [TMP stringByAppendingPathComponent: filename];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cacheDirectory = [paths objectAtIndex:0];
	NSString *uniquePath = [cacheDirectory stringByAppendingPathComponent:filename];
	
	UIImage *image;
	
	// Check for a cached version
	if([[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
	{
		NSData *data = [[NSData alloc] initWithContentsOfFile:uniquePath];
		image = [[UIImage alloc] initWithData:data] ; // this is the cached image
		if(image)
			[appRecord setObject:image forKey:@"IconImage"];
		[image release];
		[data release];
		
		[myTable reloadData];
	}
	else
	{
		// get a new one
		[self startIconDownload:appRecord forIndexPath:indexPath];
	}
}

#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(NSMutableDictionary *)appRecord forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil) 
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.appRecord = appRecord;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
		iconDownloader.flag = 1;
        [imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
        [iconDownloader release];
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([self.valueArray count] > 0)
    {
        NSArray *visiblePaths = [myTable indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            NSMutableDictionary *appRecord = [self.valueArray objectAtIndex:indexPath.row];
            if (![appRecord objectForKey:@"IconImage"]) // avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:appRecord forIndexPath:indexPath];
            }
        }
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
		PhotoCategoryCell *cell = (PhotoCategoryCell*)[myTable cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
		
		if ([iconDownloader.appRecord objectForKey:@"IconImage"])
		{
			//[cell.activity stopAnimating];
			[cell.imgView setImage:[iconDownloader.appRecord objectForKey:@"IconImage"]];
		}
		else
		{
			cell.imgView.image = [UIImage imageNamed:@"placeholder.png"];
		}
    }
	//[myTable reloadData];
}
#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    // Release any cached data, images, etc. that aren't in use.
}

@end
