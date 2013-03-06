//
//  PEPhotFrame.h
//  PhotoEditiong
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PEUtility.h"

@interface PEPhotoFrame : NSObject

@property(nonatomic,assign)int photoFrameId;
@property(nonatomic,retain)NSString *photoFrameName;
@property(nonatomic,retain)NSString *photoFramePath;
@end
