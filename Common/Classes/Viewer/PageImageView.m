//
//  PageImageView.m
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/04.
//  Copyright 2011 SAT. All rights reserved.
//

#import "PageImageView.h"
#import "VectorUtil.h"
#import "ImageUtil.h"
#import "URLLink.h"
#import "AlertDialog.h"
#import "common.h"
#import "UIView_Effects.h"
#import "CALayer_Effects.h"
#import "AppUtil.h"
#import "PageMemoView.h"

// 長押し判定する秒数
static const NSTimeInterval PRESS_DURATION = 1.0f;

// 画面上のエリア定義
typedef enum {
    LEFT,
    RIGHT,
    CENTER
} PlaceType;

#if 1
#define PIVLog(mess) {\
NSLog(@" \n(%s)%@\nleft:%@ \nright:%@ \ncontent:%@ \nflip:%@ \nflipMask:%@\nflipBack:%@\nflipBackMask:%@", __FUNCTION__,mess,[leftLayer eDesc], [rightLayer eDesc], [contentView eDesc], [flipLayer eDesc], [flipMaskLayer eDesc], [flipBackLayer eDesc], [flipBackMaskLayer eDesc]); \
}
#else
#define PIVLog(mess) 
#endif



@implementation PageImageView
@synthesize delegate, dataSource, currentPage, isPortrait, 
leftNext, marginShadow, animeType, spread, separateCover, contentView;



#pragma mark - Viewとレイヤーのレイアウト


// contentViewの位置を変える
- (void)setContentViewOrigin:(CGPoint)newOrigin {
    CGRect scr = contentView.frame;
//    LogRect(scr, @"before", __func__);
    scr.origin = newOrigin;
    
    // はみ出さないように補正
    if (scr.origin.x > 0) {
        scr.origin.x = 0;
        leftLimit = YES;
    } else {
        leftLimit = NO;
    }
    if (scr.origin.x + scr.size.width < self.frame.size.width) {
        scr.origin.x = self.frame.size.width - scr.size.width;
        rightLimit = YES;
    } else {
        rightLimit = NO;
    }
    if (scr.origin.y > 0) {
        scr.origin.y = 0;
    } else if (scr.origin.y + scr.size.height < self.frame.size.height) {
        scr.origin.y = self.frame.size.height - scr.size.height;
    }
//    LogRect(scr, @"after", __func__);
    contentView.frame = scr;
    
}

#pragma mark - ページ画像のロード

// 指定ページを含む画面に必要な画像をロードする
- (NSInteger) loadPage:(NSInteger)page 
                  left:(CALayer*)left 
                 right:(CALayer*)right
               forward:(BOOL)forward {
    CGSize fsize = self.frame.size;
    page = MAX( MIN( [dataSource pageCount] - 1, page), 0);
    PIVLog(@"before");
    if (!isPortrait && spread) {
        // 見開き表示の場合
        right.hidden = NO;
        UIImage* img1 = nil;
        NSInteger page1 = forward ? page : MAX(0, page - 1);
        UIImage* img2 = nil;

        NSInteger page2 = forward ? MIN([dataSource pageCount] - 1, page + 1) : page;
        
        if ((separateCover && (page1 == 0 || page2 == 0)) || (page1 == page2 && page1 == 0)) {
            if (forward) {
                // 表紙だけ分ける設定のときの表紙
                //NSLog(@"FORWARD page1 : %d, page2 : %d", page1, page2);
                page1 = page2 = MIN(page1, page2);
                img1 = [dataSource imageAt:page1];
            } else {
                //NSLog(@"BACKWARD page1 : %d, page2 : %d", page1, page2);
                page1 = page2 = MAX(page1, page2);
                img1 = [dataSource imageAt:page1];

            }
            if (img1.size.width > img1.size.height) {
                if (leftNext) {
                    // 右側が若い
                    img2 = [ImageUtil clip:img1 rect:CGRectMake(0, 0, 0.5, 1)];
                    img1 = [ImageUtil clip:img1 rect:CGRectMake(0.5, 0, 0.5, 1)];

                } else {
                    // 左側が若い
                    img2 = [ImageUtil clip:img1 rect:CGRectMake(0.5, 0, 0.5, 1)];
                    img1 = [ImageUtil clip:img1 rect:CGRectMake(0, 0, 0.5, 1)];

                }
            } else {
                img2 = img1;
                img1 = [UIImage imageNamed:@"coverPlaceholder.png"];

                //if (leftNext) {
                  //  img2 = img1;
                 //   img1 = nil;
                //}
                
            }
        } else {
            // 表紙以外のページ
            if (forward && page1 == page2 && page == [dataSource pageCount] - 1) {
                // 最後のページ
                img1 = [dataSource imageAt:page1];
            } else {
                img1 = [dataSource imageAt:page1];
                img2 = [dataSource imageAt:page2];
            }
            
            if ((forward && img1.size.width > img1.size.height)
                || (!forward && img2.size.width > img2.size.height)) {
                // 見開きで横長画像を表示
                UIImage* img = forward ? img1 : img2;
                page1 = page2 = forward ? page1 : page2;
                if (leftNext) {
                    // 右側が若い
                    img1 = [ImageUtil clip:img rect:CGRectMake(0.5, 0, 0.5, 1)];
                    img2 = [ImageUtil clip:img rect:CGRectMake(0, 0, 0.5, 1)];
                } else {
                    // 左側が若い
                    img1 = [ImageUtil clip:img rect:CGRectMake(0, 0, 0.5, 1)];
                    img2 = [ImageUtil clip:img rect:CGRectMake(0.5, 0, 0.5, 1)];
                }
            } else if (!forward && img1.size.width > img1.size.height) {
                img1 = nil;
                page1 = page2;
            } else if (forward && img2.size.width > img2.size.height) {
                img2 = nil;
                page2 = page1;
            } else if (img1 == nil) {
                page1 = page2;
            } else if (img2 == nil) {
                page2 = page1;
            }
        }
        CGSize size = CGSizeMake(fsize.width / 2, fsize.height);
        
        // layerに設定
        if (leftNext) {
            left.contents = (id)img2.CGImage;
            left.name = [NSString stringWithFormat:@"%d", page2];
            right.contents = (id)img1.CGImage;
            right.name = [NSString stringWithFormat:@"%d", page1];
            left.frame = CGRectMake(0, 0, size.width, size.height);
            right.frame = CGRectMake(size.width, 0, size.width, size.height);
        } else {
            left.contents = (id)img1.CGImage;
            left.name = [NSString stringWithFormat:@"%d", page1];
            right.contents = (id)img2.CGImage;
            right.name = [NSString stringWithFormat:@"%d", page2];
            left.frame = CGRectMake(0, 0, size.width, size.height);
            right.frame = CGRectMake(size.width, 0, size.width, size.height);
        }
    } else {
        // １ページ表示
        UIImage* img = [dataSource imageAt:page];
        left.contents = (id)img.CGImage;
        left.name = [NSString stringWithFormat:@"%d", page];
        if (isPortrait) {
            // 縦置き
            if (img.size.width > img.size.height) {
                // 横長画像
                if (pagingToRight) {
                    left.frame = CGRectMake(-fsize.width, 0, fsize.width * 2, fsize.height);
                } else {
                    left.frame = CGRectMake(0, 0, fsize.width * 2, fsize.height);
                }
            } else {
                left.frame = CGRectMake(0, 0, fsize.width, fsize.height);
            }
        } else {
            // 横置き
            if (img.size.width < img.size.height) {
                // 縦長
                left.frame = CGRectMake(0, 0, fsize.width, fsize.height * 2);
            } else {
                left.frame = CGRectMake(0, 0, fsize.width, fsize.height);
            }
        }
        right.frame = left.frame;
        right.contents = nil;
        right.name = left.name;
    }
    if (animeType == PageImageViewAnimationScroll) {
        left.hidden = left.contents ? NO : YES;
        right.hidden = right.contents ? NO : YES;
    }
    PIVLog(@"after");
    
    return page;
}

