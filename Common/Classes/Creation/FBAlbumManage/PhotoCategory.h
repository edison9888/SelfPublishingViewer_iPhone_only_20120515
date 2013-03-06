//
//  PhotoCategory.h
//  Demo_PhotoApp
//
//  Created by Apple on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ImageAdjustMent.h"
#import "FbGraph.h"
#import "IconDownloader.h"
#import "PhotoCategoryCell.h"
#import "GroupListView.h"
#import "EGOCache.h"

@class AlbumPicker,ForIphoneAppDelegate;


@interface PhotoCategory : UIViewController <IconDownloaderDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UISearchBarDelegate>
{
    ForIphoneAppDelegate *appDeleg;
    int selectedOption;
    NSMutableArray *arrayFriends;
    NSMutableArray *tempArrayFriends;
    
    NSMutableArray *arrayMyalbums;
     NSMutableArray *tempArrayMyalbums;
    
    NSMutableArray *arrayMyLikes;
     NSMutableArray *tempArrayMyLikes;
    
   NSMutableDictionary *imageDownloadsInProgress;
    
    FbGraphResponse *fbResponce;
    AlbumPicker *objAlbum;
    ImageAdjustMent *objImageAdj;
    UIAlertView *alert;
    UIWebView *web;
    
    IBOutlet UITableView *tblCategory;
	
	
	IBOutlet UIButton *myAlbum_btn;
	IBOutlet UIButton *myLike_btn;
	IBOutlet UIButton *myFriends_btn;
	
	IBOutlet UILabel *myTitleLbl;
	
	IBOutlet UISearchBar *searchBar;
	NSMutableDictionary *nextDictprev;
    NSMutableDictionary *likePictureDic;

    NSMutableArray *PhotoArr;
    int btnTag;
    BOOL  isdidSelect;
    
    UIProgressView *progressView;
    float prog;
    UILabel *lableProgress;
    int totalCount;
    UITextField *txtAlbumName;
    
}

@property ( nonatomic , retain )NSMutableArray *arrayFriends;
@property ( nonatomic , retain )NSMutableArray *arrayMyalbums;
@property ( nonatomic , retain )NSMutableArray *arrayMyLikes;

@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
-(void)getFriendList;

-(IBAction)categorySelected:(id)sender;
-(IBAction)logoutTapped:(id)sender;

-(void)getMyAlbumList;

-(NSMutableArray*)getFriendAlbumList:(NSString*)str;
-(NSMutableArray*)getMyAlbumPhotos:(NSString*)str;
-(NSMutableArray*)getMyLikePhotos:(NSString*)str;
-(NSString*)getLikeAlbumCoverPageURL:(NSString *)strID;

- (void) getImage:(NSMutableDictionary*)appRecord forIndexPath:(NSIndexPath *)indexPath;
- (void)startIconDownload:(NSMutableDictionary *)appRecord forIndexPath:(NSIndexPath *)indexPath;

-(void)callLoadingAlertView;

-(void)changeView;
-(void)getMoreImage:(NSString*)str;
-(void)second_search_data:(NSMutableDictionary*)dictionary;

-(void)progressValue:(int)progress;
-(void)showProgress;

-(void)saveTapped:(id)sender;
-(void)ZipAllImages:(NSString *)name;

@end
