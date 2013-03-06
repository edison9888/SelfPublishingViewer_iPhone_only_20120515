//
//  PageMemoComment.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/13.
//  Copyright 2011 SAT. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PageMemoComment : NSObject {
    NSString* path;
    CGPoint point;
    NSString* comment;
    NSInteger commentId;
}
@property(nonatomic,readonly)NSString* path;
@property(nonatomic,assign)CGPoint point;
@property(nonatomic,retain)NSString* comment;
@property(nonatomic,readonly)BOOL isNew;
@property(nonatomic,readonly)NSInteger commentId;
-(id)initWithPath:(NSString*)commentPath ;
-(void)save;
@end
