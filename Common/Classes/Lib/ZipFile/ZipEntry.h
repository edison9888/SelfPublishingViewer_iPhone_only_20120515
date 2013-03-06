//
//  ZipEntry.h
//  ForIPad
//
// Zipファイル内のエントリ一つを表現するクラス
//  Created by 藤田正訓 on 11/07/11.
//  Copyright 2011 SAT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZipEntry : NSObject {
    NSString* displayName;
    NSData* origFilename;
    NSStringEncoding encoding;
}
- (id)initWithFilename:(const char*)fName;
// もとのファイル名
@property(nonatomic,readonly) const char* fileName;
// 表示用のファイル名
@property(nonatomic,readonly) NSString* displayName;


@end
