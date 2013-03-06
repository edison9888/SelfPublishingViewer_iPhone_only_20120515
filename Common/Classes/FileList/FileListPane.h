//
//  FileListPane.h
//  ファイル一覧の親パネル
//

#import <UIKit/UIKit.h>
#import "common.h"
#import "FileListDelegate.h"

@class BookFiles;
@class Book;
@class PhotoCategory;

@interface FileListPane : UIViewController<UITabBarDelegate> {
    @private
    UIViewController<FileListDelegate>* listView;
     UIView* listArea;
     UISegmentedControl* listChanger;
     UISegmentedControl* listChanger2;
     UIBarButtonItem* editButton;
     UITabBar* tabBar;
     UIToolbar* mainToolBar;
     UIToolbar* folderToolBar;
     UIToolbar* selectToolBar;
     UILabel* editFileSelectLabel;
     UIBarButtonItem* cancelButton;
    UIViewController* musicViewController;
    UIPopoverController* musicPopover;
    Book* book;
    BOOL selectingMode;
    // ブックを多重に開かないようにするロック
    BOOL prepared;
    PhotoCategory *objPhoto;
}

@property(nonatomic,retain) IBOutlet UIView* listArea;
@property(nonatomic,retain)IBOutlet UISegmentedControl* listChanger;
@property(nonatomic,retain)IBOutlet UISegmentedControl* listChanger2;
@property(nonatomic,retain)IBOutlet UIBarButtonItem* editButton;
@property(nonatomic,retain)IBOutlet UITabBar* tabBar;
@property(nonatomic,retain)IBOutlet UIToolbar* mainToolBar;
@property(nonatomic,retain)IBOutlet UIToolbar* folderToolBar;
@property(nonatomic,retain)IBOutlet UIToolbar* selectToolBar;
@property(nonatomic,retain)IBOutlet UILabel* editFileSelectLabel;
@property(nonatomic,retain)IBOutlet UIBarButtonItem* cancelButton;




// ファイル一覧を表現するView
@property(nonatomic, retain) UIViewController<FileListDelegate>* listView;
@property(nonatomic,readonly)BOOL selectingMode;
@property(nonatomic, retain) Book* book;

// 選択モードを解除する
- (IBAction)endSelecting;

// ファイルを開く
- (void)open: (NSInteger)i;
// ファイル一覧をリロードする
- (IBAction)reload;
// ブックマーク画面に遷移する
- (IBAction)showBookmark;
// 編集モードを切り替える
- (IBAction)toggleEdit;
// 共有画面に遷移する
- (IBAction)showShare;
// Dropbox画面を表示する
- (IBAction)showDropbox;
// 設定画面を表示する
- (IBAction)showConfig;
// カメラで自炊機能
- (IBAction)showCreation;
// ミュージックプレイヤー
- (IBAction)showMusicPlayer;

- (IBAction)showHTTPDownload;
// 戻る
- (IBAction)back;

// ファイル一覧ビューを切り替える
- (IBAction)changeFileListView: (UISegmentedControl*) sender;

-(void)authenticationWithFBAccount;
@end