- (void)addButton:(URLLink*)ul size:(CGSize)sz x:(CGFloat)x {
    UIButton* lb = [UIButton buttonWithType:UIButtonTypeCustom];
//    lb.layer.borderColor = [UIColor blueColor].CGColor;
//    lb.layer.borderWidth = 3;
    lb.frame = CGRectMake(ul.rect.origin.x * sz.width + x,
                          ul.rect.origin.y * sz.height,
                          ul.rect.size.width * sz.width,
                          ul.rect.size.height * sz.height);
    lb.titleLabel.text = [ul.url absoluteString];
    [lb addTarget:self action:@selector(linkTapped:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:lb];    
}

- (void)layoutButtons {
    // すでにaddされたButtonを削除
    for (UIView* v in [contentView subviews]) {
        if ([v class] == [UIButton class]) {
            [v removeFromSuperview];
        }
    }
    // URLLinkの配列を取得
    NSInteger page1 = [leftLayer.name intValue];
    for (URLLink* ul in [dataSource urlLinks:page1]) {
        [self addButton:ul size:leftLayer.frame.size x:0];
    }
    NSInteger page2 = [rightLayer.name intValue];
    if (page2 != page1 && !isPortrait && spread) {
        for (URLLink* ul in [dataSource urlLinks:page2]) {
            [self addButton:ul size:rightLayer.frame.size x:leftLayer.frame.size.width];
        }
    }
    
}

- (void)hidePageMemo {
    memoLeftView.hidden = YES;
    memoRightView.hidden = YES;
}

- (void)showPageMemo {
    // 左側
    if (leftLayer.contents) {
        NSInteger lp = [leftLayer.name intValue];
        PageMemo* pm = [dataSource getPageMemo:lp];
        [memoLeftView dismiss];
        [memoLeftView show:pm];
        memoLeftView.frame = leftLayer.frame;
        memoLeftView.hidden = NO;
    } else {
        memoLeftView.hidden = YES;
    }
    
    if (rightLayer.left == leftLayer.right && rightLayer.contents) {
        // 2ページ表示の場合
        NSInteger rp = [rightLayer.name intValue];
        PageMemo* pm2 = [dataSource getPageMemo:rp];
        [memoRightView dismiss];
        [memoRightView show:pm2];
        memoRightView.frame = rightLayer.frame;
        memoRightView.hidden = NO;
    } else {
        memoRightView.hidden = YES;
    }
}



#pragma mark - めくりエフェクト

- (void) startCurl {
    pagingPrepared = NO;
    pagingDistance = 0;
    flipView.hidden = NO;
    [self hidePageMemo];
    BOOL singlepage = isPortrait || !spread;
    if (pagingToRight) {
        // 左ー>右へめくる
        CGRect lrc = leftLayer.frame;
        if (lrc.size.width > lrc.size.height) {
            lrc.size.width /= 2;
            lrc.origin.x = scrollView.contentOffset.x;
        }
        flipLayer.frame = flipShadowLayer.frame = lrc;
        

        NSInteger pageToLoad;
        BOOL forward;
        NSInteger leftPage = [leftLayer.name intValue];

        if (!singlepage) {
            flipLayer.contents = leftLayer.contents;
            flipLayer.name = leftLayer.name;
            rightLayer.hidden = NO;
            // 見開き表示の場合
            NSInteger rightPage = [rightLayer.name intValue];
            if (leftNext) {
                // 次へ
                pageToLoad = MAX(leftPage, rightPage) + 1;
                forward = YES;
            } else {
                // 前へ
                pageToLoad = MIN(leftPage, rightPage) - 1;
                forward = NO;
            }
            [self loadPage:pageToLoad left:leftLayer right:flipBackLayer forward:forward];
            PIVLog(@"toRight not single");
        } else {
            // １ページ表示の場合
            rightLayer.hidden = YES;
            scrollView.contentOffset = CGPointMake(0, 0);
            if (leftNext) {
                ////NSLog(@"6");
                // 次へ
                flipLayer.contents = leftLayer.contents;
                flipLayer.name = leftLayer.name;
                flipLayer.frame = leftLayer.frame;
                
                pageToLoad = leftPage + 1;
                forward = YES;
                [self loadPage:pageToLoad left:leftLayer right:flipBackLayer forward:forward];
                PIVLog(@"toRight next single");
            } else {
                // 前へ                
                pageToLoad = leftPage - 1;
                forward = NO;
                [self loadPage:pageToLoad left:flipLayer right:flipBackLayer forward:forward];
                PIVLog(@"toRight prev single");
            }
        }

        
    } else {
        // 左←右にめくる
        NSInteger pageToLoad;
        BOOL forward;
        NSInteger leftPage = [leftLayer.name intValue];

        if (!singlepage) {
            // 見開き表示の場合
            rightLayer.hidden = NO;
            flipLayer.contents = rightLayer.contents;
            flipLayer.name = rightLayer.name;
            flipLayer.frame = rightLayer.frame;
            NSInteger rightPage = [rightLayer.name intValue];
            if (leftNext) {
                // 前へ
                pageToLoad = MIN(leftPage, rightPage) - 1;
                forward = NO;
            } else {
                // 次へ
                pageToLoad = MAX(leftPage, rightPage) + 1;
                forward = YES;
            }
            [self loadPage:pageToLoad left:flipBackLayer right:rightLayer forward:forward];
            PIVLog(@"toLeft not single");
        } else {
            // １ページ表示の場合
            rightLayer.hidden = YES;
            scrollView.contentOffset = CGPointMake(0, 0);
            
            flipLayer.frame = flipBackLayer.frame = leftLayer.frame;
            if (leftNext) {
                // 前へ
                [self loadPage:leftPage - 1 left:flipLayer right:flipBackLayer forward:NO];
                PIVLog(@"toLeft prev single");

            } else {
                // 次へ
                flipLayer.contents = leftLayer.contents;
                flipLayer.name = leftLayer.name;
                flipBackLayer.contents = flipLayer.contents;
                flipBackLayer.name = flipLayer.name;
                [self loadPage:leftPage + 1 left:leftLayer right:nil forward:YES];
                PIVLog(@"toLeft next single");
            }
        }
    }
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect r = flipLayer.frame;
    r.origin.x = r.origin.y = 0;
    CGPathAddRect(path, nil, r);
    flipMaskLayer.path = path;
    CGPathRelease(path);
    
    path = CGPathCreateMutable();
    flipBackMaskLayer.path = path;
    CGPathRelease(path);
    flipBackLayer.transform = CATransform3DIdentity;
    PIVLog(@"final");

    
    
    // 裏側の共通設定
    flipBackLayer.frame = flipLayer.frame;
    flipShadowLayer.frame = flipLayer.frame;
    if (singlepage) {
        ////NSLog(@"15");
        flipBackLayer.contents = flipLayer.contents;
        flipBackLayer.name = flipLayer.name;
        flipShadowLayer.opacity = 0.9;
        flipShadowLayer.backgroundColor = [UIColor whiteColor].CGColor;
    } else {
        ////NSLog(@"16");
        flipShadowLayer.opacity = 0.5;
        flipShadowLayer.backgroundColor = [UIColor grayColor].CGColor;
    }
    paging = YES;
    
}


// 右側のめくれた状態を作る
-(void)curlRightSide:(CGFloat)dist 
               angle:(CGFloat)t 
                   w:(CGFloat)w
                   h:(CGFloat)h
                  dw:(CGFloat)dw
                  dh:(CGFloat)dh
                  tz:(CGFloat)tz {
    if (w > h) {
        //w /= 2;
    }
    
    // めくるページのクリッピング
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 0, 0);
    if (t > 0) {
        CGPathAddLineToPoint(path, nil, w, 0);
        CGPathAddLineToPoint(path, nil, w, h - dh);
        CGPathAddLineToPoint(path, nil, w - dw, h);
    } else if (t < 0) {
        CGPathAddLineToPoint(path, nil, w - dw, 0);
        CGPathAddLineToPoint(path, nil, w, dh);
        CGPathAddLineToPoint(path, nil, w, h);
    } else { // t == 0
        CGPathAddLineToPoint(path, nil, w - dw, 0);
        CGPathAddLineToPoint(path, nil, w - dw, h);
    }
    CGPathAddLineToPoint(path, nil, 0, h);
    CGPathCloseSubpath (path);
    flipMaskLayer.path = path;
    CGPathRelease(path);

    
    // めくるページの裏側（クリッピング）
    path = CGPathCreateMutable();
    if (t > 0) {
        CGPathMoveToPoint(path, nil, 1, h - dh);
        CGPathAddLineToPoint(path, nil, 0, h);
        CGPathAddLineToPoint(path, nil, dw, h);
        CGPathCloseSubpath (path);
    } else if (t < 0) {
        CGPathMoveToPoint(path, nil, 0, dh);
        CGPathAddLineToPoint(path, nil, 0, 0);
        CGPathAddLineToPoint(path, nil, dw, 0);
        CGPathCloseSubpath (path);
    } else { // t == 0
        CGPathAddRect(path, nil, CGRectMake(0, 0, dw, h));
    }
    flipBackMaskLayer.path = path;
    CGPathRelease(path);

    
    // めくるページの裏側（回転変換）
    CATransform3D tr = CATransform3DIdentity;
    if (t > 0) {
        tr = CATransform3DTranslate(tr, w / 2 - dw, h / 2, 0);
        tr = CATransform3DRotate(tr, t, 0, 0, 1);
        tr = CATransform3DRotate(tr, tz, 0, 1, 0);
        tr = CATransform3DRotate(tr, t, 0, 0, 1);
        tr = CATransform3DTranslate(tr, w / 2 - dw, -h / 2, 1);
    } else if (t < 0) {
        tr = CATransform3DTranslate(tr, w / 2 - dw, -h / 2, 0);
        tr = CATransform3DRotate(tr, t, 0, 0, 1);
        tr = CATransform3DRotate(tr, tz, 0, 1, 0);
        tr = CATransform3DRotate(tr, t, 0, 0, 1);
        tr = CATransform3DTranslate(tr, w / 2 - dw, h / 2, 1);
    } else { // t == 0
        tr = CATransform3DTranslate(tr, w / 2 - dw, 0, 0);
        tr = CATransform3DRotate(tr, tz, 0, 1, 0);
        tr = CATransform3DTranslate(tr, w / 2 - dw, 0, 1);
    }
    flipBackLayer.transform = tr;
}


