//
//  DownloadPane.m
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/28.
//  Copyright 2011 SAT. All rights reserved.
//

#import "DownloadPane.h"
#import "common.h"
#import "ProgressDialog.h"
#import "AlertDialog.h"
#import "FileUtil.h"
#import "BookFiles.h"
#import "Book.h"
#import "RootPane.h"
#import "AppUtil.h"
#import "NSString_Util.h"


@interface DownloadPane()
@property(nonatomic,retain)NSString* url;
@property(nonatomic,retain)NSMutableArray* bookUrls;
@property(nonatomic,retain)ProgressDialog* progress;
@property(nonatomic,retain)NSMutableArray* downloadQueue;
@property(nonatomic,retain)NSURLConnection* downloadConnection;
@property(nonatomic,retain)NSString* localDownloadPath;
@end


@implementation DownloadPane
@synthesize url, bookUrls, progress, downloadQueue, downloadConnection, localDownloadPath;

@synthesize tableView;


#pragma mark - DownloadPaneとしての機能

- (void)cancelDownload {
    [downloadQueue removeAllObjects];
    [downloadConnection cancel];
    self.downloadConnection = nil;
    fileDownloading = NO;
    pageLoading = NO;
    if (localDownloadPath) {
        [FileUtil rm:localDownloadPath];
    }
    [AlertDialog alert:NSLocalizedString(@"cancel", nil)
               message:NSLocalizedString(@"completeCancel", nil)
                  onOK:nil];
}

- (void)enterBackground {
    if ([downloadQueue count] > 0) {
        [downloadQueue removeAllObjects];
        [downloadConnection cancel];
        self.downloadConnection = nil;
    }
}

- (void)enterForeground 
{
    fileDownloading = NO;
    pageLoading = NO;

    if (progress != nil) {
        [progress dismiss];
        
        self.progress = nil;
        [tableView reloadData];
        if ([FileUtil exists:localDownloadPath]) {
            [FileUtil rm:localDownloadPath];
        }
        self.localDownloadPath = nil;
        self.downloadConnection = nil;
        [AlertDialog alert:NSLocalizedString(@"cancel", nil)
                   message:NSLocalizedString(@"completeCancel", nil)
                      onOK:nil];
    }
     
}

- (void)errorCancel:(NSError*)error
{
    [progress dismiss];
        
    self.progress = nil;
    [tableView reloadData];
    //NSLog(@"%@", [error description]);
    if (error) {
        [AlertDialog alert:NSLocalizedString(@"error", nil)
                   message:[error localizedDescription]
                      onOK:nil];
    }
    pageLoading = NO;
    fileDownloading = NO;
    if ([FileUtil exists:localDownloadPath]) {
        [FileUtil rm:localDownloadPath];
    }
    self.localDownloadPath = nil;
    self.downloadConnection = nil;

}


// ダウンロード開始
-(void)doDownload:(NSString*)goUrl toPath:(NSString*)toPath {
    self.localDownloadPath = toPath;
    readByte = 0;
    NSURL *parentURL = [NSURL URLWithString:url];
    
    
    
    NSURL *downURL = [NSURL URLWithString:goUrl relativeToURL:parentURL];
    
    
    NSURLRequest* req = [[NSURLRequest alloc]initWithURL:downURL];
    
    
    NSString* message = [NSString stringWithFormat:@"%@ (%@)",
                         res(@"downloading"),
                         [toPath filename]];
    
    
    self.progress = [ProgressDialog show:message
                                 message:res(@"downloading")
                                onCancel:^(){
                                    [self cancelDownload];
                                }];
    self.downloadConnection = [[[NSURLConnection alloc]
                                initWithRequest:req 
                                delegate:self]autorelease];
    [req release];
}




