//
//  StampMode.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/12.
//  Copyright 2011 SAT. All rights reserved.
//

#import "WritingMode.h"
#import "SelectAreaView.h"
#import "ImagePickDialog.h"
#import "LibraryPane.h"

@interface StampMode : WritingMode<LibraryPaneDelegate> {
    enum StampProcMode {
        Stampable, //貼付け待ち
        StampMoving, //貼付け後動かしてる
        StampChangable, //微調整待ち
        StampChanging, //微調整中
        StampNop,
        Selectable, //範囲選択モード
        SelectChangable,//範囲選択変更待ち
        SelectChanging, //範囲選択変更中
        SelectMoving, //範囲移動中
        SelectNop // 何もしない
    } procMode;
    CGPoint beginPoint;
    UIImage* image;
    SelectAreaView* areaView;
    CGContextRef context;
    ImagePickDialog* imagePicker;
    UIToolbar* topBar;
    UIToolbar* bottomBar;
    
}

@end