-(void)curlLeftSide:(CGFloat)dist 
               angle:(CGFloat)t 
                   w:(CGFloat)w
                   h:(CGFloat)h
                  dw:(CGFloat)dw
                  dh:(CGFloat)dh
                  tz:(CGFloat)tz {
    // めくるページのクリッピング
    if (w > h) {
        //w /= 2;
    }
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, w, 0);
    if (t > 0) {
        CGPathAddLineToPoint(path, nil, 0, 0);
        CGPathAddLineToPoint(path, nil, 0, h - dh);
        CGPathAddLineToPoint(path, nil, dw, h);
    } else if (t < 0) {
        CGPathAddLineToPoint(path, nil, dw, 0);
        CGPathAddLineToPoint(path, nil, 0, dh);
        CGPathAddLineToPoint(path, nil, 0, h);
    } else { // t == 0
        CGPathAddLineToPoint(path, nil, dw, 0);
        CGPathAddLineToPoint(path, nil, dw, h);
    }
    CGPathAddLineToPoint(path, nil, w, h);
    CGPathCloseSubpath (path);
    flipMaskLayer.path = path;
    CGPathRelease(path);
    
    // めくるページの裏側（クリッピング）
    path = CGPathCreateMutable();
    if (t > 0) {
        CGPathMoveToPoint(path, nil, w, h - dh);
        CGPathAddLineToPoint(path, nil, w, h);
        CGPathAddLineToPoint(path, nil, w - dw, h);
        CGPathCloseSubpath (path);
    } else if (t < 0) {
        CGPathMoveToPoint(path, nil, w, dh);
        CGPathAddLineToPoint(path, nil, w, 0);
        CGPathAddLineToPoint(path, nil, w - dw, 0);
        CGPathCloseSubpath (path);
    } else { // t == 0
        CGPathAddRect(path, nil, CGRectMake(w - dw, 0, dw, h));
    }
    flipBackMaskLayer.path = path;
    
    CGPathRelease(path);

    // めくるページの裏側（回転変換）
    CATransform3D tr = CATransform3DIdentity;
    if (t > 0) {
        tr = CATransform3DTranslate(tr, dw - w / 2, h / 2, 0);
        tr = CATransform3DRotate(tr, -t, 0, 0, 1);
        tr = CATransform3DRotate(tr, tz, 0, 1, 0);
        tr = CATransform3DRotate(tr, -t, 0, 0, 1);
        tr = CATransform3DTranslate(tr, dw - w / 2, -h / 2, 0);
    } else if (t < 0) {
        tr = CATransform3DTranslate(tr, dw - w / 2, -h / 2, 0);
        tr = CATransform3DRotate(tr, -t, 0, 0, 1);
        tr = CATransform3DRotate(tr, tz, 0, 1, 0);
        tr = CATransform3DRotate(tr, -t, 0, 0, 1);
        tr = CATransform3DTranslate(tr, dw - w / 2, h / 2, 0);
    } else { // t == 0
        tr = CATransform3DTranslate(tr, dw - w / 2, 0, 0);
        tr = CATransform3DRotate(tr, tz, 0, 1, 0);
        tr = CATransform3DTranslate(tr, dw - w / 2, 0, 0);
    }
    flipBackLayer.transform = tr;
}



// 左→右にページをめくる
-(void)curlToRight:(CGFloat)dist angle:(CGFloat)t {
//    DLog(@"curlToRight");

    CGFloat w = flipLayer.frame.size.width;
    CGFloat h = flipLayer.frame.size.height;
    if (w > h) {
        //w /= 2;
    }
    CGFloat dw = fminf(w, 1.5 * dist * w); // 三角形の底辺長さ
    if (dw == w) {
        t = t * (1 - dist);
    }
    CGFloat dh = t != 0 ? fabsf(dw / tanf(t)) : 0; // 三角形の高さ
    CGFloat tz = -M_PI / 2 * (1 - dist); // 傾き
    
    [self curlLeftSide:dist angle:t w:w h:h dw:dw dh:dh tz:tz];
  
}

// 右→左にページをめくる
-(void)curlToLeft:(CGFloat)dist angle:(CGFloat)t {
    //DLog(@"curlToLieft :%.1f", dist);

    CGFloat w = flipLayer.frame.size.width;
    CGFloat h = flipLayer.frame.size.height;
    if (w > h) {
       // w /= 2;
    }
    CGFloat dw = fminf(w, 1.5 * dist * w); // 三角形の底辺長さ
    if (dw == w) {
        t = t * (1 - dist);
    }
    CGFloat dh = t != 0 ? fabsf(dw / tanf(t)) : 0; // 三角形の高さ
    CGFloat tz = M_PI / 2 * (1 - dist); // 傾き
    
    [self curlRightSide:dist angle:t w:w h:h dw:dw dh:dh tz:tz];
}



// 左→右にページをかぶせる（Portraitの場合のみ）
-(void)curlCoverToRight:(CGFloat)dist angle:(CGFloat)t {
    //    DLog(@"curlToRight");
    
    CGFloat w = flipLayer.frame.size.width;
    CGFloat h = flipLayer.frame.size.height;
    if (w > h) {
//        w /= 2;
    }
    CGFloat dw = fminf(w, 1.5 * (1 - dist) * w); // 三角形の底辺長さ
    CGFloat dh = t != 0 ? fabsf(dw / tanf(t)) : 0; // 三角形の高さ
    CGFloat tz = -M_PI / 3 * dist; // 傾き
    [self curlRightSide:dist angle:t w:w h:h dw:dw dh:dh tz:tz];
}



// 右→左にページをかぶせる（Portraitの場合のみ）
-(void)curlCoverToLeft:(CGFloat)dist angle:(CGFloat)t {
    //DLog(@"curlCoverToLieft :%.1f", dist);
    
    CGFloat w = flipLayer.frame.size.width;
    CGFloat h = flipLayer.frame.size.height;
    if (w > h) {
//        w /= 2;
    }
    CGFloat dw = fminf(w, 1.5 * (1 - dist) * w); // 三角形の底辺長さ
    
    CGFloat dh = t != 0 ? fabsf(dw / tanf(t)) : 0; // 三角形の高さ
    CGFloat tz = M_PI / 3 * dist; // 傾き
        
    [self curlLeftSide:dist angle:t w:w h:h dw:dw dh:dh tz:tz];
    
}



- (void) curl:(CGFloat)dist angle:(CGFloat)t {
    //DLog(@"curl : %.1f", dist);

    t = fmaxf(-M_PI / 6, fminf(M_PI / 6, t));
    dist = fmaxf(0, fminf(1, dist));

    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    BOOL doublepage = (!isPortrait && spread);
    if (!paging) {
        [self startCurl];
    }
    if (pagingToRight) {
        if (!doublepage && !leftNext) {
            [self curlCoverToRight:dist angle:-t];
        } else {
            [self curlToRight:dist angle:t];
        }
    } else {
        if (!doublepage && leftNext) {
            [self curlCoverToLeft:dist angle:-t];
        } else {
            [self curlToLeft:dist angle:t];
        }
    }
    if (doublepage) {
        flipShadowLayer.opacity = 0.5 * (1 - dist);
    }
    
    
    [CATransaction commit];
    pagingDistance = dist;
    curlAngle = t;
}

- (void)performPageOpned {
    [delegate pageOpened];
}


