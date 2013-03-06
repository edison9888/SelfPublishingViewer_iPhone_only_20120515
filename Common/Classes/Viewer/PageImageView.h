//
//  PageImageView.h
//  ForIPad
//  １ページあるいは２ページの画像を表示するView部品
//  Created by 藤田正訓 on 11/07/04.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PageMemo.h"
@class PageMemoView;

// PageImageViewのカスタムイベントを扱うためのdelegate
@protocol PageImageViewDelegate
// 左のほうをタップ
-(void) tapLeft;
// 右のほうをタップ
-(void) tapRight;
// 真ん中あたりをタップ
-(void) tapCenter;
// 左のほうを長押ししている間連続して呼ばれる
-(void) pressLeft: (BOOL)end;
// 右のほうを長押ししている間連続して呼ばれる
-(void) pressRight: (BOOL)end;
// ページが開かれたイベント
-(void) pageOpened;
// 何らかのエラーが発生したイベント
-(void) errorOccured;
// 左にスワイプ
-(void) swipeLeft;
// 右にスワイプ
-(void) swipeRight;

@end

// PageImageViewにデータを提供するためのdelegate
@protocol PageImageViewDataSource
// ページ数を返す
-(NSInteger) pageCount;
// ページの画像を返す
-(UIImage*) imageAt:(NSInteger)page;
-(UIImage*) highResImageAt: (NSInteger)page;
// ページのサムネイル画像を返す
-(UIImage*) thumbnailAt:(NSInteger)page;
// キャッシュさせる
-(void)fetchCache:(NSInteger)page size:(CGSize)size;
// URLLinkの配列を返す
-(NSArray*)urlLinks:(NSInteger)page;

-(PageMemo*)getPageMemo:(NSInteger)page;

@end

// アニメーションの種類
typedef enum {
    PageImageViewAnimationScroll = 1,
    PageImageViewAnimationCurl = 2
} PageImageViewAnimation;


@interface PageImageView : UIView <UIScrollViewDelegate> {
    @private
    id<PageImageViewDelegate> delegate;
    id<PageImageViewDataSource> dataSource;
    BOOL leftNext;
    BOOL leftLimit;
    BOOL rightLimit;
    NSTimeInterval beginTime;
    CGPoint beginPoint;
    
    BOOL isPortrait;
    BOOL longPressing;
    
    // スクロール、拡大用ビュー
    UIScrollView* scrollView;
    CGFloat scaleMag;
    UIView* contentView;
    
    // 下側のレイヤー
    CALayer* leftLayer;
    CALayer* rightLayer;
    
    // 影用のレイヤー
    UIView* shadowView;
    UIView* scShadowView;

    // めくる用のレイヤー
    UIView* flipView;
    CALayer* flipLayer;
    CAShapeLayer* flipMaskLayer;
    // めくる裏側のレイヤー
    UIView* flipBackView;
    CALayer* flipBackLayer;
    CALayer* flipShadowLayer;
    CAShapeLayer* flipBackMaskLayer;
    
    // スクロール用のレイヤー
    CALayer* scLayer;
    CALayer* scLeftLayer;
    CALayer* scRightLayer;
    
    // 落書き用のビュー
    PageMemoView* memoLeftView;
    PageMemoView* memoRightView;
    
    // 現在のページ番号
    NSInteger currentPage;
    
    // 現在のページめくり状態
    CGFloat pagingDistance;
    CGFloat curlAngle;
    BOOL dragPaging;
    BOOL paging;
    BOOL pagingToRight;
    BOOL pagingPrepared;
    BOOL widePage;
    NSInteger pdfSharpenPage;
    
    BOOL marginShadow;
    PageImageViewAnimation animeType;
    // 見開き表示
    BOOL spread;
    // 表紙だけ分ける
    BOOL separateCover;
    
    NSInteger prevPage;
    NSInteger nextPage;
    
    CGSize imageSize1;
    CGSize imageSize2;
    
    NSObject* orientationLock;
    
    // 端に到達したフラグ
    BOOL leftTouch;
    BOOL rightTouch;
    CGPoint beginDragPoint;
    
}
// イベントリスナ
@property(nonatomic,assign) id<PageImageViewDelegate> delegate;
@property(nonatomic,assign) id<PageImageViewDataSource> dataSource;
// 状態量
@property(nonatomic,readonly) BOOL isPortrait;
@property(nonatomic,readonly) NSInteger currentPage;
// 動作設定
// 開き方向
@property(nonatomic,assign)BOOL leftNext;
// 見開き表示
@property(nonatomic,assign)BOOL spread;
// 綴じ代影
@property(nonatomic,assign)BOOL marginShadow;
// 表紙だけ分ける
@property(nonatomic,assign)BOOL separateCover;
// アニメーションタイプ
@property(nonatomic,assign)PageImageViewAnimation animeType;
@property(nonatomic,assign)UIView* contentView;


// 次のページがあるかどうか
- (BOOL) hasNext;
// 前のページがあるかどうか
- (BOOL) hasPrev;
// 次のページへ
- (void) animateNext;
// 前のページへ
- (void) animatePrev;
// 指定したページへ
- (void) openAt: (NSInteger)page forward:(BOOL)forward;

- (void)loadConfig;
// リンクがタップされた
- (void)linkTapped:(UIButton*) link;
// 高速アニメーション
- (void)highSpeedAnimateLeft;
// 高速アニメーション
- (void)highSpeedAnimateRight;
// 閉じる
- (void)close;

- (BOOL)isTop;

- (BOOL)isLast;
// 高さだけ揃える
- (void)fitHeight;


@end
