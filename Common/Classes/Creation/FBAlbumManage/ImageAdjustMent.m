//
//  ImageAdjustMent.m
//  Demo_PhotoApp
//
//  Created by Apple on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageAdjustMent.h"
#import "RootPane.h"
#import "ZipArchive.h"
#import "FileUtil.h"
#import "EGOImageView.h"
#import "Book.h"
#import "BookFiles.h"
#import "BookReaderPane.h"
#import "AppUtil.h"

@implementation ImageAdjustMent

@synthesize imagePicker;
@synthesize book;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
 
    self.book = [[[NewBook alloc] init] autorelease];
    [self.book removeAllPages];
    tblAdjusment.editing = YES;
    self.navigationItem.title = @"Image Adjustment";
    [arrayMyalbum retain];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"back", nil) style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"save", nil) style:UIBarButtonItemStyleDone target:self action:@selector(CreateTapped:)];

    [btnCamera setTitle:    NSLocalizedString(@"camera", nil) forState:UIControlStateNormal];
    [btnFacebook setTitle:NSLocalizedString(@"addByFacebook", nil) forState:UIControlStateNormal];
    [btnPreview setTitle:NSLocalizedString(@"priview", nil) forState:UIControlStateNormal];
    [btnAlbum setTitle:NSLocalizedString(@"album", nil) forState:UIControlStateNormal];

    [btnCamera setTitle:    NSLocalizedString(@"camera", nil) forState:UIControlStateSelected];
    [btnFacebook setTitle:NSLocalizedString(@"addByFacebook", nil) forState:UIControlStateSelected];
    [btnPreview setTitle:NSLocalizedString(@"priview", nil) forState:UIControlStateSelected];
    [btnAlbum setTitle:NSLocalizedString(@"album", nil) forState:UIControlStateSelected];

    
    // Do any additional setup after loading the view from its nib.
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"WillAppear Called");
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"123tempPreView123.zip"];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:dataPath])
    {
        [fileManager removeItemAtPath:dataPath error:&error];
        self.book.name = nil;
        //[self.book removeAllPages];
     }
    
    if(self.book.pageCount == 0)
        [self getAllDownloadPicturesPath];
    else
        [tblAdjusment reloadData];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationItem.title =  NSLocalizedString(@"imageAdjustment",nil);
}

- (void)viewDidUnload
{
    [tblAdjusment release];
    tblAdjusment = nil;
    imagePicker = nil;
    self.book = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)dealloc {
    imagePicker = nil;
    [self.book release];
    [tblAdjusment release];
    [super dealloc];
}

#pragma mark
#pragma mark UITableView DataSource Method

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   // return [arrayMyalbum count];
    
    return [self.book pageCount];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifire = [NSString stringWithFormat:@"cell%d",indexPath.row];
    EGOImageView *img;
    CustomCellImageAdjustCell *cell = (CustomCellImageAdjustCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifire];
    
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"CustomCellImageAdjustCell" owner:self options:nil];
        cell = objCustomCell;	
        objCustomCell = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//       img = [[EGOImageView alloc]initWithPlaceholderImage:[UIImage imageNamed:@"placeholder.png"]];
    }
    
    [cell.btnAdjustment setTitle:NSLocalizedString(@"imageAdjustment",nil) forState:UIControlStateNormal];
    [cell.btnAdjustment setTitle:NSLocalizedString(@"imageAdjustment",nil) forState:UIControlStateSelected];
    
    cell.imageView.image = [self.book getThumbnailImage:indexPath.row];
    
//    img.imageURL=[NSURL fileURLWithPath:[arrayMyalbum objectAtIndex:indexPath.row]] ;
//    cell.imageView.image = img.image; 
//    [img release];
    
//    if([cell.imageView.image isEqual:[UIImage imageNamed:@"placeholder.png"]] || cell.imageView.image == nil){
//    img.imageURL=[NSURL fileURLWithPath:[arrayMyalbum objectAtIndex:indexPath.row]] ;
//    cell.imageView.image = img.image;  
//    [img release];
//    }
    
    //cell.imageView.image = [UIImage imageWithContentsOfFile:[arrayMyalbum objectAtIndex:indexPath.row]];  
    
//    NSLog(@"%@", [arrayMyalbum objectAtIndex:indexPath.row]);
//    
//    cell.imageView.imageURL = [arrayMyalbum objectAtIndex:indexPath.row];          
    cell.btnAdjustment.tag = indexPath.row;
    return cell;
}