// キューの先頭をダウンロード開始する
-(void)startDownload {
    NSLog(@"sd");
    if ([downloadQueue count] > 0) {
        NSString* goUrl = [downloadQueue objectAtIndex:0];
        NSLog(@"%@", downloadQueue);
        NSString* fileName = [[goUrl lastPathComponent]stringByReplacingPercentEscapesUsingEncoding:encoding];
        NSString* ext = [[goUrl pathExtension]lowercaseString];
        
        if ([[NSSet setWithObjects: @"zip", @"cbz", @"rar", @"cbr", @"pdf", @"png",@"jpg", @"doc", @"docx", @"ppt", @"pptx", @"xls", @"xlsx", nil] member:ext]) {
            NSLog(@"format supported");
            fileDownloading = YES;
            NSString* toPath = [AppUtil docPath:fileName];
            if ([FileUtil exists:toPath]) {
                [AlertDialog 
                 confirm:fileName
                 message:res(@"confirmRename") 
                 onOK:^{
                     NSLog(@"ok");
                     [self doDownload:goUrl toPath:[FileUtil unexistingPath:toPath]];
                 }
                 onCancel:^{
                     [self cancelDownload];
                 }
                 okLabel:res(@"renameUnexisting") 
                 cancelLabel:res(@"cancel")];
                
            } else {
                [self doDownload:goUrl toPath:toPath];
            }
            
        } else {
            pageLoading = YES;            
            NSString* toPath = [AppUtil tmpPath:@"download.html"];
            if ([FileUtil exists:toPath]) {
                [FileUtil rm:toPath];
            }
            [self doDownload:goUrl toPath:toPath];
        }
    }
    
}


// URL先にアクセスする
-(void)go:(NSString*)goUrl {
    self.url = goUrl;
    [downloadQueue addObject:goUrl];
    [self startDownload];
}

// レスポンス受信
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
    NSHTTPURLResponse* res = (NSHTTPURLResponse*)response;
    if ([res statusCode] == 200) {
        NSString* encName = [response textEncodingName];
        encoding = NSUTF8StringEncoding;

        NSLog(@"What is it I got for encoding : %@", encName);
        if (encName) {
            CFStringEncoding cfenc = CFStringConvertIANACharSetNameToEncoding((CFStringRef)encName);
            encoding = CFStringConvertEncodingToNSStringEncoding(cfenc);
        } else {
            //encoding = NSShiftJISStringEncoding;
            encoding = NSUTF8StringEncoding;
        }
        contentSize = [response expectedContentLength];
    } else {
        NSString * error = [NSString stringWithFormat:@"Status code: %i", [res statusCode]];
        [AlertDialog alert:NSLocalizedString(@"error", nil)
                   message:error
                      onOK:nil];
        [self errorCancel:nil];
    }
}

// データからHTMLを生成する
-(NSString*)getDownloadedHTML {
    NSString* path = localDownloadPath;
    NSString* html = [NSString stringWithContentsOfFile:path
                                               encoding:encoding
                                                  error:nil];
    if (!html) {
        NSStringEncoding encodings[] = {
            NSUTF8StringEncoding,
            NSJapaneseEUCStringEncoding,
            NSShiftJISStringEncoding, 
            NSNonLossyASCIIStringEncoding,
            NSMacOSRomanStringEncoding,
            NSWindowsCP1251StringEncoding,
            NSWindowsCP1252StringEncoding,
            NSWindowsCP1253StringEncoding,
            NSWindowsCP1254StringEncoding,
            NSWindowsCP1250StringEncoding,
            NSISOLatin1StringEncoding,
            NSUnicodeStringEncoding,
            0
        };
        for (int i = 0; encodings[i] != 0; i++) {
            NSStringEncoding enc = encodings[i];
            html = [NSString stringWithContentsOfFile:path encoding:enc error:nil];
            if (html) {
                encoding = enc;
                break;
            }
        }
    }
    return html;    
}

