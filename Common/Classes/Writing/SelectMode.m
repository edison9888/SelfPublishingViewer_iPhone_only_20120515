//
//  SelectMode.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/12.
//  Copyright 2011 SAT. All rights reserved.
//

#import "SelectMode.h"
#import "SelectAreaView.h"
#import "TouchPanGestureRecognizer.h"
#import "UIView_Effects.h"
#import "AlertDialog.h"
#import "AppUtil.h"

@implementation SelectMode

// 選択エリアが消える瞬間にlayerに書きこむ
-(void)removeArea {
    if (areaView) {
        if (pane.inDrawing) {
            [areaView.image drawInRect:areaView.frame];
            UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
            layer.contents = (id)img.CGImage;
            [pane endDrawing];
            context = NULL;
        }
        [areaView removeFromSuperview];
        areaView = nil;
    }
}

-(void)change:(CGPoint) p {
    if (dragMode == MOVING) {
        [areaView eMove:p.x - AREA_MARGIN :p.y - AREA_MARGIN];
    } else if (dragMode == RESIZING) {
        [areaView eSetRight:p.x + AREA_MARGIN bottom:p.y + AREA_MARGIN 
                    minSize:AREA_MINSIZE];
        [areaView setNeedsLayout];
        [areaView setNeedsDisplay];
    } else if (dragMode == MAKING) {
        [areaView eSetRight:p.x + AREA_MARGIN bottom:p.y + AREA_MARGIN 
                    minSize:AREA_MINSIZE];
        [areaView setNeedsLayout];
        [areaView setNeedsDisplay];
    }
}

-(void)startMake:(CGPoint)p {
    if (!areaView) {
        areaView = [[[SelectAreaView alloc]init]autorelease];
        [canvas addSubview:areaView];
    }
    [areaView eMove:beginPoint.x :beginPoint.y];
    [areaView eSize:AREA_MINWIDTH :AREA_MINHEIGHT];
    
}

// 切り抜いて変更開始
-(void)startClip:(CGPoint)p {
    if (!pane.inDrawing) {
        context = [pane beginDrawing];
        
        // 画像を部分切り出し
        CGImageRef allImg = (CGImageRef)layer.contents;
        CGImageRef clipImg = CGImageCreateWithImageInRect(allImg, areaView.frame);
        areaView.image = [UIImage imageWithCGImage:clipImg];
        [areaView setNeedsDisplay];
        CGImageRelease(clipImg);
        CGContextClearRect(context, areaView.frame);
        UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
        layer.contents = (id)img.CGImage;
    }
}



-(void)begin:(CGPoint) p {
    if (!areaView) {
        dragMode = MAKING;
        
    } else {
        if (fabs(p.x - areaView.left - AREA_MARGIN) < SENSE_RADIUS 
            && fabs(p.y - areaView.top - AREA_MARGIN) < SENSE_RADIUS) {
            // 左上のあたりを触ったので移動モード
            dragMode = MOVING;
        } else if (fabs(p.x - areaView.right + AREA_MARGIN) < SENSE_RADIUS 
                   && fabs(p.y - areaView.bottom + AREA_MARGIN) < SENSE_RADIUS) {
            // 右下のあたりを触ったので変形モード
            dragMode = RESIZING;
        } else {
            [self removeArea];
            dragMode = MAKING;
        }
    }
    beginPoint = p;
}


#pragma mark - オーバーライド

-(void)dragged:(TouchPanGestureRecognizer *)gr {
    CGPoint p = [gr locationInView:canvas];
    if (gr.state == UIGestureRecognizerStatePossible 
        && gr.touchState == TouchPanGestureRecognizerStateBegin) {
        [self begin:p];
        
    } else if (gr.state == UIGestureRecognizerStateBegan) {
        if (dragMode == MAKING) {
            [self startMake:p];
        } else {
            [self startClip:p];
        }
    } else if (gr.state == UIGestureRecognizerStateChanged) {
        [self change:p];
        
    } else if (gr.state == UIGestureRecognizerStateEnded
               || gr.state == UIGestureRecognizerStateFailed
               || gr.state == UIGestureRecognizerStateCancelled
               || (gr.state == UIGestureRecognizerStatePossible
                   && gr.touchState == TouchPanGestureRecognizerStateEnd)
               ) {
        // nop
    }
}

-(void)modeSelected {
    NSUserDefaults* ud = [AppUtil config];
    if (![ud boolForKey:@"selectModeHelp"]) {
        [AlertDialog confirm:NSLocalizedString(@"aboutSelectMode", nil)
                     message:NSLocalizedString(@"selectModeHelp", nil)
                        onOK:^(){
                            [ud setBool:YES forKey:@"selectModeHelp"];
                        }];
    }
}

-(void)modeUnselected {
    [self removeArea];    
}

-(void)completeCurrent {
    [self removeArea];
}

#pragma mark - lifecycle

-(void)dealloc {
    [self removeArea];
    [super dealloc];
}

@end
