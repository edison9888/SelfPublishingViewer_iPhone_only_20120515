//
//  FileSelector.h
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/22.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

@interface FileSelector : UIViewController<UITableViewDelegate,UITableViewDataSource> {
    @private
    void (^onSelected)(Book* b);
    void (^onCancel)();
    UIBarButtonItem* cancelButton;
    UIView* membrane;
    UIPopoverController* pop;
    NSString* message;
    IBOutlet UITableView* table;
}

@property(nonatomic,retain) IBOutlet UIBarButtonItem* cancelButton;


// 選択時に呼ばれるコールバックを指定して生成する
- (id)initWithCallback:(NSString*)message
              onSelect:(void(^)(Book* b))callback 
              onCancel:(void(^)())onCancelCallback; 

// ポップオーバーで表示する
+ (FileSelector*)showPopover: (NSString*)message 
                    onSelected:(void (^)(Book* b))onSelectCallback
                    onCancel:(void(^)())onCancelCallback
                    fromRect:(CGRect)fromRect
                    animated:(BOOL)animated;

// ポップオーバーで表示する
- (void)showPopover: (NSString*)message
           fromRect:(CGRect)fromRect
           animated:(BOOL)animated;

// キャンセルしてポップオーバーを消す
- (IBAction)cancel;
// ポップオーバーを消す
- (void)dismiss;


@end
