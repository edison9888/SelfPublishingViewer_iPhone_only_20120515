//
//  EraseMode.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/12.
//  Copyright 2011 SAT. All rights reserved.
//

#import "EraseMode.h"
#import "common.h"
#import "TouchPanGestureRecognizer.h"
#import "UIView_Effects.h"
#import "AlertDialog.h"
#import "AppUtil.h"
#import "NSString_Util.h"

@interface EraseMode()
@property(nonatomic,retain)PalettePane* palettePane;
@end


@implementation EraseMode
@synthesize palettePane;

-(void)clear:(CGPoint)p {
    if (!pane.inDrawing) {
        context = [pane beginDrawing];
    }
	CGRect rec = CGRectMake(p.x -eraseWidth / 2 , 
                            p.y - eraseWidth / 2, 
                            eraseWidth, 
                            eraseWidth);
	CGContextClearRect(context, rec);
    
}

-(void)erase:(CGPoint)p {
    CGPoint lp = last;
    // 最初の点からの軌跡を割り出して消去する
    int mCnt = MAX(fabs(p.x - lp.x), fabs(p.y - lp.y));
    CGFloat dx = (p.x - lp.x) / mCnt;
    CGFloat dy = (p.y - lp.y) / mCnt;
    for (int i = 0; i < mCnt; i++) {
        [self clear:lp];
        lp.x += dx;
        lp.y += dy;
    }
    UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
    layer.contents = (id)img.CGImage;
    last = p;
}

#pragma mark -override

// ドラッグのイベントリスナ
-(void)dragged:(TouchPanGestureRecognizer*)gr {
    CGPoint p = [gr locationInView:canvas];
    if (gr.state == UIGestureRecognizerStatePossible) {
        if (gr.touchState == TouchPanGestureRecognizerStateBegin) {
            last = p;
        } else {
            [pane endDrawing];
            context = NULL;
        }
    } else if (gr.state == UIGestureRecognizerStateBegan) {
        [self erase:p];
    } else if (gr.state == UIGestureRecognizerStateChanged) {
        [self erase:p];
    } else if (gr.state == UIGestureRecognizerStateEnded
               || gr.state == UIGestureRecognizerStateFailed
               || gr.state == UIGestureRecognizerStateCancelled) {
        [pane endDrawing];
        context = NULL;
    } else {
        NSLog(@"other:%d", gr.state);
    }
}

-(void)modeSelected {
    NSUserDefaults* ud = [AppUtil config];
    if (![ud boolForKey:@"eraseModeHelp"]) {
        [AlertDialog confirm:res(@"aboutEraseMode")
                     message:res(@"eraseModeHelp")
                        onOK:^(){
                            [ud setBool:YES forKey:@"eraseModeHelp"];
                        }];
    }
    
}


-(void)modeAgain {
    if (palettePane) {
        [palettePane dispose];
    } else {
        PalettePane* p = [[[PalettePane alloc]init]autorelease];
        p.colorMode = NO;
        p.width = eraseWidth;
        [pane.view addSubview:p.view];
        [p.view eFittoSuperview];
        p.delegate = self;
        self.palettePane = p;
    }

}


#pragma mark - PalettePaneDelegate
-(void)widthSet:(CGFloat)width {
    eraseWidth = width;
}

-(void)palettePaneDisposed {
    self.palettePane = nil;
}

#pragma mark - object lifecycle
-(id)init {
    self = [super init];
    if (self) {
        eraseWidth = 20;
    }
    return self;
}


-(void)dealloc {
    NSLog(@"%s", __func__);
    [super dealloc];
}

@end
