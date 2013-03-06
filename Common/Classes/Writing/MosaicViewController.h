//
//  MosaicViewController.h
//  Camera
//
//  Created by Shota Nakagami on 11/06/04.
//  Copyright 2011 Shota Nakagami All rights reserved.
//
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <Security/Security.h>
#import <MessageUI/MessageUI.h>

#define VWIDTH    320.0f
#define VHEIGHT   436.0f

#define VWIDTHLandscape    480.0f
#define VHEIGHTLandscape   276.0f

#define GC_WIDTH  600.0f
#define GC_HEIGHT 800.0f

#define WHITE     0
#define BLACK     1
#define RED       2
#define ORANGE    3
#define YELLOW    4
#define GREEN     5
#define CYAN      6
#define BLUE      7
#define PINK      8

#define MOSAIC1   9
#define MOSAIC2   10
#define MOSAIC3   11
#define MOSAIC4   12
#define MOSAIC5   13
#define MOSAIC6   14
#define MOSAIC7   15
#define MOSAIC8   16
#define MOSAIC9   17

#define COLOR_BUTTON_NUM 18

#define AS_CAMERA 0
#define AS_SHARE 1

#define LOCK 1
#define UNLOCK 0

@protocol MosaicViewControllerDelegate <NSObject>

@optional

-(void)addMosaicImage:(UIImage *) img;

@end

@interface MosaicViewController : UIViewController <MFMailComposeViewControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate> {

	IBOutlet UIImageView *myimageView;       //表示画像
	IBOutlet UIImageView *colorView;         //色選択ビュー
	IBOutlet UIImageView *sizeView;          //サイズ選択ビュー
	IBOutlet UIImageView *sizeViewBG;        //サイズ選択ビュー背景
	IBOutlet UIImageView *topView;           //トップビュー
	IBOutlet UIView *EditView;               //編集ビュー
	IBOutlet UIView *infoView;               //インフォメーションビュー
    UIImage *originalImage;
    UIInterfaceOrientation previousOrientation;
    
	IBOutlet UIButton *B1;                   //ツールバーボタン
	IBOutlet UIButton *B2;                   //ツールバーボタン
	IBOutlet UIButton *B3;                   //ツールバーボタン
	IBOutlet UIButton *B4;                   //ツールバーボタン
	IBOutlet UIButton *B5;                   //ツールバーボタン
	IBOutlet UIButton *cameraButton;         //カメラボタン
	IBOutlet UIButton *albumButton;          //アルバムボタン
	
	IBOutlet UILabel *thankLabel;
	IBOutlet UIButton *maButton;
	IBOutlet UIButton *rvButton;
	IBOutlet UIButton *twButton;
	IBOutlet UIButton *fbButton;
	IBOutlet UIButton *tmButton;

	UIButton *colorButton[COLOR_BUTTON_NUM]; //色選択ボタン
	UILabel *buttonBack1;
	UILabel *buttonBack2;
	
	IBOutlet UIToolbar *toolBar;             //ツールバー
	IBOutlet UISlider *sl;                   //スライダ      
	IBOutlet UILabel *memori;                //スライダのメモリ
	IBOutlet UIActivityIndicatorView *ai;    //保存中のインディケータ
	
	CGPoint location;                        //タッチ座標
	CGPoint position;                        //画像中のタッチ座標の対応座標
	
	BOOL topViewHidden_flag;                 //カメラやカメラロールから選んだ画像があるかどうか(トップビューが表示されているかどうか)
	BOOL selectMenuOn;                       //選択ビューが表示されているかどうか
	
	int colorIndex;                          //選んだ色のインデックス
	int blockSize;                           //ブロックサイズ
	
	CGSize imageSize;                        //画像の実際のサイズ
	
	int biasHeight;                          //表示位置のギャップ
	int biasWidth;                           //表示位置のギャップ
	
	int displayHeight;                       //画面上での画像の表示サイズ
	int displayWidth;                        //画面上での画像の表示サイズ
	
	float multiHeight;                       //画面表示サイズから実際の画像サイズに直すときの拡大率
	float multiWidth;                        //画面表示サイズから実際の画像サイズに直すときの拡大率
	
	int selectR;                             //選択された色のRGB
	int selectG;                             //選択された色のRGB
	int selectB;                             //選択された色のRGB
	
	int stack_lock;                          //スタックを排他的処理するためのロック
	int effect_lock;                         //エフェクトを排他的処理するためのロック
	
	NSMutableArray *undoStack;               //アンドゥスタック用配列
	int stack_pointer;                       //スタックポインタ
	
	int mosaic_flag;                         //効果をかけたかどうか
	int actionSheet_flag;                    //アクションシート選択用
	
	CGPoint	m_touch1Point;		             //タッチ位置その1
	CGPoint	m_touch2Point;		             //タッチ位置その2
	CGPoint minXY;                           //左上のタッチ座標
	CGPoint maxXY;                           //右下のタッチ座標
	
	int twoFinger;
	int rangeFrameNum;
	int check_flag;
    
    UInt8 * alteredPixels;
    NSMutableArray * cgPointQueue;
    BOOL inProgress;
}
@property (nonatomic,retain) id<MosaicViewControllerDelegate> delegate;
@property (nonatomic,retain) IBOutlet UIImageView *myimageView;
@property (nonatomic,retain) IBOutlet UIView *infoView;

-(void)AuthCheck;
-(IBAction)infoViewBackButtonPushed:(UIBarItem *)sender;
-(IBAction)infoViewButtonsPushed:(UIButton *)sender;
-(IBAction)infoButton;
-(void)getTouches:(UIEvent *)event;
-(BOOL)isTouchingImage;
-(UIImage *)mosaicImage:(UIImage *)myImage;
-(UIImage*)rangeMosaicImage:(UIImage *)myImage;
-(IBAction)selectSource:(UIButton *)sender;
-(IBAction)selectColor:(UIButton *)sender;
-(IBAction)buttonPushed:(UIButton *)sender;
-(IBAction)changeSlider:(UISlider *)slider;
-(void)createRangeFrame;
-(void)deleteRangeFrame;
-(BOOL)reverse:(BOOL)sender;
-(void)buttonAlfa:(float)sender;
-(void)buttonEnabled:(BOOL)sender;
-(void)buttonHidden:(BOOL)sender;
-(void)createButton;
-(void)topViewHidden:(BOOL)sender;
-(void)colorViewHidden:(BOOL)sender;
-(void)sizeViewHidden:(BOOL)sender;
-(void)undoEdit;
-(void)saveImage;
-(void)showCameraSheet;
-(void)startImagePicker:(int)sourceType;
-(void)touchOK;
-(void)touchNOTOK;
-(void)pushStack;
-(void)roundAndShadow;
-(void)mosaicFill;
-(void)useImage:(UIImage *)image;
-(CGContextRef)createCGContextFromCGImage:(CGImageRef)img;
-(void)updateImageSize;
-(IBAction)done:(id)sender;
-(IBAction)cancel:(id)sender;
-(UIImage*)differenceBetween:(UIImage *)image1 and:(UIImage *)image2;

@end
