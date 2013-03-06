//
//  AlertDialog.h
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/18.
//  Copyright 2011 SAT. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AlertDialog : NSObject<UIAlertViewDelegate> {
    @private
    void (^onOK)();
    void (^onOKPrompt)(NSString* str);
    void (^onCancel)();
    BOOL isAlert;
    UITextField* textField;
}
@property(nonatomic,assign) UITextField* textField;

- (id)initWithCallbacks: (void (^)())onOKCallback :(void (^)())onCancelCallback :(BOOL)alert;
- (id)initWithPromptCallbacks: (void (^)(NSString* str))onOKCallback :(void (^)())onCancelCallback;


// アラートダイアログを表示する
+ (void)alert:(NSString*)title 
      message:(NSString*)message 
         onOK:(void (^)())onOKCallback;

// 確認ダイアログを表示する
+ (void)confirm:(NSString*)title
        message:(NSString*)message
           onOK:(void (^)())onOKCallback;

// 確認ダイアログを生成する
+ (void)confirm:(NSString*)title 
        message:(NSString*)message 
           onOK:(void (^)())onOKCallback
       onCancel:(void (^)())onCancelCallback;

// 確認ダイアログを生成する
+ (void)confirm:(NSString*)title
        message:(NSString*)message
           onOK:(void (^)())onOKCallback
       onCancel:(void (^)())onCancelCallback
        okLabel:(NSString*)okLabel
    cancelLabel:(NSString*)cancelLabel;



// テキスト入力プロンプトを生成する
+ (void)prompt:(NSString*)title
       message:(NSString*)message
          onOK:(void (^)(NSString* str))onOKCallback
      onCancel:(void(^)())onCancelCallback;

// テキスト入力プロンプトを生成する
+ (void)prompt:(NSString*)title
       message:(NSString*)message
       initial:(NSString*)initial
          onOK:(void (^)(NSString* str))onOKCallback
      onCancel:(void(^)())onCancelCallback;

@end
