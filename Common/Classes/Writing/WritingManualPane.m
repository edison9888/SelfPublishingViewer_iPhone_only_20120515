//
//  WritingManualPane.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/16.
//  Copyright 2011 SAT. All rights reserved.
//

#import "WritingManualPane.h"
#import "AppUtil.h"
#import "NSString_Util.h"
#import "RootPane.h"

@implementation WritingManualPane

@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.webView = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)viewDidAppear:(BOOL)animated {
}

-(void)webViewDidFinishLoad:(UIWebView *)wv {
    NSString* title = [webView stringByEvaluatingJavaScriptFromString:@"document.title;"];
    self.navigationItem.title = title;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString* lang = [[NSLocale preferredLanguages]objectAtIndex:0];
    NSString* fname = [lang eq:@"ja"] ? @"memo_manual_ja.html" : @"memo_manual_en.html";
    NSString* path = [[AppUtil resPath:@"memo_manual"]addPath:fname];
    NSURL* url = [NSURL fileURLWithPath:path];
    NSURLRequest* req = [NSURLRequest requestWithURL:url];
    [webView loadRequest:req];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.webView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ![RootPane isRotationLocked];
}

@end
