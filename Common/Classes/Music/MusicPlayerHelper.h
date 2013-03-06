//
//  MusicPlayerHelper.h
//  JisuiView
//
//  Created by FSCM100301 on 10/11/19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "CVMediaPickerController.h"


@interface MusicPlayerHelper : NSObject <CVMediaPickerControllerDelegate, AVAudioPlayerDelegate> {
	
	IBOutlet UIViewController *viewcontroller;
	
	IBOutlet UIView *musicPlayerView;
	IBOutlet UILabel *musicPlayerTitle;
	IBOutlet UILabel *musicPlayerArtist;
	IBOutlet UIImageView *musicPlayerArtwork;
	IBOutlet UIButton *musicPlayerPlayButton;
	IBOutlet UIButton *musicPlayerRepeatButton;
	IBOutlet UIButton *musicPlayerShuffleButton;
	
	IBOutlet UIView *musicPlayerSuperview;
	
	MPMusicPlayerController *musicPlayer;
	NSMutableArray *musicList;
	
	AVAudioPlayer *defPlayer;
	BOOL defMusicPlay;
}

@property (nonatomic, assign) IBOutlet UIViewController *viewcontroller;

@property (nonatomic, retain) IBOutlet UIView *musicPlayerView;
@property (nonatomic, retain) IBOutlet UILabel *musicPlayerTitle;
@property (nonatomic, retain) IBOutlet UILabel *musicPlayerArtist;
@property (nonatomic, retain) IBOutlet UIImageView *musicPlayerArtwork;
@property (nonatomic, retain) IBOutlet UIButton *musicPlayerPlayButton;
@property (nonatomic, retain) IBOutlet UIButton *musicPlayerRepeatButton;
@property (nonatomic, retain) IBOutlet UIButton *musicPlayerShuffleButton;

@property (nonatomic, assign) IBOutlet UIView *musicPlayerSuperview;

- (void)initView;

- (IBAction)toggleMusicPlayer;
- (void)hideMusicPlayer;

- (IBAction)musicList:(id)sender;
- (IBAction)musicPlay:(id)sender;
- (IBAction)musicStop:(id)sender;
- (IBAction)musicPrev:(id)sender;
- (IBAction)musicNext:(id)sender;
- (IBAction)musicRepeat:(id)sender;
- (IBAction)musicShuffle:(id)sender;
- (IBAction)musicHide:(id)sender;

- (void)musicPlayerItemChanged:(id)notification;
- (void)musicPlayerStateChanged:(id)notification;

@end
