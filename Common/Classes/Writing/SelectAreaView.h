//
//  SelectAreaView.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/13.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SelectAreaView : UIView {
    UIImageView* moveHandle;
    UIImageView* resizeHandle;
    UIImage* image;
}
@property(nonatomic,retain)UIImage* image;
@property(nonatomic,readonly)UIImageView* moveHandle;

@end
