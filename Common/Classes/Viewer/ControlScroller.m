//
//  ControlScroller.m
//  ForIPad
//
//  Created by 藤田正訓 on 11/08/01.
//  Copyright 2011 SAT. All rights reserved.
//

#import "ControlScroller.h"
#import "common.h"
#import "Book.h"
#import "BookReaderPane.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView_Effects.h"
#import "AppUtil.h"
//#import "LoadingView.h"


@interface ControlScroller()
//@property(nonatomic,retain) NSMutableArray* icons;
@end

@implementation ControlScroller

@synthesize dataSource,icons;
@synthesize delegate;


#pragma mark - ボタンのサムネイル読み込み

// 現在スクロールで表示されている真ん中のページ数を返す
- (NSInteger)scrollCenterPage {
    // スクロールで表示されているボタンを抽出
    CGFloat iw = SF_MARGIN_WIDTH_L + SF_ICON_WIDTH;
    int cn = [dataSource pageCount];
    CGFloat offLeft = scrollView.contentOffset.x;
    CGFloat offRight = offLeft + scrollView.width;
    // 左からの個数
    int leftD = offLeft / iw;
    int rightD = offRight / iw;
    // ページ数
    int fromP = leftNext ? cn - rightD : leftD;
    int toP = leftNext ? cn - leftD : rightD;
    int centerP = (fromP + toP) / 2;
    return MAX(MIN(centerP, cn - 1), 0);
}


// ボタンにサムネイル画像を読み込む（別スレッド）
- (void)loadIconImage:(UIButton*)b {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
    @synchronized(self) {
        UIImage* img = [dataSource getThumbnailImage:b.tag];
        [b setImage:img forState:UIControlStateNormal];
    }
    [pool release];
}

// 現在スクロールで表示されているボタンだけサムネイルを読み込む
- (void)updateIconImages {
    if (scrolling || [icons count] == 0) {
        return;
    }
    UIImage* loadingImg = [UIImage imageNamed:@"timer.png"];
    // スクロールで表示されているボタンを抽出
    CGFloat iw = SF_MARGIN_WIDTH_L + SF_ICON_WIDTH;
    int cn = [dataSource pageCount];
    CGFloat offLeft = scrollView.contentOffset.x;
    CGFloat offRight = offLeft + scrollView.width;
    // 左からの個数
    int leftD = offLeft / iw;
    int rightD = offRight / iw + 1;
    // ページ数
    int fromP = leftNext ? cn - rightD : leftD;
    int toP = leftNext ? cn - leftD : rightD;
    fromP = MAX(MIN(fromP, cn - 1), 0);
    toP = MAX(MIN(toP, cn - 1), 0);
    for (int i = fromP; i <= toP; i++) {
        if (!scrolling) {
            UIButton* b = [icons objectAtIndex:i];
            if (![b imageForState:UIControlStateNormal]) {
                [b setImage:loadingImg forState:UIControlStateNormal];
                [self performSelectorInBackground:@selector(loadIconImage:) withObject:b];

            }
        }
    }
}


#pragma mark - スクロールの調整
// 指定ページのアイコンを真ん中に表示する
- (void)updateScroll:(NSInteger)page {
    CGFloat iw = SF_MARGIN_WIDTH_L + SF_ICON_WIDTH;
    NSInteger cn = [dataSource pageCount];
    CGFloat cx = leftNext
        ? iw * (cn - page - 1)
        : iw * page;
    cx = cx + SF_ICON_WIDTH / 2 - self.width / 2;
    scrollView.contentOffset = CGPointMake(cx, 0);
}


#pragma mark - ボタンの準備

- (void)onTapped:(UIButton*)button {
    [delegate controlScroller:self selected:button.tag];
}


// とりあえず枠のUIButtonをすべて用意する
- (void)addIcons {
    for (UIButton* b in icons) {
        [b removeFromSuperview];
    }
    [icons removeAllObjects];
    
    NSInteger cn = [dataSource pageCount];
    CGFloat iw = SF_MARGIN_WIDTH_L + SF_ICON_WIDTH;
    for (int i = 0; i < cn; i++) {
        CGFloat x = leftNext 
            ? SF_MARGIN_WIDTH_L + iw * (cn - i - 1)
            : SF_MARGIN_WIDTH_L + iw * i;
        UIButton* b = [UIButton buttonWithType:UIButtonTypeCustom];
        b.layer.borderColor = [UIColor whiteColor].CGColor;
        b.layer.borderWidth = 1;
        b.frame = CGRectMake(x, 0, SF_ICON_WIDTH, SF_ICON_HEIGHT);
        b.tag = i;
        [b addTarget:self action:@selector(onTapped:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:b];
        [icons addObject:b];
        UILabel* l = [[UILabel alloc]init];
        l.frame = CGRectMake(x, SF_ICON_HEIGHT, SF_ICON_WIDTH, 20);
        l.text = [NSString stringWithFormat:@"%d", i + 1];
        l.backgroundColor = [UIColor grayColor];
        l.textColor = [UIColor whiteColor];
        l.textAlignment = UITextAlignmentCenter;
        [scrollView addSubview:l];
        [l release];
    }
    scrollView.contentSize = CGSizeMake(cn * iw + SF_MARGIN_WIDTH_L, SF_ICON_HEIGHT + 20);
    [self updateScroll:[delegate currentPage]];
}


#pragma mark - scroll event
- (void)scrollStopped {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
    scrolling = NO;
    [self updateIconImages];
    [pool release];
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    scrolling = YES;
    [ControlScroller cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollStopped) object:nil];
    [self performSelector:@selector(scrollStopped) withObject:nil afterDelay:0.2];
    [delegate controlScroller:self scrolled:[self scrollCenterPage]];
}

#pragma mark - public
- (void)onClose {
    scrollView.delegate = nil;
}

#pragma mark - view event

- (void)layoutSubviews {
    [super layoutSubviews];
    [scrollView eFittoSuperview];
    if ([dataSource pageCount] != [icons count]) {
        [self addIcons];
    }
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.icons = [NSMutableArray array];
        scrollView = [[UIScrollView alloc]init];
        [self addSubview:scrollView];
        [scrollView release];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        scrollView.delegate = self;
        NSUserDefaults* ud = [AppUtil config];
        leftNext = [ud boolForKey:@"leftNext"];
    }
    return self;
}

- (void)dealloc
{
    //NSLog(@"%s", __func__);
    self.icons = nil;
    self.dataSource = nil;
    self.delegate = nil;
    [super dealloc];
}

@end
