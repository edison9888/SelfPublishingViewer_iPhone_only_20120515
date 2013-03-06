//
//  ImagePickDialog.m
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/26.
//  Copyright 2011 SAT. All rights reserved.
//

#import "ImagePickDialog.h"
#import "AppUtil.h"
#import "ImageUtil.h"
#import "common.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "RootPane.h"
#import "FileUtil.h"
#import "LoadingView.h"


@implementation ImagePickDialog
@synthesize popc,ipc,sourceType;
// 初期化
- (id)initWithCallback:(void(^)(UIImage* img))onSelectCallback {
    self = [super init];
    if (self) {
        onSelected = [onSelectCallback copy];
    }
    return self;
}

+ (ImagePickDialog*)showPopoverInner:(void(^)(UIImage* img))onSelectCallback
                            fromRect:(CGRect)fromRect
                   fromBarButtonItem:(UIBarButtonItem*)button
                              inView:(UIView*)inView 
                              source:(UIImagePickerControllerSourceType)source
                         multiselect:(BOOL)multiselect
{
    ImagePickDialog* ipd = [[ImagePickDialog alloc]initWithCallback:onSelectCallback];
    if ([UIImagePickerController isSourceTypeAvailable:source]) {
        UIImagePickerController* ipc = nil;
        
        if (source == UIImagePickerControllerSourceTypePhotoLibrary && multiselect) {
            ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] initWithNibName:@"ELCAlbumPickerController" bundle:[NSBundle mainBundle]];    
            ipc = [[[ELCImagePickerController alloc]initWithRootViewController:albumController]autorelease];
            [albumController setParent:ipc];
            [ipc setDelegate:ipd];
            [albumController release];
        } else {
            ipc = [[[UIImagePickerController alloc]init]autorelease];
            ipc.delegate = ipd;
            ipc.sourceType = source;
        }
        ipd.ipc = ipc;
        ipd.sourceType = source;
        //ipc.allowsEditing = YES;
        
        RootPane* rp = [RootPane instance];
        if (source == UIImagePickerControllerSourceTypeCamera) {
            if ([AppUtil isForIpad]) {
                // iPadでCameraは無理やり全画面表示する
                [rp presentModalViewController:ipc animated:YES];
            } else {
                // iPhoneでCameraはメモリ食うのでnavigation
//                [rp pushPane:ipc];
                [rp presentModalViewController:ipc animated:YES];
                
            }
            
        } else {
            if ([AppUtil isForIpad]) {
                // カメラ以外でiPad
                UIPopoverController* popc = [[UIPopoverController alloc]initWithContentViewController:ipc];
                if (button) {
                    [popc presentPopoverFromBarButtonItem:button
                                 permittedArrowDirections:UIPopoverArrowDirectionAny
                                                 animated:YES];
                } else {
                    [popc presentPopoverFromRect:fromRect
                                          inView:inView
                        permittedArrowDirections:UIPopoverArrowDirectionAny
                                        animated:YES];
                }
                ipd.popc = popc;
                
            } else {
                // カメラ以外でiPhone
                [rp presentModalViewController:ipc animated:YES];
            }
            
        }
    } else {
        NSLog(@"%s - イメージソースが使えない", __func__);
    }
    return [ipd autorelease];
}

// ポップオーバーを表示する
+ (ImagePickDialog*)showCameraPopover:(void (^)(UIImage *))onSelectCallback 
                  fromBarButton:(UIBarButtonItem*)button
                         inView:(UIView *)inView {
    return [self showPopoverInner:onSelectCallback
                         fromRect:CGRectMake(0, 0, 0, 0)
                fromBarButtonItem:button
                           inView:inView
                           source:UIImagePickerControllerSourceTypeCamera
                      multiselect:NO];
}
// ポップオーバーを表示する
+ (ImagePickDialog*)showCameraPopover:(void(^)(UIImage* img))onSelectCallback
                       fromRect:(CGRect)fromRect
                         inView:(UIView*)inView {
    return [self showPopoverInner:onSelectCallback
                         fromRect:fromRect
                fromBarButtonItem:nil
                           inView:inView
                           source:UIImagePickerControllerSourceTypeCamera
                      multiselect:NO];    
}



// ポップオーバーを表示する
+ (ImagePickDialog*)showPopover:(void (^)(UIImage *))onSelectCallback 
                  fromBarButton:(UIBarButtonItem*)button
                         inView:(UIView *)inView {
    return [self showPopoverInner:onSelectCallback
                         fromRect:CGRectMake(0, 0, 0, 0)
                fromBarButtonItem:button
                           inView:inView
                           source:UIImagePickerControllerSourceTypePhotoLibrary
                      multiselect:NO];
}

// ポップオーバーを表示する
+ (ImagePickDialog*)showPopover:(void(^)(UIImage* img))onSelectCallback
                       fromRect:(CGRect)fromRect
                         inView:(UIView*)inView {
    return [self showPopoverInner:onSelectCallback
                         fromRect:fromRect
                fromBarButtonItem:nil
                           inView:inView
                           source:UIImagePickerControllerSourceTypePhotoLibrary
                      multiselect:NO];    
}


