    //
//  MusicViewController.m
//  CommonViewer
//
//  Created by FSCM100301 on 10/10/07.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MusicViewController.h"
#import "AppUtil.h"
#import "RootPane.h"


@implementation MusicViewController

@synthesize musicPlayerTitle, musicPlayerArtist, musicPlayerArtwork;
@synthesize musicPlayerListButton, musicPlayerPlayButton, musicPlayerRepeatButton, musicPlayerShuffleButton;
@synthesize mainview, navitem, tableview, modeSegment, toolbarBottom;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// size
	self.contentSizeForViewInPopover = CGSizeMake(320.0, 460.0);
    
    [self setToolbarBottomEnabled:NO];
        
	// title
	navitem.title = NSLocalizedString(titleMPPlaylist, nil);
	
	// segment
	[modeSegment setTitle:NSLocalizedString(titleMPSong, nil) forSegmentAtIndex:CVMPTagSong];
	[modeSegment setTitle:NSLocalizedString(titleMPArtist, nil) forSegmentAtIndex:CVMPTagArtist];
	
	// music-player
	NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:
						 [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"]];
	
	musicPlayerTitle.text = [dic objectForKey:keyAudioTitle];
	musicPlayerArtist.text = [dic objectForKey:keyAudioArtist];
	musicPlayerArtwork.image = [UIImage imageNamed:@"artwork.png"];
	
	musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ![RootPane isRotationLocked];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
	
	if ((defMusicPlay && defPlayer.playing) 
		|| (!defMusicPlay && musicPlayer.playbackState == MPMusicPlaybackStatePlaying)) {
		return;
	} else {
		[super didReceiveMemoryWarning];
	}
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	if (selectedList) [selectedList release];
	if (list) [list release];
	if (musicList) [musicList release];
	[defPlayer release];
    [super dealloc];
}


#pragma mark -
#pragma mark Private methods

- (void)query {
	MPMediaQuery *query = nil;
	switch (mode) {
		case CVMPTagSong:
			query = [MPMediaQuery songsQuery];
			break;
		case CVMPTagArtist:
			query = [MPMediaQuery artistsQuery];
			break;
		default:
			break;
	}
	
	if (list != nil) {
		[list release];
		list = nil;
	}
	
	list = [[NSArray alloc] initWithArray:[query collections]];
	
	[tableview reloadData];
}

- (BOOL)isToolbarBottomEnabled {
    if ([AppUtil isForIpad]) {
        return !toolbarBottom.hidden;
    } else {        
        int index = 0;
        for (UIView* v in toolbarBottom.subviews) {
            if (index != 0) {
                return !v.hidden;
            }
            index ++;
        }
        return YES;
    }
}

- (void)setToolbarBottomEnabled:(BOOL)enabled {
    if ([AppUtil isForIpad]) {
        [toolbarBottom setHidden:(!enabled)];
        if (enabled) {
            tableview.frame = CGRectMake(tableview.frame.origin.x, 
                                         tableview.frame.origin.y, 
                                         tableview.frame.size.width, 
                                         tableview.frame.size.height - toolbarBottom.frame.size.height);
        } else {
            tableview.frame = CGRectMake(tableview.frame.origin.x, 
                                         tableview.frame.origin.y, 
                                         tableview.frame.size.width, 
                                         tableview.frame.size.height + toolbarBottom.frame.size.height);
        }
    } else {
        [toolbarBottom setHidden:NO];
        int index = 0;
        for (UIView* v in toolbarBottom.subviews) {
            if (index == 0) {

            } else {
                [v setHidden:(!enabled)];
            }
            index ++;
        }
    }
}

- (BOOL)existInSelectedList:(MPMediaItem *)item index:(NSInteger *)index {
	NSInteger ret = -1;
	for (int i = 0; i < [selectedList count]; i++) {
		MPMediaItem *tempItem = [selectedList objectAtIndex:i];
		if ([[item valueForProperty:MPMediaItemPropertyPersistentID] isEqualToNumber:
			 [tempItem valueForProperty:MPMediaItemPropertyPersistentID]]) {
			ret = i;
			if (index != nil) *index = i;
			break;
		}
	}
	
	return ret >= 0;
}

- (NSData *)decrypt:(NSString *)path {
	NSData *data = [NSData dataWithContentsOfFile:path];
	
	const char *inputData = [data bytes];
	char *outputData = malloc([data length]);
	const char *flag = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
	NSInteger count = 0;
	
	for (int i = 0; i < [data length]; i++) {
		if (i % 4 == 0) {
			outputData[i] = inputData[i] - flag[count++ % 62];
		} else {
			outputData[i] = inputData[i];
		}
	}
	
	NSData *dataNew = [NSData dataWithBytes:outputData length:[data length]];
	free(outputData);
	
	return dataNew;
}


