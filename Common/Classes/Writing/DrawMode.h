//
//  DrawMode.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/12.
//  Copyright 2011 SAT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WritingMode.h"
#import "PalettePane.h"

@interface DrawMode : WritingMode<PalettePaneDelegate> {
    CGFloat penWidth;
    UIColor* penColor;
    CGPoint paletteSelectPoint;
    
    CGPoint last;
    CGPoint last2;
    BOOL isHighlight; //蛍光ペン
    CGContextRef context;
    PalettePane* palettePane;
    
    
}

@end
