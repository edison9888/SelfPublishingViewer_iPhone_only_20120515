//
//  PalettePane.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/16.
//  Copyright 2011 SAT. All rights reserved.
//

#import "PalettePane.h"
#import "UIView_Effects.h"
#import "ImageUtil.h"
#import <QuartzCore/QuartzCore.h>
#import "common.h"
#import "RootPane.h"

@implementation PalettePane
@synthesize color, width, selectorPoint;
@synthesize delegate;
@synthesize colorMode;
@synthesize hilighted;
@synthesize hlLabel,colorPalette,slider;
@synthesize previewView,paletteHolder,widthHolder,hlSwitch;

#pragma mark - private
-(void)updatePreview {
    CGSize sz = previewView.frame.size;
    UIGraphicsBeginImageContext(sz);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (colorMode) {
        CGContextSetLineWidth(context, width);
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextSetLineJoin(context, kCGLineJoinRound);	// ライン同士の結合部の形状
        CGContextSetLineCap(context, kCGLineCapRound); // 終端の形状
        CGFloat cx = sz.width / 2;
        CGFloat cy = sz.height / 2;
        CGContextMoveToPoint(context, cx - 0.5, cy);
        CGContextAddLineToPoint(context, cx + 0.5, cy);
        CGContextStrokePath(context);
    } else {
        CGRect rc = CGRectMake((sz.width - width) / 2,
                               (sz.height - width) / 2, 
                               width, 
                               width);
        CGContextSetLineWidth(context, 1);
        CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextAddRect(context, rc);
        CGContextStrokePath(context);
    }
    UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
    previewView.layer.contents = (id)img.CGImage;
    UIGraphicsEndImageContext();
    [previewView setNeedsDisplay];
}

-(void)moveSelector:(CGPoint) p {
    p.x -= ((int)p.x) % PLT_CELL_SIZE;
    p.y -= ((int)p.y) % PLT_CELL_SIZE;
    p.x -= PLT_SELECTOR_MARGIN;
    p.y -= PLT_SELECTOR_MARGIN;
    [selector eMove:p];
}


#pragma mark - public

-(void)dispose {
    [self.view removeFromSuperview];
    [delegate palettePaneDisposed];
}

#pragma mark - view event
-(void)tapped:(UITapGestureRecognizer*)gr {
    CGPoint p = [gr locationInView:self.view];
    if (paletteHolder && [paletteHolder eContains:p]) {
        CGPoint pp = [gr locationInView:colorPalette.superview];
        if ([colorPalette eContains:pp]) {
            CGPoint ppp = [gr locationInView:colorPalette];
            [self moveSelector:ppp];
            CGPoint cp = selector.center;
            cp.x /= PLT_CELL_SIZE / 18;
            cp.y /= PLT_CELL_SIZE / 18;
            self.color = [ImageUtil getColorAtPoint:cp image:colorPalette.image];
            [delegate colorSelected:color point:selector.center];
            [self updatePreview];
        }
    } else if ([widthHolder eContains:p]) {
        // nop;
    } else {
        [self dispose];
    }
}

-(IBAction)widthChanged:(UISlider*)sl {
    width = sl.value;
    [delegate widthSet:width];
    [self updatePreview];
}

-(IBAction)hilightChanged:(UISwitch *)sw {
    hilighted = sw.on;
    [delegate hilightSet:hilighted];
    [self updatePreview];
}


#pragma mark - object lifecycle

- (void)dealloc {
    self.color = nil;
    
    self.hlSwitch = nil;
    self.hlLabel = nil;
    self.colorPalette = nil;
    self.slider = nil;
    self.previewView = nil;
    self.paletteHolder = nil;
    self.widthHolder = nil;
    
    
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
    if (colorMode) {
        selector = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"palette_select.png"]];
        [selector eSize:PLT_CELL_SIZE + PLT_SELECTOR_MARGIN * 2
                       :PLT_CELL_SIZE + PLT_SELECTOR_MARGIN * 2];
        [colorPalette addSubview:selector];
        [self moveSelector:selectorPoint];
        [selector release];
        hlSwitch.on = hilighted;
    } else {
        [paletteHolder removeFromSuperview];
        paletteHolder = nil;
        colorPalette = nil;
    }
    slider.value = width;
    UITapGestureRecognizer* tapr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
    [self.view addGestureRecognizer:tapr];
    [tapr release];
    [self updatePreview];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.color = nil;
    self.hlSwitch = nil;
    self.hlLabel = nil;
    self.colorPalette = nil;
    self.slider = nil;
    self.previewView = nil;
    self.paletteHolder = nil;
    self.widthHolder = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ![RootPane isRotationLocked];
}

@end
