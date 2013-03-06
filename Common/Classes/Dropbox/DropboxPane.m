//
//  DropboxPane.m
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/22.
//  Copyright 2011 SAT. All rights reserved.
//

#import "DropboxPane.h"
#import "RootPane.h"
#import "FileUtil.h"
#import "AlertDialog.h"
#import "FileSelector.h"
#import "common.h"
#import "BookFiles.h"
#import "NSString_Util.h"
#import "AppUtil.h"
#import "ZipArchive.h"
#import "BookExportOperation.h"
#import "OperationManager.h"
#import "ForIphoneAppDelegate.h"

@implementation DropboxPane

@synthesize dir;

#pragma mark - Data loading


// ログアウト
- (void)logout {
    [[DBSession sharedSession] unlink];
    [[RootPane instance]rewindToListPane];
}

// リモートに同じファイル名が存在するかどうかを返す
- (BOOL) remoteExists: (NSString*) fileName {
    for (NSString* file in files) {
        NSString* fn = [file lastPathComponent];
        if ([fn isEqualToString:fileName]) {
            return YES;
        }
    }
    return NO;
}

- (void)dismissProgress {
    if (progress) {
        [progress dismiss];
        [progress release];
        progress = nil;
    }
}


// アップロードを開始する

- (void)doUploadBook:(NSString*)fileToUpload 
{
    [progress.alertView setMessage:NSLocalizedString(@"uploading", nil)];
    [restClient uploadFile:uploadingBook.name  toPath:dir fromPath:fileToUpload];
    uploading = YES;
    
}

- (void) cancelExport
{
    return;
}

- (void)doStartUpload:(Book*)b 
{
    [restClient uploadFile:b.name 
                    toPath:dir
                  fromPath:b.path];
    [self dismissProgress];
    progress = [[ProgressDialog show:NSLocalizedString(@"upload", nil)
                             message:NSLocalizedString(@"uploading", nil)
                            onCancel:^() {
                                if (self->_exportOperation !=nil) {
                                    [self->_exportOperation cancel];
                                    
                                }
                                [restClient cancelFileUpload:uploadingBook.path];

                                uploading = NO;
                                uploadingBook = nil;
                                [AlertDialog alert:NSLocalizedString(@"cancel", nil)
                                           message:NSLocalizedString(@"completeCancel", nil) 
                                              onOK:nil];
                            }]retain];
    
    uploadingBook = b;
    uploading = YES;
}



- (void)exportOperationDone:(BookExportOperation *)operation
{
    
    assert([NSThread isMainThread]);
    assert([operation isKindOfClass:[BookExportOperation class]]);
    assert(operation == self->_exportOperation);
    
    exporting = FALSE; 

    [exportingMessage dismissWithClickedButtonIndex:0 animated:YES];
    [_exportActivity release];
    _exportActivity = nil;

    exportingMessage = nil;
    if (operation.error == nil) {
        
        [self doStartUpload:uploadingBook];
    } 
    
    [self->_exportOperation release];
    self->_exportOperation = nil;
    
}


