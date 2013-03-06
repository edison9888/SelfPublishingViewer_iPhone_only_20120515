//
//  PhotoCategory.m
//  Demo_PhotoApp
//
//  Created by Apple on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoCategory.h"
#import "AlbumPicker.h"
#import "SBJSON.h"
#import "AlertHandler.h"
#import "RootPane.h"
#import "ForIphoneAppDelegate.h"
#import "DCImageView.h"
#import "AppUtil.h"

@implementation PhotoCategory

@synthesize imageDownloadsInProgress;


@synthesize arrayFriends;
@synthesize arrayMyalbums;
@synthesize arrayMyLikes;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDeleg =(ForIphoneAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    likePictureDic = [[NSMutableDictionary alloc] init];
    
    tempArrayFriends = [[NSMutableArray alloc]init];
    tempArrayMyalbums = [[NSMutableArray alloc]init];
    tempArrayMyLikes = [[NSMutableArray alloc]init];
     
    
    //arrayFriends = [[NSArray alloc] initWithObjects:@"Mike",@"Jason",@"Mathew",@"Lura",@"John",nil];
    //arrayMyalbums = [[NSArray alloc] initWithObjects:@"Diwali Celeb",@"31st Party",@"Holi",nil]; 
    //arrayMyLikes = [[NSArray alloc] initWithObjects:@"BTW",@"Angry Bird",@"Sudden",@"John",nil];
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"exit", nil) style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    
    UIButton *btnRightBar = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRightBar.frame = CGRectMake(0, 0, 50, 50);
    
    [btnRightBar setImage:[UIImage imageNamed:@"Logout_Btn_Img"]  forState:UIControlStateNormal];
    [btnRightBar addTarget:self action:@selector(logoutTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnRightBar];

	[self getMyAlbumList];

    [myAlbum_btn setTitle:NSLocalizedString(@"myalbumTitle", nil) forState:UIControlStateNormal];
    [myLike_btn setTitle:NSLocalizedString(@"mylikeTitle", nil) forState:UIControlStateNormal];
    [myFriends_btn setTitle:NSLocalizedString(@"myfriendsTitle", nil) forState:UIControlStateNormal];

    [myAlbum_btn setTitle:NSLocalizedString(@"myalbumTitle", nil) forState:UIControlStateSelected];
    [myLike_btn setTitle:NSLocalizedString(@"mylikeTitle", nil) forState:UIControlStateSelected];
    [myFriends_btn setTitle:NSLocalizedString(@"myfriendsTitle", nil) forState:UIControlStateSelected];

    
    // Do any additional setup after loading the view from its nib.
    // 10150375344294784/picture?type=album&access_token=
}

-(void)viewWillAppear:(BOOL)animated
{
	self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Helader_Img.png"]];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(selectedOption == 1)
    {
        self.navigationItem.title = NSLocalizedString(@"myalbumTitle", nil);
        myAlbum_btn.selected = YES;
        myLike_btn.selected = NO;
        myFriends_btn.selected = NO;

    }
    else if(selectedOption == 2)
    {
        self.navigationItem.title = NSLocalizedString(@"mylikeTitle", nil);
        myAlbum_btn.selected = NO;
        myLike_btn.selected = YES;
        myFriends_btn.selected = NO;

    }
    else 
    {
        self.navigationItem.title = NSLocalizedString(@"myfriendsTitle", nil); 
        myAlbum_btn.selected = NO;
        myLike_btn.selected = NO;
        myFriends_btn.selected = YES;

    }
}


#pragma mark UIAlertView Delegate Method

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag== 1)
    {
        if(buttonIndex == 1)
        [self.navigationController popViewControllerAnimated:YES];
        
//        [alertView release];
    }
    else if (alertView.tag == 2)
    { 
        if(buttonIndex == 1) {
				
				appDeleg.fbGraph.accessToken = nil;
				NSHTTPCookie *cookie;
				NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
				for (cookie in [storage cookies])
				{
					NSString *domainName = [cookie domain];
					NSRange domainRange = [domainName rangeOfString:@"facebook"];
					if(domainRange.length > 0)
					{
						[storage deleteCookie:cookie];
					}
				}
        [self.navigationController popViewControllerAnimated:YES];
        }
        [alertView release];
    }
    else if(alertView.tag == 3)
    {
        if(buttonIndex == 1)
        {
            //NSLog(@"Download Tapped");

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

-(void)backButtonTapped:(id)sender
{
    UIAlertView *Alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"exitAlert", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"alertExitBtn", nil),nil];
    Alert.tag = 1;
    [Alert show];
}

