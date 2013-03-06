//
//  DropboxFirstPane.h
//  ForIPad
//
//  Created by 川口主税 on 11/08/04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropboxSDK.h"


@interface DropboxFirstPane : UIViewController<DBLoginControllerDelegate> {
    UIButton* useDbButton;
}

@property(nonatomic,retain) IBOutlet UIButton* useDbButton;

@end
