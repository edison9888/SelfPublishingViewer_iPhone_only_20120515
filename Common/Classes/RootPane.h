//
//  RootPane.h
//  LiverliveRecipe
//
//  Created by 藤田正訓 on 11/06/21.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FileListPane;

@interface RootPane : UIViewController<UINavigationControllerDelegate> {
    UINavigationController* navi;
    FileListPane* fileListPane;
    BOOL _rotationLock;
    BOOL navigationLock;
    
}

@property(nonatomic,readonly) UINavigationController* navi;
// 回転ロック
@property(nonatomic,assign)BOOL rotationLock;

@property(nonatomic,assign)BOOL navigationLock;
// インスタンスを返す
+(RootPane*) instance;
// リスト画面に戻る
-(void)showListPane;
// アニメーションでトップ画面へ
-(void)rewindToListPane;

// 設定画面を表示する
-(void)showConfigPane;
// ブックマーク画面を表示する
-(void)showBookmarkPane;
// 次の画面を表示する
-(void)pushPane: (UIViewController*)nextPane;
// 前の画面に戻る
-(void)popPane;
// 現在トップかどうかを返す
-(BOOL)isTop:(UIViewController*)pane;

// 向きを返す
+(BOOL)isPortrait;
// iPad向けかどうかを返す
+(BOOL)isForIpad;

+ (BOOL)isRotationLocked;

@end
