//
//  PrefTableCellNib.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/07/31.
//  Copyright 2011 SAT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefTableCell.h"

@interface PrefTableCellNib : NSObject {
    PrefTableCell* cell;
}
@property(nonatomic,retain) IBOutlet PrefTableCell* cell;

@end
