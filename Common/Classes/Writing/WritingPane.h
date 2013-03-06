//
//  WritingPane.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/12.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Viewable.h"
#import "OtherEffectsPane.h"
#import "MosaicViewController.h"

@class WritingMode;
@class UndoBuffer;
@class PageMemo;
@class TouchPanGestureRecognizer;

@protocol WritingPaneDelegate

-(void)writingDone:(UIImage*)img;

@end


@interface WritingPane : UIViewController<UITabBarDelegate, UIActionSheetDelegate, UIAlertViewDelegate, MosaicViewControllerDelegate> {
    @private
    UITabBar* topBar;
    UITabBar* bottomBar;
    UIButton* doneButton;
    UIView* doneButtonBase;
    
    UIButton* showToolbarButton;
    
    UITabBarItem* settingButton;
    UITabBarItem* selectButton;
    UITabBarItem* stampButton;
    UITabBarItem* memoButton;
    UITabBarItem* pictureButton;
    UITabBarItem* undoButton;
    UITabBarItem* redoButton;
    UITabBarItem* drawButton;
    UITabBarItem* eraseButton;
    UITabBarItem* deleteButton;
    UITabBarItem* hideButton;
    
    UIButton* undoButton2;
    
    // 下敷き
    UIView* contentView;
    // 背景画像
    UIImageView* imageView;
    // 書き込み画面
    UIView* canvas;
    // テンポラリ書き込み用
    CALayer* layer;
    // データソース
    NSObject<Viewable>* book;
    NSInteger page;
    // 操作モード
    WritingMode* mode;
    // アンドゥ用
    UndoBuffer* undoBuffer;
    // ゼスチャー
    UITapGestureRecognizer* tapr;
    UIPinchGestureRecognizer* pinchr;
    TouchPanGestureRecognizer* panr;
    UIImage* initialImage;
    
    // 拡大縮小の中心点
    CGPoint zoomCenter;
    // 拡大率
    CGFloat beginScale;
    // 前回の拡大率
    CGFloat lastScale;
    // つかんだ位置
    CGPoint grabPoint;
    CGPoint beginLocation;
    BOOL isPortrait;
    
    BOOL inDrawing;
    BOOL scrolling;
    BOOL zooming;
    BOOL effectAdded;
    
    PageMemo* pageMemo;
    
    NSObject<WritingPaneDelegate>* delegate;
    OtherEffectsPane * otherEffects;
    MosaicViewController * mosaic;
    BOOL initialized;
    
    NSMutableDictionary* loadedModes;
    
    UIActionSheet *     _actionSheet;
    UIAlertView *       _alertView;
    
}

@property(nonatomic,retain)IBOutlet UITabBar* topBar;
@property(nonatomic,retain)IBOutlet UITabBar* bottomBar;
@property(nonatomic,retain)IBOutlet UIButton* doneButton;
@property(nonatomic,retain)IBOutlet UIView* doneButtonBase;

@property(nonatomic,retain)IBOutlet UIButton* showToolbarButton;

@property(nonatomic,retain)IBOutlet UITabBarItem* settingButton;
@property(nonatomic,retain)IBOutlet UITabBarItem* selectButton;
@property(nonatomic,retain)IBOutlet UITabBarItem* stampButton;
@property(nonatomic,retain)IBOutlet UITabBarItem* memoButton;
@property(nonatomic,retain)IBOutlet UITabBarItem* pictureButton;
@property(nonatomic,retain)IBOutlet UITabBarItem* undoButton;
@property(nonatomic,retain)IBOutlet UITabBarItem* redoButton;
@property(nonatomic,retain)IBOutlet UITabBarItem* drawButton;
@property(nonatomic,retain)IBOutlet UITabBarItem* eraseButton;
@property(nonatomic,retain)IBOutlet UITabBarItem* deleteButton;
@property(nonatomic,retain)IBOutlet UITabBarItem* hideButton;
@property(nonatomic,retain)IBOutlet UIButton* undoButton2;
@property(nonatomic,retain)IBOutlet UIView* contentView;
@property(nonatomic,retain)IBOutlet UIImageView* imageView;
@property(nonatomic,retain)IBOutlet UIView* canvas;



@property(nonatomic,retain)UIImage* initialImage;
@property(nonatomic,readonly)CALayer* layer;
@property(nonatomic,assign)NSObject<WritingPaneDelegate>* delegate;
@property(nonatomic,readonly)BOOL inDrawing;

-(void)setBookPage:(NSObject<Viewable>*)b page:(NSInteger)p;
-(IBAction)showToolbars;
-(IBAction)hideToolbars;
-(void)hideToolbars:(BOOL)absolute;
-(IBAction)undo;
-(IBAction)back;
- (IBAction)doneSelect:(id)sender;
-(void)undoEnable:(BOOL)enable;
// 描画コンテキストを開始する
-(CGContextRef)beginDrawing;
// 描画コンテキストを終了する
-(void)endDrawing;
-(void)addImage:(UIImage *) img;
-(void)showAttachmentPane;
-(void)openMosaic;

@end
