//
//  PEPhotoFrameView.h
//  PhotoEditiong
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PEPhotoFrame.h"
#import "PEDrawing.h"
#import "PEStampView.h"

//@class PEPhotoFrameView;
//@protocol PEPhotoFrameViewDelegate <NSObject>
//@optional
//-(void)didFrameSelected:(PEPhotoFrameView *)inFrameView;
//
//@end
@interface PEPhotoFrameView : PEStampView{
   // id<PEPhotoFrameViewDelegate>delegate;
}
@property(nonatomic,retain)PEDrawing *photFrame;
//@property(nonatomic,assign)id<PEPhotoFrameViewDelegate>delegate;
@end
