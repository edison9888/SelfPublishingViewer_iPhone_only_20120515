//
//  PESpecialView.h
//  PEEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PESpecialView;
@protocol PESpecialViewDelegate <NSObject>
@optional

-(void)didSpecialSelected:(PESpecialView *)inView andTag:(int)inTag;
@end

@interface PESpecialView : UIView{
    
    UIImageView *specialImageView;
    UIImageView *selectedSpecialImgView;

    NSString *colorName;

    id <PESpecialViewDelegate> delegate;
}
@property (nonatomic, retain) NSString *colorName;
@property (nonatomic, assign) id <PESpecialViewDelegate> delegate;
@property (nonatomic, retain) UIImageView *specialImageView;
@property (nonatomic, retain) UIImageView *selectedSpecialImgView;
@end
