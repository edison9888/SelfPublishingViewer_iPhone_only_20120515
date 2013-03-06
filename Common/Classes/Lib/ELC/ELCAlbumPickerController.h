//
//  AlbumPickerController.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>


@interface ELCAlbumPickerController : UITableViewController {
	
	ALAssetsLibrary *library;
	NSMutableArray *assetGroups;
	NSOperationQueue *queue;
	id parent;
}

@property (nonatomic, assign) id parent;
@property (nonatomic, retain) NSMutableArray *assetGroups;

-(void)selectedAssets:(NSArray*)_assets;

@end