// めくり完了のアニメーション
- (void) curlFinishAnimator {

    BOOL singlepage = (isPortrait || !spread);
    NSAutoreleasePool* pool;
    pool = [[NSAutoreleasePool alloc]init];
    
    for (CGFloat d = pagingDistance; d < 1.1; d += 0.1) {
        [self curl: d angle:curlAngle];
        [NSThread sleepForTimeInterval:0.05];
    }
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    
    if (!singlepage) {
        if (pagingToRight) {
            rightLayer.contents = flipBackLayer.contents;
            rightLayer.name = flipBackLayer.name;
        } else {
            leftLayer.contents = flipBackLayer.contents;
            leftLayer.name = flipBackLayer.name;
        }
    } else {
        if (pagingToRight != leftNext) {
            leftLayer.contents = flipLayer.contents;
            leftLayer.frame = flipLayer.frame;
            leftLayer.name = flipLayer.name;
        }
        rightLayer.name = leftLayer.name;
    }
//    LayerLog(__func__, @"2 leftLayer", leftLayer);
//    LayerLog(__func__, @"2 rightLayer", rightLayer);
//    ViewLog(__func__, @"2 contentView", contentView);
//    LayerLog(__func__, @"2 flipLayer", flipLayer);
//    LayerLog(__func__, @"2 flipBackLayer", flipBackLayer);
    
    flipView.hidden = YES;
    
    
    
    if (singlepage) {
        CGRect rc = leftLayer.frame;
        if (rc.origin.x < 0 && rc.size.width > rc.size.height) {
            // 横長画像が左側にはみ出している場合
            rc.origin.x = 0;
            leftLayer.frame = rc;
            contentView.frame = rc;
            if (pagingToRight) {
                
                scrollView.contentOffset = CGPointMake(rc.size.width / 2, 0);
            }
        } else {
            contentView.frame = rc;
        }
    }
    scrollView.contentSize = contentView.frame.size;
    [self showPageMemo];
    
    [CATransaction commit];
    

//    LayerLog(__func__, @"3 leftLayer", leftLayer);
//    LayerLog(__func__, @"3 rightLayer", rightLayer);
//    ViewLog(__func__, @"3 contentView", contentView);
//    LayerLog(__func__, @"3 flipLayer", flipLayer);
//    LayerLog(__func__, @"3 flipBackLayer", flipBackLayer);
    
    
    // ページ遷移
//    NSInteger leftPage = [leftLayer.name intValue];
//    currentPage = leftPage;
    currentPage = MIN([leftLayer.name intValue], [rightLayer.name intValue]);
    // 順送りの場合キャッシュする
    if (pagingToRight == leftNext) {
        [dataSource fetchCache:(currentPage + 1) size:CGSizeMake(768, 1024)];
    }
    
    
    paging = NO;
    pagingDistance = 0;
    pagingPrepared = YES;
    
    
    [self performSelector:@selector(performPageOpned) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
    [self layoutButtons];
    
    [pool drain];
    [NSThread exit];
    
}

// めくりをキャンセルする
- (void) cancelCurl {
    [self curl:0 angle:0];
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    BOOL doublepage = (!isPortrait && spread);
    if (!doublepage) {
        if (pagingToRight == leftNext) {
            leftLayer.contents = flipLayer.contents;
            leftLayer.frame = flipLayer.frame;
            leftLayer.name = flipLayer.name;
        }
    } else {
        if (pagingToRight) {
            leftLayer.contents = flipLayer.contents;
            leftLayer.name = flipLayer.name;
        } else {
            rightLayer.contents = flipLayer.contents;
            rightLayer.name = flipLayer.name;
        }
    }
    flipView.hidden = YES;
    [self showPageMemo];
    
    [CATransaction commit];
    pagingDistance = 0;
    pagingPrepared = YES;
    paging = NO;
    dragPaging = NO;
}


// めくりキャンセルのアニメーション
- (void) curlCancelAnimator {
    //DLog(@"cancelAnimator");

    NSAutoreleasePool* pool;
    pool = [[NSAutoreleasePool alloc]init];
    
    for (CGFloat d = pagingDistance; d > -0.1; d -= 0.1) {
        [self curl: d angle:curlAngle];
        [NSThread sleepForTimeInterval:0.05];
    }
    [self cancelCurl];
    
    [pool drain];
    [NSThread exit];
}

- (void) endCurl {
    SEL callback;
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    if (pagingDistance > 0.4 || now - beginTime < PRESS_DURATION) {
        callback = @selector(curlFinishAnimator);
    } else {
        callback = @selector(curlCancelAnimator);
    }
    
    NSThread* anim = [[NSThread alloc]initWithTarget:self 
                                      selector:callback
                                        object:nil];
    [anim start];
    [anim release];
}


#pragma mark - スクロールエフェクト


- (void)startPageScroll {
    NSLog(@"startPageScroll");
    pdfSharpenPage = -1;
    pagingPrepared = NO;
    pagingDistance = 0;
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    [self hidePageMemo];
    NSInteger leftPage = [leftLayer.name intValue];
    NSInteger rightPage = [rightLayer.name intValue];
    NSInteger pageToLoad;
    BOOL forward;
    if (leftNext == pagingToRight) {
        // 次へ
        pageToLoad = MAX(leftPage, rightPage) + 1;
        forward = YES;
    } else {
        // 前へ
        pageToLoad = MIN(leftPage, rightPage) - 1;
        forward = NO;
    }
    [self loadPage:pageToLoad left:scLeftLayer right:scRightLayer forward:forward];
    
    if (pagingToRight) {
        // 左側にレイヤーを挿入
        CGRect scr;
        scr.size.width = scRightLayer.frame.origin.x + scRightLayer.frame.size.width;
        scr.size.height = MAX(scRightLayer.frame.size.height, scLeftLayer.frame.size.height);
        scr.origin.x = scr.origin.y = 0;
        scLayer.frame = scr;
        PIVLog(@"左側にレイヤーを挿入");
        // 右にずらす
        CGRect lr = leftLayer.frame;
        lr.origin.x += scr.size.width;
        leftLayer.frame = lr;
        // 右にずらす
        CGRect rr = rightLayer.frame;
        rr.origin.x += scr.size.width;
        rightLayer.frame = rr;
        PIVLog(@"leftLayer,rightLayerを右にずらす");
        
        if (marginShadow && !isPortrait && spread) {
            shadowView.frame = CGRectMake(lr.origin.x + lr.size.width - SHADOW_WIDTH / 2, 0, SHADOW_WIDTH, lr.size.height);
        }
        
        CGRect cr = contentView.frame;
        cr.origin.x = - scr.size.width + (scr.size.width - scrollView.frame.size.width);
        cr.size.width += scr.size.width;
        cr.size.height = MAX(cr.size.height, scr.size.height);
        contentView.frame = cr;
        PIVLog(@"contentView.frameセット");

        scrollView.contentSize = scr.size;
        [scrollView setContentOffset:CGPointMake(scr.size.width - scrollView.frame.size.width, 0) animated:NO];

    } else {
        // 右側にレイヤーを挿入
        CGRect scr;
        scr.size.width = scRightLayer.frame.origin.x + scRightLayer.frame.size.width;
        scr.size.height = MAX(scRightLayer.frame.size.height, scLeftLayer.frame.size.height);
        scr.origin.x = rightLayer.frame.origin.x + rightLayer.frame.size.width;
        scr.origin.y = 0;
        scLayer.frame = scr;
        
        CGRect lr = leftLayer.frame;
        CGRect rr = rightLayer.frame;
        contentView.frame = CGRectMake(-scrollView.contentOffset.x, 0, 
                                       rr.origin.x + rr.size.width + scr.size.width,
                                       MAX(scr.size.height, MAX(lr.size.height, rr.size.height)));
        [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
    
    if (marginShadow && !isPortrait && spread) {
        CGRect scr = scLayer.frame;
        scShadowView.frame = CGRectMake(scr.origin.x + (scr.size.width - SHADOW_WIDTH) / 2, 0, SHADOW_WIDTH, scr.size.height);
        scShadowView.hidden = NO;
        scShadowView.layer.zPosition = 99;
    }
    
    // 一応はみ出さないように処理
    [CATransaction commit];
    paging = YES;

}

// 
- (void)pageScroll:(CGFloat)dist {
    // 各レイヤーの幅
    CGFloat rw = contentView.frame.size.width;
    CGFloat lw;
    if (rightLayer.frame.origin.x == leftLayer.frame.origin.x) {
        // 重なってたら一致
        lw = leftLayer.frame.size.width;
    } else {
        // 重なってなければ足す
        lw = leftLayer.frame.size.width + rightLayer.frame.size.width;
    }
    CGFloat px;
    if (!paging) {
        [self startPageScroll];
    }
    if (pagingToRight) {
        px = (lw - rw) + (lw * dist);
    } else {
        px = -lw * dist;
    }
//    ////NSLog(@"rw:%0.0f dist:%0.2f, px:%0.2f", rw, dist, px);
    [self setContentViewOrigin:CGPointMake(px, 0)];
    
    pagingDistance = dist;
}

// スクロール完了処理
- (void)finishPageScroll {
    if (!paging) {
        [self startPageScroll];
    }
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self pageScroll:1];
                     }
                     completion:^(BOOL finished) {
                         [CATransaction begin];
                         [CATransaction setValue:(id)kCFBooleanTrue
                                          forKey:kCATransactionDisableActions];
                         
                         CGRect lr = scLeftLayer.frame;
                         CGRect rr = scRightLayer.frame;
//                         LayerLog(__func__, @"1 scLeftLayer", scLeftLayer);
//                         LayerLog(__func__, @"1 scRightLayer", scRightLayer);
//                         LayerLog(__func__, @"1 leftLayer", leftLayer);
//                         LayerLog(__func__, @"1 rightLaer", rightLayer);
//                         ViewLog(__func__, @"1 contentView", contentView);
                         if (lr.origin.x < 0) {
                             rr.origin.x -= lr.origin.x;
                             lr.origin.x = 0;
                         }
                         
                         // scLeftLayer->leftLayer
                         leftLayer.frame = lr;
                         leftLayer.contents = scLeftLayer.contents;
                         leftLayer.name = scLeftLayer.name;
                         leftLayer.hidden = scLeftLayer.hidden;
                         
                         // scRightLayer->rightLayer
                         rightLayer.frame = rr;
                         rightLayer.contents = scRightLayer.contents;
                         rightLayer.name = scRightLayer.name;
                         rightLayer.hidden = scRightLayer.hidden;
                         
                         scLeftLayer.hidden = scRightLayer.hidden = YES;
                         // contentView
                         contentView.frame = CGRectMake(0, 0, rr.origin.x + rr.size.width, lr.size.height);
//                         LayerLog(__func__, @"2 scLeftLayer", scLeftLayer);
//                         LayerLog(__func__, @"2 scRightLayer", scRightLayer);
//                         LayerLog(__func__, @"2 leftLayer", leftLayer);
//                         LayerLog(__func__, @"2 rightLaer", rightLayer);
//                         ViewLog(__func__, @"2 contentView", contentView);

                         if (pagingToRight) {
                             scrollView.contentOffset = CGPointMake(contentView.frame.size.width - scrollView.frame.size.width, 0);
                         } else {
                             scrollView.contentOffset = CGPointMake(0, 0);
                         }
                         scrollView.contentSize = contentView.frame.size;
                         if (!isPortrait && spread) {
                             shadowView.frame = CGRectMake(rightLayer.frame.origin.x - SHADOW_WIDTH / 2,
                                                           0, 
                                                           SHADOW_WIDTH, contentView.frame.size.height);
                             scShadowView.hidden = YES;
                         }
                         [CATransaction commit];
                         
                         // ページ遷移
                         currentPage = MIN([leftLayer.name intValue], [rightLayer.name intValue]);
                         pagingDistance = 0;
                         pagingPrepared = YES;
                         paging = NO;
                         dragPaging = NO;

                         // 順送りの場合キャッシュする
                         if (pagingToRight == leftNext) {
                             [dataSource fetchCache:(currentPage + 1) size:CGSizeMake(768, 1024)];
                         }
                         
                         [self performSelector:@selector(performPageOpned) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
                         [self layoutButtons];
                         [self showPageMemo];


                     }];
    
}

- (void)completeCancelPageScroll {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    
    CGRect lr = leftLayer.frame;
    lr.origin.x = 0;
    leftLayer.frame = lr;
    
    CGRect rr = rightLayer.frame;
    rr.origin.x = lr.size.width;
    rightLayer.frame = rr;
    
    if (!isPortrait && spread && marginShadow) {
        scShadowView.hidden = YES;
        shadowView.frame = CGRectMake(rightLayer.frame.origin.x - SHADOW_WIDTH / 2,
                                      0, 
                                      SHADOW_WIDTH, contentView.frame.size.height);
    }
    
    contentView.frame = CGRectMake(0, 0, rr.origin.x + rr.size.width, lr.size.height);
    scLeftLayer.hidden = scRightLayer.hidden = YES;
    pagingDistance = 0;
    pagingPrepared = YES;
    paging = NO;
    dragPaging = NO;
    
    scrollView.contentOffset = CGPointMake(0, 0);
    scrollView.contentSize = contentView.frame.size;
    [self showPageMemo];
    [CATransaction commit];
    
}

- (void)cancelPageScroll {
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self pageScroll:0];
                     }
                     completion:^(BOOL finished) {
                         [self completeCancelPageScroll];
                     }];
    
}

