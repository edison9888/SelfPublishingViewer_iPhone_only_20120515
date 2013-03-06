//
//  DrawMode.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/12.
//  Copyright 2011 SAT. All rights reserved.
//

#import "DrawMode.h"
#import "common.h"
#import "TouchPanGestureRecognizer.h"
#import "UIView_Effects.h"
#import "AppUtil.h"
#import "NSString_Util.h"
#import "AlertDialog.h"

@interface DrawMode()
@property(nonatomic,retain)UIColor* penColor;
@property(nonatomic,retain)PalettePane* palettePane;
@end


@implementation DrawMode
@synthesize penColor;
@synthesize palettePane;

// タップのイベントリスナ
-(void)tapped:(UITapGestureRecognizer*)gr {
//    NSLog(@"タップされた");
}

-(void)drawLine:(CGPoint)p {
    if (!pane.inDrawing) {
        context = [pane beginDrawing];
        CGContextSetLineWidth(context, penWidth);
        if(isHighlight) {
            UIColor* hc = [penColor colorWithAlphaComponent:0.2];
            CGContextSetStrokeColorWithColor(context, hc.CGColor);
            CGContextSetLineJoin(context, kCGLineJoinMiter);
            CGContextSetLineCap(context, kCGLineCapSquare);
        } else {
            CGContextSetStrokeColorWithColor(context, penColor.CGColor);
            CGContextSetLineJoin(context, kCGLineJoinRound);	// ライン同士の結合部の形状
            CGContextSetLineCap(context, kCGLineCapRound);	// ライン終端の形状
        }
    }
    CGContextMoveToPoint(context, last2.x, last2.y);
    CGContextAddLineToPoint(context, last.x, last.y);
    CGContextAddLineToPoint(context, p.x, p.y);
    CGContextStrokePath(context);
    last2 = last;
    last = p;
    UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
    layer.contents = (id)img.CGImage;
}

#pragma mark - override

// ドラッグのイベントリスナ
-(void)dragged:(TouchPanGestureRecognizer*)gr {
    CGPoint p = [gr locationInView:canvas];
    if (gr.state == UIGestureRecognizerStatePossible) {
        if (gr.touchState == TouchPanGestureRecognizerStateBegin) {
            last = last2 = p;
        } else {
            [pane endDrawing];
        }
    } else if (gr.state == UIGestureRecognizerStateBegan) {
        [self drawLine:p];
    } else if (gr.state == UIGestureRecognizerStateChanged) {
        [self drawLine:p];
    } else if (gr.state == UIGestureRecognizerStateEnded
               || gr.state == UIGestureRecognizerStateFailed
               || gr.state == UIGestureRecognizerStateCancelled) {
        [pane endDrawing];
    } else {
        NSLog(@"other:%d", gr.state);
    }
}

-(void)modeAgain {
    if (palettePane) {
        [palettePane dispose];
    } else {
        PalettePane* p = [[[PalettePane alloc]init]autorelease];
        p.colorMode = YES;
        p.color = penColor;
        p.selectorPoint = paletteSelectPoint;
        p.width = penWidth;
        p.hilighted = isHighlight;
        [pane.view addSubview:p.view];
        [p.view eFittoSuperview];
        p.delegate = self;
        self.palettePane = p;
    }
}

-(void)modeSelected {
    NSUserDefaults* ud = [AppUtil config];
    if (![ud boolForKey:@"drawModeHelp"]) {
        [AlertDialog confirm:res(@"aboutDrawMode")
                     message:res(@"drawModeHelp")
                        onOK:^(){
                            [ud setBool:YES forKey:@"drawModeHelp"];
                        }];
    }

}

#pragma mark - PalettePaneイベント
-(void)palettePaneDisposed {
    self.palettePane = nil;
}

-(void)colorSelected:(UIColor *)color point:(CGPoint)point{
    self.penColor = color;
    paletteSelectPoint = point;
}
-(void)hilightSet:(BOOL)hilighted {
    isHighlight = hilighted;
}
-(void)widthSet:(CGFloat)width {
    penWidth = width;
}

#pragma mark - object lifecycle
-(id)init {
    self = [super init];
    if (self) {
        penWidth = 5;
        self.penColor = [UIColor blackColor];
    }
    return self;
}


-(void)dealloc {
    NSLog(@"%s", __func__);
    self.penColor = nil;
    [super dealloc];
}

@end
