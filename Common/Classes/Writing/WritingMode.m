//
//  WritingMode.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/12.
//  Copyright 2011 SAT. All rights reserved.
//

#import "WritingMode.h"


@implementation WritingMode

-(void)setWritingPane:(WritingPane*)wp {
    self = [super init];
    if (self) {
        pane = wp;
        canvas = wp.canvas;
        layer = wp.layer;
    }
}

// モードに入った
-(void)modeSelected {
    
}
// モードから出る
-(void)modeUnselected {
    
}

// 再タップ
-(void)modeAgain {
    
}
// タップのイベントリスナ
-(void)tapped:(UITapGestureRecognizer*)gr {
    
}
// ドラッグのイベントリスナ
-(void)dragged:(TouchPanGestureRecognizer*)gr {
    
}
// 今やっている作業を完了する
-(void)completeCurrent {
    
}
@end