#pragma mark -
#pragma mark UITableView Delegate Methods

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@" Delete Tapped");
    
    //   [FileUtil rm:[arrayMyalbum objectAtIndex:indexPath.row]];
    //    [self getAllDownloadPicturesPath];

    [self.book removePageAt:indexPath.row];
    [tblAdjusment reloadData];
    
}


-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSLog(@"Move Perform");
    
    NSString *strSourcePath = [NSString stringWithFormat:@"%@",[arrayMyalbum objectAtIndex:sourceIndexPath.row]];
    NSString *strDestiPath = [NSString stringWithFormat:@"%@",[arrayMyalbum objectAtIndex:destinationIndexPath.row]];
//    
    [arrayMyalbum replaceObjectAtIndex:sourceIndexPath.row withObject:strDestiPath];
    [arrayMyalbum replaceObjectAtIndex:destinationIndexPath.row withObject:strSourcePath];

    
    [self.book movePage:sourceIndexPath.row to:destinationIndexPath.row];
    [tableView reloadData];
//    [self getAllDownloadPicturesPath];
}


#pragma mark -
#pragma mark User Define Methods

-(void)ZipAllImages:(NSString *)name deleteFolder:(BOOL)flag
{
//    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"ZipFolder"];

//    for(int i = 0;i< [arrayMyalbum count]; i++)
//    {
////        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"ZipFolder"];
//        
//        NSString *picname;
//        picname=[NSString stringWithFormat:@"Image%d.png",i];
//        
//        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
//            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
//        
//        NSString *dataFilePath = [[dataPath stringByAppendingPathComponent:picname] retain];
//        
//        UIImage *img = [UIImage imageWithContentsOfFile:[arrayMyalbum objectAtIndex:i]];
//        [UIImagePNGRepresentation(img) writeToFile:dataFilePath atomically:YES ];
//        
//    }
//    self.book = [[[NewBook alloc] init] autorelease];
    
//    if(self.book)
//    {
//        [self.book removeAllPages];
//    }
//    for(int i = 0;i< [arrayMyalbum count]; i++)
//    {
//        [self.book addPage:[UIImage imageWithContentsOfFile:[arrayMyalbum objectAtIndex:i]]];
//    }
    
    if ([self.book pageCount] > 0)
    {
        self.book.name = name;
        NSString* path = [AppUtil docPath:[book.name add:@".zip"]];
        [self.book makeZipFile:path];
        [self.book deleteTmpdir];
    }

    BOOL isDir=NO;
    NSArray *subpaths;
    NSString *exportPath = dataPath;
    NSFileManager *fileManager = [NSFileManager defaultManager];    
    if ([fileManager fileExistsAtPath:exportPath isDirectory:&isDir] && isDir){
        subpaths = [fileManager subpathsAtPath:exportPath];
    }
    
    NSString *archivePath = [dataPath stringByAppendingString:@".zip"];
    
//    ZipArchive *archiver = [[ZipArchive alloc] init];
//    [archiver CreateZipFile2:archivePath];
//    for(NSString *pathnew in subpaths)
//    {
//        NSString *longPath = [exportPath stringByAppendingPathComponent:pathnew];
//        if([fileManager fileExistsAtPath:longPath isDirectory:&isDir] && !isDir)
//        {
//            [archiver addFileToZip:longPath newname:pathnew];      
//        }
//    }
    
//    BOOL successCompressing = [archiver CloseZipFile2];
//    if(successCompressing)
//    {
        NSLog(@"Success");
        NSString *filePath2 = [documentsDirectory 
                               stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip",name]];
        
        NSError *error1;
        // Attempt the move
        if ([fileManager moveItemAtPath:archivePath toPath:filePath2 error:&error1] != YES)
            NSLog(@"Unable to move file: %@", [error1 localizedDescription]);
        
        // Show contents of Documents directory
        NSLog(@"Documents directory: %@", 
              [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error1]);
        
        if(flag)
        {
            [fileManager removeItemAtPath:archivePath error:&error1];
            [fileManager removeItemAtPath:dataPath error:&error1];
        
            NSString *dataPath1 = [documentsDirectory stringByAppendingPathComponent:@"MyFolder"];//[NSString stringWithFormat:@"%@",name]];
            [fileManager removeItemAtPath:dataPath1 error:&error1];
        }
        
//    }
//    else
//    {
//        NSLog(@"Fail");
//    }
}

-(void)writingDone:(UIImage *)img
{
    NSLog(@"Image Recives");
    
    UIImageView *imgView1, *imgView2,*referenceView;
    
    referenceView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    
    imgView1 = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[arrayMyalbum objectAtIndex:imageForAdjustment]]];
    imgView2 = [[UIImageView alloc] initWithImage:img];
    
    imgView1.frame = CGRectMake(0, 0, 320, 480);
    imgView2.frame = CGRectMake(0, 0, 320, 480);
    
    [referenceView addSubview:imgView1];
    [referenceView addSubview:imgView2];
    
    UIGraphicsBeginImageContext(referenceView.bounds.size);
    [referenceView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSString *strImagePath = [arrayMyalbum objectAtIndex:imageForAdjustment];

    [FileUtil rm:strImagePath];
    
    [UIImagePNGRepresentation(finalImage) writeToFile:strImagePath atomically:YES];

    
    [self.book changeImage:finalImage atPage:imageForAdjustment];
   // [self getAllDownloadPicturesPath];
    
}

