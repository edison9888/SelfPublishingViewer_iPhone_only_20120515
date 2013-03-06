//
//  WebViewPopUp.m
//  I am Live
//
//  Created by openxcell121 on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WebViewPopUp.h"

@implementation WebViewPopUp

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

- (void)dealloc {
    [super dealloc];
}
- (IBAction)closeBtn:(id)sender {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=FALSE;
    
    self.view.frame = CGRectMake(0, 20, 320, 460);
    [UIView animateWithDuration:.5f animations:^{
        self.view.frame = CGRectMake(0, 480, 320, 460);
    } completion:^(BOOL finished) {
 //       [self.view removeFromSuperview];
          [self dismissModalViewControllerAnimated:YES];
    }];
    

    
}
@end
