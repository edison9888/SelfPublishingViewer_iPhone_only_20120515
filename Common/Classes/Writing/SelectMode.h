//
//  SelectMode.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/12.
//  Copyright 2011 SAT. All rights reserved.
//

#import "WritingMode.h"
@class SelectAreaView;


@interface SelectMode : WritingMode {
    SelectAreaView* areaView;
    enum DragMode {
        MAKING,
        MOVING,
        RESIZING
    } dragMode;
    CGPoint beginPoint;
    CGContextRef context;
}

@end
