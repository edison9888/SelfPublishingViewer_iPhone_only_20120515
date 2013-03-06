//
//  MusicViewController.h
//  CommonViewer
//
//  Created by FSCM100301 on 10/10/07.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CVMediaPickerController.h"
#import "ScrollLabel.h"

@interface MusicViewController : UIViewController 
<AVAudioPlayerDelegate, CVMediaPickerControllerDelegate, UITableViewDelegate, UITableViewDataSource> {
	 ScrollLabel *musicPlayerTitle;
	 ScrollLabel *musicPlayerArtist;
	 UIImageView *musicPlayerArtwork;
	 UIButton *musicPlayerListButton;
	 UIButton *musicPlayerPlayButton;
	 UIButton *musicPlayerRepeatButton;
	 UIButton *musicPlayerShuffleButton;
	
	 UIView *mainview;
	 UINavigationItem *navitem;
	 UITableView *tableview;
	 UISegmentedControl *modeSegment;
	 UIToolbar *toolbarBottom;
	
	// music-player
	MPMusicPlayerController *musicPlayer;
	NSMutableArray *musicList;
	
	AVAudioPlayer *defPlayer;
	BOOL defMusicPlay;
	
	
	CVMPListTag listMode;
	CVMPTag mode;
	BOOL inArtist;
	NSInteger selectedArtist;
	
	NSArray *list;
	NSMutableArray *selectedList;
	
}

@property (nonatomic, retain) IBOutlet ScrollLabel *musicPlayerTitle;
@property (nonatomic, retain) IBOutlet ScrollLabel *musicPlayerArtist;
@property (nonatomic, retain) IBOutlet UIImageView *musicPlayerArtwork;
@property (nonatomic, retain) IBOutlet UIButton *musicPlayerListButton;
@property (nonatomic, retain) IBOutlet UIButton *musicPlayerPlayButton;
@property (nonatomic, retain) IBOutlet UIButton *musicPlayerRepeatButton;
@property (nonatomic, retain) IBOutlet UIButton *musicPlayerShuffleButton;

@property (nonatomic, retain) IBOutlet UIView *mainview;
@property (nonatomic, retain) IBOutlet UINavigationItem *navitem;
@property (nonatomic, retain) IBOutlet UITableView *tableview;
@property (nonatomic, retain) IBOutlet UISegmentedControl *modeSegment;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbarBottom;

- (void)query;
- (BOOL)existInSelectedList:(MPMediaItem *)item index:(NSInteger *)index;

- (NSData *)decrypt:(NSString *)path;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)modeChanged:(id)sender;
- (IBAction)back:(id)sender;

// music-player
- (IBAction)musicList:(id)sender;
- (IBAction)musicPlay:(id)sender;
- (IBAction)musicStop:(id)sender;
- (IBAction)musicPrev:(id)sender;
- (IBAction)musicNext:(id)sender;
- (IBAction)musicRepeat:(id)sender;
- (IBAction)musicShuffle:(id)sender;

- (void)musicPlayerItemChanged:(id)notification;
- (void)musicPlayerStateChanged:(id)notification;

- (BOOL)isToolbarBottomEnabled;
- (void)setToolbarBottomEnabled:(BOOL)enabled;

@end