- (void)endPageScroll {
    pdfSharpenPage = -1;
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];

    if (pagingDistance > 0.4 || now - beginTime < PRESS_DURATION) {
        [self finishPageScroll];
    } else {
        [self cancelPageScroll];
    }

}


#pragma mark - ページ送り

// 次のページがあるかどうかを返す
- (BOOL) hasNext {
    NSInteger leftPage = [leftLayer.name intValue];
    if (isPortrait || !spread) {
        return leftPage + 1 < [dataSource pageCount];
    } else {
        NSInteger rightPage = [rightLayer.name intValue];
        return MAX(leftPage, rightPage) + 1 < [dataSource pageCount];
    }
}

// 前のページがあるかどうかを返す
- (BOOL) hasPrev {
    NSInteger leftPage = [leftLayer.name intValue];
    if (isPortrait || !spread) {
        return leftPage - 1 >= 0;
    } else {
        NSInteger rightPage = [rightLayer.name intValue];
        return MIN(leftPage, rightPage) - 1 >= 0;
    }
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
    __block NSInteger page = pagingToRight ? [rightLayer.name intValue] : [leftLayer.name intValue];
    
    NSLog(@"paging to right: %@, page #: %i", (pagingToRight ? @"YES" : @"NO"), page);
    
    if (pdfSharpenPage != page) {
        pdfSharpenPage = page;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            // the priority for image loading is low to keep scrolling smooth
            UIImage * img = [dataSource highResImageAt:page];
            if (img) {
                [leftLayer performSelectorOnMainThread:@selector(setContents:) withObject:(id)img.CGImage waitUntilDone:YES];
            }
        });
    }
}