-(void)backButtonTapped:(id)sender
{
    [[RootPane instance] popPane];
}
 
-(void)getAllDownloadPicturesPath
{
    NSString* bookDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/MyFolder"];
    arrayMyalbum = [[NSMutableArray alloc] initWithArray:[FileUtil files:bookDir  extensions:[NSArray arrayWithObjects: @"png",nil]]];

    if(self.book)
    {
        [self.book removeAllPages];
    }
    
    self.book = [[[NewBook alloc] init] autorelease];
    for(int i = 0;i< [arrayMyalbum count]; i++)
    {
        [self.book addPage:[UIImage imageWithContentsOfFile:[arrayMyalbum objectAtIndex:i]]];
    }
    [tblAdjusment reloadData];
}

-(void)CreateTapped:(id)sender
{
    UIAlertView* alertAddTestName = [[UIAlertView alloc] init];
    alertAddTestName.tag=1;
    [alertAddTestName setDelegate:self];
    [alertAddTestName setTitle:NSLocalizedString(@"createAlbumTitle", nil)];
    [alertAddTestName setMessage:@" "];
    [alertAddTestName addButtonWithTitle:NSLocalizedString(@"cancel", nil)];
    [alertAddTestName addButtonWithTitle:NSLocalizedString(@"save", nil)];  
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [languages objectAtIndex:0];

    if ([currentLanguage isEqualToString:@"ja"]) {
    
        txtAlbumName = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 45.0, 245.0, 25.0)];
    }    
    else {
        txtAlbumName = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 45.0, 245.0, 25.0)];
    }
    
    [txtAlbumName setBackgroundColor:[UIColor whiteColor]];
    
    [alertAddTestName addSubview:txtAlbumName];
    
    [alertAddTestName show];
    [alertAddTestName release];
    [txtAlbumName release];
}

-(void)saveAlbumImages:(UIImage *)img
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"MyFolder"];
    
    NSString *picname;
    picname=[[[NSString stringWithFormat:@"albumImage%d",[arrayMyalbum count]] stringByAppendingString:@".png"]retain];
    NSError *error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    NSString *dataFilePath = [[dataPath stringByAppendingPathComponent:picname] retain];
    
    [UIImagePNGRepresentation(img) writeToFile:dataFilePath atomically:YES ];

    [self.book addPage:img];
    [tblAdjusment reloadData];
    //    [self getAllDownloadPicturesPath];
}



-(void)createTemporaryPreviewZip
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"MyFolder"];
    BOOL isDir=NO;
    NSArray *subpaths;
    NSString *exportPath = dataPath;
    NSFileManager *fileManager = [NSFileManager defaultManager];    
    if ([fileManager fileExistsAtPath:exportPath isDirectory:&isDir] && isDir){
        subpaths = [fileManager subpathsAtPath:exportPath];
    }
    
    NSString *archivePath = [dataPath stringByAppendingString:@".zip"];
    
    ZipArchive *archiver = [[ZipArchive alloc] init];
    [archiver CreateZipFile2:archivePath];
    for(NSString *pathnew in subpaths)
    {
        NSString *longPath = [exportPath stringByAppendingPathComponent:pathnew];
        if([fileManager fileExistsAtPath:longPath isDirectory:&isDir] && !isDir)
        {
            [archiver addFileToZip:longPath newname:pathnew];      
        }
    }
    BOOL successCompressing = [archiver CloseZipFile2];
    if(successCompressing)
    {
        NSLog(@"Success");
        NSString *filePath2 = [documentsDirectory 
                               stringByAppendingPathComponent:[NSString stringWithFormat:@"temp.zip"]];
        
        NSError *error;
        // Attempt the move
        if ([fileManager moveItemAtPath:archivePath toPath:filePath2 error:&error] != YES)
            NSLog(@"Unable to move file: %@", [error localizedDescription]);
        
        // Show contents of Documents directory
        NSLog(@"Documents directory: %@", 
              [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error]);
    }
    else
    {
        NSLog(@"Fail");
    }
}

