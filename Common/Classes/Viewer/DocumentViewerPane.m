//
//  DocumentViewerPane.m
//  ForIphone
//
//  Created by Lionel Seidman on 12/2/24.
//  Copyright (c) 2012 SAT. All rights reserved.
//

#import "DocumentViewerPane.h"

@implementation DocumentViewerPane

@synthesize docContent, docTitle, fileURL, isDoc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        docContent.delegate = self;
        spinner.alpha = 0.0f;
    }
    return self;
}

-(IBAction)openTranslator{
    if (translatorOpened) {
        return;
    }
    translatorOpened = YES;
    NSString *htmlTXT = [docContent stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
    NSString * script = @"<div id='google_translate_element' align='center'></div><script>function googleTranslateElementInit() {new google.translate.TranslateElement({pageLanguage: 'auto',autoDisplay: false, layout: google.translate.TranslateElement.InlineLayout.HORIZONTAL}, 'google_translate_element');}</script><script src='http://translate.google.com/translate_a/element.js?cb=googleTranslateElementInit'></script>";
    
    //NSLog(@"htmlTXT: %@", htmlTXT);
    
    NSString * separator = @"</head><body class=\"s0\">";
    NSArray * components = [htmlTXT componentsSeparatedByString:separator];
    if ([components count] == 2) {
        NSString * newHTML = [NSString stringWithFormat:@"%@%@%@%@", [components objectAtIndex:0], separator, script, [components objectAtIndex:1]];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0],@"index.html"];   
        
        [newHTML writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];

        dispatch_async(dispatch_get_main_queue(), ^{
            [docContent loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]]];      
        });
        
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Hide Translator" style:UIBarButtonSystemItemDone target:self action:@selector(hideTranslator)];
        self.navigationItem.rightBarButtonItem = rightButton;
        [rightButton release];
        
    }
}

-(IBAction)hideTranslator{
    NSURL *url = [[NSURL alloc] initFileURLWithPath:fileURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [docContent loadRequest:request];      
    });
    translatorOpened = NO;
    
    if ([self shouldShowTranslateButton]) {
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Translate" style:UIBarButtonSystemItemDone target:self action:@selector(openTranslator)];
        self.navigationItem.rightBarButtonItem = rightButton;
        [rightButton release];
    }
}

-(BOOL)shouldShowTranslateButton{
    if (!isDoc) {
        return NO;
    }
    NSString *htmlTXT = [docContent stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
    NSString * separator = @"</head><body class=\"s0\">";
    NSArray * components = [htmlTXT componentsSeparatedByString:separator];
    if ([components count] == 2) {
        return YES;
    } else{
        NSLog(@"Translator not available.  htmlTXT: %@", htmlTXT);
    }
    return YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"finished");
    [spinner stopAnimating];
    spinner.alpha = 0.0;
    
    /*
    if (!translatorOpened && [self shouldShowTranslateButton]) {
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Translate" style:UIBarButtonSystemItemDone target:self action:@selector(openTranslator)];
        self.navigationItem.rightBarButtonItem = rightButton;
        [rightButton release];
    }*/
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"started");
    [spinner startAnimating];
    spinner.alpha = 1.0;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"document failed to load: %@", [error localizedDescription]);
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
    docContent.delegate = self;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(IBAction)closeViewer:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;//(interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
