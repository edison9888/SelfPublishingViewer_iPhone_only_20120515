//
//  DCImageView.m
//  asyTblDemo
//
//  Created by digicorp on 12/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DCImageView.h"
#import "FileUtil.h"
#import "ForIphoneAppDelegate.h"

@implementation DCImageView

@synthesize strURL;
@synthesize myWebData;
@synthesize dRef1;
@synthesize delegate;
@synthesize arrayImageURLs;

int counter;
int incCounter;

-(void)loadURLImage:(NSString*)urlStringValue dictionaryRef:(NSMutableDictionary*)dRef countNumber:(int)count callBackTarget:(id)target{

//  DCImageView *dc=[[DCImageView alloc] init];
//	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
    self.delegate = target;
    counter = count;
	self.dRef1 = dRef;
	self.strURL=urlStringValue;

	//[dc release]; dc=nil;
}

-(void)setStrURL:(NSString *)urlInStringFormat{
//	NSURLConnection *con=[[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlInStringFormat]] delegate:self];
//
//    strName = urlInStringFormat;
//    
//    if(!self.arrayImageURLs)
//    {
//        self.arrayImageURLs = [[NSMutableArray alloc]  init];
//    }
//    [self.arrayImageURLs addObject:urlInStringFormat];
//    
//	if(con){
//		myWebData=[[NSMutableData data] retain];
//	} else {
//	}	
        
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"MyFolder"];
    
    NSString *picname;
    picname=[[[[[urlInStringFormat lastPathComponent] componentsSeparatedByString:@"."] objectAtIndex:0] stringByAppendingString:@".png"]retain];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    NSString *dataFilePath = [[dataPath stringByAppendingPathComponent:picname] retain];
    
    NSString* bookDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/MyFolder"];
    if([[FileUtil files:bookDir  extensions:[NSArray arrayWithObjects: @"png",nil]] containsObject:dataFilePath])
    {
        NSLog(@"Already Downloaded !!");
    }
    else {
        
        NSLog(@"pic :%@",picname);

        strName = urlInStringFormat;
        myWebData = [[NSMutableData alloc] initWithContentsOfURL:[NSURL URLWithString:urlInStringFormat]];
        
        UIImage *img = [self postProcessLazyImage:[UIImage imageWithData:myWebData]];
        [UIImagePNGRepresentation(img) writeToFile:dataFilePath atomically:YES ];
    }
    incCounter++;
    ForIphoneAppDelegate *AppDelegate = (ForIphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (AppDelegate.checkFlag==1)
    {
        [self.delegate progressValue:incCounter];
        
        if(counter == incCounter)
        {
            incCounter = 0;
        }

    }
    else if(AppDelegate.checkFlag==2)
    {
        [self.delegate progressValue:incCounter];
        
        if(counter == incCounter)
        {
            incCounter = 0;
            [self.delegate goToNextView];
        }
    }
    else
    {
        [self.delegate progressValue:incCounter];
        
        if(counter == incCounter)
        {
            incCounter = 0;
        }
    }
}

/*
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

	[myWebData setLength: 0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
	[myWebData appendData:data];		
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[connection release];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[connection release];
    
	 NSLog(@"%d",[dRef1 count]);
    
    [dRef1 setObject:myWebData forKey:@"mywebdata"];
    
    NSString *picname;
   
    NSString *name = nil;
    if(incCounter > [self.arrayImageURLs count])
    {
    
    }
    else {
        name = [NSString stringWithFormat:@"%@",[self.arrayImageURLs objectAtIndex:incCounter]];
    }
    
    NSLog(@"String URL :: %@",name);
    
    picname=[[[[[name lastPathComponent] componentsSeparatedByString:@"."] objectAtIndex:0] stringByAppendingString:@".png"]retain];
    NSLog(@"pic :%@",picname);
    incCounter += 1;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"MyFolder"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    NSString *dataFilePath = [[dataPath stringByAppendingPathComponent:picname] retain];
    
    UIImage *img = [self postProcessLazyImage:[UIImage imageWithData:[dRef1 valueForKey:@"mywebdata"]]];
    [UIImagePNGRepresentation(img) writeToFile:dataFilePath atomically:YES ];

    if(counter == incCounter)
    {
        incCounter = 0;
        [self.delegate goToNextView];
    }
}
*/


- (UIImage*)postProcessLazyImage:(UIImage*)image
{
    CGSize itemSize = CGSizeMake(320, 480);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0);
    CGRect imageRect = CGRectMake(0, 0, 320, 480);
    [image drawInRect:imageRect];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)dealloc{
	if(dRef1!=nil && [dRef1 retainCount]>0) { [dRef1 release]; dRef1=nil; }
//	if(ip!=nil && [ip retainCount]>0) { [ip release]; ip=nil; }
	[super dealloc];
}

@end


