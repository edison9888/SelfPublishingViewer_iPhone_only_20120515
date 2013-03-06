//
//  HTTPDownloadPane.m
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/28.
//  Copyright 2011 SAT. All rights reserved.
//

#import "HTTPDownloadPane.h"
#import "common.h"
#import "DownloadURLs.h"
#import "DownloadPane.h"
#import "RootPane.h"

@implementation HTTPDownloadPane

@synthesize urlField,tableView,inputView,saveButton;
@synthesize help,btn2,btn1;

#pragma mark - HTTPDownloadPaneとしての機能

- (void)resignField {
    if ([urlField canResignFirstResponder]) {
        [urlField resignFirstResponder];
    }
}


- (void)updateButtonState {
    if ([urls isLimit]) {
        saveButton.hidden = YES;
    } else {
        saveButton.hidden = NO;
    }
}

// 
- (void)showDownloadPane:(NSString*)url {
    [self resignField];
    DownloadPane* dp = [[DownloadPane alloc]init];
    [[RootPane instance]pushPane:dp];
    [dp go:url];
    //[dp release];
}

// 今回だけ利用
- (IBAction)useOnetime {
    if ([urlField.text length] > 0) {
        [self showDownloadPane:urlField.text];
    }
}
// 保存して利用
- (IBAction)useSaving {
    NSString* url = urlField.text;
    if ([url length] > 0) {
        [urls addURL:url];
        [self updateButtonState];
        [tableView reloadData];
        [self showDownloadPane:url];
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TABLECELL_NALLOWHEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [urls count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
// セルの内容
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:TABLECELL_FONTSIZE];
    }
    
    cell.textLabel.text = [urls getURLAtIndex:indexPath.row];
    return cell;
}

// セル選択イベント
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tv deselectRowAtIndexPath:indexPath animated:NO];
    urlField.text = [urls getURLAtIndex:indexPath.row];
    [self resignField];

}


#pragma mark - UITableView editing
- (void)tableView:(UITableView *)tv 
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [urls removeURLAt:indexPath.row];
        [tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                  withRowAnimation:YES];
        [self updateButtonState];
    }
}



// セルの移動
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    [urls move:fromIndexPath.row to:toIndexPath.row];
}




#pragma mark - 

- (void)toggleEdit:(UIBarButtonItem*)item {
    if (!tableView.editing) {
        [tableView setEditing:YES];
        item.title = NSLocalizedString(@"complete", nil);
        item.style = UIBarButtonItemStyleDone;
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rc = inputView.frame;
            rc.origin.y = -rc.size.height;
            inputView.frame = rc;
            tableView.frame = self.view.frame;
        }];
    } else {
        [tableView setEditing:NO];
        item.title = NSLocalizedString(@"edit", nil);
        item.style = UIBarButtonItemStyleBordered;
        [UIView animateWithDuration:0.5 animations:^ {
            CGRect rc = inputView.frame;
            rc.origin.y = 0;
            inputView.frame = rc;
            CGRect trc = self.view.frame;
            trc.origin.y = rc.size.height;
            trc.size.height -= rc.size.height;
            tableView.frame = trc;
        }];
    }
    [self resignField];
}

#pragma mark - Object lifecycle

- (id)init {
    self = [super init];
    if (self) {
        urls = [[DownloadURLs alloc]init];
    }
    return self;
}

- (void)dealloc
{
    [urls release];
    self.urlField = nil;
    self.tableView = nil;
    self.inputView = nil;
    self.saveButton = nil;
    self.help = nil;
    self.btn1 = nil;
    self.btn2 = nil;
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
    
    UIBarButtonItem* sb = [[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"edit", nil)
                                   style:UIBarButtonItemStyleBordered
                                   target:self action:@selector(toggleEdit:)];
    self.navigationItem.rightBarButtonItem = sb;
    [sb release];
    [self updateButtonState];

    help.text = NSLocalizedString(@"downloadHelp", nil);
    [btn1 setTitle:NSLocalizedString(@"useOnce", nil) forState:UIControlStateNormal];
    [btn2 setTitle:NSLocalizedString(@"useSaving", nil) forState:UIControlStateNormal];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [urls release];
    urls = nil;
    self.urlField = nil;
    self.tableView = nil;
    self.inputView = nil;
    self.saveButton = nil;
    self.help = nil;
    self.btn1 = nil;
    self.btn2 = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ![RootPane isRotationLocked];
}

@end
