//
//  PEColorView.h
//  PEEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PEColorView;
@protocol PEColorViewDelgate <NSObject>
@optional

-(void)didColorSelected:(PEColorView *)inView andTag:(int)inTag;
@end

@interface PEColorView : UIView {
    
    UIImageView *colorImgView;
    UIImageView *selectedHvrImgView;
    NSString *coloName;
    id <PEColorViewDelgate> delegate;
    
    UIColor *_color;
    
    BOOL isViewWithColor;
    
}
@property (nonatomic, retain) IBOutlet UIImageView *colorImgView;
@property (nonatomic, retain) IBOutlet UIImageView *selectedHvrImgView;
@property (nonatomic, retain) NSString *coloName;
@property (nonatomic, retain) id <PEColorViewDelgate> delegate;

@property (nonatomic, retain) UIColor *_color;
@property (nonatomic, assign) BOOL isViewWithColor;
@end
