//
//  BookReaderPane.h
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/01.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "common.h"
#import "BookControlPane.h"
#import "PageImageView.h"
#import "Viewable.h"

@interface BookReaderPane : UIViewController<PageImageViewDelegate, PageImageViewDataSource> {
    @private
    PageImageView* imageView;
    NSObject<Viewable>* book;
    BOOL isInError;
    BOOL previewing;
    NSInteger currentPage;
    BOOL viewerInvalid;
    UILabel* lastPageLabel;
    BookControlPane* control;
    BOOL isFromImageAdjustment;
}

@property(nonatomic,assign) BOOL isFromImageAdjustment;
@property(nonatomic,retain) IBOutlet UILabel* lastPageLabel;
@property(nonatomic,assign)BOOL viewerInvalid;
@property(nonatomic,assign)BOOL previewing;
@property(readonly) NSObject<Viewable>* book;
@property(readonly) NSInteger currentPage;
@property(readonly) NSInteger pageCount;

// Bookを閉じる
- (void) closeBook;
// Bookを開く
- (void) openBook: (NSObject<Viewable>*) bookToOpen;
// 指定したページを開く
- (void) openPage: (NSInteger) page;
- (UIImage*) highResImageAt: (NSInteger)page;
// 次のページを開く
- (void) nextPage;
// 前のページを開く
- (void) prevPage;
// Controlを表示する
- (void) showControl;
// Controlを消す
- (void) hideControl;

@end
