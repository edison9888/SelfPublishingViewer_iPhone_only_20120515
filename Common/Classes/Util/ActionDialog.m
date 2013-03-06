//
//  ActionDialog.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/07/27.
//  Copyright 2011 SAT. All rights reserved.
//

#import "ActionDialog.h"
#import "AppUtil.h"


@implementation ActionDialog

// 全部入り
-(id)initWithTitle:(NSString *)title 
          callback:(void (^)(NSInteger index))onSelectCallback
 cancelButtonTitle:(NSString *)cancelButtonTitle 
destructiveButtonTitle:(NSString *)destructiveButtonTitle 
 otherButtonTitles:(NSArray*)buttonTitles {
    self = [super initWithTitle:title
                       delegate:self
              cancelButtonTitle:nil
         destructiveButtonTitle:destructiveButtonTitle
              otherButtonTitles:nil];
    if (self) {
        for (NSString* t in buttonTitles) {
            [self addButtonWithTitle:t];
        }
        onSelected = [onSelectCallback copy];
        // キャンセルボタンを後から足す
        [self addButtonWithTitle:cancelButtonTitle];
        if ([AppUtil isForIpad]) {
            [self addButtonWithTitle:nil];
        }
        NSInteger cnt = [buttonTitles count];
        if (destructiveButtonTitle) {
            cnt++;
        }
        self.cancelButtonIndex = cnt;
    }
    return self;
}

// 簡易版
- (id)initWithTitle:(NSString *)title 
           callback:(void (^)(NSInteger))onSelectCallback 
  otherButtonTitles:(NSArray *)buttonTitles {
    self = [super initWithTitle:title
                       delegate:self
              cancelButtonTitle:nil
         destructiveButtonTitle:nil
              otherButtonTitles:nil];
    if (self) {
        for (NSString* t in buttonTitles) {
            [self addButtonWithTitle:t];
        }
        // キャンセルボタンを後から足す
        [self addButtonWithTitle:NSLocalizedString(@"cancel", nil)];
        if ([AppUtil isForIpad]) {
            [self addButtonWithTitle:nil];
        }
        self.cancelButtonIndex = [buttonTitles count];
        onSelected = [onSelectCallback copy];
    }
    
    return self;
}


-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (onSelected) {
        onSelected(buttonIndex);
        [onSelected release];
        onSelected = nil;
    }
}

-(void)dealloc {
    [onSelected release];
    [super dealloc];
}

@end
