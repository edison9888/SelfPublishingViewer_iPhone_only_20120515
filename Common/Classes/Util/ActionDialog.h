//
//  ActionDialog.h
//  ForIphone
//  ActionSheetのblock版
//  Created by 藤田正訓 on 11/07/27.
//  Copyright 2011 SAT. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ActionDialog : UIActionSheet<UIActionSheetDelegate> {
    @private
    void (^onSelected)(NSInteger index);
}

-(id)initWithTitle:(NSString *)title 
          callback:(void (^)(NSInteger index))onSelectCallback
 cancelButtonTitle:(NSString *)cancelButtonTitle 
destructiveButtonTitle:(NSString *)destructiveButtonTitle 
 otherButtonTitles:(NSArray*)buttonTitles ;

- (id)initWithTitle:(NSString *)title 
           callback:(void (^)(NSInteger))onSelectCallback 
  otherButtonTitles:(NSArray *)buttonTitles;


@end
