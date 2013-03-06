//
//  CommentView.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/14.
//  Copyright 2011 SAT. All rights reserved.
//

#import "CommentView.h"
#import "UIView_Effects.h"
#import "CommentViewNib.h"


@implementation CommentView
@synthesize delegate, baseView;
@synthesize deleteButton, saveButton, closeButton, textView;

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [saveButton setTitle:NSLocalizedString(@"save", nil)
                forState:UIControlStateNormal];
    [deleteButton setTitle:NSLocalizedString(@"delete", nil)
                  forState:UIControlStateNormal];
}

-(void)setComment:(NSString*)comment {
    textView.text = comment;
}

-(void)close {
    [self removeFromSuperview];
    [delegate onClose];
}

-(IBAction)tapSave:(UIButton*)b {
    [delegate onSave:textView.text];
    [self close];
}
-(IBAction)tapDelete:(UIButton*)b {
    [delegate onDelete];
    [self close];
}
-(IBAction)tapClose:(UIButton*)b {
    [self close];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

+(CommentView*)view {
    CommentViewNib* nib = [[[CommentViewNib alloc]init]autorelease];
    return nib.view;
}


- (void)dealloc
{
    self.deleteButton = nil;
    self.saveButton = nil;
    self.closeButton = nil;
    self.textView = nil;
    self.baseView = nil;
    [super dealloc];
}

@end
