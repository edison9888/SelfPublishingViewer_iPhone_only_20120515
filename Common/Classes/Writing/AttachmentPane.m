//
//  AttachmentPane.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/14.
//  Copyright 2011 SAT. All rights reserved.
//

#import "AttachmentPane.h"
#import "ActionDialog.h"
#import "UIView_Effects.h"
#import "ImagePickDialog.h"
#import "AlertDialog.h"
#import "TouchPanGestureRecognizer.h"
#import "RootPane.h"

#import <QuartzCore/QuartzCore.h>

@interface AttachmentPane() 
@property(nonatomic,retain)ImagePickDialog* imagePicker;
@end

@implementation AttachmentPane
@synthesize pageMemo;
@synthesize imagePicker;
@synthesize editMode;
@synthesize scrollView,primaryView,secondaryView;
@synthesize toolbar,editToolbar,addButton,prevButton,prevButton2;
@synthesize nextButton,nextButton2,removeButton;

#pragma mark - AttachmentPaneとしての機能

// 参照を取り替える
-(void)swapPrimary {
    UIImageView* work = primaryView;
    primaryView = secondaryView;
    secondaryView = work;
    secondaryView.hidden = YES;
    secondaryView.image = nil;
}

-(BOOL)hasNext {
    return current > 0;
}
-(BOOL)hasPrev {
    return current < [pageMemo attachmentCount] - 1;
}

-(void)updateDecoration {
    nextButton.enabled = nextButton2.enabled = [self hasNext];
    prevButton.enabled = prevButton2.enabled = [self hasPrev];
    removeButton.enabled = (current >= 0);
    NSInteger cnt = [pageMemo attachmentCount];
    if (cnt > 0) {
        self.navigationItem.title = [NSString
                                     stringWithFormat:@"%d / %d",
                                     cnt - current,
                                     cnt];
    } else {
        self.navigationItem.title = NSLocalizedString(@"noAttachment", nil);
        
    }
}

-(void)setViewSize:(UIImageView*)iv image:(UIImage*)img {
    if ([RootPane isPortrait]) {
        if (img.size.width > img.size.height) {
            [iv eSize:scrollView.width * 2 :scrollView.height];
        } else {
            [iv eSameSize:scrollView];
        }
    } else {
        if (img.size.height > img.size.width) {
            [iv eSize:scrollView.width :scrollView.height * 2];
        } else {
            [iv eSameSize:scrollView];
        }
    }
}

-(IBAction)jumpTop {
    NSInteger idx = [pageMemo attachmentCount] - 1;
    if (idx >= 0) {
        UIImage* img = [pageMemo attachmentImageAt:idx];
        UIImageView* iv = (idx != current) ? secondaryView : primaryView;
        [self setViewSize:iv image:img];
        iv.image = img;
        if (iv == secondaryView) {
            // 右から左へスクロール
            [secondaryView eMove:primaryView.right :0];
            secondaryView.hidden = NO;
            [UIView animateWithDuration:0.3
                             animations:^{
                                 [primaryView eOffset:-primaryView.width :0];
                                 [secondaryView eOffset:-primaryView.width :0];
                             }
                             completion:^(BOOL finished) {
                                 [CATransaction begin];
                                 [CATransaction setValue:(id)kCFBooleanTrue
                                                  forKey:kCATransactionDisableActions];

                                 [self swapPrimary];
                                 scrollView.contentSize = primaryView.frame.size;
                                 current = idx;
                                 [self updateDecoration];
                                 [CATransaction commit];
                             }];
        } else {
            scrollView.contentSize = primaryView.frame.size;
            current = idx;
            [self updateDecoration];
        }
    }
}


-(void)addFromCamera {
    self.imagePicker = [ImagePickDialog 
     showCameraPopover:^(UIImage* img){
         [pageMemo addAttachment:img];
         [self jumpTop];
     }
     fromBarButton:addButton
     inView:self.view];
}
-(void)addFromAlbum {
    self.imagePicker = [ImagePickDialog
     showPopover:^(UIImage* img){
         [pageMemo addAttachment:img];
         [self jumpTop];
     }
     fromBarButton:addButton
     inView:self.view];
}

