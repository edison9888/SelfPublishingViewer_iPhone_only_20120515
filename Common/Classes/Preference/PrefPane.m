//
//  PrefPane.m
//

#import "PrefPane.h"
#import "common.h"
#import "RootPane.h"
#import "PrefTableCell.h"
#import "PrefTableCellNib.h"
#import "AppUtil.h"
#import "PrefSampleCell.h"
#import "NSString_Util.h"
#import "ImageUtil.h"

@implementation PrefPane

@synthesize tableView,versionLabel;

// キーの配列定義
- (id)init
{
    self = [super init];
    if (self) {
        boolPrefKeys = [[NSArray arrayWithObjects:
                         @"leftNext", // 開く方向
                         @"rotation", // デバイスの回転に追従
                         @"spread", // 見開き表示
                         @"separateCover", // 表紙だけ単独
                         @"pageAnimation", // ページアニメーション:スクロール/めくり
                         @"pageMarginEffect",// 綴じ代の影
                         @"shelfFilename",//本棚でファイル名表示
                         nil]retain];
        shelfTypeKeys = [[NSArray arrayWithObjects:
                          @"black",
                          @"choco",
                          @"yellow",
//                          @"green",
//                          @"camouflage",
                          @"pastel",
                          @"japan",
                          @"red",
                          @"stars",
                          @"wood",
                          @"wbox",
                          @"wbox2",
                          @"wbox3",
                          nil]retain];
    }
    return self;
}

- (void)dealloc
{
    [boolPrefKeys release];
    [shelfTypeKeys release];
    self.tableView = nil;
    self.versionLabel = nil;
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
    NSString* ver = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleVersion"];
    versionLabel.text = ver;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [boolPrefKeys release];
    boolPrefKeys = nil;
    [shelfTypeKeys release];
    shelfTypeKeys = nil;
    self.tableView = nil;
    self.versionLabel = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationItem.title = NSLocalizedString(@"prefPane",nil);
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

// セクション数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

// 行数
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [boolPrefKeys count];
    } else {
        return shelfTypeSelecting ? [shelfTypeKeys count] + 1 : 1;
    }
}

// SegmentatedControlの選択イベント
- (void)confChanged:(UISegmentedControl*)sender {
    if (sender.enabled) {
        NSUserDefaults* ud = [AppUtil config];
        NSString* key = [boolPrefKeys objectAtIndex:sender.tag];
        if ([key isEqualToString:@"leftNext"]) {
            [ud setBool:(sender.selectedSegmentIndex == 0) forKey:key];
        } else {
            [ud setBool:(sender.selectedSegmentIndex == 1) forKey:key];
        }
        [ud synchronize];            
    }
}

- (void)onOffChanged:(UISwitch*)sender {
    if (sender.enabled) {
        NSUserDefaults* ud = [AppUtil config];
        NSString* key = [boolPrefKeys objectAtIndex:sender.tag];
        if ([key isEqualToString:@"rotation"]) {
            NSLog(@"ON %d", sender.on);
            [RootPane instance].rotationLock = !sender.on;
        } else {
            [ud setBool:sender.on forKey:key];
            [ud synchronize];        
        }
    }
}


// セルの表示
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults* ud = [AppUtil config];
    if (indexPath.section == 0) {
        static NSString *CellIdentifier0 = @"PrefTableCell";
        PrefTableCell* cell = (PrefTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier0];
        if (cell == nil) {
            PrefTableCellNib* cellNib = [[[PrefTableCellNib alloc]init]autorelease];
            cell = cellNib.cell;
            
            UISegmentedControl* sc = cell.segmentControl;
            [sc addTarget:self action:@selector(confChanged:) forControlEvents:UIControlEventValueChanged];
            
            UISwitch* sw = cell.onOffSwitch;
            [sw addTarget:self action:@selector(onOffChanged:) forControlEvents:UIControlEventValueChanged];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.font = [UIFont systemFontOfSize:TABLECELL_FONTSIZE];
        }
        NSString* key = [boolPrefKeys objectAtIndex:indexPath.row];
        cell.label.text = NSLocalizedString(key, nil);
        
        UISegmentedControl* acseg = cell.segmentControl;
        UISwitch* sw = cell.onOffSwitch;
        if ([key isEqualToString:@"leftNext"]) {
            acseg.enabled = NO;
            acseg.selectedSegmentIndex = [ud boolForKey:key] ? 0 : 1;
            acseg.enabled = YES;
            acseg.tag = indexPath.row;
            acseg.hidden = NO;
            sw.hidden = YES;
            [acseg setTitle:NSLocalizedString(@"leftward", nil) forSegmentAtIndex:0];
            [acseg setTitle:NSLocalizedString(@"rightward", nil) forSegmentAtIndex:1];
        } else if ([key isEqualToString:@"pageAnimation"]) {
            acseg.enabled = NO;
            acseg.selectedSegmentIndex = [ud boolForKey:key] ? 1 : 0;
            acseg.enabled = YES;
            acseg.tag = indexPath.row;
            acseg.hidden = NO;
            sw.hidden = YES;
            [acseg setTitle:NSLocalizedString(@"scroll", nil) forSegmentAtIndex:0];
            [acseg setTitle:NSLocalizedString(@"curl", nil) forSegmentAtIndex:1];
        } else {
            acseg.hidden = YES;
            sw.hidden = NO;
            [sw setOn:[ud boolForKey:key] animated:NO];
            
            sw.tag = indexPath.row;
        }
        return cell;
        
        
    } else {
        // 本棚背景の選択肢
        static NSString *CellIdentifier1 = @"PrefSampleCell";
        PrefSampleCell* cell = (PrefSampleCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        if (cell == nil) {
            cell = [PrefSampleCell createCell];
        }
        
        NSString* st = [ud valueForKey:@"shelfType"];
        if (indexPath.row == 0) {
            // 頭の一行
            cell.nameLabel.text = res(@"shelfType");
            cell.subLabel.text = shelfTypeSelecting ? @"" : res(st);
            cell.sampleImageView.image = nil;
            cell.checkMark.hidden = YES;
        } else {
            // 選択肢
            NSString* type = [shelfTypeKeys objectAtIndex:indexPath.row - 1];
            UIImage* img = [UIImage imageNamed:[type add:@".png"]];
            UIImage* cimg = [ImageUtil clip:img rect:CGRectMake(0.1, 0.3, 0.3, 0.3)];
            
            cell.nameLabel.text = res(type);
            cell.sampleImageView.image = cimg;
            cell.subLabel.text = @"";
            
            if ([st eq:type]) {
                cell.nameLabel.textColor = [UIColor blueColor];
                cell.checkMark.hidden = NO;
            } else {
                cell.nameLabel.textColor = [UIColor blackColor];
                cell.checkMark.hidden = YES;
            }
        }
        return cell;
    }
    
}



// セル高さの定義
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return PF_SEGROW_HEIGHT;
    } else {
        return PF_ROW_HEIGHT;
    }
}

- (CGFloat)tableView:(UITableView *)tv heightForHeaderInSection:(NSInteger)section {
    return PF_ROW_HEIGHT;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"\n\n";
    } else {
        return @"";
    }
}


// セル選択→本棚画像の選択
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO]; // 選択状態の解除
    if (indexPath.section == 1) {
        if (shelfTypeSelecting) {
            if (indexPath.row != 0) {
                NSString* type = [shelfTypeKeys objectAtIndex:indexPath.row - 1];
                NSUserDefaults* ud = [AppUtil config];
                [ud setValue:type forKey:@"shelfType"];
                [ud synchronize];
            }
        }
        shelfTypeSelecting = !shelfTypeSelecting;
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
