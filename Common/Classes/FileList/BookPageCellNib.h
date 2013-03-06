//
//  BookCellNib.h
//  ForIPad
//
//  Created by 藤田正訓 on 11/07/26.
//  Copyright 2011 SAT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookPageCell.h"

@interface BookPageCellNib : NSObject {
@private
    BookPageCell* cell;
}
@property(nonatomic,retain)IBOutlet BookPageCell* cell;

@end