-(IBAction)imageAdjustmentTapped:(UIButton *)sender
{
    NSLog(@"Button Pressed :: %d",sender.tag);
    imageForAdjustment = sender.tag;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:imageForAdjustment inSection:0];
    
    CustomCellImageAdjustCell *cell = (CustomCellImageAdjustCell *)[tblAdjusment cellForRowAtIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:@"placeholder.png"];
    
    PEEditorViewController *_editorController = [[PEEditorViewController alloc] initWithNibName:@"PEEditorViewController" bundle:nil];
    
//    _editorController.img = [UIImage imageWithContentsOfFile:[arrayMyalbum objectAtIndex:imageForAdjustment]];
    _editorController.img = [self.book getPageImage:imageForAdjustment];
    _editorController.delegate = self;
    [[RootPane instance]pushPane:_editorController];
    [_editorController release];
    
}

- (IBAction)addImageFromAlbum:(UIBarButtonItem*)sender {
    if (self.imagePicker.visible) {
        [self.imagePicker dismiss];
        self.imagePicker = nil;
    } else {
        // フォトアルバムから選択する
        self.imagePicker = [ImagePickDialog showMultiselectPopover:^(UIImage* img) {
            
            NSLog(@"Block Called");
            [self performSelectorOnMainThread:@selector(saveAlbumImages:) withObject:img waitUntilDone:NO];
        }
                                                     fromBarButton:sender
                                                            inView:self.view];
    }
}

- (IBAction)addImageByCamera:(UIBarButtonItem*)sender {
    if (self.imagePicker.visible) {
        [self.imagePicker dismiss];
        self.imagePicker = nil;
    } else {
        // フォトアルバムから選択する
        self.imagePicker = [ImagePickDialog showCameraPopover:^(UIImage* img) {
            
            NSLog(@"Block Called");
            [self performSelectorOnMainThread:@selector(saveAlbumImages:) withObject:img waitUntilDone:NO];
        }
                                                fromBarButton:sender
                                                       inView:self.view];
    }
}

-(IBAction)openBookForPreview:(id)sender
{
//     self.book = [[[NewBook alloc] init] autorelease];
//    [self.book deleteTmpdir];
//    for(int i = 0;i< [arrayMyalbum count]; i++)
//    {
//        [self.book addPage:[UIImage imageWithContentsOfFile:[arrayMyalbum objectAtIndex:i]]];
//    }
    
    if ([self.book pageCount] > 0)
    {        
        self.book.name = @"123tempPreView123";
        NSString* path = [AppUtil docPath:[book.name add:@".zip"]];
        [self.book makeZipFile:path];
//     [self.book deleteTmpdir];
    
        BookReaderPane* p = [[BookReaderPane alloc]init];
        p.isFromImageAdjustment = YES;
        [p openBook:self.book];
        [p openPage:self.book.readingPage];
        
//        [book1 openBook:b];
        
        [[RootPane instance]pushPane:p];
    }
//    NSLog(@"Book Pages :: %d",[self.book pageCount]);
    
    // My Own Function to make zip File
//    [self ZipAllImages:@"tempPreView" deleteFolder:NO];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"tempPreView.zip"];
//    NSLog(@"Preview Zip :: %@",dataPath);
//    
//    Book* b = [[BookFiles bookFiles] bookAtPath:dataPath];
//    BookReaderPane* p = [[BookReaderPane alloc]init];
//    p.isFromImageAdjustment = YES;
//    [p openBook:b];
//    //[p openBook:b];
//    [p openPage:b.readingPage];
//    [[RootPane instance]pushPane:p];
//    [p release];
    
}

- (IBAction)goToImageFacebookPage:(id)sender {
    
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];
    
}

#pragma mark -
#pragma mark UIAlertView Delegate Method

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        NSLog(@"Cancle Tapped :");
    }
    else if(buttonIndex == 1)
    {
        NSLog(@"OK Tapped :");   
        
        NSString *zipname = txtAlbumName.text;
        [self ZipAllImages:zipname deleteFolder:YES];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



@end