- (void)fetchAllLinks {
    NSError* error;
    NSString* html = [self getDownloadedHTML];
    NSRegularExpression* regex = [NSRegularExpression 
                                  regularExpressionWithPattern:@"<a ([^>]*)>"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    NSArray* atags = [regex matchesInString:html
                                    options:0 
                                      range:NSMakeRange(0, [html length])];
    if ([atags count] > 0) {
        NSRegularExpression* atrex = [NSRegularExpression 
                                      regularExpressionWithPattern:@"href=[\"\']([^\"\']*)[\"\']"
                                      options:NSRegularExpressionCaseInsensitive
                                      error:&error];
        for (NSTextCheckingResult* m in atags) {
            NSString* attrs = [html substringWithRange:[m rangeAtIndex:1]];
            NSTextCheckingResult* am = [atrex firstMatchInString:attrs
                                                         options:0
                                                           range:NSMakeRange(0, [attrs length])];
            if (am.numberOfRanges > 0) {
                NSString* path = [attrs substringWithRange:[am rangeAtIndex:1]];
                NSString* ext = [path pathExtension];
                
                if ([[NSSet setWithObjects: @"zip", @"cbz", @"rar", @"cbr", @"pdf", @"png",@"jpg", @"doc", @"docx", @"ppt", @"pptx", @"xls", @"xlsx", nil] member:ext]) {
                    path = [path stringByReplacingOccurrencesOfString:@"ghttp" withString:@"http"];
                    path = [path stringByReplacingOccurrencesOfString:@"ibihttp" withString:@"http"];
                    NSLog(@"adding path : %@", path);
                    if (![bookUrls containsObject:path]) [bookUrls addObject:path];
                    //[bookUrls addObject:path];
                }
            }
        }
    }
    
    
}


// ダウンロードデータ受信
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if ([data length] > 0) {
        readByte += [data length];
        if (contentSize > 0) {
            progress.progress = readByte / contentSize;
        }
        
        [FileUtil append:data path:localDownloadPath];
    }
}

// ダウンロード完了
-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [progress dismiss];
    self.progress = nil;
    
    if ([downloadQueue count] > 0) {
        [downloadQueue removeObjectAtIndex:0];
    }
    if (pageLoading) {
        pageLoading = NO;
        [self fetchAllLinks];
        self.localDownloadPath = nil;
        
        [tableView reloadData];
        
    } else if (fileDownloading) {
        fileDownloading = NO;
        self.localDownloadPath = nil;
        // キューに残っていれば続けてダウンロード
        if ([downloadQueue count] > 0) {
            [self startDownload];
        } else {
            [AlertDialog alert:NSLocalizedString(@"complete", nil)
                       message:NSLocalizedString(@"completeDownload", nil)
                          onOK:nil];
        }
    }
}



// コネクションエラー
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self errorCancel:error];
}





#pragma mark - UITableViewDelegate, UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return [bookUrls count];
    }
}



// セルの内容
-(UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:TABLECELL_FONTSIZE];
    }
    if (indexPath.section == 0) {
        if (!progress) {
            if ([bookUrls count] > 0) {
                cell.textLabel.text = NSLocalizedString(@"batchDownload", nil);
            } else {
                cell.textLabel.text = NSLocalizedString(@"noFileCanBeDowonload", nil);
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        } else {
            cell.textLabel.text = NSLocalizedString(@"reading", nil);
        }
    } else {
        NSString* burl = [bookUrls objectAtIndex:indexPath.row];
        NSString* fileName = [[burl lastPathComponent]stringByReplacingPercentEscapesUsingEncoding:encoding];
        cell.textLabel.text = fileName;
    }
    return cell;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return NSLocalizedString(@"discoveredFile", nil);
    } else {
        return nil;
    }
}

// セル選択
-(void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tv deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
        // 一括ダウンロード
        for (NSString* burl in bookUrls) {
            [downloadQueue addObject:burl];
        }
        [self startDownload];
        
        
    } else {
        // 個別ダウンロード
        NSString* burl = [bookUrls objectAtIndex:indexPath.row];

        [downloadQueue addObject:burl];
        [self startDownload];
    }
}


#pragma mark - Object lifecycle

- (id)init {
    self = [super init];
    if (self) {
        self.bookUrls = [NSMutableArray array];
        self.downloadQueue = [NSMutableArray array];
    }
    return self;
}



- (void)dealloc
{
    NSLog(@"%s", __func__);
    self.url = nil;
    
    self.progress = nil;

    self.downloadQueue = nil;
    self.downloadConnection = nil;
    self.localDownloadPath = nil;
    
    self.tableView = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.progress = nil;
    self.downloadConnection = nil;
    self.localDownloadPath = nil;
    self.tableView = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ![RootPane isRotationLocked];
}

@end
