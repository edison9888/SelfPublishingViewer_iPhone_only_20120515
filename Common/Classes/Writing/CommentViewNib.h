//
//  CommentViewNib.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/14.
//  Copyright 2011 SAT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommentView.h"

@interface CommentViewNib : NSObject {
    @private
    CommentView* view;
}
@property(nonatomic,retain)IBOutlet CommentView* view;
@end
