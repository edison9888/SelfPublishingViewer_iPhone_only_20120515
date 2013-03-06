//
//  BluetoothPane.m
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/24.
//  Copyright 2011 SAT. All rights reserved.
//

#import "BluetoothPane.h"
#import "FileSelector.h"
#import "common.h"
#import "FileUtil.h"
#import "AlertDialog.h"
#import "BookFiles.h"
#import "LoadingView.h"
#import "ShareExplanation.h"
#import "RootPane.h"
#import "AppUtil.h"
#import "NSString_Util.h"
#import "ZipArchive.h"
#import "PageMemo.h"
#import "BookExportOperation.h"

@interface BluetoothPane()
@property(nonatomic,retain)GKSession* session;
@property(nonatomic,retain)NSString* peerID;
@property(nonatomic,retain)FileSelector* fileSelector;
@property(nonatomic,retain)ProgressDialog* progress;
@property(nonatomic,retain)Book* sendingBook;
@property(nonatomic,retain)NSFileHandle* sendingHandle;
@property(nonatomic,retain)NSString* downloadPath;
@property(nonatomic,retain)NSString* downloadedBookPath;
@end




@implementation BluetoothPane

@synthesize startButton,selectButton,messageLabel,loadingView;
@synthesize session;
@synthesize peerID,downloadPath,downloadedBookPath;
@synthesize fileSelector, progress;
@synthesize sendingBook;
@synthesize sendingHandle;

static NSString* SESSION_ID = @"1234567890apdmebk93kmfjufg";
static NSString* OK = @"###OK###";
static NSString* CANCEL = @"###CANCEL###";


#pragma mark - Bluetooth通信基本
// データを送信する
- (void) sendData: (NSData*) data {
    if (peerID) {
        [session sendData:data
                  toPeers:[NSArray arrayWithObject:peerID]
             withDataMode:GKSendDataReliable
                    error:nil];
    }
}