#pragma mark -
#pragma mark Action methods

- (IBAction)cancel:(id)sender {
    if ([self isToolbarBottomEnabled]) {
        musicPlayerListButton.enabled = YES;
	
        [musicPlayerListButton setImage:[UIImage imageNamed:@"music_list_normal.png"]
                               forState:UIControlStateNormal];

        listMode = CVMPListTagPlaylist;
        navitem.title = NSLocalizedString(titleMPPlaylist, nil);
	
        [tableview reloadData];
	
        [UIView beginAnimations:@"animation" context:nil];
	
        [self setToolbarBottomEnabled:NO];
	
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                               forView:mainview
                                 cache:YES];
        [UIView commitAnimations];
    } else {
        UIViewController* rp = [AppUtil rootViewController];
        [rp dismissModalViewControllerAnimated:YES];        
    }
}

- (IBAction)done:(id)sender {
	musicPlayerListButton.enabled = YES;
	
	[musicPlayerListButton setImage:[UIImage imageNamed:@"music_list_normal.png"]
						   forState:UIControlStateNormal];
	
	if (musicList) {
		[musicList release];
		musicList = nil;
	}
	
	listMode = CVMPListTagPlaylist;
	navitem.title = NSLocalizedString(titleMPPlaylist, nil);
	
	[UIView beginAnimations:@"animation" context:nil];
	
    [self setToolbarBottomEnabled:NO];
	
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
						   forView:mainview
							 cache:YES];
	[UIView commitAnimations];
	
	MPMediaItemCollection *c = nil;
	if ([selectedList count] > 0 && (c = [MPMediaItemCollection collectionWithItems:selectedList]) && c.count > 0) {
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
		defPlayer.currentTime = 0;
		
		NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:
							 [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"]];
		
		musicPlayerTitle.text = [dic objectForKey:keyAudioTitle];
		musicPlayerArtist.text = [dic objectForKey:keyAudioArtist];
		musicPlayerArtwork.image = [UIImage imageNamed:@"artwork.png"];
		
		if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
			[musicPlayer stop];
			[defPlayer play];
		}
		
		musicPlayerRepeatButton.enabled = NO;
		musicPlayerShuffleButton.enabled = NO;
	}
	
	[tableview reloadData];
}

- (IBAction)modeChanged:(id)sender {
	mode = ((UISegmentedControl *)sender).selectedSegmentIndex;
	
	if (mode == CVMPTagSong) {
		navitem.title = NSLocalizedString(titleMPSong, nil);
	} else if (mode == CVMPTagArtist) {
		navitem.title = NSLocalizedString(titleMPArtist, nil);
	} else {
		navitem.title = nil;
	}
	
	[self query];
}

- (IBAction)back:(id)sender {
	inArtist = NO;
	navitem.leftBarButtonItem = nil;
	[tableview reloadData];
}


