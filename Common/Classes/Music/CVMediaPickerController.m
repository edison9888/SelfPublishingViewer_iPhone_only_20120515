    //
//  CVMediaPickerController.m
//  CommonViewer
//
//  Created by FSCM100301 on 10/08/19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CVMediaPickerController.h"
#import "RootPane.h"


@implementation CVMediaPickerController

@synthesize navitem, tableview, tabbar;
@synthesize doneButton,cancelButton,backButton;
@synthesize cvmpDelegate;

/*
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
    }
    return self;
}
*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil items:(NSArray *)items {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		if (items) {
			selectedList = [[NSMutableArray alloc] initWithArray:items];
		} else {
			selectedList = [[NSMutableArray alloc] init];
		}
	}
	return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// title
//	navitem.title = NSLocalizedString(titleMPSong, nil);
	
	// buttons
	doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
															   target:self
															   action:@selector(done:)];
	cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																 target:self
																 action:@selector(cancel:)];
	backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(labelBack, nil)
												  style:UIBarButtonItemStylePlain
												 target:self
												 action:@selector(back:)];
	navitem.leftBarButtonItem = cancelButton;
	navitem.rightBarButtonItem = doneButton;
	
	// tabbar
	UITabBarItem *item = (UITabBarItem *)[tabbar.items objectAtIndex:CVMPTagSong];
//	[item setTitle:NSLocalizedString(titleMPSong, nil)];
	[tabbar setSelectedItem:item];
	
	item = (UITabBarItem *)[tabbar.items objectAtIndex:CVMPTagArtist];
//	[item setTitle:NSLocalizedString(titleMPArtist, nil)];
	
	[self query];
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ![RootPane isRotationLocked];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.navitem = nil;
    self.doneButton = nil;
    self.cancelButton = nil;
    self.backButton = nil;
    self.tabbar = nil;
    self.tableview = nil;
}


- (void)dealloc {
	[selectedList release];
	[list release];
    self.navitem = nil;
    self.doneButton = nil;
    self.cancelButton = nil;
    self.backButton = nil;
    self.tabbar = nil;
    self.tableview = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Tabbar delegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
	mode = item.tag;
	inArtist = NO;
	
	switch (item.tag) {
		case CVMPTagSong:
//			navitem.title = NSLocalizedString(titleMPSong, nil);
			break;
		case CVMPTagArtist:
//			navitem.title = NSLocalizedString(titleMPArtist, nil);
			break;
		default:
			break;
	}
	
	[self query];
}


#pragma mark -
#pragma mark Tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (mode == CVMPTagArtist && inArtist) {
		return ((MPMediaItemCollection *)[list objectAtIndex:selectedArtist]).count;
	} else {
		return list.count;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *SubCellIdentifier = @"SubCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SubCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									   reuseIdentifier:SubCellIdentifier] autorelease];
	}
	
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
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
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
				navitem.leftBarButtonItem = backButton;
				navitem.rightBarButtonItem = nil;
				[tableView reloadData];
			}
			break;
		default:
			break;
	}
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


#pragma mark -
#pragma mark Action methods

- (IBAction)back:(id)sender {
	inArtist = NO;
	navitem.leftBarButtonItem = cancelButton;
	navitem.rightBarButtonItem = doneButton;
	[tableview reloadData];
}

- (IBAction)done:(id)sender {
	if (cvmpDelegate != nil) {
		if (selectedList != nil && [selectedList count] > 0) {
			[cvmpDelegate didSelected:self collection:[MPMediaItemCollection collectionWithItems:selectedList]];
		} else {
			[cvmpDelegate didSelected:self collection:nil];
		}
	}
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}


@end
