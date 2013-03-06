//
//  ScrollLabel.h
//  CommonViewer
//
//  Created by FSCM100301 on 10/10/08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ScrollLabel : UILabel {
	NSString *textOrg;
	NSInteger textCount;
	NSInteger textIndex;
	NSTimer *timer;
}

- (void)textCut;

@end
