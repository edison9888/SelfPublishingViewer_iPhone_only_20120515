//
//  ClubView.h
//  DSC
//
//  Created by sparsh on 11/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThumbSelected.h"
#import "EGOImageView.h"

@class EGOImageView;


@interface ClubView : UIView  {
	
	EGOImageView* imageViewL;
	IBOutlet UIImageView *clubImg;
	IBOutlet UIButton *btn;
	IBOutlet UILabel *nameLbl;
	NSMutableDictionary *clubDict;
	IBOutlet UIActivityIndicatorView *spinner;
	id <ThumbSelected> delegate;
}
@property(nonatomic, retain) NSMutableDictionary *clubDict;
@property (nonatomic, assign) id <ThumbSelected> delegate;
@property(nonatomic, retain)UILabel *nameLbl;
@property(nonatomic, retain)IBOutlet UIButton *btn;
@property(nonatomic, retain)IBOutlet UIImageView *clubImg;

-(void) setImageView :(NSString *)filePath;
-(void) setLabelName :(NSString *)filePath;
@end