-(IBAction)logoutTapped:(id)sender
{
    UIAlertView *Alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"logoutAlert", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"logout", nil),nil];
    
    Alert.tag = 2;
    [Alert show];
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
        txtAlbumName = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 45.0, 245.0, 25.0)];
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


-(void)changeView
{  
    appDeleg.checkFlag=1;
    
    NSMutableDictionary *dict = (NSMutableDictionary*)[tempArrayMyalbums objectAtIndex:btnTag];
    
    PhotoArr = [self getMyAlbumPhotos:[NSString stringWithFormat:@"%@",[dict valueForKey:@"id"]]];
    
    if ([nextDictprev objectForKey:@"next"] && [PhotoArr count] >= 25)
    {
        NSString *str = [NSString stringWithFormat:@"%@",[nextDictprev objectForKey:@"next"]];
        [self getMoreImage:str];
	}
	else 
    {
       
        if (isdidSelect==YES)
        {
            
            [AlertHandler hideAlert];

            AlbumPicker *obj = [[AlbumPicker alloc]init];
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
            //            [[RootPane instance] pushPane:objImageAdj];  
            

            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"downloadComplete", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"save", nil) otherButtonTitles:NSLocalizedString(@"edit", nil), nil];
            alertView.tag = 5;
            [alertView show];
            
        }
	}
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

-(void)getMoreImage:(NSString*)str
{
	NSString  *urlstring = [NSString stringWithFormat:@"%@",str];
    NSURL *url = [NSURL URLWithString:urlstring];
    NSString  *jsonRes = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    SBJSON *parser = [[SBJSON alloc] init];
    NSMutableDictionary *dict = [parser objectWithString:jsonRes error:nil];
    [parser release];
    [self second_search_data:dict];
}

-(void)second_search_data:(NSMutableDictionary*)dictionary{
	
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
        if (isdidSelect==YES)
        {
            AlbumPicker *obj = [[AlbumPicker alloc]init];
            
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
            
            if (objImageAdj) {
                objImageAdj = nil;
                [objImageAdj release];
            }
            
            objImageAdj = [[ImageAdjustMent alloc] initWithNibName:@"ImageAdjustMent" bundle:nil];
            [self.navigationController pushViewController:objImageAdj animated:YES];
            
        }
        [alert dismissWithClickedButtonIndex:0 animated:YES];
	}
}

-(IBAction)categorySelected:(id)sender
{
    UIBarButtonItem *btnTemp = (UIBarButtonItem *)sender;
    selectedOption = btnTemp.tag;
    //NSLog(@"%d",selectedOption);
	
	NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    [self callLoadingAlertView];
    
	
    if(selectedOption == 1)
    {
		[myTitleLbl setText:@"My Albums"];
        self.navigationItem.title = NSLocalizedString(@"myalbumTitle", nil);
        myAlbum_btn.selected = YES;
        myLike_btn.selected = NO;
        myFriends_btn.selected = NO;
        
        [self performSelector:@selector(getMyAlbumList) withObject:nil afterDelay:0.2];
    }
    else if(selectedOption == 2)
    {
		[myTitleLbl setText:@"My Likes"];
        self.navigationItem.title = NSLocalizedString(@"mylikeTitle", nil);
        myAlbum_btn.selected = NO;
        myLike_btn.selected = YES;
        myFriends_btn.selected = NO;
        
        [self performSelector:@selector(getmyLikeList) withObject:nil afterDelay:0.2];
        
    }
    else if(selectedOption == 3)
    {
		[myTitleLbl setText:@"My Friends"];
        self.navigationItem.title = NSLocalizedString(@"myfriendsTitle", nil); 
        myAlbum_btn.selected = NO;
        myLike_btn.selected = NO;
        myFriends_btn.selected = YES;
        
        
        [self performSelector:@selector(getFriendList) withObject:nil afterDelay:0.2];
    } 
}

-(void)callLoadingAlertView
{
    [AlertHandler showAlertForProcess];		
}


