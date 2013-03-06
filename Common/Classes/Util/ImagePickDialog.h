//
//  ImagePickDialog.h
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/26.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePickDialog : NSObject<UINavigationControllerDelegate,
UIImagePickerControllerDelegate> {
@private
    void (^onSelected)(UIImage* img);
    UIPopoverController* popc;
    UIImagePickerController* ipc;
    UIImagePickerControllerSourceType sourceType;
    
}
@property(nonatomic,retain)UIImagePickerController* ipc;
@property(nonatomic,assign)UIImagePickerControllerSourceType sourceType;
@property(nonatomic,retain) UIPopoverController* popc;
@property(readonly) BOOL visible;

// 初期化
- (id)initWithCallback:(void(^)(UIImage* img))onSelectCallback;
// ポップオーバーを消す
- (void)dismiss;

// ポップオーバーを表示する
+ (ImagePickDialog*)showCameraPopover:(void (^)(UIImage *))onSelectCallback 
                  fromBarButton:(UIBarButtonItem*)button
                         inView:(UIView *)inView;

// ポップオーバーを表示する
+ (ImagePickDialog*)showCameraPopover:(void(^)(UIImage* img))onSelectCallback
                       fromRect:(CGRect)fromRect
                         inView:(UIView*)inView;

// ポップオーバーを表示する
+ (ImagePickDialog*)showPopover:(void (^)(UIImage *))onSelectCallback 
                  fromBarButton:(UIBarButtonItem*)button
                         inView:(UIView *)inView;

// ポップオーバーを表示する
+ (ImagePickDialog*)showPopover:(void(^)(UIImage* img))onSelectCallback
                       fromRect:(CGRect)fromRect
                         inView:(UIView*)inView;

// ポップオーバーを表示する
+ (ImagePickDialog*)showMultiselectPopover:(void (^)(UIImage *))onSelectCallback 
      fromBarButton:(UIBarButtonItem*)button
             inView:(UIView *)inView;

// ポップオーバーを表示する
+ (ImagePickDialog*)showMultiselectPopover:(void(^)(UIImage* img))onSelectCallback
           fromRect:(CGRect)fromRect
             inView:(UIView*)inView;



@end
