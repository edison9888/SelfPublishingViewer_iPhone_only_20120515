//
//  WritingManualPane.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/16.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WritingManualPane : UIViewController<UIWebViewDelegate> {
     UIWebView* webView;
}

@property(nonatomic,retain) IBOutlet UIWebView* webView;

@end
