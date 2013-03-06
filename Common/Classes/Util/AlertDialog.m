//
//  AlertDialog.m
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/18.
//  Copyright 2011 SAT. All rights reserved.
//

#import "AlertDialog.h"
#import "TextAlertView.h"
#import "AppUtil.h"


@implementation AlertDialog
@synthesize textField;

- (id)initWithCallbacks: (void (^)())onOKCallback :(void (^)())onCancelCallback :(BOOL)alert {
    self = [super init];
    isAlert = alert;
    onOK = [onOKCallback copy];
    onCancel = [onCancelCallback copy];
    return self;
}

- (id)initWithPromptCallbacks: (void(^)(NSString* str))onOKCallback :(void (^)())onCancelCallback {
    self = [super init];
    onOKPrompt = [onOKCallback copy];
    onCancel = [onCancelCallback copy];
    return self;    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if (onCancel) {
            onCancel();
        } else if (isAlert && onOK) {
            onOK();
        }
    } else {
        if (onOK) {
            onOK();
        } else if (onOKPrompt) {
            if ([AppUtil isIOSFive]) {
                onOKPrompt([[alertView textFieldAtIndex:0]text]);
            }else {
                onOKPrompt(textField.text);
            }
        }
    }
    [onCancel release];
    onCancel = nil;
    [onOK release];
    onOK = nil;
    [onOKPrompt release];
    onOKPrompt = nil;
    alertView.delegate = nil;
    [self autorelease];
}




// アラートダイアログを表示する
+ (void)alert:(NSString*)title 
      message:(NSString*)message 
         onOK:(void (^)())onOKCallback {
    AlertDialog* ad = [[AlertDialog alloc]initWithCallbacks:onOKCallback :nil :YES];
    UIAlertView* alert = [[UIAlertView alloc]
                          initWithTitle:title 
                          message:message 
                          delegate:ad
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

// 確認ダイアログを表示する
+ (void)confirm:(NSString*)title
        message:(NSString*)message
           onOK:(void (^)())onOKCallback {
    AlertDialog* ad = [[AlertDialog alloc]initWithCallbacks:onOKCallback :nil :NO];
    UIAlertView* alert = [[UIAlertView alloc]
                          initWithTitle:title 
                          message:message 
                          delegate:ad
                          cancelButtonTitle:NSLocalizedString(@"cancel",nil) 
                          otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
    [alert show];
    [alert release];
}

// 確認ダイアログを生成する
+ (void)confirm:(NSString*)title 
        message:(NSString*)message 
           onOK:(void (^)())onOKCallback
       onCancel:(void (^)())onCancelCallback {
    AlertDialog* ad = [[AlertDialog alloc]initWithCallbacks:onOKCallback :onCancelCallback :NO];
    UIAlertView* alert = [[UIAlertView alloc]
                          initWithTitle:title 
                          message:message 
                          delegate:ad
                          cancelButtonTitle:NSLocalizedString(@"cancel",nil) 
                          otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
    [alert show];
    [alert release];
}

// 確認ダイアログを生成する
+ (void)confirm:(NSString*)title
        message:(NSString*)message
           onOK:(void (^)())onOKCallback
       onCancel:(void (^)())onCancelCallback
        okLabel:(NSString*)okLabel
    cancelLabel:(NSString*)cancelLabel {
    AlertDialog* ad = [[AlertDialog alloc]initWithCallbacks:onOKCallback :onCancelCallback :NO];
    UIAlertView* alert = [[UIAlertView alloc]
                          initWithTitle:title 
                          message:message 
                          delegate:ad
                          cancelButtonTitle:cancelLabel
                          otherButtonTitles:okLabel, nil];
    [alert show];
    [alert release];
    
}

// テキスト入力プロンプトを生成する
+ (void)prompt:(NSString*)title
       message:(NSString*)message
          onOK:(void (^)(NSString* str))onOKCallback
      onCancel:(void(^)())onCancelCallback {
    AlertDialog* ad = [[AlertDialog alloc]initWithPromptCallbacks:onOKCallback :onCancelCallback];
    TextAlertView* alert = [[TextAlertView alloc]
                          initWithTitle:title 
                          message:message 
                          delegate:ad
                          cancelButtonTitle:NSLocalizedString(@"cancel",nil) 
                          otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
    if ([AppUtil isIOSFive]) {
        ad.textField = [alert textFieldAtIndex:0];
    } else {
        ad.textField = alert.textField;

    }
    [alert show];
    [alert release];
}


// テキスト入力プロンプトを生成する
+ (void)prompt:(NSString*)title
       message:(NSString*)message
       initial:(NSString*)initial
          onOK:(void (^)(NSString* str))onOKCallback
      onCancel:(void(^)())onCancelCallback {
    AlertDialog* ad = [[AlertDialog alloc]initWithPromptCallbacks:onOKCallback :onCancelCallback];
    TextAlertView* alert = [[TextAlertView alloc]
                            initWithTitle:title 
                            message:message 
                            delegate:ad
                            cancelButtonTitle:NSLocalizedString(@"cancel",nil) 
                            otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
    
    if ([AppUtil isIOSFive]) {
        ad.textField = [alert textFieldAtIndex:0];
        [alert textFieldAtIndex:0].text = initial;

    } else {
        ad.textField = alert.textField;
        alert.textField.text = initial;

        
    }
    [alert show];
    [alert release];
}



- (void)dealloc {
   // NSLog(@"%s", __func__);
    [onOK release];
    [onCancel release];
    [onOKPrompt release];
    [super dealloc];
}

@end