// ポップオーバーを表示する
+ (ImagePickDialog*)showMultiselectPopover:(void (^)(UIImage *))onSelectCallback 
           fromBarButton:(UIBarButtonItem*)button
             inView:(UIView *)inView {
    return [self showPopoverInner:onSelectCallback
                         fromRect:CGRectMake(0, 0, 0, 0)
                fromBarButtonItem:button
                           inView:inView
                           source:UIImagePickerControllerSourceTypePhotoLibrary
                      multiselect:YES];
}

// ポップオーバーを表示する
+ (ImagePickDialog*)showMultiselectPopover:(void(^)(UIImage* img))onSelectCallback
           fromRect:(CGRect)fromRect
                         inView:(UIView*)inView {
    return [self showPopoverInner:onSelectCallback
                         fromRect:fromRect
                fromBarButtonItem:nil
                           inView:inView
                           source:UIImagePickerControllerSourceTypePhotoLibrary
                      multiselect:YES];    
}


-(CGPoint)calcDrawPoint:(CGSize*)imgSize {
    CGSize scSize = [UIScreen mainScreen].bounds.size;
    CGPoint p = CGPointMake(0, 0);
    if ((int)scSize.width * 3 == (int)scSize.height * 2) {
        // iPhoneで画面縦横比3:2の場合
        CGFloat vhr = (*imgSize).width / (*imgSize).height;
        if (1.32f <= vhr && vhr <= 1.34f) {
            // 4:3横長の場合、上下を切る
            CGFloat dy = (*imgSize).height / 24.0f;
            p.y = -dy;
            (*imgSize).height *= (11.0f / 12.0f);
            
        } else if (0.74f <= vhr && vhr <= 0.77f) {
            // 3:4縦長の場合、左右を切る
            CGFloat dx = (*imgSize).width / 24.0f;
            p.x = -dx;
            (*imgSize).width *= (11.0f / 12.0f);
        }
    }
    
    return p;
}

// 画像が選択された
-(void)imagePickerController:(UIImagePickerController *)picker 
       didFinishPickingImage:(UIImage *)image
                 editingInfo:(NSDictionary *)info {
    if (onSelected) {
        LoadingView* lv = [LoadingView show:nil];
        
        // あまりに大きい画像を縮小する
        CGSize imgSize = image.size;
        CGFloat mag = 1;
        if (imgSize.width > CAMERA_IMAGESIZE_LIMIT || imgSize.height > CAMERA_IMAGESIZE_LIMIT) {
            mag = fminf(CAMERA_IMAGESIZE_LIMIT / imgSize.height, CAMERA_IMAGESIZE_LIMIT / imgSize.width);
            imgSize.width *= mag;
            imgSize.height *= mag;
        }
        // 4:3の画像がスクリーンに合わない場合、端をトリムする
        CGPoint drawPoint = [self calcDrawPoint:&imgSize];
//        NSLog(@"%0.0f,%0.0f / %0.0f,%0.0f %s", drawPoint.x, drawPoint.y, imgSize.width, imgSize.height, __func__);
        
        
        // カメラで撮影した画像の縦横がおかしかったりするので補正する
        UIGraphicsBeginImageContext(imgSize);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(ctx, mag, mag);
        [image drawInRect:CGRectMake(drawPoint.x, drawPoint.y, image.size.width, image.size.height)];
        UIImage* ret = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        onSelected(ret);
        
        [lv dismiss];
    }
    [self dismiss];
}



- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    LoadingView* lv = [LoadingView show:nil];
	for(NSDictionary *dict in info) {
        UIImage* image = [dict objectForKey:UIImagePickerControllerOriginalImage];
        // 画像を縮小する
        CGSize imgSize = image.size;
        CGFloat mag = 1;
        if (imgSize.width > CAMERA_IMAGESIZE_LIMIT || imgSize.height > CAMERA_IMAGESIZE_LIMIT) {
            mag = fminf(CAMERA_IMAGESIZE_LIMIT / imgSize.height, CAMERA_IMAGESIZE_LIMIT / imgSize.width);
            imgSize.width *= mag;
            imgSize.height *= mag;
        }
        // 4:3の画像がスクリーンに合わない場合、端をトリムする
        CGPoint drawPoint = [self calcDrawPoint:&imgSize];
        
        // カメラ画像の縦横がおかしかったりするので補正する
        UIGraphicsBeginImageContext(imgSize);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        if (mag != 1) {
            CGContextScaleCTM(ctx, mag, mag);
        }
        [image drawInRect:CGRectMake(drawPoint.x, drawPoint.y, image.size.width, image.size.height)];
        UIImage* imgToProc = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        onSelected(imgToProc);
	}
    [lv dismiss];
    [self dismiss];
}


- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {    
    [self dismiss];
}



-(BOOL)visible {
    if ([AppUtil isForIpad]) {
        return [self.popc isPopoverVisible];
    } else {
        UIViewController* rp = [AppUtil rootViewController];
        return [rp isModalInPopover];
    }
}


// ポップオーバーを消す
- (void)dismiss {
    RootPane* rp = [RootPane instance];
    if (self.popc) {
        [self.popc dismissPopoverAnimated:YES];
        self.popc = nil;
    } else if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        //[rp popPane];
        [rp dismissModalViewControllerAnimated:YES];
        
    } else {
        [rp dismissModalViewControllerAnimated:YES];
    }
}



-(void)dealloc {
    self.popc = nil;
    [onSelected release];
    [super dealloc];
}


@end