-(IBAction)add {
    NSArray* buttons = [NSArray 
                        arrayWithObjects:
                        NSLocalizedString(@"addByCamera", nil),
                        NSLocalizedString(@"addByAlbum", nil), nil];
    ActionDialog* ad = [[ActionDialog alloc]
                        initWithTitle:NSLocalizedString(@"addAttachment", nil)
                        callback:^(NSInteger idx) {
                            if (idx == 0) {
                                [self addFromCamera];
                            } else if (idx == 1) {
                                [self addFromAlbum];
                            }
                        }
                        otherButtonTitles:buttons
                        ];
    [ad showFromToolbar:editToolbar];
    [ad release];
}
-(IBAction)prev {
    if ([self hasPrev]) {
        NSInteger idx = current + 1;
        UIImage* img = [pageMemo attachmentImageAt:idx];
        [self setViewSize:secondaryView image:img];
        secondaryView.image = img;
        // 左から右へスクロール
        [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
        [scrollView setZoomScale:1 animated:NO];
        [secondaryView eMove:-secondaryView.width :0];
        secondaryView.hidden = NO;
        [UIView animateWithDuration:0.3
                         animations:^{
                             [primaryView eOffset:secondaryView.width :0];
                             [secondaryView eOffset:secondaryView.width :0];
                         }
                         completion:^(BOOL finished) {
                             [CATransaction begin];
                             [CATransaction setValue:(id)kCFBooleanTrue
                                              forKey:kCATransactionDisableActions];

                             [self swapPrimary];
                             scrollView.contentSize = primaryView.frame.size;
                             current = idx;
                             [self updateDecoration];
                             [CATransaction commit];
                         }];
    }
}
-(IBAction)next {
    if ([self hasNext]) {
        NSInteger idx = current - 1;
        UIImage* img = [pageMemo attachmentImageAt:idx];
        [self setViewSize:secondaryView image:img];
        secondaryView.image = img;
        // 右から左へスクロール
        [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
        [scrollView setZoomScale:1 animated:NO];
        [secondaryView eMove:primaryView.width :0];
        secondaryView.hidden = NO;
        [UIView animateWithDuration:0.3
                         animations:^{
                             [primaryView eOffset:-primaryView.width :0];
                             [secondaryView eOffset:-primaryView.width :0];
                         }
                         completion:^(BOOL finished) {
                             [CATransaction begin];
                             [CATransaction setValue:(id)kCFBooleanTrue
                                              forKey:kCATransactionDisableActions];
                             [self swapPrimary];
                             scrollView.contentSize = primaryView.frame.size;
                             current = idx;
                             [self updateDecoration];
                             [CATransaction commit];
                         }];
    }
}
-(IBAction)remove {
    if (current >= 0) {
        [AlertDialog confirm:NSLocalizedString(@"confirm", nil) 
                     message:NSLocalizedString(@"confirmDelete", nil) 
                        onOK:^{
                            [pageMemo deleteAttachmentAt:current];
                            if ([self hasPrev]) {
                                [self prev];
                            } else if ([pageMemo attachmentCount] > 0) {
                                current = -1;
                                [self jumpTop];
                            } else {
                                primaryView.image = nil;
                                [primaryView eFittoSuperview];
                                scrollView.contentSize = primaryView.frame.size;
                                current = -1;
                                [self updateDecoration];
                            }
                        }];
    }
}

#pragma mark - UIScrollViewDelegate
// zoom対象
-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return primaryView;
}

// スクロールイベント
-(void)scrollViewDidScroll:(UIScrollView *)sv {

}

-(BOOL)touchingLeft {
    CGPoint of = scrollView.contentOffset;
    if (fabs(of.x) < 3) {
        return YES;
    } else {
        return NO;
    }
}
-(BOOL)touchingRight {
    CGPoint of = scrollView.contentOffset;
    if (fabs(primaryView.width - scrollView.width - of.x) < 3) {
        return YES;
    } else {
        return NO;
    }
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)sv {
    if (scrollView.width < scrollView.contentSize.width) {
        // 横スクロールが有効な場合
        touchLeft = [self touchingLeft];
        touchRight = [self touchingRight];
        beginTime = [NSDate timeIntervalSinceReferenceDate];
        beginPoint = scrollView.contentOffset;
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)sv willDecelerate:(BOOL)decelerate {
    if (scrollView.width < scrollView.contentSize.width) {
        // 横スクロールが有効な場合
        CGFloat dy = fabsf(scrollView.contentOffset.y - beginPoint.y);
        NSTimeInterval dt = [NSDate timeIntervalSinceReferenceDate] - beginTime;
        if (dy < 10 && dt < 0.5 && 0.01 < dt) {
            // 縦にあまり動いていなくて0.5秒以内の場合
            if (touchLeft && [self touchingLeft]) {
                // 左側に張り付いている
                [self performSelector:@selector(prev) withObject:nil afterDelay:0.1];
            } else if (touchRight && [self touchingRight]) {
                // 右側に張り付いている
                [self performSelector:@selector(next) withObject:nil afterDelay:0.1];
            }
        }
    }
}

- (void)panned:(TouchPanGestureRecognizer*)gr {
    CGPoint p = [gr locationInView:self.view];
    if (gr.state == UIGestureRecognizerStateBegan) {
        beginPoint = p;
        beginTime = [NSDate timeIntervalSinceReferenceDate];
    } else if (gr.state == UIGestureRecognizerStateChanged) {
        
    } else if (gr.state == UIGestureRecognizerStateEnded) {
        CGFloat dy = fabsf(p.y - beginPoint.y);
        NSTimeInterval dt = [NSDate timeIntervalSinceReferenceDate] - beginTime;
        if (dy < 10 && dt < 0.5 && 0.01 < dt) {
            CGFloat dx = p.x - beginPoint.x;
            if (dx > 10) {
                [self performSelector:@selector(prev) withObject:nil afterDelay:0.1];
            } else if (dx < -10) {
                [self performSelector:@selector(next) withObject:nil afterDelay:0.1];
            }
        }
    }
}


#pragma mark - viewイベント

-(void)updateRotation {
    [self setViewSize:primaryView image:primaryView.image];
    scrollView.contentSize = primaryView.frame.size;
}

-(void)didRotate:(NSNotification *)notification {
    [AttachmentPane cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateRotation) object:nil];
    [self performSelector:@selector(updateRotation) withObject:nil afterDelay:0.2];
}


-(void)viewWillAppear:(BOOL)animated {
    if (editMode) {
        editToolbar.hidden = NO;
        toolbar.hidden = YES;
    } else {
        editToolbar.hidden = YES;
        toolbar.hidden = NO;
    }
    // 新しい順にページ送りをするため、currentはインデックスと逆
    current = [pageMemo attachmentCount] - 1;
    [self updateDecoration];
}

-(void)viewDidAppear:(BOOL)animated {
    if (current >= 0) {
        [self jumpTop];
    } else {
        [self add];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ![RootPane isRotationLocked];
}



#pragma mark - object lifecycle


- (void)dealloc
{
    //NSLog(@"%s", __func__);
    self.pageMemo = nil;
    self.imagePicker = nil;
    self.scrollView = nil;
    self.primaryView = nil;
    self.secondaryView = nil;
    self.toolbar = nil;
    self.editToolbar = nil;
    self.addButton = nil;
    self.prevButton = nil;
    self.prevButton2 = nil;
    self.nextButton = nil;
    self.nextButton2 = nil;
    self.removeButton = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    primaryView.contentMode = UIViewContentModeScaleToFill;
    secondaryView.contentMode = UIViewContentModeScaleToFill;
    scrollView.bouncesZoom = NO;
    scrollView.bounces = NO;
    
    TouchPanGestureRecognizer* gr = [[TouchPanGestureRecognizer alloc]initWithTarget:self action:@selector(panned:)];
    [self.view addGestureRecognizer:gr];
    [gr release];

    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.imagePicker = nil;
    self.scrollView = nil;
    self.primaryView = nil;
    self.secondaryView = nil;
    self.toolbar = nil;
    self.editToolbar = nil;
    self.addButton = nil;
    self.prevButton = nil;
    self.prevButton2 = nil;
    self.nextButton = nil;
    self.nextButton2 = nil;
    self.removeButton = nil;
}


@end