- (void)startActualUpload:(Book*)b 
{
      if (b.isJPG || b.isPNG) {
        [FileUtil copy:[b.bookDataLocation stringByAppendingPathComponent:b.name] :b.path];
        [self doStartUpload:b];
    }else if (b.isPDF) {
        [self doStartUpload:b];
    } else {
        if (!b.isImported) {
            [self doStartUpload:b];
            return;
        }
        assert(exportingMessage == nil);
        NSString *plzWait = NSLocalizedString(@"wait", nil);
        NSString *preparing = NSLocalizedString(@"preparing", nil);

        
        exportingMessage = [[[UIAlertView alloc] initWithTitle:plzWait
                                            message:preparing delegate:self cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
        
        _exportActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _exportActivity =  [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 80, 30, 30)];

        [_exportActivity startAnimating];
        //[exportingMessage addSubview:_exportActivity];
        _exportActivity.center = CGPointMake(exportingMessage.bounds.size.width / 2, exportingMessage.bounds.size.height - 50);

        
        [exportingMessage show];
        assert(self->_exportOperation == nil);
        self->_exportOperation = [[[BookExportOperation alloc] initWithBook:b.bookLocation] retain];
        assert(self->_exportOperation != nil);
        
        [self->_exportOperation setQueuePriority:NSOperationQueuePriorityNormal];
        
        [[OperationManager sharedManager] addCPUOperation:self->_exportOperation finishedTarget:self action:@selector(exportOperationDone:)];
        exporting = TRUE;
        
    }
    
    
}

- (void)startUpload:(Book*)b 
{
    
#if(0)
    // This is original code, but it's not available for iPad app.
    uploadingBook = b;

    ForIphoneAppDelegate *iPhone = [(ForIphoneAppDelegate *) [UIApplication sharedApplication] delegate];
    
    if (iPhone.onCelular) {
        [AlertDialog alert:NSLocalizedString(@"warning", nil)
            message:NSLocalizedString(@"bigFilesOver3G", nil) 
                      onOK:^{
                          [self startActualUpload:b];
                    }];
    }else {
        [self startActualUpload:b];
    }
#endif
    
}


// ダウンロード中情報の後始末
- (void)disposeDownloadInfo {
    [downloadingLocalPath release];
    [downloadingRemotePath release];
    downloadingLocalPath = nil;
    downloadingRemotePath = nil;
    downloading = NO;
}



-(void)startDownload:(NSString*)path toPath:(NSString*)toPath {
    downloadingRemotePath = [path retain];
    downloadingLocalPath = [toPath retain];
    
    // プログレスバーの準備
    [self dismissProgress];
    progress = [[ProgressDialog 
                 show:res(@"download")
                 message:res(@"downloading")
                 onCancel:^() {
                     [restClient cancelFileLoad:path];
                     [FileUtil rm:toPath];
                     [self disposeDownloadInfo];
                     [AlertDialog alert:res(@"cancel")
                                message:res(@"completeCancel") 
                                   onOK:nil];
                     
                 }]retain];
    downloading = YES;
    [restClient loadFile:path intoPath:toPath];
    
}


// アップロードファイルを選択開始
- (void)selectUploadFile: (CGRect)fromRect {
    if (fileSelector) {
        return;
    }
    fileSelector = [[FileSelector
                     showPopover:NSLocalizedString(@"selectFile", nil)
                     onSelected:^(Book* b) {
                         [fileSelector dismiss];
                         [fileSelector release];
                         fileSelector = nil;
                         if ([self remoteExists:b.name]) {
                             // 上書き確認
                             [AlertDialog confirm:NSLocalizedString(@"overrideConfirm", nil)
                                          message:NSLocalizedString(@"confirmOverride", nil)
                                             onOK:^() {
                                                 [NSThread sleepForTimeInterval:0.3];
                                                 [self startUpload:b];
                                             }];
                             
                         } else {
                             [self startUpload:b];
                             
                         }
                         
                     }
                     onCancel:^() {
                         [fileSelector release];
                         fileSelector = nil;
                     }
                     fromRect:fromRect
                     animated:YES]retain];
}


// ログアウト、アップロード
- (void)dropboxAction:(UISegmentedControl*)sender {
    if (sender.selectedSegmentIndex == 0) {
        [self logout];
    } else if (sender.selectedSegmentIndex == 1) {
        [self selectUploadFile:sender.frame];
    }
    sender.selectedSegmentIndex = -1;
}



// ディレクトリリストが取得されたイベント
- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    [files removeAllObjects];
    [dirs removeAllObjects];
    for (DBMetadata* md in metadata.contents) {
        if (md.isDirectory) {
            [dirs addObject:md.path];
        } else {
            [files addObject:md.path];
        }
    }
    loading = NO;
    [self.tableView reloadData];
}

// ファイルダウンロード中のイベント
- (void)restClient:(DBRestClient *)client 
      loadProgress:(CGFloat)p 
           forFile:(NSString *)destPath {
    progress.progress = p;
}

// ファイルアップロード中のイベント
- (void)restClient:(DBRestClient *)client 
    uploadProgress:(CGFloat)p
           forFile:(NSString *)srcPath {
    progress.progress = p;
}

// ファイルダウンロード失敗のイベント
- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    downloading = NO;
    [AlertDialog alert:NSLocalizedString(@"abort", nil)
               message:[error description]
                  onOK:nil];

    [FileUtil rm:downloadingLocalPath];
    [self disposeDownloadInfo];
    [self dismissProgress];
}

// ファイルアップロード失敗のイベント
- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    uploading = NO;
    uploadingBook = nil;
    [self dismissProgress];
    
    [AlertDialog alert:NSLocalizedString(@"abort", nil)
               message:[error description]
                  onOK:nil]; 
}

