//
//  ShareExplanation.h
//  ForIPad
//
//  Created by 川口主税 on 11/08/04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ShareExplanation : UIViewController {
	int explanationType;
	UIScrollView *scrollview01;
}
@property(nonatomic,retain)IBOutlet UIScrollView *scrollview01;

- (void)setExplanationType:(int)type;
- (void)setDisplay:(BOOL)portrait;

@end
