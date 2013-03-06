//
//  PEController.h
//  PhotoEditiong
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PEUtility.h"

@interface PEController : NSObject {
    int brush_Size;
    NSString *normalColorImageName,*specialColorImageName; 
    NSString *normalColorRgb,*specialColorRgb;
}

@property(nonatomic,retain) NSString *normalColorImageName,*specialColorImageName,*normalColorRgb,*specialColorRgb;
@property(nonatomic,assign) int brush_Size;
@property(nonatomic,assign)BrushType brushType;

@end