#pragma mark -
#pragma mark Tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (listMode == CVMPListTagPlaylist) {
		if ([musicList count] == 0) {
            defMusicPlay = YES;
			return 1;
		} else {
			return [musicList count];
		}
	} else if (listMode == CVMPListTagSelect) {
		if (mode == CVMPTagArtist && inArtist) {
			return ((MPMediaItemCollection *)[list objectAtIndex:selectedArtist]).count;
		} else {
			return [list count];
		}
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *SubCellIdentifier = @"SubCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SubCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									   reuseIdentifier:SubCellIdentifier] autorelease];
		cell.textLabel.textColor = [UIColor whiteColor];
		cell.detailTextLabel.textColor = [UIColor lightTextColor];
	}
	
	if (listMode == CVMPListTagPlaylist) {
		if (defMusicPlay) {
			NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:
								 [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"]];
			cell.textLabel.text = [dic objectForKey:keyAudioTitle];
			cell.detailTextLabel.text = [dic objectForKey:keyAudioArtist];
			cell.imageView.image = [UIImage imageNamed:@"artwork.png"];
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		} else {
			MPMediaItem *item = [musicList objectAtIndex:indexPath.row];
			cell.textLabel.text = [item valueForProperty:MPMediaItemPropertyTitle];
			cell.detailTextLabel.text = [item valueForProperty:MPMediaItemPropertyArtist];
			
			MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
			if (artwork == nil) {
				cell.imageView.image = [UIImage imageNamed:@"artwork.png"];
			} else {
				cell.imageView.image = [artwork imageWithSize:CGSizeMake(40.0f, 40.0f)];
			}
			
			if ([musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyPersistentID] &&
				[(NSNumber *)[item valueForProperty:MPMediaItemPropertyPersistentID] isEqualToNumber:
				 (NSNumber *)[musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyPersistentID]]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
		}
	} else if (listMode == CVMPListTagSelect) {
		switch (mode) {
			case CVMPTagSong: {
				MPMediaItemCollection *collection = [list objectAtIndex:indexPath.row];
				MPMediaItem *item = [collection representativeItem];
				cell.textLabel.text = [item valueForProperty:MPMediaItemPropertyTitle];
				cell.detailTextLabel.text = [item valueForProperty:MPMediaItemPropertyArtist];
				
				if ([self existInSelectedList:item index:nil]) {
					cell.accessoryType = UITableViewCellAccessoryCheckmark;
				} else {
					cell.accessoryType = UITableViewCellAccessoryNone;
				}
				
				MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
				if (artwork == nil) {
					cell.imageView.image = [UIImage imageNamed:@"artwork.png"];
				} else {
					cell.imageView.image = [artwork imageWithSize:CGSizeMake(40.0f, 40.0f)];
				}
			}
				break;
			case CVMPTagArtist: {
				cell.imageView.image = nil;
				if (inArtist) {
					MPMediaItemCollection *collection = [list objectAtIndex:selectedArtist];
					MPMediaItem *item = [collection.items objectAtIndex:indexPath.row];
					cell.textLabel.text = [item valueForProperty:MPMediaItemPropertyTitle];
					cell.detailTextLabel.text = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
					
					if ([self existInSelectedList:item index:nil]) {
						cell.accessoryType = UITableViewCellAccessoryCheckmark;
					} else {
						cell.accessoryType = UITableViewCellAccessoryNone;
					}
				} else {
					MPMediaItemCollection *collection = [list objectAtIndex:indexPath.row];
					MPMediaItem *item = [collection representativeItem];
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.textLabel.text = [item valueForProperty:MPMediaItemPropertyArtist];
					cell.detailTextLabel.text = nil;
				}
			}
				break;
			default:
				break;
		}
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (listMode == CVMPListTagPlaylist) {
		if (defMusicPlay) {
			if (defPlayer.playing) {
				defPlayer.currentTime = 0;
			} else {
				[self musicPlay:nil];
			}
		} else {
			musicPlayer.nowPlayingItem = [musicList objectAtIndex:indexPath.row];
			
			if (musicPlayer.playbackState != MPMusicPlaybackStatePlaying) {
				[self musicPlay:nil];
			}
		}
	} else if (listMode == CVMPListTagSelect) {
		switch (mode) {
			case CVMPTagSong: {
				NSInteger index;
				MPMediaItemCollection *collection = [list objectAtIndex:indexPath.row];
				MPMediaItem *item = [collection representativeItem];
				if ([self existInSelectedList:item index:&index]) {
					((UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath]).accessoryType = UITableViewCellAccessoryNone;
					[selectedList removeObjectAtIndex:index];
				} else {
					((UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath]).accessoryType = UITableViewCellAccessoryCheckmark;
					[selectedList addObject:item];
				}
			}
				break;
			case CVMPTagArtist:
				if (inArtist) {
					NSInteger index;
					MPMediaItemCollection *collection = [list objectAtIndex:selectedArtist];
					MPMediaItem *item = [collection.items objectAtIndex:indexPath.row];
					if ([self existInSelectedList:item index:&index]) {
						((UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath]).accessoryType = UITableViewCellAccessoryNone;
						[selectedList removeObjectAtIndex:index];
					} else {
						((UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath]).accessoryType = UITableViewCellAccessoryCheckmark;
						[selectedList addObject:item];
					}
				} else {
					inArtist = YES;
					selectedArtist = indexPath.row;
					
					UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(labelBack, nil)
																				   style:UIBarButtonItemStylePlain
																				  target:self
																				  action:@selector(back:)];
					navitem.leftBarButtonItem = backButton;
					[backButton release];
					[tableView reloadData];
				}
				break;
			default:
				break;
		}
	}
}


#pragma mark -
#pragma mark MusicPlayer

/*
 - (IBAction)musicList:(id)sender {
 CVMediaPickerController *picker = [[CVMediaPickerController alloc] initWithNibName:@"CVMediaPickerController"
 bundle:nil
 items:musicList ? musicList : nil];
 picker.cvmpDelegate = self;
 [self presentModalViewController:picker animated:YES];
 [picker release];
 }*/

- (IBAction)musicList:(id)sender {
	if (![self isToolbarBottomEnabled]) {
		[musicPlayerListButton setImage:[UIImage imageNamed:@"music_list_pressed.png"]
							   forState:UIControlStateNormal];
		
		if (!selectedList) {
			selectedList = [[NSMutableArray alloc] init];
		}
		[selectedList removeAllObjects];
		[selectedList addObjectsFromArray:musicList];
		
		listMode = CVMPListTagSelect;
		
		mode = modeSegment.selectedSegmentIndex;
		
		[UIView beginAnimations:@"animation" context:nil];
		
		if (mode == CVMPTagSong) {
			navitem.title = NSLocalizedString(titleMPSong, nil);
		} else if (mode == CVMPTagArtist) {
			navitem.title = NSLocalizedString(titleMPArtist, nil);
		} else {
			navitem.title = nil;
		}
		
        [self setToolbarBottomEnabled:YES];
		
		[UIView setAnimationDuration:0.5f];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
							   forView:mainview
								 cache:YES];
		[UIView commitAnimations];
		
		[self query];
		
	} else {
		[self cancel:nil];
	}
}

