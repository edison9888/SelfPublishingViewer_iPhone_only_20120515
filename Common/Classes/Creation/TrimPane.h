//
//  TrimPane.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/07/27.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ImagePickDialog.h"
#import "TrimFrameView.h"
#import "WritingPane.h"
#import "LoadingView.h"

@protocol TrimPaneDelegate

-(void)imageSaved:(UIImage*)img;

@end


@interface TrimPane : UIViewController<UITabBarDelegate, WritingPaneDelegate> {
    UIButton* nw;
    UIButton* ne;
    UIButton* sw;
    UIButton* se;
    UIButton* reflectionButton;
    UIView* trimmingView;
    UIView* canvas;
    UIScrollView* scrollView;
    TrimFrameView* frameView;
    UISlider* contrastSlider;
    UISlider* resolutionSlider;
    UIButton* monoButton;
    UIButton* bwButton;
    
    UIView* eventView;
    UILabel* contrastTitleLabel;
    UILabel* contrastLabel;
    UILabel* resolutionTitleLabel;
    UILabel* resolutionLabel;
    UITabBarItem* item1;   //右回転
    UITabBarItem* item2;   //左回転
    UITabBarItem* item4;   //再撮影
    UITabBarItem* item5;   //調整
    UITabBarItem* item6;   //枠検出
    IBOutlet UIButton* cancelButton;
    LoadingView* loadingView;
    
    CALayer* bgLayer;
    CALayer* imageLayer;
    UIImage* image;
    ImagePickDialog* ipd;
    UIButton* draggingButton;
    NSObject<TrimPaneDelegate>* delegate;
    
    NSInteger rotationAngle;
}
@property(nonatomic,assign) NSObject<TrimPaneDelegate>* delegate;


@property(nonatomic,retain) IBOutlet UIButton* nw;
@property(nonatomic,retain) IBOutlet UIButton* ne;
@property(nonatomic,retain) IBOutlet UIButton* sw;
@property(nonatomic,retain) IBOutlet UIButton* se;
@property(nonatomic,retain) IBOutlet UIButton* reflectionButton;
@property(nonatomic,retain) IBOutlet UIView* trimmingView;
@property(nonatomic,retain) IBOutlet UIView* canvas;
@property(nonatomic,retain) IBOutlet UIScrollView* scrollView;
@property(nonatomic,retain) IBOutlet TrimFrameView* frameView;
@property(nonatomic,retain) IBOutlet UISlider* contrastSlider;
@property(nonatomic,retain) IBOutlet UISlider* resolutionSlider;
@property(nonatomic,retain) IBOutlet UIButton* monoButton;
@property(nonatomic,retain) IBOutlet UIButton* bwButton;

@property(nonatomic,retain) IBOutlet UIView* eventView;
@property(nonatomic,retain) IBOutlet UILabel* contrastTitleLabel;
@property(nonatomic,retain) IBOutlet UILabel* contrastLabel;
@property(nonatomic,retain) IBOutlet UILabel* resolutionTitleLabel;
@property(nonatomic,retain) IBOutlet UILabel* resolutionLabel;



@property(nonatomic,retain) IBOutlet UITabBarItem* item1;
@property(nonatomic,retain) IBOutlet UITabBarItem* item2;
@property(nonatomic,retain) IBOutlet UITabBarItem* item4;
@property(nonatomic,retain) IBOutlet UITabBarItem* item5;
@property(nonatomic,retain) IBOutlet UITabBarItem* item6;



// 画像を読み込む
- (void) setImage:(UIImage*)img;

// 決定
-(IBAction) updateImage:(UIButton*)sender;
-(IBAction) hideTrimmingView;

// ドラッグ開始
- (IBAction) startDragPoint:(UIButton*)b;

// ボタンの選択アクション
-(IBAction) toggleSelect:(UIButton*)sender;

// スライダーのイベント
-(IBAction) updateLabels;

@end