// 次のページへ
- (void) animateNext {
//    NSLog(@"%s", __func__);
    if ([self hasNext]) {
        if (scrollView.zoomScale > 1 || scrollView.frame.size.width < scrollView.contentSize.width) {
            // 拡大中、スクロール中
            [scrollView setZoomScale:1 animated:NO];
            [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
            NSInteger pageToOpen = MAX([rightLayer.name intValue], [leftLayer.name intValue]) + 1;
            [self openAt: pageToOpen forward:YES];
        } else {
            if (pagingPrepared) {
                pagingPrepared = NO;
                pagingToRight = leftNext;
                if (animeType == PageImageViewAnimationCurl) {
                    NSThread* anim = [[NSThread alloc]initWithTarget:self 
                                                            selector:@selector(curlFinishAnimator)
                                                              object:nil];
                    [anim start];
                    [anim release];
                } else {
                    [self finishPageScroll];
                }
            }
        }
    }
}


// 前のページへ
- (void) animatePrev {
//    NSLog(@"%s", __func__);
    if ([self hasPrev]) {
        if (scrollView.zoomScale > 1 || scrollView.frame.size.width < scrollView.contentSize.width) {
            scrollView.zoomScale = 1;
            [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
            NSInteger pageToOpen = MIN([rightLayer.name intValue], [leftLayer.name intValue]) - 1;
            [self openAt:pageToOpen forward:NO];
            
        } else {
            if (pagingPrepared) {
                // 自動めくり
                pagingPrepared = NO;
                pagingToRight = !leftNext;
                if (animeType == PageImageViewAnimationCurl) {
                    NSThread* anim = [[NSThread alloc]initWithTarget:self 
                                                            selector:@selector(curlFinishAnimator)
                                                              object:nil];
                    [anim start];
                    [anim release];
                } else {
                    [self finishPageScroll];
                }
            }
        }
    }
}


- (void)showRightScroll {
    [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width, 0) animated:NO];
}

- (void)showLeftScroll {
    [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
}

// 指定したページへ
- (void) openAt: (NSInteger)page forward:(BOOL)forward {
    BOOL changed = currentPage != page;
    currentPage = [self loadPage:page left:leftLayer right:rightLayer forward:forward];
    if (animeType == PageImageViewAnimationCurl) {
        flipView.hidden = YES;
    }
    CGSize csz = leftLayer.frame.size;
    if (!rightLayer.hidden && rightLayer.left != leftLayer.left) {
        csz.width += rightLayer.width;
    }
    scrollView.contentSize = csz;
    [contentView eMove:0 :0];
    [contentView eSize:csz];
    [leftLayer eMove:0 :0];
    
    if (!rightLayer.hidden) {
        [rightLayer eMove:leftLayer.right :0];
    }
    if (forward == leftNext && scrollView.contentSize.width > scrollView.width) {
        // 戻るとき:右側を表示する
        [self showRightScroll];
        [self performSelector:@selector(showRightScroll) withObject:nil afterDelay:0.1];
    } else {
        // 通常
        [self showLeftScroll];
        [self performSelector:@selector(showLeftScroll) withObject:nil afterDelay:0.1];
    }
    if (!isPortrait && spread) {
        shadowView.hidden = NO;
        shadowView.frame = CGRectMake(leftLayer.width - SHADOW_WIDTH / 2, 0, SHADOW_WIDTH, leftLayer.height);
        
    } else {
        shadowView.hidden = YES;
    }
    
    // 順送りの場合キャッシュする
    [dataSource fetchCache:(currentPage + 1) size:CGSizeMake(768, 1024)];
    if (changed) {
        [delegate pageOpened];
    }
    PIVLog(@"openPage完了");
    [self layoutButtons];
    [self showPageMemo];

}

#pragma mark - 高速アニメーション
- (UIView*)createFlip {
    UIView* flip = [[[UIView alloc]init]autorelease];
    flip.backgroundColor = [UIColor whiteColor];
    flip.layer.borderColor = [UIColor blackColor].CGColor;
    flip.layer.borderWidth = 2;
    flip.layer.shadowColor = [UIColor blackColor].CGColor;
    flip.layer.shadowOffset = CGSizeMake(-10, 20);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, flip.layer.frame);
    flip.layer.shadowPath = path;
    CGPathRelease(path);
    flip.layer.shadowOpacity = 0.4;
    flip.layer.masksToBounds = NO;
    flip.layer.anchorPoint = CGPointMake(0.5, 0.5);
    return flip;
}

// 左からめくり上げる
- (void)curlUpRight {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
    UIView* flip = [self createFlip];
    flip.frame = contentView.frame;
    flip.layer.contents = leftLayer.contents;
    leftLayer.contents = nil;
    [contentView addSubview:flip];
    [UIView animateWithDuration:0.3
                     animations:^{
                         CATransform3D tr = CATransform3DIdentity;
                         tr = CATransform3DTranslate(tr, flip.frame.size.width, 0, flip.frame.size.width / 2);
                         tr = CATransform3DRotate(tr, M_PI_2, 0.1, 1, 0);
                         flip.layer.transform = tr;
                     }
                     completion:^(BOOL finished) {
                         [flip removeFromSuperview];
                     }];
    [pool release];
    [NSThread exit];
}

// 左からかぶせる
- (void)curlDownRight {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
    UIView* flip = [self createFlip];
    flip.frame = contentView.frame;
    CATransform3D tr = CATransform3DIdentity;
    tr = CATransform3DTranslate(tr, -flip.frame.size.width, 0, flip.frame.size.width / 2);
    tr = CATransform3DRotate(tr, -M_PI_2, -0.1, 1, 0);
    flip.layer.transform = tr;
    BOOL erase = (leftLayer.contents != nil);
    
    [contentView addSubview:flip];
    [UIView animateWithDuration:0.3
                     animations:^{
                         flip.layer.transform = CATransform3DIdentity;
                     }
                     completion:^(BOOL finished) {
                         if (erase) {
                             leftLayer.contents = nil;
                         }
                         [flip removeFromSuperview];
                     }];
    
    [pool release];
    [NSThread exit];
}

- (void)curlLeftToRight {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
    UIView* flip = [self createFlip];
    flip.frame = leftLayer.frame;
    flip.layer.contents = leftLayer.contents;
    BOOL erase = (rightLayer.contents != nil);
    [contentView addSubview:flip];
    leftLayer.contents = nil;
    [UIView animateWithDuration:0.3
                     animations:^{
                         CATransform3D tr = CATransform3DIdentity;
                         tr = CATransform3DTranslate(tr, flip.frame.size.width, 0, flip.frame.size.width / 2);
                         tr = CATransform3DRotate(tr, M_PI, 0, 1, 0);
                         flip.layer.transform = tr;
                     }
                     completion:^(BOOL finished) {
                         [flip removeFromSuperview];
                         if (erase) {
                             rightLayer.contents = nil;
                         }
                     }];
    
    [pool release];
    [NSThread exit];
}


// 右からめくり上げる
- (void)curlUpLeft {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
    UIView* flip = [self createFlip];
    flip.frame = contentView.frame;
    flip.layer.contents = leftLayer.contents;
    leftLayer.contents = nil;
    [contentView addSubview:flip];
    [UIView animateWithDuration:0.3
                     animations:^{
                         CATransform3D tr = CATransform3DIdentity;
                         tr = CATransform3DTranslate(tr, -flip.frame.size.width, 0, flip.frame.size.width / 2);
                         tr = CATransform3DRotate(tr, -M_PI_2, -0.1, 1, 0);
                         flip.layer.transform = tr;
                     }
                     completion:^(BOOL finished) {
                         [flip removeFromSuperview];
                     }];
    [pool release];
    [NSThread exit];
}

// 左からかぶせる
- (void)curlDownLeft {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
    UIView* flip = [self createFlip];
    flip.frame = contentView.frame;
    CATransform3D tr = CATransform3DIdentity;
    tr = CATransform3DTranslate(tr, flip.frame.size.width, 0, flip.frame.size.width / 2);
    tr = CATransform3DRotate(tr, M_PI_2, 0.1, 1, 0);
    flip.layer.transform = tr;
    BOOL erase = (leftLayer.contents != nil);
    
    [contentView addSubview:flip];
    [UIView animateWithDuration:0.3
                     animations:^{
                         flip.layer.transform = CATransform3DIdentity;
                     }
                     completion:^(BOOL finished) {
                         [flip removeFromSuperview];
                         if (erase) {
                             leftLayer.contents = nil;
                         }
                     }];
    
    [pool release];
    [NSThread exit];
}

- (void)curlRightToLeft {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
    UIView* flip = [self createFlip];
    flip.frame = rightLayer.frame;
    flip.layer.contents = rightLayer.contents;
    BOOL erase = (leftLayer.contents != nil);
    
    [contentView addSubview:flip];
    rightLayer.contents = nil;
    [UIView animateWithDuration:0.3
                     animations:^{
                         CATransform3D tr = CATransform3DIdentity;
                         tr = CATransform3DTranslate(tr, -flip.frame.size.width, 0, flip.frame.size.width / 2);
                         tr = CATransform3DRotate(tr, -M_PI, 0, 1, 0);
                         flip.layer.transform = tr;
                     }
                     completion:^(BOOL finished) {
                         if (erase) {
                             leftLayer.contents = nil;
                         }
                         [flip removeFromSuperview];
                     }];
    
    [pool release];
    [NSThread exit];
}

- (void)highScrollToLeft {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
    UIView* lflip = [self createFlip];
    UIView* rflip = (!isPortrait && spread) ? [self createFlip] : nil;
    lflip.frame = leftLayer.frame;
    rflip.frame = rightLayer.frame;
    lflip.layer.contents = leftLayer.contents;
    rflip.layer.contents = rightLayer.contents;
    
    [contentView addSubview:lflip];
    if (rflip) {
        [contentView addSubview:rflip];
    }
    leftLayer.contents = nil;
    rightLayer.contents = nil;
    [UIView animateWithDuration:0.1
                     animations:^{
                         [self hidePageMemo];
                         CGRect lr = lflip.frame;
                         lr.origin.x -= contentView.frame.size.width;
                         lflip.frame = lr;
                         if (rflip) {
                             CGRect rr = rflip.frame;
                             rr.origin.x -= contentView.frame.size.width;
                             rflip.frame = rr;
                         }
                     }
                     completion:^(BOOL finished) {
                         [lflip removeFromSuperview];
                         [rflip removeFromSuperview];
                     }];
    
    [pool release];
    [NSThread exit];
}

- (void)highScrollToRight {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
    UIView* lflip = [self createFlip];
    UIView* rflip = (!isPortrait && spread) ? [self createFlip] : nil;
    lflip.frame = leftLayer.frame;
    rflip.frame = rightLayer.frame;
    lflip.layer.contents = leftLayer.contents;
    rflip.layer.contents = rightLayer.contents;
    
    [contentView addSubview:lflip];
    if (rflip) {
        [contentView addSubview:rflip];
    }
    leftLayer.contents = nil;
    rightLayer.contents = nil;
    [UIView animateWithDuration:0.1
                     animations:^{
                         [self hidePageMemo];
                         CGRect lr = lflip.frame;
                         lr.origin.x += contentView.frame.size.width;
                         lflip.frame = lr;
                         if (rflip) {
                             CGRect rr = rflip.frame;
                             rr.origin.x += contentView.frame.size.width;
                             rflip.frame = rr;
                         }
                     }
                     completion:^(BOOL finished) {
                         [lflip removeFromSuperview];
                         [rflip removeFromSuperview];
                     }];
    
    [pool release];
    [NSThread exit];
    
}


// 高速アニメーション
- (void)highSpeedAnimateLeft {
    BOOL singlePage = (isPortrait || !spread);
    
    if (animeType == PageImageViewAnimationCurl) {
        //NSLog(@"高速curl");
        if (singlePage) {
            if (leftNext) {
                // 単独表示　左からめくりあげる
                [NSThread detachNewThreadSelector:@selector(curlUpRight) toTarget:self withObject:nil];
            } else {
                // 単独表示　左からかぶせる
                [NSThread detachNewThreadSelector:@selector(curlDownRight) toTarget:self withObject:nil];
                
            }
        } else {
            // 左から右へ
            [NSThread detachNewThreadSelector:@selector(curlLeftToRight) toTarget:self withObject:nil];
            
            
        }
    } else {
        // 右に飛ばす
        [NSThread detachNewThreadSelector:@selector(highScrollToRight) toTarget:self withObject:nil];
    }
}
// 高速アニメーション
- (void)highSpeedAnimateRight {
    BOOL singlePage = (isPortrait || !spread);
    
    if (animeType == PageImageViewAnimationCurl) {
        //NSLog(@"高速curl");
        if (singlePage) {
            if (leftNext) {
                // 単独表示　右からめくりあげる
                [NSThread detachNewThreadSelector:@selector(curlDownLeft) toTarget:self withObject:nil];
            } else {
                // 単独表示　右からかぶせる
                [NSThread detachNewThreadSelector:@selector(curlUpLeft) toTarget:self withObject:nil];
            }
        } else {
            // 右から左へ
            [NSThread detachNewThreadSelector:@selector(curlRightToLeft) toTarget:self withObject:nil];
        }
    } else {
        // 左に飛ばす
        [NSThread detachNewThreadSelector:@selector(highScrollToLeft) toTarget:self withObject:nil];
            
    }
}




#pragma mark - 回転関係

// デバイスの向きを頻繁にアクセスするためにメンバ変数に覚えておく
- (void)updateRotation {
    @synchronized(orientationLock) {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
        BOOL nowPortrait = [AppUtil isPortrait];
        if (isPortrait != nowPortrait) {
            isPortrait = nowPortrait;
            flipView.hidden = YES;
            paging = NO;
            pagingPrepared = YES;
            [self eFittoSuperview];
            contentView.frame = self.frame;
            if ([self superview]) { 
                [self openAt:currentPage forward:YES];   
                id lc = leftLayer.contents;
                leftLayer.contents = nil;
                leftLayer.contents = lc;
//                id rc = rightLayer.contents;
//                rightLayer.contents = nil;
//                rightLayer.contents = rc;
            }
        }
        [pool release];
    }
}

// 回転を検知
- (void)didRotate:(NSNotification *)notification {
    [PageImageView cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateRotation) object:nil];
    //DLog(@"didRotate");
    [self performSelector:@selector(updateRotation) withObject:nil afterDelay:0.2];
}



