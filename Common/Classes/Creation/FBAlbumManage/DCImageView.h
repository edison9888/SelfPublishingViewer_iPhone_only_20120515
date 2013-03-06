//
//  DCImageView.h
//  asyTblDemo
//
//  Created by digicorp on 12/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumPicker.h"

@interface DCImageView : UIView {
	NSString *strURL;
	NSMutableDictionary *dRef1;
	NSMutableData *myWebData;
    NSError *error;
	
    NSString *strName;
    NSMutableArray *arrayImageURLs;
    
    id delegate;
	
}
@property(nonatomic, retain) NSMutableArray *arrayImageURLs;
@property(nonatomic,retain) NSMutableData *myWebData;
@property(nonatomic,retain) NSString *strURL;
@property(nonatomic,retain) NSMutableDictionary *dRef1;
@property(nonatomic,retain)id delegate;


-(void)loadURLImage:(NSString*)urlStringValue dictionaryRef:(NSMutableDictionary*)dRef countNumber:(int)count callBackTarget:(id)target;
- (UIImage*)postProcessLazyImage:(UIImage*)image;
@end






