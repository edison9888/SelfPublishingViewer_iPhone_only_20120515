//
//  CreatePane.h
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/25.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewBook.h"
#import "ImagePickDialog.h"
#import "TrimPane.h"


@class FbGraph,PhotoCategory;
@interface CreatePane : UIViewController<UITableViewDelegate,UITableViewDataSource,TrimPaneDelegate> {
    @private
    NewBook* book;
    ImagePickDialog* imagePicker;
    NSInteger trimmingImageIndex;
    UITableView* tableView;
    
//    UIBarButtonItem* cameraButton;
//    UIBarButtonItem* albumButton;
//    UIBarButtonItem* previewButton;
//    UIBarButtonItem* facebookButton;

    UIButton* cameraButton;
    UIButton* albumButton;
    UIButton* previewButton;
    UIButton* facebookButton;

    
 //   FbGraph *fbGraph;
    PhotoCategory *objPhoto;

}
@property(nonatomic,retain) IBOutlet UITableView* tableView;
@property(nonatomic,retain) IBOutlet UIButton* cameraButton;
@property(nonatomic,retain) IBOutlet UIButton* albumButton;
@property(nonatomic,retain) IBOutlet UIButton* previewButton;
@property(nonatomic,retain) IBOutlet UIButton* facebookButton;


@property(nonatomic,retain) ImagePickDialog* imagePicker;
@property(nonatomic,retain) NewBook* book;

// カメラを起動して画像を追加
- (IBAction)addImageByCamera:(UIBarButtonItem*)sender;
// アルバムから画像を追加
- (IBAction)addImageFromAlbum:(UIBarButtonItem*)sender;
// プレビューする
- (IBAction)preview:(UIBarButtonItem*)sender;
// 電子書籍化する
- (IBAction)save:(UIBarButtonItem*)sender;
// 削除
- (void)deleteFiles;

@end
