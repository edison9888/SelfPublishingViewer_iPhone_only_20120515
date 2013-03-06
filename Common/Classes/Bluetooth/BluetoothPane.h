//
//  BluetoothPane.h
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/24.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GKSession.h>
#import <GameKit/GKPeerPickerController.h>
#import "FileSelector.h"
#import "ProgressDialog.h"
#import "BookExportOperation.h"


typedef enum {
    BTSendStateInit = 1,
    BTSendStateFilesizeSent = 2,
    BTSendStateFilenameSent = 3,
    BTSendStateFileSending = 4,
    BTSendStateCompleted = 5,
    BTSendStateMemosizeSent = 6,
    BTSendStateMemoSending = 7,
    BTSendStateMemoCompleted = 8,
    BTSendStateCanceled = 99
} BTSendState;

typedef enum {
    BTReceiveStateInit = 1,
    BTReceiveStateFilesizeReceipt = 2,
    BTReceiveStateFilenameReceipt = 3,
    BTReceiveStateFileReceiving = 4,
    BTReceiveStateCompleted = 5,
    BTReceiveStateMemosizeReceipt = 6,
    BTReceiveStateMemoReceiving = 7,
    BTReceiveStateMemoCompleted = 8,
    BTReceiveStateCanceled = 99
} BTReceiveState;

@interface BluetoothPane : UIViewController<GKPeerPickerControllerDelegate, GKSessionDelegate> {
    UIButton* startButton;       // 送信側スタートボタン
    UIButton* selectButton;   // ファイル選択ボタン
    UILabel* messageLabel;
    UIActivityIndicatorView* loadingView;

    // 通信オブジェクト
    GKSession* session;
    NSString* peerID;
    // ダイアログ
    FileSelector* fileSelector;
    ProgressDialog* progress;
    // 送信中のオブジェクト
    Book* sendingBook;
//    NSData* sendingData;
    NSFileHandle* sendingHandle;
    NSUInteger sendingFileSize;
    // 送信バイト数
    NSUInteger sendByte;
    BTSendState sendState;
    // 受信先ファイル
    NSUInteger receiptByte;
    NSUInteger allByteSize;
    NSString* downloadPath;
    NSString* downloadedBookPath;
    BTReceiveState receiveState;
    // 状態変数
    BOOL accepting;
    BOOL sending;
    BOOL exporting;
    BookExportOperation *_exportOperation;

    
}

@property(nonatomic,retain)IBOutlet UIButton* startButton;       // 送信側スタートボタン
@property(nonatomic,retain)IBOutlet UIButton* selectButton;   // ファイル選択ボタン
@property(nonatomic,retain)IBOutlet UILabel* messageLabel;
@property(nonatomic,retain)IBOutlet UIActivityIndicatorView* loadingView;


// 接続を開始する
- (IBAction)startSharing;
// 送信ファイルを選択して送信する
-(IBAction)selectBook;


@end
