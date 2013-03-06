//
//  CommentView.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/14.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommentViewDelegate

-(void)onSave:(NSString*)comment;
-(void)onDelete;
-(void)onClose;

@end


@interface CommentView : UIView {
    @private
     UIButton* deleteButton;
     UIButton* saveButton;
     UIButton* closeButton;
     UITextView* textView;
     UIView* baseView;
    NSObject<CommentViewDelegate>* delegate;
}
@property(nonatomic,retain) IBOutlet UIButton* deleteButton;
@property(nonatomic,retain)IBOutlet UIButton* saveButton;
@property(nonatomic,retain)IBOutlet UIButton* closeButton;
@property(nonatomic,retain)IBOutlet UITextView* textView;
@property(nonatomic,retain)IBOutlet UIView* baseView;
@property(nonatomic,assign)NSObject<CommentViewDelegate>* delegate;
-(void)setComment:(NSString*)comment;
-(IBAction)tapSave:(UIButton*)b;
-(IBAction)tapDelete:(UIButton*)b;
-(IBAction)tapClose:(UIButton*)b;

+(CommentView*)view;
@end