#pragma mark
#pragma mark TableView Delegate Method

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(selectedOption == 1)
    {
        return [tempArrayMyalbums count];
    }
    else if(selectedOption == 2)
    {
        return [tempArrayMyLikes count];
    }
    else 
    {
        return [tempArrayFriends count];
    }

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 80.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(selectedOption == 1){
   
        NSString *cellIdentifire = @"Cell0";
        
		
		PhotoCategoryCell *cell = (PhotoCategoryCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifire];
		
		
		if (cell == nil) {			
			NSArray *nib = nil;		
			
			nib = [[NSBundle mainBundle] loadNibNamed:@"PhotoCategoryCell" owner:nil options:nil];
			cell = [nib objectAtIndex:0];	
			
		}
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		[cell.cellBGImage setImage:[UIImage imageNamed:@"albumBg_img.png"]];
		
		NSMutableDictionary *dict = [tempArrayMyalbums objectAtIndex:indexPath.row];
		cell.nameLbl.text = [NSString stringWithFormat:@"%@",[dict valueForKey:@"name"]];
		cell.countLbl.text = [NSString stringWithFormat:@"%@ Photos",[dict valueForKey:@"count"]];
        
        [cell.btnDownload addTarget:self action:@selector(btnDownloadClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnDownload setTag:indexPath.row];
		
		//NSLog(@"%@",[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=album&access_token=%@",[dict valueForKey:@"id"],appDeleg.fbGraph.accessToken]);
		
		if (![dict objectForKey:@"IconImage"])
		{
			if (tblCategory.dragging == NO && tblCategory.decelerating == NO)
			{
				[self getImage:dict forIndexPath:indexPath];
			}
			cell.imgView.image = [UIImage imageNamed:@"placeholder.png"];                
		}
		else
		{
			cell.imgView.image = [dict objectForKey:@"IconImage"];
		}
		
        //cell.textLabel.text = [arrayMyalbums objectAtIndex:indexPath.row];
		
        return cell;
    }
    else if(selectedOption == 2){
		NSString *cellIdentifire = @"Cell1";
		PhotoCategoryCell *cell = (PhotoCategoryCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifire];
		
//		UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifire]; 
		if (cell == nil) {		
            
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifire];
            
			NSArray *nib = nil;		
			
			nib = [[NSBundle mainBundle] loadNibNamed:@"PhotoCategoryCell" owner:nil options:nil];
			cell = [nib objectAtIndex:0];	
			
		}
        cell.lblDownload.hidden = YES;
        cell.btnDownload.hidden = YES;
		[cell.cellBGImage setImage:[UIImage imageNamed:@"cellBg.png"]];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		NSMutableDictionary *dict = [tempArrayMyLikes objectAtIndex:indexPath.row];
		cell.nameLbl.text = [NSString stringWithFormat:@"%@",[dict valueForKey:@"name"]];
        
//        cell.textLabel.text = [NSString stringWithFormat:@"%@",[dict valueForKey:@"name"]];
		//NSLog(@"%@",[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=album&access_token=%@",[dict valueForKey:@"id"],appDeleg.fbGraph.accessToken]);
		
		if (![dict objectForKey:@"IconImage"])
		{
			if (tblCategory.dragging == NO && tblCategory.decelerating == NO)
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
    else {
        
        static NSString *CellIdentifier = @"PhotoCategoryCell";
		
		PhotoCategoryCell *cell = (PhotoCategoryCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
		if (cell == nil) {			
			NSArray *nib = nil;		
			
			nib = [[NSBundle mainBundle] loadNibNamed:@"PhotoCategoryCell" owner:nil options:nil];
			cell = [nib objectAtIndex:0];	
			
			
		}
        
        cell.lblDownload.hidden = YES;
        cell.btnDownload.hidden = YES;
		[cell.cellBGImage setImage:[UIImage imageNamed:@"cellBg.png"]];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		cell.nameLbl.text = [NSString stringWithFormat:@"%@",[[tempArrayFriends objectAtIndex:indexPath.row] valueForKey:@"name"]];

		
        NSMutableDictionary *dict = [tempArrayFriends objectAtIndex:indexPath.row];
        if (![dict objectForKey:@"IconImage"])
		{
			
			if (tblCategory.dragging == NO && tblCategory.decelerating == NO)
			{
				[self getImage:dict forIndexPath:indexPath];
			}
			cell.imgView.image = [UIImage imageNamed:@"placeholder.png"];                
		}
		else
		{
			cell.imgView.image = [dict objectForKey:@"IconImage"];
		}
//      cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%da",indexPath.row+1]];
//      cell.textLabel.text = 
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self performSelectorInBackground:@selector(callLoadingAlertView) withObject:nil];
    
    if (!objAlbum) {
        objAlbum = nil;
        [objAlbum release];
    }

	if(selectedOption == 1)
    {
        if (nextDictprev) {
            nextDictprev = nil;
            [nextDictprev release];
        }
        
        nextDictprev = [[NSMutableDictionary alloc]init];
        isdidSelect=YES;
        btnTag = indexPath.row;
        [self performSelectorOnMainThread:@selector(changeView) withObject:nil waitUntilDone:NO];
    }
    else if(selectedOption == 2)
    {
		NSMutableDictionary *dict = (NSMutableDictionary*)[tempArrayMyLikes objectAtIndex:indexPath.row];
		//NSLog(@"list :: %@",dict);
		GroupListView *obj = [[GroupListView alloc]init];
		obj.valueArray = [self getMyLikePhotos:[NSString stringWithFormat:@"%@",[dict valueForKey:@"id"]]];
        [[RootPane instance] pushPane:obj];
		[obj release];
    }
    else if(selectedOption == 3)
    {
		NSMutableDictionary *dict = [tempArrayFriends objectAtIndex:indexPath.row];
		NSString *str = [NSString stringWithFormat:@"%@",[dict valueForKey:@"id"]];
		NSMutableArray* arr = [self getFriendAlbumList:str];
		
        if([arr count] > 0)
        {
		GroupListView *obj = [[GroupListView alloc]init];
		obj.valueArray = arr;
        [[RootPane instance] pushPane:obj];
        }
        else {
        // SHOW ALERT VIEW;
        }
    }
}

-(void)btnDownloadClick:(UIButton*)sender
{
    totalCount = [[[tempArrayMyalbums objectAtIndex:sender.tag] valueForKey:@"count"] integerValue];
    isdidSelect = NO;
    btnTag = sender.tag;
    UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"downloadAllMessage", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"downloadBtn", nil), nil];
    alert1.tag =3;
    [alert1 show];
    [alert1 release];
}

