//
//  ControlScroller.h
//  ForIPad
//
//  Created by 藤田正訓 on 11/08/01.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PageImageView.h"

@protocol Viewable;
@class ControlScroller;

@protocol ControlScrollerDelegate <NSObject>
// 選択されたイベント
-(void)controlScroller:(ControlScroller*)cs selected:(NSInteger)page;
-(NSInteger)currentPage;
-(void)controlScroller:(ControlScroller*)cs scrolled:(NSInteger)page;
@end



@interface ControlScroller : UIView <UIScrollViewDelegate> {
    //@private
    NSObject<Viewable>* dataSource;
    NSObject<ControlScrollerDelegate>* delegate;
    UIScrollView* scrollView;
    BOOL leftNext;
    NSMutableArray* icons;
    BOOL scrolling;
}

// データソース
@property(nonatomic,retain) NSObject<Viewable>* dataSource;
@property(nonatomic,retain) NSMutableArray* icons;

// イベントリスナ
@property(nonatomic,assign) NSObject<ControlScrollerDelegate>* delegate;
// 表示位置を変更する
- (void)updateScroll:(NSInteger)page;
// 終了時処理
- (void)onClose;
@end