#pragma mark - イベント

- (void)linkTapped:(UIButton*) link {
    NSString* url = link.titleLabel.text;
    [AlertDialog confirm:NSLocalizedString(@"confirm", nil)
                 message:NSLocalizedString(@"openSafari", nil)
                    onOK:^() {
                        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url]];
                    }];
}

// タップのイベント
- (void)tapping:(UITapGestureRecognizer*) tapr {
    CGPoint bp = [tapr locationInView:contentView];
    
    for (UIView* v in [contentView subviews]) {
        if ([v class] == [UIButton class]) {
            if (CGRectContainsPoint(v.frame, bp)) {
                [self linkTapped:(UIButton*)v];
                return;
            }
        }
    }
    if (!memoLeftView.hidden) {
        CGPoint lp = [tapr locationInView:memoLeftView];
        if ([memoLeftView tapped:lp]) {
            return;
        }
    }
    if (!memoRightView.hidden) {
        CGPoint rp = [tapr locationInView:memoRightView];
        if ([memoRightView tapped:rp]) {
            return;
        }
    }
    
    ////NSLog(@"%s", __func__);
    CGFloat px = [tapr locationInView:self].x;
    CGFloat w = self.frame.size.width;
    if (px < w / 3) {
        if (scrollView.contentOffset.x > 0) {
            [UIView animateWithDuration:0.5 animations:^{
                scrollView.contentOffset = CGPointMake(0, 0);
            }];
        } else {
            [delegate tapLeft];
        }
    } else if (px < w * 2 / 3) {
        [delegate tapCenter];
    } else {
        if (scrollView.contentSize.width > scrollView.frame.size.width
            && scrollView.contentOffset.x < scrollView.contentSize.width / 2) {
            [UIView animateWithDuration:0.5 animations:^{
                scrollView.contentOffset = CGPointMake(scrollView.contentSize.width / 2, 0);
            }];
        } else {
            [delegate tapRight];
        }
    }
}

// スワイプのイベント
- (void)swiping:(UISwipeGestureRecognizer*) sr 
{
    //NSLog(@"%s", __func__);
    if (sr.direction == UISwipeGestureRecognizerDirectionRight) {
        [delegate swipeLeft];
    } else if (sr.direction == UISwipeGestureRecognizerDirectionRight) {
        [delegate swipeRight];
    }
    
}


- (void)endPressing {
    BOOL left = beginPoint.x < self.frame.size.width / 3;
    BOOL right = beginPoint.x > self.frame.size.width / 3 * 2;
    if (left) {
        [delegate pressLeft:YES];
    } else if (right) {
        [delegate pressRight:YES];
    }
    
}


// 長押しイベントを繰り返し発行するためのメソッド
- (void)repeatPressing:(UILongPressGestureRecognizer*)lr {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
    BOOL left = beginPoint.x < self.frame.size.width / 3;
    BOOL right = beginPoint.x > self.frame.size.width / 3 * 2;
    
    while (lr.state != 0) {
        if (left) {
            [delegate pressLeft:NO];
        } else if (right) {
            [delegate pressRight:NO];
        }
        [NSThread sleepForTimeInterval:0.1];
    }
    [self performSelector:@selector(endPressing) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
    longPressing = NO;
    [pool release];
    [NSThread exit];
}

- (void)pressing:(UILongPressGestureRecognizer*)lr {
    if (lr.state == UIGestureRecognizerStateBegan) {
        [self hidePageMemo];
        longPressing = YES;
        beginPoint = [lr locationInView:self];
        //NSLog(@"began");
        [NSThread detachNewThreadSelector:@selector(repeatPressing:) toTarget:self withObject:lr];
        
    } else if (lr.state == UIGestureRecognizerStateChanged) {
        //NSLog(@"change");
    } else if (lr.state == UIGestureRecognizerStateEnded) {
        longPressing = NO;
        [self showPageMemo];
    } else {
        //NSLog(@"else:%d", lr.state);
    }
}


// ドラッグのイベント
- (void)dragging:(UIPanGestureRecognizer*) pr {
    if (!longPressing && scrollView.frame.size.width == scrollView.contentSize.width) {
        if (pr.state == UIGestureRecognizerStateBegan) {
            beginTime = [NSDate timeIntervalSinceReferenceDate];
            beginPoint = [pr locationInView:self];
            
        } else if (pr.state == UIGestureRecognizerStateChanged) {
            CGPoint curr = [pr locationInView:self];
            CGPoint v = [VectorUtil vector:beginPoint :curr];
            
            if (pagingPrepared && !paging) {
                // ドラッグ始め
                if (v.x >= 0) {
                    pagingToRight = YES;
                } else {
                    pagingToRight = NO;
                }
            }
            if (pagingPrepared || dragPaging) {
                if ((pagingToRight == leftNext && [self hasNext])
                    || (pagingToRight != leftNext && [self hasPrev])) {
                    dragPaging = YES;
                    CGFloat w = self.frame.size.width;
                    CGFloat dist;
                    CGFloat angle;
                    if (pagingToRight) {
                        dist = MAX(0, v.x / (w - beginPoint.x));
                        angle = (curr.x != 0) ? -tanf(v.y / curr.x) : 0;
                    } else {
                        dist = MAX(0, - (v.x / beginPoint.x));
                        angle = (curr.x != w) ? -tanf(v.y / (w - curr.x)) : 0;
                    }
                    if (dist < pagingDistance) {
                        if (pagingDistance - dist > 0.05) {
                            dist = pagingDistance - 0.05;
                        }
                    } else {
                        if (dist - pagingDistance > 0.05) {
                            dist = pagingDistance + 0.05;
                        }
                    }
                    if (animeType == PageImageViewAnimationCurl) {
                        [self curl:dist angle:angle];
                    } else {
                        [self pageScroll:dist];
                    }
                }
            }
            
            
            
        } else if (pr.state == UIGestureRecognizerStateEnded) {
            if (dragPaging) {
                if (animeType == PageImageViewAnimationCurl) {
                    [self endCurl];
                } else {
                    [self endPageScroll];
                }
                dragPaging = NO;
            }
            
        }
    }
}

// 高さだけ揃える
-(void) fitHeight {
    if (scrollView.height < self.height) {
        [scrollView eFittoSuperview];
        if (contentView.height < self.height) {
            [contentView eSize:contentView.width :self.height];
        }
        CGFloat ch = contentView.height;
        [leftLayer eSize:leftLayer.width :ch];
        [rightLayer eSize:rightLayer.width :ch];
        [shadowView eSize:shadowView.width :ch];
        [scShadowView eSize:scShadowView.width :ch];
        [flipView eSize:flipView.width :ch];
        [flipLayer eSize:flipLayer.width :ch];
        [flipMaskLayer eSize:flipMaskLayer.width :ch];
        [flipBackView eSize:flipBackView.width :ch];
        [flipShadowLayer eSize:flipShadowLayer.width :ch];
        [flipBackMaskLayer eSize:flipBackMaskLayer.width :ch];
        [scLayer eSize:scLayer.width :ch];
        [scLeftLayer eSize:scLayer.width :ch];
        [scRightLayer eSize:scRightLayer.width :ch];
        [memoLeftView eSize:memoLeftView.width :ch];
        [memoRightView eSize:memoRightView.width :ch];
    }
}


#pragma mark - UIScrollViewDelegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)sv {
    return contentView;
}

