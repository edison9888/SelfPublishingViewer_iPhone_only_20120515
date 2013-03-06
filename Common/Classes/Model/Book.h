//
//  Book.h
//

#import <Foundation/Foundation.h>
#import "Viewable.h"
#import "BookImportOperation.h"
#import "OperationManager.h"
#import <Unrar4iOS/Unrar4iOS.h>

@class BookImportOperation;


@interface Book : NSObject<Viewable> {
    @private
    NSString* name;
    NSString* path;
    NSString* uploadingPath;

    NSString *_bookName;
    NSString *_originPath;
    NSString *_bookLocation;
    NSString *_bookDataLocation;
    NSArray * rarBookPageEntries;
    
    NSString* folderName;
    NSMutableArray* pages;
    NSMutableArray* _bookPages;

    NSInteger pdfPageCount;
    NSMutableDictionary* props;
    NSTimeInterval modifiedTime;
    NSMutableArray* folders; 
    NSMutableArray* folderBooks;
    NSMutableDictionary* links;
    BOOL isInFolder;
    BOOL isImported;
    BOOL isImporting;
    BOOL isWeirdFlag;

    NSMutableDictionary* cachedPdfImages;
    Unrar4iOS* unrar;

    
    BookImportOperation      *_importOperation;

}

- (void) loadTheOldPages;
- (void) loadPages;

// 表紙が新しいかどうかをチェックする
- (BOOL)isCoverModifiedSince:(NSTimeInterval)since;
// パスを指定するコンストラクタ
- (id) initWithPath: (NSString*) path;
// パスを指定するオブジェクト生成
+ (id) bookWithPath: (NSString*) bookPath;
// ページのファイル名を返す
- (NSString*) getPageFilename: (NSInteger) pageNum;
// ページ数を返す
- (NSInteger) pageCount;
// ブックマークされているかどうか
- (BOOL) isBookmarked: (NSInteger) page;
// ブックマークする
- (void) addToBookmark: (NSInteger) page;
// 表紙の画像を返す
- (UIImage*) getCoverImage:(CGSize)size;
// 表示の画像を設定する
- (void) setCoverImage: (UIImage*)img;
// ページの画像を返す
- (UIImage*) getPageImage: (NSInteger)pageNum;
- (UIImage *) getHighResPDFImage:(NSInteger)pageNum;

// サムネイル画像を返す
- (UIImage*) getThumbnailImage: (NSInteger)pageNum;
// ページの表示名を返す
- (NSString*) getPageDisplayName: (NSInteger) pageNum;
// ファイルを削除する
- (void) deleteFile;
// 表紙画像とサムネイルを削除する
- (void) deleteThumbnails;
// 複数のフォルダが存在する
-(BOOL)hasFolders;
// フォルダを返す
- (NSArray*)folders;
// 再読み込みを予約する
- (void)invalidate;
// キャッシュしておく
- (void)fetchCache:(NSInteger)pageNum size:(CGSize)size;
// 複製ファイル名の候補
- (NSString*)dupFilenameCandidate;
// 複製を実行する
- (void)duplicateTo:(NSString*)dstPath;
// フォルダの中に入っている
//@property(readonly)BOOL isInFolder;
// 表示名

- (UIImage*) getPageImage: (NSInteger)pageNum;
- (UIImage *) getHighResPDFImage:(NSInteger)pageNum;

- (void)startBookImportOperation;

- (UIImage*) getPDFPageImageInner: (NSInteger)pageNum size:(CGSize)size loadLink:(BOOL)loadLink;

- (UIImage*) getBookPageImage: (NSInteger)pageNum;

- (NSString*) getBookPagePath: (NSInteger) pageNum;

- (UIImage*) getZIPPageImage: (NSInteger)pageNum;

- (UIImage*) getRARPageImage: (NSInteger)pageNum;

@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) NSString *bookName;
@property(nonatomic, retain) NSString *bookLocation;
@property(nonatomic, retain) NSString *bookDataLocation;


// ファイルパス
@property(nonatomic, retain) NSString* path;
@property(nonatomic, retain) NSString* uploadingPath;

@property(nonatomic, retain) NSString* originPath;


@property(nonatomic, retain) NSString* folderName;
@property(nonatomic, retain) NSString* extractedAtDir;

// PDFかどうかを返す
@property(nonatomic, readonly) BOOL isPDF;
@property(nonatomic, readonly) BOOL isImported;
@property(nonatomic, readonly) BOOL isImporting;
@property(nonatomic, readwrite) BOOL isWeirdFlag;

@property(nonatomic, readonly) BOOL isPNG;

@property(nonatomic, readonly) BOOL isJPG;

@property(nonatomic, readonly) BOOL isZIP;
@property(nonatomic, readonly) BOOL isRAR;
@property(nonatomic, readonly) BOOL isDOC;
@property(nonatomic, readonly) BOOL isPPT;
@property(nonatomic, readonly) BOOL isXLS;



// 並び順
@property(nonatomic, readwrite) NSInteger order;
// 読み途中のページ
@property(nonatomic, assign) NSInteger readingPage;
// オブジェクトの更新時刻
@property(nonatomic, assign) NSTimeInterval modifiedTime;
// 自分で作ったものかどうかを返す
@property(nonatomic,readonly) BOOL isSelfMade;

@property(nonatomic,retain) NSMutableDictionary* cachedPdfImages;
// 最後に開かれたものかどうかを返す
@property(nonatomic,readonly) BOOL isLastOpened;


@property(nonatomic,retain) NSMutableArray* pages;
@property(nonatomic,retain) NSMutableArray* bookPages;

@property (nonatomic, retain, readwrite) BookImportOperation *importOperation;

@end

@interface PageMoving : NSObject {
@private
    NSInteger from;
    NSInteger to;
}
@property(nonatomic,assign)NSInteger from;
@property(nonatomic,assign)NSInteger to;
+ (PageMoving*) pageMoving:(NSInteger)from :(NSInteger)to;
@end
