//
//  OtherEffectsPane.m
//  ForIphone
//
//  Created by Lionel Seidman on 2/29/12.
//  Copyright (c) 2012 SAT. All rights reserved.
//

#import "OtherEffectsPane.h"

@implementation OtherEffectsPane

@synthesize writingPane;


-(IBAction)showAttachmentPane:(id)sender{
    [writingPane showAttachmentPane];
}

-(IBAction)openMosaic:(id)sender{
    
    MosaicViewController * mosaic = [[MosaicViewController alloc] init];
    [writingPane openMosaic:mosaic];
    [[self navigationController] pushViewController:mosaic animated:YES];
    [mosaic release];
}

-(IBAction)goBack:(id)sender{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    
    for (UIButton * b in [NSArray arrayWithObjects:mosaicButton, attachmentButton, nil]) {
        if ([b class] == [UIButton class]) {
            b.layer.cornerRadius = 4.0f;
            b.layer.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f].CGColor;
            b.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
            b.layer.shadowRadius = 5.0f;
        }
    }
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;// for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
