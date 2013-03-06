//
//  MusicPlayerHelper.m
//  JisuiView
//
//  Created by FSCM100301 on 10/11/19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MusicPlayerHelper.h"


@implementation MusicPlayerHelper

@synthesize viewcontroller;
@synthesize musicPlayerView, musicPlayerTitle, musicPlayerArtist, musicPlayerArtwork;
@synthesize musicPlayerPlayButton, musicPlayerRepeatButton, musicPlayerShuffleButton;
@synthesize musicPlayerSuperview;

- (id)init {
    self = [super init];
	if (self) {
		NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:
							 [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"]];
		
		NSError *error;
		defPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:
					 [NSURL fileURLWithPath:
					  [[NSBundle mainBundle] pathForResource:[dic objectForKey:keyAudioPath]
													  ofType:nil]]
														   error:&error];
		[defPlayer prepareToPlay];
		defPlayer.delegate = self;
		defMusicPlay = YES;
		
		musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
		[musicPlayer setShuffleMode:MPMusicShuffleModeOff];
		[musicPlayer setRepeatMode:MPMusicRepeatModeNone];
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self 
			   selector:@selector(musicPlayerItemChanged:) 
				   name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
				 object:musicPlayer];
		[nc addObserver:self
			   selector:@selector(musicPlayerStateChanged:)
				   name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
				 object:musicPlayer];
		[musicPlayer beginGeneratingPlaybackNotifications];
	}
	return self;
}

- (void)dealloc {
	if (defPlayer.playing) {
		[defPlayer stop];
	}
	[defPlayer release];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:musicPlayer];
	[nc removeObserver:self name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:musicPlayer];
	
	[super dealloc];
}


#pragma mark -
#pragma mark Private methods

- (void)initView {
	NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:
						 [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"]];
	
	musicPlayerTitle.text = [dic objectForKey:keyAudioTitle];
	musicPlayerArtist.text = [dic objectForKey:keyAudioArtist];
	musicPlayerArtwork.image = [UIImage imageNamed:@"artwork.png"];
}

- (void)toggleMusicPlayer {
	BOOL hiddenFlag = musicPlayerView.hidden;
	
	//	if (hiddenFlag) {
	//		if (!landscaping && tabbarMenu.alpha == 0.75f) [self toggleMenuTabbar];
	//		if (searchbar.alpha == 1.0f) [self toggleSearchbar];
	//	}
	
	if (hiddenFlag) musicPlayerView.hidden = NO;
	[UIView beginAnimations:@"animation" context:nil];
	[UIView setAnimationDuration:0.3f];
	musicPlayerView.frame = CGRectMake(musicPlayerView.frame.origin.x, 
									   hiddenFlag ?
									   musicPlayerView.frame.origin.y + musicPlayerView.frame.size.height :
									   musicPlayerView.frame.origin.y - musicPlayerView.frame.size.height, 
									   musicPlayerView.frame.size.width, 
									   musicPlayerView.frame.size.height);
	[UIView commitAnimations];
	if (!hiddenFlag) {
		[NSTimer scheduledTimerWithTimeInterval:0.3f 
										 target:self 
									   selector:@selector(hideMusicPlayer) 
									   userInfo:nil
										repeats:NO];
	}
}

- (void)hideMusicPlayer {
	musicPlayerView.hidden = YES;
}


#pragma mark -
#pragma mark MusicPlayer

- (IBAction)musicList:(id)sender {
	CVMediaPickerController *picker = [[CVMediaPickerController alloc] initWithNibName:@"CVMediaPickerController"
																				bundle:nil
																				 items:musicList ? musicList : nil];
	picker.cvmpDelegate = self;
	[viewcontroller presentModalViewController:picker animated:YES];
	[picker release];
}

- (IBAction)musicPlay:(id)sender{
	BOOL playFlag = NO;
	if (defMusicPlay) {
		if (defPlayer.playing) {
			[defPlayer pause];
		} else {
			[defPlayer play];
			playFlag = YES;
		}
	} else {
		if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
			[musicPlayer pause];
		} else {
			[musicPlayer play];
			playFlag = YES;
		}
	}
	
	if (playFlag) {
		[musicPlayerPlayButton setImage:[UIImage imageNamed:@"music_pause_normal.png"]
							   forState:UIControlStateNormal];
		[musicPlayerPlayButton setImage:[UIImage imageNamed:@"music_pause_pressed.png"]
							   forState:UIControlStateHighlighted];
		[musicPlayerPlayButton setImage:[UIImage imageNamed:@"music_pause_pressed.png"]
							   forState:UIControlStateSelected];
	} else {
		[musicPlayerPlayButton setImage:[UIImage imageNamed:@"music_play_normal.png"]
							   forState:UIControlStateNormal];
		[musicPlayerPlayButton setImage:[UIImage imageNamed:@"music_play_pressed.png"]
							   forState:UIControlStateHighlighted];
		[musicPlayerPlayButton setImage:[UIImage imageNamed:@"music_play_pressed.png"]
							   forState:UIControlStateSelected];
	}
}

