//
//  StampLibrary.h
//  ForIphone
//  スタンプの登録画像ライブラリ
//  Created by 藤田正訓 on 11/08/15.
//  Copyright 2011 SAT. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface StampLibrary : NSObject {
    @private
    NSMutableArray* files;
}
-(NSInteger)imageCount;
-(void)addImage:(UIImage*)img;
-(UIImage*)getImageAt:(NSInteger)idx;
-(void)deleteImageAt:(NSInteger)idx;
+(StampLibrary*)library;

@end
