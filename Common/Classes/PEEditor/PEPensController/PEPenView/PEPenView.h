//
//  PEPenView.h
//  PEEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PEPenView;
@protocol PEPenViewDelgate <NSObject>
@optional
-(void)didPenStyleSelected:(PEPenView *)inView andTag:(int)inTag;
@end

@interface PEPenView : UIView {
    UILabel *penStyleNameLbl;
    UIImageView *penImgView;
    NSString *penName;
    NSString *penImgName;
    
    id<PEPenViewDelgate> delegate;
    NSString *penImgForDrawing;
}
@property (nonatomic, retain) UILabel *penStyleNameLbl;
@property (nonatomic, retain) UIImageView *penImgView;
@property (nonatomic, retain) NSString *penName;
@property (nonatomic, retain) NSString *penImgName;
@property (nonatomic, assign) id<PEPenViewDelgate> delegate;
@property (nonatomic,retain) NSString *penImgForDrawing;

@end
