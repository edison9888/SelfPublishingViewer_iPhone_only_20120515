//
//  BookPageCell.m
//

#import "BookPageCell.h"


@implementation BookPageCell
@synthesize coverView, mainLabel, pathLabel, button, badgeView;

- (void)dealloc {
    self.coverView = nil;
    self.badgeView = nil;
    self.mainLabel = nil;
    self.pathLabel = nil;
    self.button = nil;
    [super dealloc];
}

-(void)layoutSubviews {
    if (coverView.image.size.width > coverView.image.size.height) {
        CGRect rc = coverView.frame;
        if (rc.size.width < rc.size.height) {
            rc.size.width *= 2;
            coverView.frame = rc;
        }
    }
    [super layoutSubviews];
}

@end
