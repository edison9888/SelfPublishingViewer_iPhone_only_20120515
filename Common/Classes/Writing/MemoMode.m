//
//  MemoMode.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/12.
//  Copyright 2011 SAT. All rights reserved.
//

#import "MemoMode.h"
#import "PageMemo.h"
#import "PageMemoComment.h"
#import "UIView_Effects.h"
#import "CommentView.h"
#import "AppUtil.h"
#import "common.h"
#import "NSString_Util.h"
#import "AlertDialog.h"

@interface MemoMode()
@property(nonatomic,retain)NSMutableArray* icons;
@property(nonatomic,retain)NSMutableArray* comments;
@end

@implementation MemoMode
@synthesize icons,comments;


#pragma mark -private


#pragma mark - イベント

-(void)showEditView {
    CommentView* cv = [CommentView view];
    [cv setComment:editingComment.comment];
    cv.delegate = self;
    [pane.view addSubview:cv];
    [cv eFittoSuperview];
}

// コメントに関連付けられたボタンを作成する
-(UIButton*)addIcon:(PageMemoComment*)c {
    UIImage* iconimg = [UIImage imageNamed:@"comment.png"];
    CGSize csize = canvas.frame.size;
    UIButton* b = [UIButton buttonWithType:UIButtonTypeCustom];
    [b setImage:iconimg forState:UIControlStateNormal];
    [b eSize:iconimg.size];
    [b eCenter:csize.width * c.point.x :csize.height * c.point.y];
    b.tag = c.commentId;
    [canvas addSubview:b];
    [icons addObject:b];
    return b;
}

// タップした場所にあるボタンを返す
-(UIButton*) hitIcon:(CGPoint)p {
    for (UIButton* icon in icons) {
        if ([icon eContains:p]) {
            return icon;
        }
    }
    return nil;
}
// ボタンに対応するコメントを返す
-(PageMemoComment*) comment:(UIButton*)icon {
    for (PageMemoComment* c in comments) {
        if (c.commentId == icon.tag) {
            return c;
        }
    }
    return nil;
}


-(void)dragged:(TouchPanGestureRecognizer *)gr {
    CGPoint p = [gr locationInView:canvas];
    if (gr.touchState == TouchPanGestureRecognizerStateBegin) {
        draggingIcon = [self hitIcon:p];
        dragging = NO;
        if (!draggingIcon) {
            making = YES;
        }
    } else if (gr.state == UIGestureRecognizerStateBegan) {
        if (!draggingIcon) {
            PageMemoComment* c = [pageMemo createComment];
            [comments addObject:c];
            c.point = CGPointMake(p.x / canvas.width, p.y / canvas.height);
            draggingIcon = [self addIcon:c];
            making = YES;
        }
        dragging = YES;
    } else if (gr.state == UIGestureRecognizerStateChanged) {
        if (draggingIcon) {
            [draggingIcon setCenter:p];
        }
    } else if (gr.state == UIGestureRecognizerStateEnded
               || gr.state == UIGestureRecognizerStateCancelled
               || gr.state == UIGestureRecognizerStateFailed
               || gr.touchState == TouchPanGestureRecognizerStateEnd) {
        if (!draggingIcon && making) {
            PageMemoComment* c = [pageMemo createComment];
            [comments addObject:c];
            c.point = CGPointMake(p.x / canvas.width, p.y / canvas.height);
            draggingIcon = [self addIcon:c];
        }
        if (draggingIcon) {
            PageMemoComment* com = [self comment:draggingIcon];
            com.point = CGPointMake(p.x / canvas.width,
                                    p.y / canvas.height);
            if (making || !dragging) {
                editingIcon = draggingIcon;
                editingComment = com;
                [self showEditView];
                making = NO;
            } else {
                [com save];
            }
            draggingIcon = nil;
        }
    }
}

#pragma mark - CommentViewのイベント
-(void)onSave:(NSString *)comment {
    editingComment.comment = comment;
    [editingComment save];
}
-(void)onDelete {
    [pageMemo deleteComment:editingComment];
}
-(void)onClose {
    if (editingComment.isNew) {
        // 削除した時もisNewになる
        [editingIcon removeFromSuperview];
        [comments removeObject:editingComment];
        [icons removeObject:editingIcon];
    }
    
    editingIcon = nil;
    editingComment = nil;
}


#pragma mark - 外部操作
// 最初にアイコンを表示させる
-(void)modeSelected {
    self.comments = [NSMutableArray arrayWithArray:[pageMemo myComments]];
    for (PageMemoComment* c in comments) {
        [self addIcon:c];
    }
    NSUserDefaults* ud = [AppUtil config];
    if (![ud boolForKey:@"memoModeHelp"]) {
        [AlertDialog confirm:res(@"aboutMemoMode")
                     message:res(@"memoModeHelp")
                        onOK:^(){
                            [ud setBool:YES forKey:@"memoModeHelp"];
                        }];
    }
}



-(id)initWithPageMemo:(PageMemo *)pm {
    self = [super init];
    if (self) {
        pageMemo = pm;
        self.icons = [NSMutableArray array];
    }
    return self;
}

-(void)dealloc {
    for (UIView* v in icons) {
        [v removeFromSuperview];
    }
    self.icons = nil;
    [super dealloc];
}

@end
