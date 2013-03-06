//
//  PEOriginalStampView.h
//  PhotoEditiong
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import "PEStampView.h"
@class PEOriginalStampView;
@protocol PEOriginalStampViewDelgate
@optional
-(void)didSelectOriginalStamp:(PEOriginalStampView *)originalStamp;
@end

@interface PEOriginalStampView : PEStampView{
    
}

@property(nonatomic,assign)UIButton *deleteBtn;
//@property(nonatomic,assign)NSObject<PEOriginalStampViewDelgate> *delegate;

@end