// 文字列を送信する
- (void) sendString: (NSString*) str {
    [self sendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
}

// 数値を送信する
- (void) sendInt: (NSInteger) i {
    [self sendData:[NSData dataWithBytes:&i length:sizeof(i)]];
}

// OKパケットを送信する
- (void) sendOk {
    [self sendString:OK];
}

// CANCELパケットを送信する
- (void) sendCancel {
    [self sendString:CANCEL];
}

// 受信パケットを整数値に変換する
- (NSInteger) toInt:(NSData*)data {
    NSInteger i = 0;
    if ([data length] == sizeof(NSInteger)) {
        [data getBytes:&i length:sizeof(i)];
    }
    return i;
}

// 受信パケットを文字列に変換する
- (NSString*) toStr:(NSData*)data {
    return [[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]autorelease];
}

// 受信パケットが文字列に等しいかどうか
- (BOOL) isEqualToString: (NSData*)data with:(NSString*)str {
    if ([data length] == [[str dataUsingEncoding:NSUTF8StringEncoding]length]) {
        if ([[self toStr:data] isEqualToString:str]) {
            return YES;
        }
    }
    return NO;
}

// OKパケットかどうか
- (BOOL) isOk: (NSData*) data {
    return [self isEqualToString:data with:OK];
}

// CANCELパケットかどうか
- (BOOL) isCancel: (NSData*) data {
    return [self isEqualToString:data with:CANCEL];
}


// 接続をキャンセルする
- (void)disposeSession {
    @synchronized(self) {
        //NSLog(@"%s %@", __func__, @"");
        if (session) {
            if (session.available && peerID) {
                [session disconnectPeerFromAllPeers:peerID];
            }
            [session setDataReceiveHandler:nil withContext:nil];
            session.delegate = nil;
            session.available = NO;
            self.session = nil;
        }
        self.peerID = nil;
        
        sendState = BTSendStateInit;
        receiveState = BTReceiveStateInit;
        
        if (downloadPath) {
            [FileUtil rm:downloadPath];
            self.downloadPath = nil;
        }
        if (downloadedBookPath) {
            [FileUtil rm:downloadedBookPath];
            self.downloadedBookPath = nil;
        }
        
        if (sendingHandle) {
            [sendingHandle closeFile];
            self.sendingHandle = nil;
        }
        if (sendingBook) {
            self.sendingBook = nil;
        }
        [loadingView stopAnimating];
        messageLabel.hidden = YES;
        loadingView.hidden = YES;
        
        
        accepting = NO;
        sending = NO;
        if (progress) {
            //NSLog(@"%s %@", __func__, @"progress 削除");
            [progress dismiss];
            self.progress = nil;
        }
        if (fileSelector) {
            //NSLog(@"%s %@", __func__, @"fileSelector 削除");
            [fileSelector dismiss];
            self.fileSelector = nil;
        }
    }
}

// エラーをthrowする
- (void) throwError:(NSData*)data reason:(NSString*)reason {
    @throw [NSException exceptionWithName:@"DataReceiveError"
                                   reason:reason
                                 userInfo:nil];
}



// ボタンを初期化する
- (void)initializeButtons {
    [startButton setTitle:NSLocalizedString(@"startShare", nil) forState:UIControlStateNormal];
    startButton.enabled = YES;
    accepting = NO;
    sending = NO;
    
    selectButton.enabled = NO;
    selectButton.hidden = YES;
    
    [loadingView stopAnimating];
    messageLabel.hidden = YES;
    loadingView.hidden = YES;

}





#pragma mark - Bluetoothクライアント側

// ファイルを送信する

- (void)sendBookFile: (NSString *)fileToSend 
{
    
    [progress.alertView setMessage:NSLocalizedString(@"sending", nil)];

    sending = YES;
    
    
    self.sendingHandle = [NSFileHandle fileHandleForReadingAtPath:fileToSend];
    
    sendingFileSize = [FileUtil length:fileToSend];
    [self sendInt:sendingFileSize];
    sendState = BTSendStateFilesizeSent;
}


- (void)exportOperationDone:(BookExportOperation *)operation
{
    
    assert([NSThread isMainThread]);
    assert([operation isKindOfClass:[BookExportOperation class]]);
    assert(operation == self->_exportOperation);
    
    NSString *_bookFileName = [self.sendingBook.name lastPathComponent];
    
    NSString *_exportFilename = [[AppUtil bookExportDir] stringByAppendingPathComponent:_bookFileName];
    
    if (operation.error != nil) {
        //NSLog(@"Failed to export");
    } else {
        exporting = FALSE; 
        
        [self sendBookFile:_exportFilename];
        
    }
    [self->_exportOperation release];
    self->_exportOperation = nil;
    
}



- (void)sendBook: (Book*)b 
{

    self.sendingBook = b;
    
    
    progress = [[ProgressDialog 
                 show:res(@"exporting")
                 message:res(@"exporting")
                 onCancel:^() {
                     [AlertDialog alert:res(@"send")
                                message:res(@"sendComplete") 
                                   onOK:nil];
                     
                 }]retain];
    
    
    if (b.isJPG || b.isPNG) {
        NSString *fileNameToSend = [b.bookDataLocation stringByAppendingPathComponent:b.name];

        [self sendBookFile:fileNameToSend];
    } else  if (b.isPDF) {
        [self sendBookFile:b.path];

    } else {
        
        assert(self->_exportOperation == nil);
        self->_exportOperation = [[[BookExportOperation alloc] initWithBook:b.bookLocation] retain];
        assert(self->_exportOperation != nil);
        
        [self->_exportOperation setQueuePriority:NSOperationQueuePriorityNormal];
        
        [[OperationManager sharedManager] addCPUOperation:self->_exportOperation finishedTarget:self action:@selector(exportOperationDone:)];
        exporting = TRUE;
        
    }
    
    
}





// 送信ファイルを選択して送信開始する
- (void)selectBook {
    self.fileSelector = [FileSelector 
                         showPopover:NSLocalizedString(@"selectFile", nil) 
                         onSelected:^(Book* b){
                             [fileSelector dismiss];
                             self.fileSelector = nil;
                             [self sendBook:b];
                             
                         }
                         onCancel:nil
                         fromRect:startButton.frame
                         animated:YES];
}

// メモ送信を開始する
- (void)startSendMemo {
    NSString* archivePath = [PageMemo createArchive:sendingBook];
    if (archivePath != nil) {
        [sendingHandle closeFile];
        self.sendingHandle = [NSFileHandle fileHandleForReadingAtPath:archivePath];
        sendingFileSize = [FileUtil length:archivePath];
        [self sendInt:sendingFileSize];
        self.progress = [ProgressDialog show:@"メモ送信中" 
                                 message:@"メモを送信しています" 
                                onCancel:^(){
                                    sendState = BTSendStateCanceled;
                                }];
        sendState = BTSendStateMemosizeSent;
    } else {
        [self sendInt:0];
        sendState = BTSendStateMemoCompleted;
    }
}

// クライアント側データ受信時に呼ばれる
- (void) clientReceiveData:(NSData *)data 
            fromPeer:(NSString *)peer 
           inSession: (GKSession *)session 
             context:(void *)context {
    switch (sendState) {
        case BTSendStateInit:
            // ここにはこない
            break;
            
        case BTSendStateCanceled:
            //NSLog(@"%s %@", __func__, @"送信側キャンセル送信");
            [self sendCancel];
            [self disposeSession];
            [self initializeButtons];
            break;
            
        case BTSendStateFilesizeSent:
            //NSLog(@"%s %@", __func__, @"ファイル名を送信");

            if ([self isOk:data]) {
                // 次にファイル名を送信する
                [self sendString:sendingBook.name];
                sendState = BTSendStateFilenameSent;
            } else {
                [self disposeSession];
                [self initializeButtons];
            }
            break;
            
        case BTSendStateFilenameSent:
            if ([self isOk:data]) {
                //NSLog(@"%s %@", __func__, @"ファイル先頭を送信");
                // 次にファイルを読みだして送る
                NSData* subdata = [sendingHandle readDataOfLength:PACKET_SIZE];
                [self sendData:subdata];
                sendByte = [subdata length];
                progress.progress = (float)sendByte / (float)sendingFileSize;
                if (sendByte >= sendingFileSize) {
                    sendState = BTSendStateCompleted;
                } else {
                    sendState = BTSendStateFileSending;
                }
                
            } else {
                [self disposeSession];
                [self initializeButtons];
            }
            break;
            
        case BTSendStateFileSending:
            //NSLog(@"%s %@", __func__, @"ファイル送信中");
            if ([self isOk:data]) {
                // ファイルを読みだして送る
                NSData* subdata = [sendingHandle readDataOfLength:PACKET_SIZE];
                [self sendData:subdata];
                sendByte += [subdata length];
                progress.progress = (float)sendByte / (float)sendingFileSize;
                
                if (sendByte >= sendingFileSize) {
                    sendState = BTSendStateCompleted;
                }
            } else {
                [self disposeSession];
                [self initializeButtons];
            }
            break;
            
            
            
        case BTSendStateCompleted:
            //NSLog(@"%s %@", __func__, @"ファイル送信完了、メモ送信開始");
            [progress dismiss];
            self.progress = nil;
             
            if ([self isOk:data]) {
                [self startSendMemo];
                progress.progress = 0;
                sendByte = 0;
                
            } else {
                [self disposeSession];
                [self initializeButtons];
            }
            break;
            
        case BTSendStateMemosizeSent:
            if ([self isOk:data]) {
                NSData* subdata = [sendingHandle readDataOfLength:PACKET_SIZE];
                [self sendData:subdata];
                sendByte = [subdata length];
                progress.progress = (float)sendByte / (float)sendingFileSize;
                if (sendByte >= sendingFileSize) {
                    sendState = BTSendStateMemoCompleted;
                } else {
                    sendState = BTSendStateMemoSending;
                }
                
            }
            break;
            
        case BTSendStateMemoSending:
            if ([self isOk:data]) {
                // ファイルを読みだして送る
                NSData* subdata = [sendingHandle readDataOfLength:PACKET_SIZE];
                [self sendData:subdata];
                sendByte += [subdata length];
                progress.progress = (float)sendByte / (float)sendingFileSize;
                
                if (sendByte >= sendingFileSize) {
                    sendState = BTSendStateMemoCompleted;
                }
            } else {
                [self disposeSession];
                [self initializeButtons];
                
            }
            
            break;
            
        case BTSendStateMemoCompleted:
            //NSLog(@"%s %@", __func__, @"メモ送信完了");
            if ([self isOk:data]) {
                sendState = BTSendStateInit;
                sendByte = 0;
                [sendingHandle closeFile];
                self.sendingHandle = nil;
                self.sendingBook = nil;
                sendState = BTSendStateInit;
                sending = NO;
                
                [self sendOk];
                // ファイル送信完了
                if (progress) {
                    [progress dismiss];
                    self.progress = nil;
                }
                [AlertDialog
                 alert:NSLocalizedString(@"complete", nil)
                 message:NSLocalizedString(@"transmissionComp", nil)
                 onOK:nil];
                
            } else {
                [self disposeSession];
                [self initializeButtons];
            }
            break;
            
        default:
            NSLog(@"%@", [self toStr:data]);
    }
    
}

#pragma mark - Bluetoothサーバー側


- (void)startReceiveMemo {
    NSString* tmpFilename = [NSString stringWithFormat:@"%d.sbrmemo", (int)[NSDate timeIntervalSinceReferenceDate]];
    NSString* tmpFilePath = [AppUtil tmpPath:tmpFilename];
    self.downloadPath = tmpFilePath;
    self.progress = [ProgressDialog show:@"メモ受信中"
                             message:@"メモを受信しています"
                            onCancel:^() {
                                receiveState = BTReceiveStateCanceled;
                            }];
}

- (void)startReceiveFile:(NSString*)toPath {
    self.downloadPath = [FileUtil unexistingPath:toPath];
    self.progress = [ProgressDialog show:[downloadPath lastPathComponent]
                             message:NSLocalizedString(@"fileReceived", nil)
                            onCancel:^() {
                                //NSLog(@"%s %@", __func__, @"onCancel");
                                receiveState = BTReceiveStateCanceled;
                                self.progress = nil;
                            }];
    
    [self sendOk];
    receiveState = BTReceiveStateFilenameReceipt;

}


// サーバー側データ受信時に呼ばれる
- (void) serverReceiveData:(NSData *)data 
            fromPeer:(NSString *)peer 
           inSession: (GKSession *)session 
             context:(void *)context {
    if (fileSelector) {
        [fileSelector dismiss];
        self.fileSelector = nil;
    }
    switch (receiveState) {
        case BTReceiveStateCanceled:
            //NSLog(@"%s %@", __func__, @"受信キャンセル");

            // キャンセル
            [self sendCancel];
            [self disposeSession];
            [self initializeButtons];
            break;
        case BTReceiveStateInit:
            //NSLog(@"%s %@", __func__, @"受信初期状態");

            // ファイルサイズを受信
            allByteSize = [self toInt:data];
            if (allByteSize > 0) {
                [self sendOk];
                receiveState = BTReceiveStateFilesizeReceipt;
            } else {
                [self disposeSession];
                [self initializeButtons];
            }
            break;
            
        case BTReceiveStateFilesizeReceipt:
            NSLog(@"%s %@", __func__, @"ファイル名受信");

            // ファイル名を受信
            NSString* toPath = [AppUtil docPath:[self toStr:data]];
            if ([FileUtil exists:toPath]) {
                [AlertDialog 
                 confirm:res(@"confirm")
                 message:res(@"confirmRename") 
                 onOK:^{
                     [self startReceiveFile:toPath];
                 }
                 onCancel:^{
                     [self sendCancel];
                     receiveState = BTReceiveStateCanceled;
                 }
                 okLabel:res(@"renameUnexisting") 
                 cancelLabel:res(@"cancel")];
            } else {
                [self startReceiveFile:toPath];
            }
            
            break;
            
        case BTReceiveStateFilenameReceipt:
            NSLog(@"%s %@", __func__, @"ファイル先頭を受信");

            // ファイル内容の先頭を受信
            [FileUtil append:data path:downloadPath];
            receiptByte = [data length];
            progress.progress = (float)receiptByte / (float)allByteSize;
            //NSLog(@"receive start %d / %d received", receiptByte, allByteSize);
            [self sendOk];
            receiveState = BTReceiveStateFileReceiving;
            break;
            
        case BTReceiveStateFileReceiving:
            //NSLog(@"%s %@", __func__, @"ファイル受信中");

            // ファイル受信中
            [FileUtil append:data path:downloadPath];
            receiptByte += [data length];
            progress.progress = (float)receiptByte / (float)allByteSize;
            //NSLog(@"receiving %d / %d received", receiptByte, allByteSize);
            [self sendOk];
            if (receiptByte >= allByteSize) {
                receiveState = BTReceiveStateCompleted;
            }
            
            break;
            
        case BTReceiveStateCompleted:
            NSLog(@"%s %@", __func__, @"ファイル受信完了、メモ受信中");
            [progress dismiss];
            self.progress = nil;
            allByteSize = [self toInt:data];
            if (allByteSize > 0) {
                receiveState = BTReceiveStateMemosizeReceipt;
                self.downloadedBookPath = downloadPath;
                [self startReceiveMemo];
            } else {
                receiveState = BTReceiveStateMemoCompleted;
            }
            [self sendOk];
            break;
            
        case BTReceiveStateMemosizeReceipt:
            // ファイル内容の先頭を受信
            [FileUtil append:data path:downloadPath];
            receiptByte = [data length];
            progress.progress = (float)receiptByte / (float)allByteSize;
            //NSLog(@"memo receive start %d / %d received", receiptByte, allByteSize);
            [self sendOk];
            if (receiptByte >= allByteSize) {
                receiveState = BTReceiveStateMemoCompleted;
            } else {
                receiveState = BTReceiveStateMemoReceiving;
            }
            
            break;
            
        case BTReceiveStateMemoReceiving:
            // ファイル受信中
            [FileUtil append:data path:downloadPath];
            receiptByte += [data length];
            progress.progress = (float)receiptByte / (float)allByteSize;
            //NSLog(@"memo receiving %d / %d received", receiptByte, allByteSize);
            [self sendOk];
            if (receiptByte >= allByteSize) {
                receiveState = BTReceiveStateMemoCompleted;
            }
            
            
            break;
            
            
        case BTReceiveStateMemoCompleted:
            if (downloadedBookPath) {
                [PageMemo extractArchive:downloadedBookPath archive:downloadPath];
                [FileUtil rm:downloadPath];
                self.downloadedBookPath = nil;
            }
            // ファイル受信完了
            receiptByte = 0;
            self.downloadPath = nil;
            allByteSize = 0;
            receiveState = BTReceiveStateInit;
            [BookFiles purge];
            [progress dismiss];
            self.progress = nil;
            [AlertDialog
             alert:NSLocalizedString(@"complete", nil) 
             message:NSLocalizedString(@"receptionComp", nil) 
             onOK:nil];
            
            break;
            
        default:
            NSLog(@"%@", [self toStr:data]);
    }
}

#pragma mark - Bluetooth共通

// 接続を開始する
- (IBAction)startSharing {
    if (accepting) {
        accepting = NO;
        [self disposeSession];
        [self initializeButtons];
    } else {
        accepting = YES;
        messageLabel.text = NSLocalizedString(@"btSeeking", nil);
        messageLabel.hidden = NO;
        loadingView.hidden = NO;
        [loadingView startAnimating];
        
        [startButton setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
        self.session = [[[GKSession alloc]initWithSessionID:SESSION_ID
                                          displayName:NSLocalizedString(@"jisuiViewerConnect", nil)
                                          sessionMode:GKSessionModePeer]autorelease];
        // イベントリスナ登録
        session.delegate = self;
        [session setDataReceiveHandler:self withContext:nil];
        session.available = YES; // 探し始める
    }
}



// コネクションが切れた
-(void)session:(GKSession *)sess connectionWithPeerFailed:(NSString *)peerID 
     withError:(NSError *)error {
    NSInteger code = [error code];
    //NSLog(@"[%d]%@ / %s", code, [error description], __func__);
    if (code == 30510 || code == 30505) {
        
    } else {
        //NSLog(@"%@", [error description]);
        [AlertDialog alert:NSLocalizedString(@"communicationFault", nil) 
                   message:NSLocalizedString(@"conectionCut", nil)
                      onOK:nil];
        [self disposeSession];
        [self initializeButtons];
    }
}


// 通信エラー
-(void)session:(GKSession *)sess didFailWithError:(NSError *)error {
    [AlertDialog alert:NSLocalizedString(@"communicationFault", nil)
               message:NSLocalizedString(@"failCommunication", nil)
                  onOK:nil];
    [self disposeSession];
    [self initializeButtons];
}

-(void)session:(GKSession *)sess didReceiveConnectionRequestFromPeer:(NSString *)pid {
    //NSLog(@"接続要求:%@", pid);
    if (peerID) {
        if ([peerID isEqualToString:pid]) {
            NSLog(@"接続受け入れ : %@", pid);
            [sess acceptConnectionFromPeer:pid error:nil];
            return;
        }
    }
    //NSLog(@"接続拒否 : %@", pid);
    [sess denyConnectionFromPeer:pid];
}



// セッションのイベント
-(void)session:(GKSession *)sess 
          peer:(NSString *)pid
didChangeState:(GKPeerConnectionState)sessionState {
    if (sessionState == GKPeerStateUnavailable) {
        //NSLog(@"利用不可になった:%@ / %s", pid, __func__);
        // 切断された
        [self disposeSession];
        [self initializeButtons];
    } else if (sessionState == GKPeerStateConnected) {
        // ぴあ接続された
        //NSLog(@"ピア接続された:%@ / %s", pid, __func__);
        if ([peerID isEqualToString:pid]) {
            accepting = YES;
            receiveState = BTReceiveStateInit;
            selectButton.enabled = YES;
            selectButton.hidden = NO;
            [selectButton setTitle:NSLocalizedString(@"selectFile", nil) forState:UIControlStateNormal];
            [loadingView stopAnimating];
            messageLabel.hidden = YES;
            loadingView.hidden = YES;
        }

    } else if (sessionState == GKPeerStateDisconnected) {
        // 切断された
        //NSLog(@"相手に切断された:%@ / %s", pid, __func__);
        if ([peerID isEqualToString:pid]) {
            [self disposeSession];
            [self initializeButtons];
        }
    } else if (sessionState == GKPeerStateAvailable) {
        //NSLog(@"利用可能:%@ / %s", pid, __func__);
        if (!peerID) {
            self.peerID = pid;
            [session connectToPeer:pid withTimeout:10];
        }
    } else if (sessionState == GKPeerStateConnecting) {
        //NSLog(@"接続しようとしている:%@ / %s", pid, __func__ );
        if (!peerID) {
            self.peerID = pid;
        }
        
    } else {
        //NSLog(@"%d:%@ / %s", sessionState, pid, __func__);
    }

}





// データ受信時に呼ばれる
- (void) receiveData:(NSData *)data 
            fromPeer:(NSString *)peer 
           inSession: (GKSession *)sess
             context:(void *)context {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];

    if ([self isCancel:data]) {
        // 相手方のキャンセル
        [self disposeSession];
        [self initializeButtons];
        [AlertDialog alert:NSLocalizedString(@"cancel", nil)
                   message:NSLocalizedString(@"canceledOtherSide", nil)
                      onOK:nil];
    } else if (sending) {
        // 送信側
        [self clientReceiveData:data fromPeer:peer inSession:sess context:context];
    } else if (accepting) {
        // 受信側
        [self serverReceiveData:data fromPeer:peer inSession:sess context:context];
    }
    [pool release];
}


#pragma mark - View lifecycle
- (id)init {
    self = [super init];
    if (self) {
        
        
    }
    return self;
}

- (void)dealloc
{
    //NSLog(@"dealloc");
    [self disposeSession];
    self.sendingBook = nil;
    [sendingHandle release];
    self.startButton = nil;
    self.selectButton = nil;
    self.messageLabel = nil;
    self.loadingView = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)showExplanation:(UIBarButtonItem*)sender {
    ShareExplanation* se = [[ShareExplanation alloc] init];
    [se setExplanationType:sender.tag];
    [[RootPane instance] pushPane:se];
    [se release];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeButtons];
    startButton.titleLabel.text = NSLocalizedString(@"startShare", nil);
    selectButton.titleLabel.text = NSLocalizedString(@"selectFile", nil);
    
    //Bluetootのヘルプ画面への遷移ボタンを追加
    UIBarButtonItem* toHelpButton = [[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"explanation", nil)
                                   style:UIBarButtonItemStyleDone
                                   target:self action:@selector(showExplanation:)];
    toHelpButton.tag = 0;
    toHelpButton.style = UIBarButtonItemStyleBordered;
    self.navigationItem.rightBarButtonItem = toHelpButton;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self disposeSession];
    self.sendingBook = nil;
    self.sendingHandle = nil;
    self.startButton = nil;
    self.selectButton = nil;
    self.messageLabel = nil;
    self.loadingView = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ![RootPane isRotationLocked];
}


@end
