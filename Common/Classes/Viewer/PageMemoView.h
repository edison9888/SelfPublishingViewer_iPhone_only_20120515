//
//  PageMemoView.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/15.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageMemo.h"
#import "PageMemoComment.h"
#import "Book.h"

@interface PageMemoView : UIView {
    @private
    PageMemo* pageMemo;
    NSArray* comments;
    NSMutableArray* buttons;
    UIButton* attachmentButton;
    UIImage* image;
    UILabel* commentLabel;
    NSInteger showingId;
}

// 自分でイベントを処理したらYESを返す
-(BOOL)tapped:(CGPoint)p;

-(void)show:(PageMemo*)pm;

-(void)dismiss;



@end
