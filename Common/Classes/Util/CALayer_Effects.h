//
//  CALayer_Effects.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/12.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface CALayer(Effects)

@property(nonatomic,readonly)CGFloat left;
@property(nonatomic,readonly)CGFloat top;
@property(nonatomic,readonly)CGFloat right;
@property(nonatomic,readonly)CGFloat bottom;
@property(nonatomic,readonly)CGFloat width;
@property(nonatomic,readonly)CGFloat height;

// 移動
-(void)eMove:(CGFloat)x :(CGFloat)y;
// 相対移動
-(void)eOffset:(CGFloat)x :(CGFloat)y;
// サイズ変更
-(void)eSize:(CGFloat)width :(CGFloat)height;
// 同じサイズにする
-(void)eSameSize:(CALayer*)layer;
// 親に合わせる
-(void)eFittoSuperlayer;
// 左端に寄せる
-(void)eFitLeft:(BOOL)fitHeight;
// 上端に寄せる
-(void)eFitTop:(BOOL)fitWidth;
// 右端に寄せる
-(void)eFitRight:(BOOL)fitHeight;
// 下端に寄せる
-(void)eFitBottom:(BOOL)fitWidth;
// フェードアウト
-(void)eFadeout;
// フェードイン
-(void)eFadein;
// 上端に隠す
-(void)eHidetoTop;
// 下端に隠す
-(void)eHidetoBottom;
// 上端から出現する
-(void)eShowFromTop;
// 下端から出現する
-(void)eShowFromBottom;
// ログ出力用フォーマット
-(NSString*)eDesc;

@end
