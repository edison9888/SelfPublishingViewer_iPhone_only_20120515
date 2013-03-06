//
//  SettingPane.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/16.
//  Copyright 2011 SAT. All rights reserved.
//

#import "SettingPane.h"
#import "SettingTableCell.h"
#import "NSString_Util.h"
#import "AppUtil.h"
#import "WritingManualPane.h"
#import "RootPane.h"
#import "common.h"

@implementation SettingPane
@synthesize pageMemo;
@synthesize helpButton,tableView;


#pragma mark - action
-(IBAction)showHelp {
    WritingManualPane* mp = [[WritingManualPane alloc]init];
    [[RootPane instance]pushPane:mp];
    [mp release];
}

-(void)setDisplayConf:(UISwitch*)sw {
    NSString* udid = [pageMemo writingUdidAt:sw.tag];
    [pageMemo setVisible:sw.on udid:udid index:sw.tag];
}

#pragma mark - tableView delegate,dataSource

// セルの内容
-(UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* ident = @"SettingTableCell";
    SettingTableCell* cell = (SettingTableCell*)[tv dequeueReusableCellWithIdentifier:ident];
    if (!cell) {
        cell = [SettingTableCell createCell];
    }
    int row = indexPath.row;
    NSString* wid = [pageMemo writingUdidAt:row];
    
    if ([wid eq:[AppUtil udid]]) {
        cell.mainLabel.text = res(@"myWriting");
    } else {
        cell.mainLabel.text = res(@"othersWriting");
    }
    cell.displaySwitch.tag = indexPath.row;
    cell.displayLabel.text = res(@"display");
    cell.thumbView.image = [pageMemo writingImageAt:row];
    [cell.displaySwitch addTarget:self action:@selector(setDisplayConf:) forControlEvents:UIControlEventValueChanged];
    
    cell.displaySwitch.on = [pageMemo isVisible:wid index:indexPath.row];
    
    return cell;
}

// セクション数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// 行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [pageMemo writingCount];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return WSET_ROW_HEIGHT;
}

// ヘッダ高さ
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return WSET_HEADER_HEIGHT;
}
// ヘッダタイトル
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"レイヤー";
}

// セル移動
-(void)tableView:(UITableView *)tv moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [pageMemo changeWritingOrder:sourceIndexPath.row to:destinationIndexPath.row];
    [tv reloadData];
}

// セル削除
-(void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 削除イベント
        [pageMemo deleteWritingAt:indexPath.row];
        [tv reloadData];
        
    } else {
        
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}



#pragma mark - view event

-(void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"setting";
}


#pragma mark - object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.helpButton = nil;
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
    tableView.editing = YES;
    tableView.alwaysBounceVertical = YES;
    [helpButton setTitle:res(@"writingHelp") forState:UIControlStateNormal];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.helpButton = nil;
    self.tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ![RootPane isRotationLocked];
}

@end
