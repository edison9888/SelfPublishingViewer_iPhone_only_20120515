//
//  TableFileListPane.m
//

#import "TableFileListPane.h"
#import "FileListPane.h"
#import "BookFiles.h"
#import "Book.h"
#import "common.h"
#import "BookPageCellNib.h"
#import "BookPageCell.h"
#import "RootPane.h"

@implementation TableFileListPane
@synthesize fileListPane, filenameLabelValid;

- (void)reload {
    BookFiles* bf = [BookFiles bookFiles];
    if ([bf checkReload]) {
        [self.tableView reloadData];
    } else {
        if (fileListPane.book) {
            if ([fileListPane.book isCoverModifiedSince:updatedTime]) {
                [self.tableView reloadData];
            }
        } else {
            if ([bf isCoverModifiedSince:updatedTime]) {
                [self.tableView reloadData];
            }
        }
    }
    updatedTime = [NSDate timeIntervalSinceReferenceDate];
}



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
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
}

- (void)updateLayout {
    // 特に何も無し
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ![RootPane isRotationLocked];
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
    if (fileListPane.book) {
        return [[fileListPane.book folders]count];
    } else {
        return [[BookFiles bookFiles] bookCount];
    }
}

// TableViewの各セルの表示
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BookPageCell";
    
    BookPageCell* cell = (BookPageCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        BookPageCellNib* nib = [[BookPageCellNib alloc]init];
        cell = nib.cell;
        [nib release];
    }
    Book* book = nil;
    if (fileListPane.book) {
        book = [[fileListPane.book folders]objectAtIndex:indexPath.row];
    } else {
        book = [[BookFiles bookFiles] bookAtIndex:indexPath.row];
    }
    cell.mainLabel.text = book.name;
    cell.coverView.image = [book getCoverImage:cell.coverView.frame.size];
    NSString* ext = @"";
    if ([book hasFolders]) {
        ext = [NSString stringWithFormat:@" [%d Folders]", [[book folders]count]];
        cell.badgeView.image = [UIImage imageNamed:@"icon_folder.png"];
    } else {
        cell.badgeView.image = nil;
    }
    cell.pathLabel.text = [NSString stringWithFormat:@"%d / %d Page%@", (book.readingPage + 1), [book pageCount], ext];
    
    if (book.isDOC || book.isPPT || book.isXLS) {
        cell.pathLabel.alpha = 0.0f;
    }
    
    if (fileListPane.selectingMode && !book.isSelfMade) {
        cell.mainLabel.textColor = [UIColor lightGrayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.mainLabel.textColor = [UIColor blackColor];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    return cell;
}



// 編集可能
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (fileListPane.book) {
        return NO;
    } else {
        return YES;
    }
}

// TableViewの編集
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BookFiles* bf = [BookFiles bookFiles];
        [bf deleteBookAt:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

// TableViewの並べ替え
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    [[BookFiles bookFiles]changeBookOrder:fromIndexPath.row to:toIndexPath.row];
}

// TableView並べ替え可能
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TL_ROW_HEIGHT;
}




#pragma mark - Table view delegate
// TableViewのセルがタップされた
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:NO]; // 選択状態の解除
    [fileListPane open:indexPath.row];
}

- (void)startSelection {
    [self.tableView reloadData];
}

- (void)endSelection {
    [self.tableView reloadData];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)setEditMode:(BOOL)editMode {
    self.editing = editMode;
}

- (BOOL)editMode {
    return self.editing;
}

@end
