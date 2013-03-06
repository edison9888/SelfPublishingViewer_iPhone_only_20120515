//
//  MemoMode.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/12.
//  Copyright 2011 SAT. All rights reserved.
//

#import "WritingMode.h"
#import "CommentView.h"
@class PageMemo;

@interface MemoMode : WritingMode <CommentViewDelegate>{
    PageMemo* pageMemo;
    NSMutableArray* icons;
    NSMutableArray* comments;
    UIButton* draggingIcon;
    UIButton* editingIcon;
    PageMemoComment* editingComment;
    UIView* membrane;
    BOOL making;
    BOOL dragging;
}

-(id)initWithPageMemo:(PageMemo*)pm;
@end
