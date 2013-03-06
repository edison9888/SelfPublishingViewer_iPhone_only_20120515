//
//  TextAlertView.m
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/26.
//  Copyright 2011 SAT. All rights reserved.
//


/*
 * Text Alert View
 *
 * File: TextAlertView.m
 * Abstract: UIAlertView extension with UITextField (Implementation).
 *
 */

#import "TextAlertView.h"
#import "AppUtil.h"

@implementation TextAlertView

@synthesize textField;

/*
 * Initialize view with maximum of two buttons
 */
- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate 
  cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle
              otherButtonTitles:otherButtonTitles, nil];
    if (self) {
        if ([AppUtil isIOSFive]) {
            [self setAlertViewStyle:UIAlertViewStylePlainTextInput];
            return self;
        }
        
        /*
        CGRect entryFieldRect = CGRectZero;
        if( UIDeviceOrientationIsPortrait( [UIApplication sharedApplication].statusBarOrientation ) ) {
            entryFieldRect = CGRectMake(12, 90, 260, kUITextFieldHeight);
        }
        else {
            entryFieldRect = CGRectMake(12, 72, 260, kUITextFieldHeight);
        }
         */

        // Create and add UITextField to UIAlertView
        UITextField *myTextField = [[[UITextField alloc] initWithFrame:CGRectZero] retain];
        myTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        //myTextField.alpha = 0.75;
        myTextField.borderStyle = UITextBorderStyleRoundedRect;
        myTextField.delegate = delegate;
        [self setTextField:myTextField];
        // insert UITextField before first button
        //BOOL inserted = NO;
    
        //for( UIView *view in self.subviews ){
         //   if(!inserted && ![view isKindOfClass:[UILabel class]])
         //       [self insertSubview:myTextField aboveView:view];
        //}
        
        [self addSubview:textField];
        // ensure that layout for views is done once
        layoutDone = NO;
        CGRect frm = [self frame];
        frm.size.height += kUITextFieldHeight + 2.0;
        [self setFrame:frm];
        // add a transform to move the UIAlertView above the keyboard
        //CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 10);
        //[self setTransform:myTransform];
    }
    return self;
}

/*
 * Show alert view and make keyboard visible
 */
- (void) show {
    [super show];
    if (![AppUtil isIOSFive]) {
        [[self textField] becomeFirstResponder];
    }
}

/*
 * Determine maximum y-coordinate of UILabel objects. This method assumes that only
 * following objects are contained in subview list:
 * - UILabel
 * - UITextField
 * - UIThreePartButton (Private Class)
 */
- (CGFloat) maxLabelYCoordinate {
    // Determine maximum y-coordinate of labels
    CGFloat maxY = 0;
    for( UIView *view in self.subviews ){
        if([view isKindOfClass:[UILabel class]]) {
            CGRect viewFrame = [view frame];
            CGFloat lowerY = viewFrame.origin.y + viewFrame.size.height;
            if(lowerY > maxY)
                maxY = lowerY;
        }
    }
    return maxY;
}

/*
 * Override layoutSubviews to correctly handle the UITextField
 */

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ([AppUtil isIOSFive]) {
        return;
    }    
    CGRect frame = [self frame];
    //CGFloat alertWidth = frame.size.width;
    // Perform layout of subviews just once
    //if(!layoutDone) {
        //CGFloat labelMaxY = [self maxLabelYCoordinate];
        
        // Insert UITextField below labels and move other fields down accordingly
        for(UIView *view in self.subviews){
            NSString *viewClassName = NSStringFromClass([view class]);
            if([view isKindOfClass:[UITextField class]]){
                
                CGRect entryFieldRect = CGRectZero;
                if( UIDeviceOrientationIsPortrait( [UIApplication sharedApplication].statusBarOrientation ) ) {
                    entryFieldRect = CGRectMake(kUITextFieldXPadding, 75, 260, kUITextFieldHeight);
                    }
                else {
                    entryFieldRect = CGRectMake(kUITextFieldXPadding, 58, 260, kUITextFieldHeight);
                    //CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 0.0);
                    //[self setTransform:myTransform];              
                }
                
                /* CGRect viewFrame = CGRectMake(
                                              kUITextFieldXPadding, 
                                              labelMaxY + kUITextFieldYPadding, 
                                              alertWidth - 4.6*kUITextFieldXPadding, 
                                              kUITextFieldHeight); */
                [view setFrame:entryFieldRect];
            } else if([viewClassName isEqualToString:@"UIThreePartButton"]) {
                
                CGRect viewFrame = [view frame];
                viewFrame.origin.y += kUITextFieldHeight;
                [view setFrame:viewFrame];
            }
        }
        
        // size UIAlertView frame by height of UITextField
        frame.size.height += kUITextFieldHeight + 2.0;
        [self setFrame:frame];
        layoutDone = YES;
    //} else {
        // reduce the x placement and width of the UITextField based on UIAlertView width
      //  for(UIView *view in self.subviews){
        //    if([view isKindOfClass:[UITextField class]]){
         //       CGRect viewFrame = [view frame];
          //      viewFrame.origin.x = kUITextFieldXPadding;
           //     viewFrame.size.width = alertWidth - 4.6*kUITextFieldXPadding;
            //    [view setFrame:viewFrame];
            //}
        //}
    //}
    
   
}
 

@end