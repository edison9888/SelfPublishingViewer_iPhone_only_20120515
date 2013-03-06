//
//  FileSelector.m
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/22.
//  Copyright 2011 SAT. All rights reserved.
//

#import "FileSelector.h"
#import "BookFiles.h"
#import "Book.h"
#import "AppUtil.h"
#import "RootPane.h"

#import "common.h"
@implementation FileSelector

@synthesize cancelButton;


// ポップオーバーで表示する / staticバージョン
+ (FileSelector*)showPopover: (NSString*)message 
                  onSelected:(void (^)(Book* b))onSelectCallback
                    onCancel:(void(^)())onCancelCallback
                    fromRect:(CGRect)fromRect
                    animated:(BOOL)animated {
    FileSelector* fs = [[FileSelector alloc]initWithCallback:message
                                                    onSelect:onSelectCallback
                                                    onCancel:onCancelCallback];
    [fs showPopover:message fromRect:fromRect animated:animated];
    return [fs autorelease];
}


// ポップオーバーで表示する
- (void)showPopover: (NSString*)message
           fromRect:(CGRect)fromRect
           animated:(BOOL)animated {
    UIWindow* win = [AppUtil window];
    CGRect rect = win.frame;
    if ([AppUtil isForIpad]) {
        pop = [[UIPopoverController alloc]initWithContentViewController:self];
        pop.popoverContentSize = self.view.frame.size;
        rect.origin = CGPointMake(0, 0);
        membrane = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 2000, 2000)];
        [win addSubview:membrane];
        
        pop.passthroughViews = [NSArray arrayWithObject:membrane];
        [pop presentPopoverFromRect:fromRect
                             inView:win
           permittedArrowDirections:UIPopoverArrowDirectionAny
                           animated:animated];
        
    } else {
//        RootPane* root = [RootPane instance];
//        CGRect rc = root.navi.view.frame;
//        RectLog(__func__, @"navi.rect", rc);
//        [table reloadData];
//        membrane = [[UIView alloc]initWithFrame:rc];
//        membrane.alpha = 0.4;
//        membrane.backgroundColor = [UIColor blackColor];
//        [root.view addSubview:membrane];
//        [root.view addSubview:self.view];
        [[AppUtil rootViewController] presentModalViewController:self animated:animated];
    }
}


// ポップオーバーを消す
- (void)dismiss {
    if ([AppUtil isForIpad]) {
        [pop dismissPopoverAnimated:YES];
        [pop release];
        pop = nil;
        [membrane removeFromSuperview];
        [membrane release];
        membrane = nil;
        
    } else {
//        [membrane removeFromSuperview];
//        [membrane release];
//        membrane = nil;
//        [self.view removeFromSuperview];
//        RootPane* root = [RootPane instance];
//        [root popPane];
//        
        [[AppUtil rootViewController]dismissModalViewControllerAnimated:YES];
    }
}

// キャンセルしてポップオーバーを消す
- (IBAction)cancel {
    if (onCancel) {
        onCancel();
    }
    [self dismiss];
}



- (void)reload {
    if ([[BookFiles bookFiles] checkReload]) {
        [table reloadData];
    }
}

// 初期化
- (id)initWithCallback:(NSString*)messageStr
              onSelect:(void(^)(Book* b))onSelectCallback 
              onCancel:(void(^)())onCancelCallback {
    self = [super init];
    if (self) {
        onSelected = [onSelectCallback copy];
        onCancel = [onCancelCallback copy];
        message = [messageStr retain];
        cancelButton.title = NSLocalizedString(@"cancel", nil);
        
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
    [pop release];
    [message release];
    [onSelected release];
    [onCancel release];
    self.cancelButton = nil;
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
}

- (void)viewDidUnload
{
    [pop release];
    pop = nil;
    [message release];
    message = nil;
    [onSelected release];
    onSelected = nil;
    [onCancel release];
    onCancel = nil;
    self.cancelButton = nil;
    [super viewDidUnload];
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
	return YES;
}

#pragma mark - Table view data source


// TableViewのセクション数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// TableViewの行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[BookFiles bookFiles] bookCount];
}

// TableViewの各セルの表示
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:TABLECELL_FONTSIZE];
    }
    
    cell.textLabel.text = [[BookFiles bookFiles] bookAtIndex:indexPath.row].name;
    
    return cell;
}

// ヘッダ文字列
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return message;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}



#pragma mark - Table view delegate
// セル選択イベント
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookFiles* bf = [BookFiles bookFiles];
    Book* b = [bf bookAtIndex:indexPath.row];
    if (onSelected) {
        onSelected(b);
    }
}

@end
