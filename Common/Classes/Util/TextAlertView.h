//
//  TextAlertView.h
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/26.
//  Copyright 2011 SAT. All rights reserved.
//

/*
 * Text Alert View
 *
 * File: TextAlertView.h
 * Abstract: UIAlertView extension with UITextField (Interface Declaration).
 *
 */

#import <UIKit/UIKit.h>

#define kUITextFieldHeight 30.0
#define kUITextFieldXPadding 12.0
#define kUITextFieldYPadding 10.0
#define kUIAlertOffset 100

@interface TextAlertView : UIAlertView {
    UITextField *textField;
    BOOL layoutDone;
}

@property (nonatomic, retain) UITextField *textField;

- (id)initWithTitle:(NSString *)title 
            message:(NSString *)message 
           delegate:(id)delegate 
  cancelButtonTitle:(NSString *)cancelButtonTitle 
  otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end