// ダウンロード完了のイベント
-(void)restClient:(DBRestClient *)client 
       loadedFile:(NSString *)destPath 
      contentType:(NSString *)contentType {
    downloading = NO;
    [self dismissProgress];
    [AlertDialog alert:NSLocalizedString(@"complete",nil)
               message:NSLocalizedString(@"completeDownload", nil)
                  onOK:nil];
    [self disposeDownloadInfo];
    [BookFiles purge];
}

// アップロード完了のイベント
-(void)restClient:(DBRestClient *)client uploadedFile:(NSString *)srcPath {
    [self dismissProgress];
    uploading = NO;
    uploadingBook = nil;
    [AlertDialog alert:NSLocalizedString(@"complete",nil)
               message:NSLocalizedString(@"completeUpload", nil)
                  onOK:nil];
    [restClient loadMetadata:dir];
    loading = YES;

    
}




#pragma mark - Object lifecycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        NSArray* items = [NSArray arrayWithObjects:NSLocalizedString(@"logout", nil),
                          NSLocalizedString(@"upload", nil), 
                          nil];
        seg = [[UISegmentedControl alloc]initWithItems:items];
        seg.segmentedControlStyle = UISegmentedControlStyleBar;
        seg.tintColor = [UIColor darkGrayColor];
        [seg addTarget:self 
                action:@selector(dropboxAction:) 
      forControlEvents:UIControlEventValueChanged];
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithCustomView:seg]autorelease];
        [seg release];
        restClient = [[DBRestClient alloc]initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
        files = [[NSMutableArray array]retain];
        dirs = [[NSMutableArray array]retain];
    }
    return self;
}

- (void)dealloc
{
    [self disposeDownloadInfo];
    [progress release];
    [restClient release];
    [files removeAllObjects];
    [files release];
    [dirs removeAllObjects];
    [dirs release];
    [fileSelector release];
    self.dir = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [restClient loadMetadata:dir];
    loading = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self disposeDownloadInfo];
    [progress release];
    progress = nil;
    [restClient release];
    restClient = nil;
    [files removeAllObjects];
    [files release];
    files = nil;
    [dirs removeAllObjects];
    [dirs release];
    dirs = nil;
    [fileSelector release];
    fileSelector = nil;
    self.dir = nil;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ![RootPane isRotationLocked];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// 行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger cnt = [files count] + [dirs count];
    return cnt == 0 ? 1 : cnt;
}

// セルの内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:TABLECELL_FONTSIZE];
    }
    
    if ([files count] + [dirs count] == 0) {
        cell.textLabel.text = loading ? @"loading...." : @"directory empty";
    } else {
        if(indexPath.row < [dirs count]) {
            cell.textLabel.text = [[dirs objectAtIndex:indexPath.row]lastPathComponent];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.imageView.image = [UIImage imageNamed:@"folder.gif"];
        } else {
            NSInteger idx = indexPath.row - [dirs count];
            cell.textLabel.text = [[files objectAtIndex:idx]lastPathComponent];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.imageView.image = [UIImage imageNamed:@"page_white.gif"];
        }
    }
    return cell;
}


#pragma mark - Table view delegate

// セル選択イベント
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO]; // 選択状態の解除

    if (indexPath.row < [dirs count]) {
        // ディレクトリ選択＝掘る
        NSString* path = [dirs objectAtIndex:indexPath.row];
        DropboxPane* dp = [[[DropboxPane alloc]initWithStyle:UITableViewStylePlain]autorelease];
        dp.dir = path;
        [[RootPane instance]pushPane:dp];
    } else {
        // ファイル選択
        NSInteger idx = indexPath.row - [dirs count];
        NSString* path = [files objectAtIndex:idx];
        NSString* ext = [[path pathExtension]lowercaseString];
        if ([[NSSet setWithObjects: @"zip", @"cbz", @"rar", @"cbr", @"pdf", @"png",@"jpg", @"doc", @"docx", @"ppt", @"pptx", @"xls", @"xlsx", nil] member:ext]) {
            // ダウンロード
            NSString* toPath = [AppUtil docPath:[path filename]];
            if ([FileUtil exists:toPath]) {
                [AlertDialog 
                 confirm:res(@"confirm") 
                 message:res(@"confirmRename") 
                 onOK:^{
                     [self startDownload:path toPath:[FileUtil unexistingPath:toPath]];
                 }
                 onCancel:nil
                 okLabel:res(@"renameUnexisting")
                 cancelLabel:res(@"cancel")];
            } else {
                [self startDownload:path toPath:toPath];
            }
        }
    }
}

@end
