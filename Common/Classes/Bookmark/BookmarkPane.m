//
//  BookmarkPane.m
//

#import "common.h"
#import "RootPane.h"
#import "BookmarkPane.h"
#import "DBUtil.h"
#import "FMDatabase.h"
#import "FileUtil.h"
#import "BookPageCellNib.h"
#import "BookPageCell.h"
#import "Bookmarks.h"
#import "BookmarkEntry.h"
#import "Book.h"
#import "BookReaderPane.h"
#import "ImageUtil.h"
#import "AlertDialog.h"

@implementation BookmarkPane
@synthesize records, tableView;
@synthesize compButton,delAllButton,toolBar;


- (void)startEdit {
    isEditing = YES;
    [RootPane instance].navi.navigationBarHidden = YES;
    toolBar.hidden = NO;
    CGRect rc = self.tableView.frame;
    rc.origin.y += toolBar.frame.size.height;
    rc.size.height -= toolBar.frame.size.height;
    self.tableView.frame = rc;
    [self.tableView setEditing:isEditing animated:YES];
}

- (void)endEdit {
    toolBar.hidden = YES;
    [RootPane instance].navi.navigationBarHidden = NO;
    isEditing = NO;
    CGRect rc = self.view.frame;
    rc.origin = CGPointMake(0, 0);
    self.tableView.frame = rc;
    [self.tableView setEditing:NO animated:YES];
}

// 全削除
- (void)deleteAll {
    if ([records count] > 0) {
        [AlertDialog confirm:NSLocalizedString(@"deleteAll", nil)
                     message:NSLocalizedString(@"confirmDeleteAll", nil)
                        onOK:^(){
                            Bookmarks* bm = [Bookmarks bookmarks];
                            [bm removeAll];
                            self.records = nil;
                            [self.tableView reloadData];
                        }];
    }
}

- (void)loadRecords {
    if (!self.records) {
        Bookmarks* bm = [Bookmarks bookmarks];
        self.records = [bm entries];
    }
}


- (void)dealloc
{
    self.tableView = nil;
    self.compButton = nil;
    self.delAllButton = nil;
    self.toolBar = nil;
    self.records = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    self.records = nil;
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    compButton.title = NSLocalizedString(@"done", nil);
    compButton.target = self;
    compButton.action = @selector(endEdit);
    delAllButton.title = NSLocalizedString(@"deleteAll", nil);
    delAllButton.target = self;
    delAllButton.action = @selector(deleteAll);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.records = nil;
    self.tableView = nil;
    self.compButton = nil;
    self.delAllButton = nil;
    self.toolBar = nil;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = NSLocalizedString(@"bookmark",nil);
    UIBarButtonItem* eb = [[UIBarButtonItem alloc]
                           initWithTitle:NSLocalizedString(@"edit",nil) 
                           style:UIBarButtonItemStyleBordered 
                           target:self 
                           action:@selector(startEdit)];
    self.navigationItem.rightBarButtonItem = eb;
    [eb release];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return BM_ROW_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self loadRecords];
    return [records count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BookPageCell";
    BookPageCell *cell = (BookPageCell*)[tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        BookPageCellNib* nib = [[BookPageCellNib alloc]init];
        cell = nib.cell;
        [nib release];
    }
    [self loadRecords];
    BookmarkEntry* entry = [records objectAtIndex:indexPath.row];
    
    cell.mainLabel.text = [NSString stringWithFormat:@"(%d Page)", entry.page + 1];
    cell.pathLabel.text = entry.displayName;
//    CGSize size = CGSizeMake(SF_ICON_WIDTH, SF_ICON_HEIGHT);
//    cell.coverView.image = [ImageUtil shrink:[entry.book getPageImage:entry.page] toSize:size];
    cell.coverView.image = [entry.book getThumbnailImage:entry.page];
    
    return cell;
}

// エディット
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BookmarkEntry* entry = [records objectAtIndex:indexPath.row];
        [entry deleteEntry];
        self.records = nil;
        
        [tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath:indexPath animated:NO]; // 選択状態の解除
    BookmarkEntry* entry = [records objectAtIndex:indexPath.row];
    BookReaderPane* bp = [[BookReaderPane alloc]init];
    RootPane* rp = [RootPane instance];
    [rp showListPane];
    [rp pushPane:bp];
    [bp openBook:entry.book];
    [bp openPage:entry.page];
    [bp release];
}

@end