- (IBAction)musicPlay:(id)sender {
	BOOL playFlag = NO;
	if (defMusicPlay) {
        if (!defPlayer) {
            NSError *error;
            defPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:
                         [NSURL fileURLWithPath:
                          [[NSBundle mainBundle] pathForResource:@"Samples/Beethoven_Symphonies_No_7"
                                                        ofType:@"mp3"]]
                                                               error:&error];
            [defPlayer prepareToPlay];
            defPlayer.numberOfLoops = -1;
            defPlayer.delegate = self;
        }
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
        [defPlayer release];
        defPlayer = nil;
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
//		defPlayer.numberOfLoops = -1;
		[musicPlayer setRepeatMode:MPMusicRepeatModeOne];
		[musicPlayerRepeatButton setImage:[UIImage imageNamed:@"music_repeating_1.png"]
								 forState:UIControlStateNormal];
		[musicPlayerRepeatButton setImage:[UIImage imageNamed:@"music_repeat_1_pressed.png"]
								 forState:UIControlStateHighlighted];
		[musicPlayerRepeatButton setImage:[UIImage imageNamed:@"music_repeat_1_pressed.png"]
								 forState:UIControlStateSelected];
	} else if (musicPlayer.repeatMode == MPMusicRepeatModeOne) {
//		defPlayer.numberOfLoops = -1;
		[musicPlayer setRepeatMode:MPMusicRepeatModeAll];
		[musicPlayerRepeatButton setImage:[UIImage imageNamed:@"music_repeating.png"]
								 forState:UIControlStateNormal];
		[musicPlayerRepeatButton setImage:[UIImage imageNamed:@"music_repeat_pressed.png"]
								 forState:UIControlStateHighlighted];
		[musicPlayerRepeatButton setImage:[UIImage imageNamed:@"music_repeat_pressed.png"]
								 forState:UIControlStateSelected];
	} else if (musicPlayer.repeatMode == MPMusicRepeatModeAll) {
//		defPlayer.numberOfLoops = 0;
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
//	BOOL played = (musicPlayer.playbackState == MPMusicPlaybackStatePlaying);
//	if (played) [musicPlayer stop];
	if (musicPlayer.shuffleMode == MPMusicShuffleModeOff) {
		[musicPlayer setShuffleMode:MPMusicShuffleModeSongs];
		[musicPlayerShuffleButton setImage:[UIImage imageNamed:@"music_shuffling.png"] 
								  forState:UIControlStateNormal];
	} else if (musicPlayer.shuffleMode == MPMusicShuffleModeSongs) {
		[musicPlayer setShuffleMode:MPMusicShuffleModeOff];
		[musicPlayerShuffleButton setImage:[UIImage imageNamed:@"music_shuffle_normal.png"] 
								  forState:UIControlStateNormal];
	}
//	if (played) [musicPlayer play];
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
		
		[tableview reloadData];
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
		
		[tableview reloadData];
	}
	
	if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
		musicPlayerRepeatButton.enabled = YES;
		musicPlayerShuffleButton.enabled = YES;
	} else {
		musicPlayerRepeatButton.enabled = NO;
		musicPlayerShuffleButton.enabled = NO;
	}
}


#pragma mark -
#pragma mark AVAudioPlayer delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	
}


@end
