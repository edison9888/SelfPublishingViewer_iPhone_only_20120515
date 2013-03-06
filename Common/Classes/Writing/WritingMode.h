//
//  WritingMode.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/12.
//  Copyright 2011 SAT. All rights reserved.
//

#import "WritingPane.h"
#import "TouchPanGestureRecognizer.h"

#define SENSE_RADIUS 30
#define AREA_MINWIDTH 20
#define AREA_MINHEIGHT 20
#define AREA_MINSIZE CGSizeMake(AREA_MINWIDTH, AREA_MINHEIGHT)
#define AREA_MARGIN 15


@interface WritingMode : NSObject {
    @protected
    WritingPane* pane;
    UIView* canvas;
    CALayer* layer;
}
// モードに入った
-(void)modeSelected;
// モードに入っているときに再度スイッチをタップされた
-(void)modeAgain;
// モードから出る
-(void)modeUnselected;
// WritingPaneへの参照をセットする
-(void)setWritingPane:(WritingPane*)wp;
// タップのイベントリスナ
-(void)tapped:(UITapGestureRecognizer*)gr;
// ドラッグのイベントリスナ
-(void)dragged:(TouchPanGestureRecognizer*)gr;
// 今やっている作業を終了する
-(void)completeCurrent;

@end
