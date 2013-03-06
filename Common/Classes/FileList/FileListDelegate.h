//
//  FileListDelegate.h
//

@class FileListPane;

@protocol FileListDelegate

- (void)updateLayout;
- (void)reload;
- (void)startSelection;
- (void)endSelection;

@property(nonatomic,assign) FileListPane* fileListPane;
@property(nonatomic,readwrite) BOOL editMode;
@property(nonatomic,readwrite) BOOL filenameLabelValid;

@end