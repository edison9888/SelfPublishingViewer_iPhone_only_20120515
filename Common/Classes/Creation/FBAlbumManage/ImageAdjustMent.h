//
//  ImageAdjustMent.h
//  Demo_PhotoApp
//
//  Created by Apple on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PEEditorViewController.h"
#import "CustomCellImageAdjustCell.h"
#import "ImagePickDialog.h"
#import "NewBook.h"

@class EGOImageView;
@interface ImageAdjustMent : UIViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,PEEditorViewControllerDelegate>
{
    @private
    NewBook* book;

    IBOutlet UITableView *tblAdjusment;
    UITextField *txtAlbumName;
    
    IBOutlet CustomCellImageAdjustCell *objCustomCell;
    
    int imageForAdjustment;
    NSMutableArray *arrayMyalbum;
    
    IBOutlet UIButton *btnFacebook;
    IBOutlet UIButton *btnPreview;
    IBOutlet UIButton *btnAlbum;
    IBOutlet UIButton *btnCamera;
    
    EGOImageView *imageView;
    ImagePickDialog *imagePicker;
}

@property ( nonatomic , retain ) ImagePickDialog *imagePicker;
@property ( nonatomic , retain ) NewBook *book;

- (IBAction)goToImageFacebookPage:(id)sender;
-(void)getAllDownloadPicturesPath;
-(IBAction)imageAdjustmentTapped:(UIButton *)sender;

-(void)ZipAllImages:(NSString *)name deleteFolder:(BOOL)flag;
//-(void)ZipAllImages:(NSString *)name;
 
- (IBAction)addImageFromAlbum:(UIBarButtonItem*)sender;
- (IBAction)addImageByCamera:(UIBarButtonItem*)sender;

-(void)createTemporaryPreviewZip;
-(IBAction)openBookForPreview:(id)sender;

@end