// scrollViewで指が離れた瞬間
-(void)scrollViewDidEndDragging:(UIScrollView *)sv willDecelerate:(BOOL)decelerate 
{
    NSLog(@"Handling the DRAG");
    if (scrollView.contentSize.width > scrollView.frame.size.width) {
        CGPoint v = [VectorUtil vector:beginDragPoint :sv.contentOffset];
        if (fabs(v.y) < DRAG_Y_THRESHOLD) {
            int x = sv.contentOffset.x;
            //    int w = scrollView.frame.size.width;
            int cw = contentView.frame.size.width;
            int sw = scrollView.frame.size.width;
            
            
            if (x == 0 && leftTouch) {
                [delegate swipeRight];
            } else if (abs(cw - x - sw) < 3 && rightTouch) {
                [delegate swipeLeft];
            }
            leftTouch = rightTouch = NO;
//            NSLog(@"endx:%d cw-x:%d sw:%d lt:%d rt:%d", x, cw - x, sw, leftTouch, rightTouch);
        }
    }
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)sv {
    if (scrollView.contentSize.width > scrollView.frame.size.width) {
        int x = sv.contentOffset.x;
        beginDragPoint = sv.contentOffset;
        //    int w = scrollView.frame.size.width;
        int cw = contentView.frame.size.width;
        int sw = scrollView.frame.size.width;
        //    float zm = sv.zoomScale;
        //    //NSLog(@"x:%d w:%d sw:%d cw:%d cw-x:%d zoom:%0.1f decelerate:%d(%s)", x, w, sw, cw, (int)(cw-x), zm, decelerate, __func__);
        if (x == 0 && abs(cw - x - sw) < 3) {
            leftTouch = NO;
            rightTouch = NO;
        } else if (x == 0) {
            leftTouch = YES;
            rightTouch = NO;
        } else if (abs(cw - x - sw) < 3) {
            leftTouch = NO;
            rightTouch = YES;
        } else {
            leftTouch = NO;
            rightTouch = NO;
        }
//        NSLog(@"beginx:%d cw-x:%d sw:%d lt:%d rt:%d", x, cw - x, sw, leftTouch, rightTouch);
    }    
}

- (void)scrollViewDidScroll:(UIScrollView *)sv {
//    NSLog(@"%f,%f",sv.contentOffset.x,sv.contentOffset.y);
}


#pragma mark - ライフサイクル


// 初期化でLayer追加
- (void)initializeInner {
    orientationLock = [[NSString alloc]initWithString:@"lock"];
    [[NSNotificationCenter defaultCenter] 
     addObserver:self
     selector:@selector(didRotate:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
    
    scrollView = [[[UIScrollView alloc]initWithFrame:self.frame]autorelease];
    scrollView.maximumZoomScale = 3.0;
    scrollView.minimumZoomScale = 1.0;
    scrollView.bouncesZoom = YES;
    scrollView.bounces = YES;
    scrollView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    scrollView.delegate = self;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
                                | UIViewAutoresizingFlexibleHeight
                                | UIViewAutoresizingFlexibleLeftMargin
                                | UIViewAutoresizingFlexibleRightMargin
                                | UIViewAutoresizingFlexibleTopMargin
                                | UIViewAutoresizingFlexibleWidth;
    [self addSubview:scrollView];
    
    
    contentView = [[[UIView alloc]initWithFrame:self.frame]autorelease];
    
    [scrollView addSubview:contentView];
    
    leftLayer = [CALayer layer];
    leftLayer.minificationFilter = kCAFilterTrilinear;
    leftLayer.magnificationFilter = kCAFilterTrilinear;
    rightLayer = [CALayer layer];
    rightLayer.minificationFilter = kCAFilterTrilinear;
    rightLayer.magnificationFilter = kCAFilterTrilinear;
    [contentView.layer addSublayer:leftLayer];
    [contentView.layer addSublayer:rightLayer];
    
    if (marginShadow) {
        shadowView = [[[UIView alloc]init]autorelease];
        shadowView.layer.contents = (id)[UIImage imageNamed:@"shadow.png"].CGImage;
        CGRect cr = contentView.frame;
        shadowView.frame = CGRectMake(cr.size.width / 2 - SHADOW_WIDTH / 2, 0, SHADOW_WIDTH, cr.size.height);
        [contentView addSubview:shadowView];
        
        if (animeType == PageImageViewAnimationScroll) {
            scShadowView = [[[UIView alloc]init]autorelease];
            scShadowView.layer.contents = (id)[UIImage imageNamed:@"shadow.png"].CGImage;
            scShadowView.frame = shadowView.frame;
            scShadowView.hidden = YES;
            [contentView addSubview:scShadowView];
        }
        
    }
    
    if (animeType == PageImageViewAnimationCurl) {
        
        // 上にかぶせるレイヤー
        flipView = [[[UIView alloc]initWithFrame:self.frame]autorelease];
        flipView.clipsToBounds = NO;
        [contentView addSubview:flipView];
        flipLayer = [CALayer layer];
        flipLayer.minificationFilter = kCAFilterTrilinear;
        flipLayer.magnificationFilter = kCAFilterTrilinear;
        flipLayer.masksToBounds = NO;
        [flipView.layer addSublayer:flipLayer];    
        flipMaskLayer = [CAShapeLayer layer];
        [flipLayer addSublayer:flipMaskLayer];
        flipLayer.mask = flipMaskLayer;
        flipLayer.backgroundColor = [UIColor whiteColor].CGColor;
        
        // 上にかぶせるレイヤーの裏側
        flipBackView = [[[UIView alloc]initWithFrame:self.frame]autorelease];
        flipBackView.clipsToBounds = NO;
        [flipView addSubview:flipBackView];
        flipBackLayer = [CALayer layer];
        flipBackLayer.minificationFilter = kCAFilterTrilinear;
        flipBackLayer.magnificationFilter = kCAFilterTrilinear;
        flipBackLayer.masksToBounds = NO;
        [flipBackView.layer addSublayer:flipBackLayer];
        
        flipShadowLayer = [CALayer layer];
        flipShadowLayer.masksToBounds = NO;
        [flipBackLayer addSublayer:flipShadowLayer];
        
        
        flipBackMaskLayer = [CAShapeLayer layer];
        [flipBackLayer addSublayer:flipBackMaskLayer];
        flipBackLayer.mask = flipBackMaskLayer;

        if (marginShadow) {
            CALayer* l = flipView.layer;
            l.shadowOffset = CGSizeMake(10, 0);
            l.shadowColor = [UIColor blackColor].CGColor;
            l.shadowOpacity = 0.4;
            l.shadowRadius = 10;
        }
        
        
    } else {
        // スクロールの準備
        scLayer = [CALayer layer];
        scLeftLayer = [CALayer layer];
        scLeftLayer.hidden = YES;
        [scLayer addSublayer:scLeftLayer];
        
        scRightLayer = [CALayer layer];
        scRightLayer.hidden = YES;
        [scLayer addSublayer:scRightLayer];
        
        [contentView.layer addSublayer:scLayer];
    }
    
    // 落書き用のビュー
    memoLeftView = [[PageMemoView alloc]init];
    [contentView addSubview:memoLeftView];
    [memoLeftView release];
    memoRightView = [[PageMemoView alloc]init];
    [contentView addSubview:memoRightView];
    [memoRightView release];

    
    
    // タップのイベントリスナ
    UITapGestureRecognizer* tapr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapping:)];
    [self addGestureRecognizer:tapr];
    [tapr release];
    
    // ドラッグのイベントリスナ
    UIPanGestureRecognizer* panr = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragging:)];
    [self addGestureRecognizer:panr];
    [panr release];
    
    // 長押しのイベントリスナ
    UILongPressGestureRecognizer* lpr = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(pressing:)];
    [self addGestureRecognizer:lpr];
    [lpr release];
    
    
    [self updateRotation];
    pagingPrepared = YES;
    pdfSharpenPage = -1;
}

- (void)loadConfig {
    // 設定値
    NSUserDefaults* ud = [AppUtil config];
    // アニメーションタイプ
    if ([ud boolForKey:@"pageAnimation"]) {
        animeType = PageImageViewAnimationCurl;
    } else {
        animeType = PageImageViewAnimationScroll;
    }
    // 綴じ代影
    marginShadow = [ud boolForKey:@"pageMarginEffect"];
    // 開き方向
    leftNext = [ud boolForKey:@"leftNext"];
    // 表紙だけ分ける
    separateCover = [ud boolForKey:@"separateCover"];
    // 見開き
    spread = [ud boolForKey:@"spread"];
}


- (BOOL)isTop {
    int p = MIN([leftLayer.name intValue], [rightLayer.name intValue]);
    return p == 0;
}

- (BOOL)isLast {
    int p = MAX([leftLayer.name intValue], [rightLayer.name intValue]);
    return p == [dataSource pageCount] - 1;
}


// 初期化
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self loadConfig];    
    [self initializeInner];
    return self;
}

// 初期化
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self loadConfig];
    [self initializeInner];
    return self;
}

- (void)close {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 破棄
- (void)dealloc
{
    //NSLog(@"%s", __func__);
    self.delegate = nil;
    self.dataSource = nil;
    [orientationLock release];
    [super dealloc];
}

@end
