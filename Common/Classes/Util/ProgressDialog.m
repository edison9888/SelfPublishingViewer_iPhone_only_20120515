//
//  ProgressDialog.m
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/22.
//  Copyright 2011 SAT. All rights reserved.
//

#import "ProgressDialog.h"
#import "common.h"


@implementation ProgressDialog
@synthesize progressView, alertView, activityIndicator;

- (id)initWithCallback:(void (^)())onCancelCallback {
    self = [super init];
    if (self) {
        onCancel = [onCancelCallback copy];
    }
    return self;
}


- (void)dealloc {
    [onCancel release];
    [super dealloc];
}

// プログレスバーの値を設定する
- (void)setProgress:(CGFloat)progress 
{
    progressView.progress = progress;
}
// プログレスバーの値を返す
- (CGFloat) progress 
{
    return progressView.progress;
}

// 
- (void)alertView:(UIAlertView *)av didDismissWithButtonIndex:(NSInteger)buttonIndex {
    alertView.delegate = nil;
    progressView = nil;
    activityIndicator = nil;
    alertView = nil;
    if (buttonIndex == 0) {
        if (onCancel) {
            onCancel();
        }
    }
}

// キャンセルイベントを起こして消す
-(IBAction)cancel {
    if (alertView.visible) {
        [alertView dismissWithClickedButtonIndex:0 animated:NO];
        alertView = nil;
        [onCancel release];
        onCancel = nil;

    }
}


// キャンセルイベントを起こさず消す
- (void)dismiss {
    if (alertView.visible) {
        alertView.delegate = nil;
        [alertView dismissWithClickedButtonIndex:1 animated:NO];
        alertView = nil;
        [onCancel release];
        onCancel = nil;

    }
}

// UIAlertViewを生成する
- (UIAlertView*)createAlertView:(NSString*)title
                        message:(NSString*)message {
    message = message ? message : @"";
    message = [message stringByAppendingString:@"\n\n"];
    UIAlertView* av = [[UIAlertView alloc]
                       initWithTitle:@"" 
                       message:message
                       delegate:self 
                       cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                       otherButtonTitles:nil, nil];
    progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityIndicator startAnimating];
    progressView.progress = 0;
    alertView = av;
    activityIndicator.frame = CGRectMake(240,25,30,30);
    progressView.frame = CGRectMake(20,10,240,30);

    [av addSubview:progressView];
    [av addSubview:activityIndicator];
    [progressView release];
    return av;
}

// AlertView表示前にサイズの調整
-(void)willPresentAlertView:(UIAlertView *)av {
    for (UIView* v in [av subviews]) {
        NSString *className = NSStringFromClass([v class]);
        if ([className isEqualToString:(@"UIThreePartButton")]) {
            // ボタンの上につける
            CGRect r = v.frame;
            r.origin.y -= r.size.height / 2;
            progressView.frame = r;
            break;
        }
        
    }
}




// プログレスをポップオーバーで表示する
+(ProgressDialog*)show: (NSString*)title
               message:(NSString*)message
              onCancel:(void (^)())onCancelCallback 
{
    ProgressDialog* pd = [[ProgressDialog alloc]initWithCallback:onCancelCallback];
    UIAlertView* alert = [pd createAlertView:title message:message];
    [alert show];
    //[alert release];
    return [pd autorelease];
}

@end
