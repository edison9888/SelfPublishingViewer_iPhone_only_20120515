//
//  TileView.m
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/22.
//  Copyright 2011 SAT. All rights reserved.
//

#import "TileView.h"


@implementation TileView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
    }
    return self;
}

- (UIImage*) backgroundImage {
    return backgroundImage;
}

- (void)setBackgroundImage:(UIImage *)bgImage {
    if (backgroundImage != bgImage) {
        [backgroundImage release];
        backgroundImage = bgImage;
        [backgroundImage retain];
        [self setNeedsDisplay];
    }
}

// 背景画像を描画する
- (void)drawRect:(CGRect)rect
{
    if (backgroundImage) {
        CGFloat ih = backgroundImage.size.height;
        CGRect r = CGRectMake(0, 0, self.frame.size.width, ih);
        for (; r.origin.y < rect.origin.y + rect.size.height; r.origin.y += ih) {
            if (r.origin.y + r.size.height > rect.origin.y) {
                [backgroundImage drawInRect:r];
            }
        }
    }
}

- (void)dealloc
{
    self.backgroundImage = nil;
    [super dealloc];
}

@end
