//
//  PEStampView.h
//  PhotoEditiong
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PEUtility.h"
#import "PEDrawing.h"
@class PEStampView;
@protocol PEStampViewDelegate <NSObject>
@optional
-(void)didStampViewSelected:(PEStampView *)inStamp;
@end
@interface PEStampView : UIView{
    id<PEStampViewDelegate>delegate;
}
@property(nonatomic,retain)PEDrawing *drawing;
@property(nonatomic,assign)id<PEStampViewDelegate>delegate;
@end
