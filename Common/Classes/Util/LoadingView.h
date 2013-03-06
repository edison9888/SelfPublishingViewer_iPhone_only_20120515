//
//  LoadingView.h
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/31.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView {
    @private
    UIActivityIndicatorView* indicator;
}
@property(nonatomic,readonly) UIActivityIndicatorView* indicator;
// 表示する
+ (LoadingView*)show: (UIView*)inView;
+ (LoadingView*)show: (UIView*)inView membrane:(BOOL)membraneVisible;
// 削除する
- (void)dismiss;

@end
