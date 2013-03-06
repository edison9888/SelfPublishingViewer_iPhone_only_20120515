//
//  ProgressDialog.h
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/22.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProgressDialog : NSObject<UIAlertViewDelegate> {
    @private
    UIProgressView* progressView;
    UIActivityIndicatorView* activityIndicator;

    UIAlertView* alertView;
    void (^onCancel)();
}

@property(nonatomic,assign) CGFloat progress;
@property(nonatomic,readonly) UIProgressView* progressView;
@property(nonatomic,readonly) UIActivityIndicatorView* activityIndicator;

@property(nonatomic,retain) UIAlertView* alertView;

// 消す
-(void)dismiss;
// キャンセルイベントを起こす
-(void)cancel;
// 初期化
-(id)initWithCallback:(void (^)())onCancelCallback;

// プログレスをポップオーバーで表示する
+(ProgressDialog*)show: (NSString*)title
               message:(NSString*)message
              onCancel:(void (^)())onCancelCallback;

@end
