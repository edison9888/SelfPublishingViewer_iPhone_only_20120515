//
//  ForIphoneAppDelegate.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/07/21.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "FbGraph.h"

@class Reachability;

@interface ForIphoneAppDelegate : NSObject <UIApplicationDelegate> {
    Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;

    FbGraph *fbGraph;
    int checkFlag;
}
@property (nonatomic) int checkFlag;
@property (nonatomic, retain) FbGraph *fbGraph;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic) BOOL onWiFi;
@property (nonatomic) BOOL onCelular;

+(BOOL)isRoutingViaWWan;
+(BOOL)isRoutingViaWiFi;

@end
