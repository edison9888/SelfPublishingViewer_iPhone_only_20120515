//
//  ViewUtil.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/12.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView(Effects)

@property(nonatomic,readonly)CGFloat left;
@property(nonatomic,readonly)CGFloat top;
@property(nonatomic,readonly)CGFloat right;
@property(nonatomic,readonly)CGFloat bottom;
@property(nonatomic,readonly)CGFloat width;
@property(nonatomic,readonly)CGFloat height;
@property(nonatomic,readonly) CGFloat centerX;
@property(nonatomic,readonly)CGFloat centerY;

// 移動
-(void)eMove:(CGFloat)x :(CGFloat)y;
// 移動
-(void)eMove:(CGPoint)p;
// 移動
-(void)eCenter:(CGFloat)x :(CGFloat)y;
-(void)eCenter:(CGPoint)p;
// 相対移動
-(void)eOffset:(CGFloat)x :(CGFloat)y;
// サイズ変更
-(void)eSize:(CGFloat)width :(CGFloat)height;
// サイズ変更
-(void)eSize:(CGSize)size;
// 拡大縮小して右下座標を決める
-(void)eSetRight:(CGFloat)right bottom:(CGFloat)bottom minSize:(CGSize)minSize ;
// 同じサイズにする
-(void)eSameSize:(UIView*)view;
// 親に合わせる
-(void)eFittoSuperview;
// 左端に寄せる
-(void)eFitLeft:(BOOL)fitHeight;
// 上端に寄せる
-(void)eFitTop:(BOOL)fitWidth;
// 右端に寄せる
-(void)eFitRight:(BOOL)fitHeight;
// 下端に寄せる
-(void)eFitBottom:(BOOL)fitWidth;
// 座標を含むかどうか
-(BOOL)eContains:(CGPoint)p;
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


