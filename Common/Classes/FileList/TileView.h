//
//  TileView.h
//  ForIPad
// 背景画像を繰り返し描画する
//
//  Created by 藤田正訓 on 11/07/22.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TileView : UIView {
    @private
    UIImage* backgroundImage;
}
@property(nonatomic,retain) UIImage* backgroundImage;

@end
