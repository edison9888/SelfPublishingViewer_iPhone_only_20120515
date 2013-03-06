//
//  commonlog.h
//  ForIphone
//
//  Created by 藤田正訓 on 11/08/13.
//  Copyright 2011 SAT. All rights reserved.
//
/*
#ifdef DEBUG

#if !defined(NSLog)
// ログ出力マクロ
#define NSLog( args... ) NSLog( args, 0 )
// CGRectログ出力
#define RectLog(rect, message) NSLog(@"%@[%0.1f,%0.1f,%0.1f,%0.1f] / %s", \
message, rect.origin.x, rect.origin.y, \
rect.size.width, rect.size.height, __func__)
// UIViewログ出力
#define ViewLog(view, message) NSLog(@"%@[%0.1f,%0.1f,%0.1f,%0.1f]%@ / %s",\
message, view.frame.origin.x, view.frame.origin.y, \
view.frame.size.width, view.frame.size.height,\
view.hidden ? @"hidden":@"", __func__)
// CALayerログ出力
#define LayerLog(layer, message) NSLog(@"%@[%0.1f,%0.1f,%0.1f,%0.1f]%@/%@ / %s",\
message, layer.frame.origin.x, layer.frame.origin.y, \
layer.frame.size.width, layer.frame.size.height,\
layer.hidden ? @"hidden":@"", layer.name, __func__)
// CGPointログ
#define PointLog(pt, message) NSLog(@"%@[%f,%f] / %s", \
message, pt.x, pt.y, __func__)
// CGSizeログ
#define SizeLog(sz, message) NSLog(@"%@[%f,%f] / %s", \
message, sz.width, sz.height, __func__)

#endif

#else

#if !defined (NSLog)
#define NSLog( args... )
#define RectLog(rect, message)
#define ViewLog(view, message)
#define LayerLog(layer,message)
#define PointLog(pt, message)
#define SizeLog(sz, message)
#endif

#endif
*/
