//
//  PageMemoView.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/15.
//  Copyright 2011 SAT. All rights reserved.
//

#import "PageMemoView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView_Effects.h"
#import "AttachmentPane.h"
#import "RootPane.h"

@interface PageMemoView() 
@property(nonatomic,retain) PageMemo* pageMemo;
@property(nonatomic,retain) NSArray* comments;
@property(nonatomic,retain) NSArray* buttons;
@property(nonatomic,retain) UIImage* image;
@end

@implementation PageMemoView
@synthesize comments, buttons, image, pageMemo;
-(PageMemoComment*)comment:(NSInteger)commentId {
    if (comments) {
        for (PageMemoComment* c in comments) {
            if (c.commentId == commentId) {
                return c;
            }
        }
    }
    return nil;
}

-(void)showComment:(UIButton*)b {
    [commentLabel removeFromSuperview];
    if (b.tag != showingId) {
        PageMemoComment* c = [self comment:b.tag];
        UIFont* font = [UIFont systemFontOfSize:14];
        CGSize size = [c.comment sizeWithFont:font 
                       constrainedToSize:CGSizeMake(self.width * 0.7, self.height)
                                lineBreakMode:UILineBreakModeCharacterWrap];
        CGRect rect;
        rect.origin.x = MAX(5, b.left - (size.width - b.width) / 2);
        rect.origin.y = b.bottom + 5;
        rect.size = size;
        UILabel* l = [[UILabel alloc]initWithFrame:rect];
        l.numberOfLines = 0;
        //    l.lineBreakMode = UILineBreakModeCharacterWrap;
        l.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.8];
        l.textColor = [UIColor whiteColor];
        l.font = font;
        l.text = c.comment;
        [self addSubview:l];
        if (l.right > self.width) {
            [l eOffset:self.width - l.right - 5 :0];
        }
        if (l.bottom > self.height) {
            [l eMove:l.left :b.top - l.height - 5];
        }
        commentLabel = l;
        [l release];
        showingId = b.tag;
    } else {
        commentLabel = nil;
        showingId = 0;
    }
}

-(void)showAttachment:(UIButton*)b {
    AttachmentPane* p = [[AttachmentPane alloc]init];
    p.pageMemo = pageMemo;
    [[RootPane instance]pushPane:p];
    [p release];
}

#pragma mark - 外部操作
-(void)show:(PageMemo*)pm {
    self.pageMemo = pm;
    self.comments = [pageMemo comments];
    self.buttons = [NSMutableArray arrayWithCapacity:[comments count]];
    self.image = [pageMemo layeredWritingImage];
    self.layer.contents = (id)image.CGImage;
    if ([pageMemo attachmentCount] > 0) {
        attachmentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* atimg = [UIImage imageNamed:@"attachment.png"];
        [attachmentButton setImage:atimg
                          forState:UIControlStateNormal];
        [attachmentButton eSize:atimg.size];
        attachmentButton.exclusiveTouch = YES;
        [self addSubview:attachmentButton];
    }
    [self layoutSubviews];
}

-(void)dismiss {
    if (buttons) {
        for (UIButton* b in buttons) {
            [b removeFromSuperview];
        }
    }
    self.buttons = nil;
    self.comments = nil;
    if (commentLabel) {
        [commentLabel removeFromSuperview];
        commentLabel = nil;
    }
    self.image = nil;
    self.layer.contents = nil;
    if (attachmentButton) {
        [attachmentButton removeFromSuperview];
        attachmentButton = nil;
    }
    
}

-(BOOL)tapped:(CGPoint)p {
    for (UIButton* b in buttons) {
        if ([b eContains:p]) {
            [self showComment:b];
            return YES;
        }
    }
    if (attachmentButton) {
        if ([attachmentButton eContains:p]) {
            [self showAttachment:attachmentButton];
            return YES;
        }
    }
    if (commentLabel) {
        if ([commentLabel eContains:p]) {
            [commentLabel removeFromSuperview];
            commentLabel = nil;
            return YES;
        }
    }
    return NO;
}


#pragma mark - view イベント

-(void)layoutSubviews {
    if (pageMemo) {
        if ([comments count] != [buttons count]) {
            UIImage* iconImg = [UIImage imageNamed:@"comment.png"];
            for (PageMemoComment* c in comments) {
                UIButton* b = [UIButton buttonWithType:UIButtonTypeCustom];
                [b setImage:iconImg forState:UIControlStateNormal];
                b.tag = c.commentId;
                [b eSize:iconImg.size];
                [buttons addObject:b];
                [self addSubview:b];
            }
        }
        CGFloat sw = self.width;
        CGFloat sh = self.height;
        // コメントボタンを配置
        for (UIButton* b in buttons) {
            PageMemoComment* c = [self comment:b.tag];
            [b eCenter:sw * c.point.x :sh * c.point.y];
            if (b.right > self.width) {
                [b eFitRight:NO];
            }
            if (b.left < 0) {
                [b eFitLeft:NO];
            }
            if (b.top < 0) {
                [b eFitTop:NO];
            }
            if (b.bottom > self.height) {
                [b eFitBottom:NO];
            }
        }
        // 添付画像ボタン
        if (attachmentButton) {
            [attachmentButton eMove:sw - attachmentButton.width :50];
        }
    }
}

- (id)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)dealloc
{
    NSLog(@"%s", __func__);
    self.layer.contents = nil;
    [pageMemo release];
    pageMemo = nil;
    self.comments = nil;
    self.buttons = nil;
    self.image = nil;
    [super dealloc];
}

@end
