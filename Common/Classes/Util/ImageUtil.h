//
//  ImageUtil.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/07/28.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ImageUtil : NSObject {
    
}

// 画像を比率で切り抜く
+ (UIImage*)clip: (UIImage*)img rect:(CGRect)rect;

// 画像を縮小する
+ (UIImage*)shrink: (UIImage*)img toSize:(CGSize)size;
// アスペクト比を保ったまま枠に入るように画像を縮小する
+ (UIImage*)shrinkAspect:(UIImage*)img toSize:(CGSize)size;
// 画像を縮小する。横長の画像であれば半分に切り取る。
+ (UIImage*)shrinkClip:(UIImage*)img toSize:(CGSize)size left:(BOOL)left;
// グレイスケールに変換する。
+ (UIImage*)grayscale:(UIImage*)origImage;
// 射影変換
+ (UIImage*)homography:(UIImage*)origImage 
                 nw:(CGPoint)nw
                 ne:(CGPoint)ne
                 sw:(CGPoint)sw
                 se:(CGPoint)se;
// 枠検出 検出できたらYES
+ (BOOL)findMaxSquare: (UIImage*)uiimg result:(CGPoint*)ret;

// 指定ポイントの色を取得する
+ (UIColor*)getColorAtPoint:(CGPoint)point image:(UIImage*)image ;

@end
