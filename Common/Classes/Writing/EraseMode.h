//
//  EraseMode.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/12.
//  Copyright 2011 SAT. All rights reserved.
//

#import "WritingMode.h"
#import "PalettePane.h"

@interface EraseMode : WritingMode<PalettePaneDelegate> {
    CGFloat eraseWidth;
    CGContextRef context;
    CGPoint last;
    PalettePane* palettePane;
}

@end