- (IBAction)musicStop:(id)sender {
	if (defMusicPlay) {
		[defPlayer pause];
		defPlayer.currentTime = 0;
	} else {
		[musicPlayer stop];
	}
	
	[musicPlayerPlayButton setImage:[UIImage imageNamed:@"music_play_normal.png"]
						   forState:UIControlStateNormal];
	[musicPlayerPlayButton setImage:[UIImage imageNamed:@"music_play_pressed.png"]
						   forState:UIControlStateHighlighted];
	[musicPlayerPlayButton setImage:[UIImage imageNamed:@"music_play_pressed.png"]
						   forState:UIControlStateSelected];
}

- (IBAction)musicPrev:(id)sender {
	if (defMusicPlay) {
		defPlayer.currentTime = 0;
	} else {
		if (musicPlayer.currentPlaybackTime >= 3.0f) {
			[musicPlayer skipToBeginning];
		} else {
			[musicPlayer skipToPreviousItem];
		}
	}
}

- (IBAction)musicNext:(id)sender {
	if (defMusicPlay) {
		defPlayer.currentTime = 0;
	} else {
		[musicPlayer skipToNextItem];
	}
}

- (IBAction)musicRepeat:(id)sender {
	if (musicPlayer.repeatMode == MPMusicRepeatModeNone) {
		defPlayer.numberOfLoops = -1;
		[musicPlayer setRepeatMode:MPMusicRepeatModeOne];
		[musicPlayerRepeatButton setImage:[UIImage imageNamed:@"music_repeating_1.png"]
								 forState:UIControlStateNormal];
		[musicPlayerRepeatButton setImage:[UIImage imageNamed:@"music_repeat_1_pressed.png"]
								 forState:UIControlStateHighlighted];
		[musicPlayerRepeatButton setImage:[UIImage imageNamed:@"music_repeat_1_pressed.png"]
								 forState:UIControlStateSelected];
	} else if (musicPlayer.repeatMode == MPMusicRepeatModeOne) {
		defPlayer.numberOfLoops = -1;
		[musicPlayer setRepeatMode:MPMusicRepeatModeAll];
		[musicPlayerRepeatButton setImage:[UIImage imageNamed:@"music_repeating.png"]
								 forState:UIControlStateNormal];
		[musicPlayerRepeatButton setImage:[UIImage imageNamed:@"music_repeat_pressed.png"]
								 forState:UIControlStateHighlighted];
		[musicPlayerRepeatButton setImage:[UIImage imageNamed:@"music_repeat_pressed.png"]
								 forState:UIControlStateSelected];
	} else if (musicPlayer.repeatMode == MPMusicRepeatModeAll) {
		defPlayer.numberOfLoops = 0;
		[musicPlayer setRepeatMode:MPMusicRepeatModeNone];
		[musicPlayerRepeatButton setImage:[UIImage imageNamed:@"music_repeat_normal.png"]
								 forState:UIControlStateNormal];
		[musicPlayerRepeatButton setImage:[UIImage imageNamed:@"music_repeat_pressed.png"]
								 forState:UIControlStateHighlighted];
		[musicPlayerRepeatButton setImage:[UIImage imageNamed:@"music_repeat_pressed.png"]
								 forState:UIControlStateSelected];
	}
}

