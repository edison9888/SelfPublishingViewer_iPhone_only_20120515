//
//  PEDrawing.h
//  PhotoEditiong
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PEUtility.h"

@interface PEDrawing : NSObject {
    int stampId;
    NSString *stampName;
    NSString *stampPath;
    float scale;
}

@property(nonatomic,assign)StampType typeOfStamp;
@property(nonatomic,assign) int stampId;
@property(nonatomic,retain) NSString *stampName;
@property(nonatomic,retain) NSString *stampPath;
@property(nonatomic,assign) float scale;
@end

@interface PalletColor : NSObject{
    CGFloat redVal;
    CGFloat greenVal;
    CGFloat blueVal;
}
@property (nonatomic, assign) CGFloat redVal;
@property (nonatomic, assign) CGFloat greenVal;
@property (nonatomic, assign) CGFloat blueVal;
@end