#pragma mark -
#pragma mark UISearchBar Methods

-(void)searchwithKeyWord:(UISearchBar*)SearchB{
    
    if (selectedOption == 1) {
        [tempArrayMyalbums removeAllObjects];
        NSDictionary *dic;
        for(dic in self.arrayMyalbums)
        {
            NSString *st =    [dic valueForKey:@"name"];
            NSRange rang =[st rangeOfString:SearchB.text options:NSCaseInsensitiveSearch];
            
            if (rang.length == [SearchB.text length]) {
                [tempArrayMyalbums addObject:dic];
            }else {
                [tempArrayMyalbums removeObject:dic];
            }
        }        
    }
    else if (selectedOption == 2) {
        [tempArrayMyLikes removeAllObjects];
        NSDictionary *dic;
        for(dic in self.arrayMyLikes)
        {
            NSString *st =    [dic valueForKey:@"name"];
            NSRange rang =[st rangeOfString:SearchB.text options:NSCaseInsensitiveSearch];
            
            if (rang.length == [SearchB.text length]) {
                [tempArrayMyLikes addObject:dic];
            }else {
                [tempArrayMyLikes removeObject:dic];
            }
        }
    }
    else if (selectedOption == 3) {
        [tempArrayFriends removeAllObjects];
        NSDictionary *dic;
        for(dic in self.arrayFriends)
        {
            NSString *st =    [dic valueForKey:@"name"];
            NSRange rang =[st rangeOfString:SearchB.text options:NSCaseInsensitiveSearch];
            
            if (rang.length == [SearchB.text length]) {
                [tempArrayFriends addObject:dic];
            }else {
                [tempArrayFriends removeObject:dic];
            }
        }
    }
    [tblCategory reloadData];
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar1{
    [searchBar1 setShowsCancelButton:YES animated:YES];
    searchBar1.showsCancelButton=YES;
    return YES;
}

-(BOOL)searchBar:(UISearchBar *)searchBar1 shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    [self performSelector:@selector(searchwithKeyWord:) withObject:searchBar1 afterDelay:0.2];
    return YES;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar1{
    [searchBar1 setShowsCancelButton:NO animated:YES];
    [searchBar1 resignFirstResponder];
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar1{
    [searchBar1 resignFirstResponder];
    [searchBar1 setShowsCancelButton:NO animated:YES];
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar1{
    [self searchwithKeyWord:searchBar1];
    return YES;
}


- (void)viewDidUnload
{

    [tblCategory release];
    tblCategory = nil;
    [super viewDidUnload];
    
    [arrayFriends release];
    [arrayMyalbums release];
    [arrayMyLikes release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
}

#pragma mark -
#pragma mark Class Methods For Facebook Data

-(NSMutableArray*)getFriendAlbumList:(NSString*)str
{
    fbResponce = [appDeleg.fbGraph doGraphGet:[NSString stringWithFormat:@"%@/albums",str] withGetVars:nil];
    SBJSON *parser = [[SBJSON alloc] init];
    NSDictionary *facebook_response = [parser objectWithString:fbResponce.htmlResponse error:nil];   
    [parser release];
	NSMutableArray* arr = [facebook_response objectForKey:@"data"];
    //NSLog(@"Friends Album list :: %@",arr);
    [AlertHandler hideAlert];
    return arr;  
}

-(NSMutableArray*)getMyAlbumPhotos:(NSString*)str
{
    fbResponce = [appDeleg.fbGraph doGraphGet:[NSString stringWithFormat:@"%@/photos",str] withGetVars:nil];
    SBJSON *parser = [[SBJSON alloc] init];
    NSDictionary *facebook_response = [parser objectWithString:fbResponce.htmlResponse error:nil];
	//NSLog(@"Friends Album list :: %@",facebook_response);
    [parser release];
	NSMutableArray* arr = [facebook_response objectForKey:@"data"];
    nextDictprev = [facebook_response objectForKey:@"paging"];
    //NSLog(@"Friends Album list :: %@",arr);
    [AlertHandler hideAlert];
    return arr;  
}

-(NSMutableArray*)getMyLikePhotos:(NSString*)str
{
    fbResponce = [appDeleg.fbGraph doGraphGet:[NSString stringWithFormat:@"%@/albums",str] withGetVars:nil];
    SBJSON *parser = [[SBJSON alloc] init];
    NSDictionary *facebook_response = [parser objectWithString:fbResponce.htmlResponse error:nil];
	//NSLog(@"Friends Album list :: %@",facebook_response);
    [parser release];
	NSMutableArray* arr = [facebook_response objectForKey:@"data"];
    //NSLog(@"Friends Album list :: %@",arr);
    [AlertHandler hideAlert];
    return arr;  
}

-(void)getMyAlbumList
{
    selectedOption = 1;

	[myTitleLbl setText:@"My Albums"];
    
//    self.navigationItem.title = @"My Albums";
	
    fbResponce = [appDeleg.fbGraph doGraphGet:@"me/albums" withGetVars:nil];
    SBJSON *parser = [[SBJSON alloc] init];
    NSDictionary *facebook_response = [parser objectWithString:fbResponce.htmlResponse error:nil];   
    [parser release];
    
	self.arrayMyalbums = [facebook_response objectForKey:@"data"];
    
    //NSLog(@"Array %d Friends list :: %@",[arrayMyalbums count],arrayMyalbums);
    [tempArrayMyalbums removeAllObjects];
    tempArrayMyalbums = [self.arrayMyalbums mutableCopy];
    
    
    [AlertHandler hideAlert];
    
    tblCategory.dataSource = self;
    tblCategory.delegate = self;
    [tblCategory reloadData];    
    
}


-(void)getFriendList
{
    
//    self.navigationItem.title = @"My Albums";
    
    fbResponce = [appDeleg.fbGraph doGraphGet:@"me/friends" withGetVars:nil];
    SBJSON *parser = [[SBJSON alloc] init];
    NSDictionary *facebook_response = [parser objectWithString:fbResponce.htmlResponse error:nil];   
    [parser release];
    
	self.arrayFriends = [facebook_response objectForKey:@"data"];
    
    [tempArrayFriends removeAllObjects];
    tempArrayFriends = [self.arrayFriends mutableCopy];
    
    //NSLog(@"Array %d Friends list :: %@",[arrayFriends count],arrayFriends);
    
    [AlertHandler hideAlert];
    
    tblCategory.dataSource = self;
    tblCategory.delegate = self;
    [tblCategory reloadData];    
    
}


-(void)getmyLikeList
{
    
//    self.navigationItem.title = @"My Albums";
    
    fbResponce = [appDeleg.fbGraph doGraphGet:@"me/likes" withGetVars:nil];
    SBJSON *parser = [[SBJSON alloc] init];
    NSDictionary *facebook_response = [parser objectWithString:fbResponce.htmlResponse error:nil];   
    [parser release];
    
	self.arrayMyLikes = [facebook_response objectForKey:@"data"];
    
    [tempArrayMyLikes removeAllObjects];
    tempArrayMyLikes = [self.arrayMyLikes mutableCopy];
    
    for (int i = 0; i < [tempArrayMyLikes count]; i++) {
        NSString *keyID = [[tempArrayMyLikes objectAtIndex:i] valueForKey:@"id"];
        
        if(![likePictureDic valueForKey:keyID])
       [likePictureDic setValue:[self getLikeAlbumCoverPageURL:keyID] forKey:keyID];
    }
    NSLog(@"Picture Dictionary :%@",likePictureDic);
    //NSLog(@"Array %d Friends list :: %@",[arrayFriends count],arrayFriends);
    
    [AlertHandler hideAlert];

    tblCategory.dataSource = self;
    tblCategory.delegate = self;
    [tblCategory reloadData];    
}

-(NSString *)getLikeAlbumCoverPageURL:(NSString *)strID
{
    fbResponce = [appDeleg.fbGraph doGraphGet:[NSString stringWithFormat:@"%@",strID] withGetVars:nil];
    SBJSON *parser = [[SBJSON alloc] init];
    NSDictionary *facebook_response = [parser objectWithString:fbResponce.htmlResponse error:nil];  
    [parser release];
//  NSLog(@"Download Data :: %@",[facebook_response valueForKey:@"picture"]);
//  [likePictureDic setValue: forKey:keyID];
    
    return [facebook_response valueForKey:@"picture"];
}


#pragma mark -
#pragma mark Image Caching Methods

- (void) getImage:(NSMutableDictionary*)appRecord forIndexPath:(NSIndexPath *)indexPath
{
	
	NSString *ImageURLString;
	
	if(selectedOption == 1)
    {
		ImageURLString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=album&access_token=%@",[appRecord valueForKey:@"id"],appDeleg.fbGraph.accessToken];
	}
	else if(selectedOption == 2)
	{
        NSString *keyID = [appRecord valueForKey:@"id"];
        
		ImageURLString = [likePictureDic valueForKey:keyID];  //[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=small",[appRecord objectForKey:@"id"]];
	
//        NSLog(@"Image Link no :: %@",ImageURLString);

    }
	else if(selectedOption == 3)
	{
		ImageURLString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=small",[appRecord objectForKey:@"id"]];
	}
	
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
		
		[tblCategory reloadData];
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
        
        if(selectedOption == 2){
            iconDownloader.likePictureDic = likePictureDic;
        }
        else
        {
            iconDownloader.likePictureDic = nil;
        }
        
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
		iconDownloader.flag = selectedOption;
        [imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
        [iconDownloader release];   
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    
    if(selectedOption ==1)
    {
        if ([tempArrayMyalbums count] > 0)
        {
            NSArray *visiblePaths = [tblCategory indexPathsForVisibleRows];
            for (NSIndexPath *indexPath in visiblePaths)
            {
                NSMutableDictionary *appRecord ;
                
                appRecord = [tempArrayMyalbums objectAtIndex:indexPath.row];
                if (![appRecord objectForKey:@"IconImage"]) // avoid the app icon download if the app already has an icon
                {
                    [self startIconDownload:appRecord forIndexPath:indexPath];
                }
            }
        }
    }
    else if(selectedOption == 2) {
        
            if ([tempArrayMyLikes count] > 0)
            {
                NSArray *visiblePaths = [tblCategory indexPathsForVisibleRows];
                for (NSIndexPath *indexPath in visiblePaths)
                {
                    NSMutableDictionary *appRecord ;
                
                    appRecord = [tempArrayMyLikes objectAtIndex:indexPath.row];
                    if (![appRecord objectForKey:@"IconImage"]) // avoid the app icon download if the app already has an icon
                    {
                        [self startIconDownload:appRecord forIndexPath:indexPath];
                    }
                }
            }
    }
    else {
        if ([tempArrayFriends count] > 0)
        {
            NSArray *visiblePaths = [tblCategory indexPathsForVisibleRows];
            for (NSIndexPath *indexPath in visiblePaths)
            {
                NSMutableDictionary *appRecord ;
                
                appRecord = [tempArrayFriends objectAtIndex:indexPath.row];
                if (![appRecord objectForKey:@"IconImage"]) // avoid the app icon download if the app already has an icon
                {
                    [self startIconDownload:appRecord forIndexPath:indexPath];
                }
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
		PhotoCategoryCell *cell = (PhotoCategoryCell*)[tblCategory cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
		
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
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    // Release any cached data, images, etc. that aren't in use.
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [tblCategory release];
    [super dealloc];
}
@end
