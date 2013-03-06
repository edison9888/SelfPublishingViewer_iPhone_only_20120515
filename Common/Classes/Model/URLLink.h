//
//  URLLink.h
//  ForIPad
//
//  Created by 藤田正訓 on 11/08/03.
//  Copyright 2011 SAT. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface URLLink : NSObject {
    CGRect rect;
    NSURL* url;
}
@property(nonatomic,assign)CGRect rect;
@property(nonatomic,retain)NSURL* url;

@end
