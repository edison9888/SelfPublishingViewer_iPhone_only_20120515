//
//  PEDrawPresentViewController.m
//  PEEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import "PEDrawPresentViewController.h"
#import "PEAddTextViewController.h"

@implementation PEDrawPresentViewController

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
    

    // Do any additional setup after loading the view from its nib.
}
- (void)viewDidAppear:(BOOL)animated;{
    PEAddTextViewController *_addTxtController = [[PEAddTextViewController alloc] initWithNibName:@"PEAddTextViewController" bundle:nil];
    //self.addTextViewController  = _addTxtController;
    //[_addTxtController release];
    //_addTxtController=nil;
    [self presentModalViewController:_addTxtController animated:YES];
    }
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
