//
//  GroupListView.h
//  Demo_PhotoApp
//
//  Created by apple on 6/23/12.
//  Copyright 2012 fgbfg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FbGraph.h"
#import "ForIphoneAppDelegate.h"
#import "SBJSON.h"
#import "AlbumPicker.h"
#import "IconDownloader.h"
#import "PhotoCategoryCell.h"
//#import "ASIHttpParser.h"

@class ImageAdjustMent;
@interface GroupListView : UIViewController <IconDownloaderDelegate>{

	NSMutableDictionary *imageDownloadsInProgress;
	
	
	NSMutableArray *valueArray;
	
	IBOutlet UITableView *myTable;
	
	ForIphoneAppDelegate *appDeleg;
	FbGraphResponse *fbResponce;
	
	IBOutlet UILabel *myTitleLbl;
	
	NSMutableArray *arrayValue;
	NSMutableDictionary *nextDictprev;
	
    NSMutableArray *PhotoArr;
    int btnTag;
    BOOL  isdidSelect;
    ImageAdjustMent *objImageAdj;
 
//	ASIHttpParser *Web_req;

    
    UIAlertView *alert;
    UIProgressView *progressView;
    float prog;
    UILabel *lableProgress;
    int totalCount;
    
    UITextField *txtAlbumName;

}

@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property ( nonatomic , retain)NSMutableArray *valueArray;

-(NSMutableDictionary*)getFriendAlbum:(NSString*)str;
- (void) getImage:(NSMutableDictionary*)appRecord forIndexPath:(NSIndexPath *)indexPath;
- (void)startIconDownload:(NSMutableDictionary *)appRecord forIndexPath:(NSIndexPath *)indexPath;

-(IBAction)Back_Btn_Clicked:(id)sender;
-(void)getMoreImage:(NSString*)str;
-(void)second_search_data:(NSDictionary*)dictionary;

-(void)progressValue:(int)progress;
-(void)showProgress;

-(void)ZipAllImages:(NSString *)name;
-(void)saveTapped:(id)sender;

@end
