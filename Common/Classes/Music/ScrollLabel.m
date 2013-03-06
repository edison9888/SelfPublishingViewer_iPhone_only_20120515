//
//  ScrollLabel.m
//  CommonViewer
//
//  Created by FSCM100301 on 10/10/08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ScrollLabel.h"


@implementation ScrollLabel


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//}


- (void)dealloc {
	if (timer) {
		[timer invalidate];
		[timer release];
	}
	if (textOrg) {
		[textOrg release];
	}
    [super dealloc];
}


- (void)setText:(NSString *)t {
	super.text = t;
	
 	if (timer) {
		[timer invalidate];
		[timer release];
		timer = nil;
	}
	
	if (textOrg) {
		[textOrg release];
		textOrg = nil;
	}
	
	if ([t sizeWithFont:self.font].width > self.frame.size.width) {
		textIndex = 0;
		textCount = [t length];
		
		textOrg = [[NSString alloc] initWithString:t];
		
		timer = [[NSTimer scheduledTimerWithTimeInterval:1
												  target:self
												selector:@selector(textCut)
												userInfo:nil
												 repeats:YES] retain];
	}
}

- (void)textCut {
	if (textIndex < textCount) {
		super.text = [textOrg substringFromIndex:textIndex++];
	} else {
		textIndex = 0;
	}
}


@end
