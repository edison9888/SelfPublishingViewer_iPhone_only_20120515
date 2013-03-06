//
//  DocumentViewerPane.h
//  ForIphone
//
//  Created by Lionel Seidman on 12/2/24.
//  Copyright (c) 2012 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DocumentViewerPane : UIViewController <UIWebViewDelegate>{
    IBOutlet UIActivityIndicatorView * spinner;
    BOOL translatorOpened;
}

@property (nonatomic, retain) IBOutlet UIWebView * docContent;
@property (nonatomic, retain) IBOutlet UINavigationBar * docTitle;
@property (nonatomic, retain) NSString * fileURL;
@property BOOL isDoc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
-(IBAction)closeViewer:(id)sender;
- (void)webViewDidFinishLoad:(UIWebView *)webView;
- (void)webViewDidStartLoad:(UIWebView *)webView;
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
- (BOOL)shouldShowTranslateButton;
- (IBAction)openTranslator;
- (IBAction)hideTranslator;

@end