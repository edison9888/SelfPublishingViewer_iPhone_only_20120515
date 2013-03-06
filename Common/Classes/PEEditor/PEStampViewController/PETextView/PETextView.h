//
//  PETextView.h
//  PEEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PETextView;
@protocol  PETextViewDelegate <NSObject>
@optional
-(void)didFontTypeSelected:(PETextView *)selectedFontType andTag:(int)inTag;
@end

@interface PETextView : UIView{
    UILabel *fontTypeLbl;
    NSString *fontName;
    id<PETextViewDelegate> delegate;
    
    NSString *fontType;
    CGFloat fontSize;
}
@property (nonatomic, retain) UILabel *fontTypeLbl;
@property (nonatomic, assign) id<PETextViewDelegate> delegate;
@property (nonatomic, retain) NSString *fontName;
@property (nonatomic, retain) NSString *fontType;
@property (nonatomic, assign) CGFloat fontSize;
@end