- (IBAction)musicShuffle:(id)sender {
	BOOL played = (musicPlayer.playbackState == MPMusicPlaybackStatePlaying);
	if (played) [musicPlayer stop];
	if (musicPlayer.shuffleMode == MPMusicShuffleModeOff) {
		[musicPlayer setShuffleMode:MPMusicShuffleModeSongs];
		[musicPlayerShuffleButton setImage:[UIImage imageNamed:@"music_shuffling.png"] 
								  forState:UIControlStateNormal];
	} else if (musicPlayer.shuffleMode == MPMusicShuffleModeSongs) {
		[musicPlayer setShuffleMode:MPMusicShuffleModeOff];
		[musicPlayerShuffleButton setImage:[UIImage imageNamed:@"music_shuffle_normal.png"] 
								  forState:UIControlStateNormal];
	}
	if (played) [musicPlayer play];
}

- (IBAction)musicHide:(id)sender {
	[self toggleMusicPlayer];
}


#pragma mark -
#pragma mark CVMediaPickerController delegate

- (void)didSelected:(CVMediaPickerController *)controller collection:(MPMediaItemCollection *)c {
	
	if (musicList) {
		[musicList release];
		musicList = nil;
	}
	
	if (c != nil && c.count > 0) {
		BOOL played = NO;
		
		if (defMusicPlay) {
			if (defPlayer.playing) {
				played = YES;
				[defPlayer pause];
				defPlayer.currentTime = 0;
			}
			defMusicPlay = NO;
		}
		
		musicList = [[NSMutableArray alloc] initWithArray:c.items];
		
		if (!played && musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
			played = YES;
			[musicPlayer stop];
		}
		
		[musicPlayer setQueueWithItemCollection:c];
		
		MPMediaItem *item = [musicList objectAtIndex:0];
		musicPlayerTitle.text = [item valueForProperty:MPMediaItemPropertyTitle];
		musicPlayerArtist.text = [item valueForProperty:MPMediaItemPropertyArtist];
		
		MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
		if (artwork != nil) {
			musicPlayerArtwork.image = [artwork imageWithSize:musicPlayerArtwork.frame.size];
		} else {
			musicPlayerArtwork.image = [UIImage imageNamed:@"artwork.png"];
		}
		
		if (played) [musicPlayer play];
		
	} else {
		defMusicPlay = YES;
		
		NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:
							 [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"]];
		
		musicPlayerTitle.text = [dic objectForKey:keyAudioTitle];
		musicPlayerArtist.text = [dic objectForKey:keyAudioArtist];
		musicPlayerArtwork.image = [UIImage imageNamed:@"artwork.png"];
		
		if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
			[musicPlayer stop];
			[defPlayer play];
		}
	}
}


#pragma mark -
#pragma mark MusicPlayer notification

- (void)musicPlayerItemChanged:(id)notification {
	MPMediaItem *item = musicPlayer.nowPlayingItem;
	if (item) {
		musicPlayerTitle.text = [item valueForProperty:MPMediaItemPropertyTitle];
		musicPlayerArtist.text = [item valueForProperty:MPMediaItemPropertyArtist];
		
		MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
		if (artwork != nil) {
			musicPlayerArtwork.image = [artwork imageWithSize:musicPlayerArtwork.frame.size];
		} else {
			musicPlayerArtwork.image = [UIImage imageNamed:@"artwork.png"];
		}
	}
}

- (void)musicPlayerStateChanged:(id)notification {
	if (musicPlayer.playbackState == MPMusicPlaybackStateStopped && [musicList count] > 0) {
		MPMediaItem *item = [musicList objectAtIndex:0];
		musicPlayerTitle.text = [item valueForProperty:MPMediaItemPropertyTitle];
		musicPlayerArtist.text = [item valueForProperty:MPMediaItemPropertyArtist];
		
		MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
		if (artwork != nil) {
			musicPlayerArtwork.image = [artwork imageWithSize:musicPlayerArtwork.frame.size];
		} else {
			musicPlayerArtwork.image = [UIImage imageNamed:@"artwork.png"];
		}
		
		[musicPlayerPlayButton setImage:[UIImage imageNamed:@"music_play_normal.png"]
							   forState:UIControlStateNormal];
		[musicPlayerPlayButton setImage:[UIImage imageNamed:@"music_play_pressed.png"]
							   forState:UIControlStateHighlighted];
		[musicPlayerPlayButton setImage:[UIImage imageNamed:@"music_play_pressed.png"]
							   forState:UIControlStateSelected];
	}
}


#pragma mark -
#pragma mark AVAudioPlayer delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	
}

@end
