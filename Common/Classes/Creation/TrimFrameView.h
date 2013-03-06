//
//  TrimFrameView.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/07/27.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TrimFrameView : UIView {
     UIButton* nw;
     UIButton* ne;
     UIButton* sw;
     UIButton* se;

}
@property(nonatomic,retain) IBOutlet UIButton* nw;
@property(nonatomic,retain)IBOutlet UIButton* ne;
@property(nonatomic,retain)IBOutlet UIButton* sw;
@property(nonatomic,retain)IBOutlet UIButton* se;



@end
