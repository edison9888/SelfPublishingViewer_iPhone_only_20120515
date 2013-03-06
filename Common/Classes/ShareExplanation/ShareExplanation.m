//
//  ShareExplanation.m
//  ForIPad
//
//  Created by 川口主税 on 11/08/04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShareExplanation.h"
#import "AppUtil.h"
#import "RootPane.h"


@implementation ShareExplanation
@synthesize scrollview01;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setExplanationType:(int)type {
	explanationType = type;
}

- (void)dbWebto:(id)sender {
	UIApplication *app = [UIApplication sharedApplication];
	
	[app openURL:[NSURL URLWithString:NSLocalizedString(@"http://clfd.jp/atr-app-00010/",nil)]];
}

- (void)setDisplay:(BOOL)portrait {
    CGRect rect = [[UIScreen mainScreen]applicationFrame];
    
	CGFloat displaySizeW;
    CGFloat frameWidth;
    if ([AppUtil isForIpad]) {
        displaySizeW = 768;
        frameWidth = rect.size.width;
        if(!portrait) {
            displaySizeW = 1024.0f;
            frameWidth = rect.size.width;
        }
    }else{
        displaySizeW = 320;
        frameWidth = rect.size.width;
        if (!portrait) {
            displaySizeW = 480;
            frameWidth = rect.size.width + 20;
        }
    }
	CGFloat labelLeftMargin = 20.0f;
    CGFloat labelWidth = frameWidth - (labelLeftMargin * 2);

	if(explanationType == 0) {
		
		UIButton *btnback = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [btnback setFrame:CGRectMake(10, 15, frameWidth - (10 * 2), 21 * 41)];
		[btnback setEnabled:NO];
        btnback.autoresizingMask = 2;
		[scrollview01 addSubview:btnback];
		
		int pos = 20;
		int line = 4;
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 21 * line)];
		[label setText:NSLocalizedString(@"shareHelpTextBt01", nil)];
		[label setNumberOfLines:0];
		[label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = 2;
		[scrollview01 addSubview:label];
		[label release];
		pos += 21 * (line + 1);
		
		line = 2;
		label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 21 * line)];
		[label setText:NSLocalizedString(@"shareHelpTextBt02", nil)];
		[label setNumberOfLines:0];
		[label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = 2;
		[scrollview01 addSubview:label];
		[label release];
		pos += 21 * (line + 1);
		
		line = 3;
		label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 21 * line)];
		[label setText:NSLocalizedString(@"shareHelpTextBt03", nil)];
		[label setNumberOfLines:0];
		[label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = 2;
		[scrollview01 addSubview:label];
		[label release];
		pos += 21 * (line + 1);
		
		line = 3;
		label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 21 * line)];
		[label setText:NSLocalizedString(@"shareHelpTextBt04", nil)];
		[label setNumberOfLines:0];
		[label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = 2;
		[scrollview01 addSubview:label];
		[label release];
		pos += 21 * (line + 1);
		
		line = 3;
		label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 21 * line)];
		[label setText:NSLocalizedString(@"shareHelpTextBt05", nil)];
		[label setNumberOfLines:0];
		[label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = 2;
		[scrollview01 addSubview:label];
		[label release];
		pos += 21 * (line + 1);
		
		line = 4;
		label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 21 * line)];
		[label setText:NSLocalizedString(@"shareHelpTextBt06", nil)];
		[label setNumberOfLines:0];
		[label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = 2;
		[scrollview01 addSubview:label];
		[label release];
		pos += 21 * (line + 1);
		
		line = 3;
		label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 21 * line)];
		[label setText:NSLocalizedString(@"shareHelpTextBt07", nil)];
		[label setNumberOfLines:0];
		[label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = 2;
		[scrollview01 addSubview:label];
		[label release];
		pos += 21 * (line + 1);
		
		line = 3;
		label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 21 * line)];
		[label setText:NSLocalizedString(@"shareHelpTextBt08", nil)];
		[label setNumberOfLines:0];
		[label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = 2;
		[scrollview01 addSubview:label];
		[label release];
		pos += 21 * (line + 1);
		
		line = 3;
		label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 21 * line)];
		[label setText:NSLocalizedString(@"shareHelpTextBt09", nil)];
		[label setNumberOfLines:0];
		[label setBackgroundColor:[UIColor clearColor]];
		[label setTextColor:[UIColor redColor]];
        label.autoresizingMask = 2;
		[scrollview01 addSubview:label];
		[label release];
		pos += 21 * (line + 1);
		
		line = 3;
		label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 21 * line)];
		[label setText:NSLocalizedString(@"shareHelpTextBt10", nil)];
		[label setNumberOfLines:0];
		[label setBackgroundColor:[UIColor clearColor]];
		[label setTextColor:[UIColor redColor]];
        label.autoresizingMask = 2;
		[scrollview01 addSubview:label];
		[label release];
		pos += 21 * (line + 1);
		
		[scrollview01 setContentSize:CGSizeMake(frameWidth, pos)];
		
	} else {
		UIButton *btnback = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		//		[btnback setFrame:CGRectMake(10, 15, 300, 21 * 63 + 58)];
        [btnback setFrame:CGRectMake(10, 15, frameWidth - (10 * 2), 21 * 63 + 58)];
		[btnback setEnabled:NO];
        btnback.autoresizingMask = 2;
		[scrollview01 addSubview:btnback];
		
		int pos = 20;
		int line = 4;
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 21 * line)];
		[label setText:NSLocalizedString(@"shareHelpTextDB01", nil)];
		[label setNumberOfLines:0];
		[label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = 2;
		[scrollview01 addSubview:label];
		[label release];
		pos += 21 * (line + 1);
		
		UIButton *btnwebto = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[btnwebto setFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 37)];
		[btnwebto setTitle:NSLocalizedString(@"shareHelpButtonDB", nil) forState:UIControlStateNormal];
		[btnwebto addTarget:self action:@selector(dbWebto:) forControlEvents:UIControlEventTouchUpInside];
        btnwebto.autoresizingMask = 2;
		[scrollview01 addSubview:btnwebto];
		pos += 58;
		
		line = 1;
		label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 21 * line)];
		[label setText:NSLocalizedString(@"shareHelpTextDB02", nil)];
		[label setNumberOfLines:0];
		[label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = 2;
		[scrollview01 addSubview:label];
		[label release];
		pos += 21 * (line + 1);
		
		line = 2;
		label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 21 * line)];
		[label setText:NSLocalizedString(@"shareHelpTextDB03", nil)];
		[label setNumberOfLines:0];
		[label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = 2;
		[scrollview01 addSubview:label];
		[label release];
		pos += 21 * (line + 1);
		
		line = 3;
		label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 21 * line)];
		[label setText:NSLocalizedString(@"shareHelpTextDB04", nil)];
		[label setNumberOfLines:0];
		[label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = 2;
		[scrollview01 addSubview:label];
		[label release];
		pos += 21 * (line + 1);
		
		line = 3;
		label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 21 * line)];
		[label setText:NSLocalizedString(@"shareHelpTextDB05", nil)];
		[label setNumberOfLines:0];
		[label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = 2;
		[scrollview01 addSubview:label];
		[label release];
		pos += 21 * (line + 1);
		
		line = 6;
		label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 21 * line)];
		[label setText:NSLocalizedString(@"shareHelpTextDB06", nil)];
		[label setNumberOfLines:0];
		[label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = 2;
		[scrollview01 addSubview:label];
		[label release];
		pos += 21 * (line + 1);
		
		line = 3;
		label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 21 * line)];
		[label setText:NSLocalizedString(@"shareHelpTextDB07", nil)];
		[label setNumberOfLines:0];
		[label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = 2;
		[scrollview01 addSubview:label];
		[label release];
		pos += 21 * (line + 1);
		
		line = 2;
		label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 21 * line)];
		[label setText:NSLocalizedString(@"shareHelpTextDB08", nil)];
		[label setNumberOfLines:0];
		[label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = 2;
		[scrollview01 addSubview:label];
		[label release];
		pos += 21 * (line + 1);
		
		line = 3;
		label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 21 * line)];
		[label setText:NSLocalizedString(@"shareHelpTextDB09", nil)];
		[label setNumberOfLines:0];
		[label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = 2;
		[scrollview01 addSubview:label];
		[label release];
		pos += 21 * (line + 1);
		
		line = 3;
		label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 21 * line)];
		[label setText:NSLocalizedString(@"shareHelpTextDB10", nil)];
		[label setNumberOfLines:0];
		[label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = 2;
		[scrollview01 addSubview:label];
		[label release];
		pos += 21 * (line + 1);
		
		line = 4;
		label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 21 * line)];
		[label setText:NSLocalizedString(@"shareHelpTextDB11", nil)];
		[label setNumberOfLines:0];
		[label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = 2;
		[scrollview01 addSubview:label];
		[label release];
		pos += 21 * (line + 1);
		
		line = 3;
		label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 21 * line)];
		[label setText:NSLocalizedString(@"shareHelpTextDB12", nil)];
		[label setNumberOfLines:0];
		[label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = 2;
		[scrollview01 addSubview:label];
		[label release];
		pos += 21 * (line + 1);
		
		line = 4;
		label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 21 * line)];
		[label setText:NSLocalizedString(@"shareHelpTextDB13", nil)];
		[label setNumberOfLines:0];
		[label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = 2;
		[label setTextColor:[UIColor redColor]];
		[scrollview01 addSubview:label];
		[label release];
		pos += 21 * (line + 1);
		
		line = 4;
		label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 21 * line)];
		[label setText:NSLocalizedString(@"shareHelpTextDB14", nil)];
		[label setNumberOfLines:0];
		[label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = 2;
		[label setTextColor:[UIColor redColor]];
		[scrollview01 addSubview:label];
		[label release];
		pos += 21 * (line + 1);
		
		line = 3;
		label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftMargin, pos, labelWidth, 21 * line)];
		[label setText:NSLocalizedString(@"shareHelpTextDB15", nil)];
		[label setNumberOfLines:0];
		[label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = 2;
		[label setTextColor:[UIColor redColor]];
		[scrollview01 addSubview:label];
		[label release];
		pos += 21 * (line + 1);
		
		[scrollview01 setContentSize:CGSizeMake(frameWidth, pos)];
		
	}
}


- (void)dealloc
{
    self.scrollview01 = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(BOOL)checkRotate {
	BOOL portrait = YES;
    //	if(rect.size.width > rect.size.height) {
    //		portrait = NO;
    //	}
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            portrait = YES;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            portrait = NO;
            break;
        default:
            portrait = YES;
    }
    return portrait;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//	CGRect rect = [[UIScreen mainScreen]applicationFrame];
    BOOL Rotate = [self checkRotate];
	[self setDisplay:Rotate];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.scrollview01 = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ![RootPane isRotationLocked];
}

@end
