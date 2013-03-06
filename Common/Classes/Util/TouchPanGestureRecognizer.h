//
//  TouchPanRecognizer.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/13.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TouchPanGestureRecognizerStateBegin,
    TouchPanGestureRecognizerStateEnd,
    TouchPanGestureRecognizerStateChanging
} TouchPanGestureRecognizerState;

@interface TouchPanGestureRecognizer : UIPanGestureRecognizer {
    SEL touchSelector;
    id touchTarget;
    TouchPanGestureRecognizerState touchState;
}
@property(nonatomic,readonly)CGPoint beginPoint;

@property(nonatomic,readonly)TouchPanGestureRecognizerState touchState;

// タッチ開始時のイベントを取得するセレクタを登録する
-(void)setTouchTarget:(id)target selector:(SEL)selector;
@end
