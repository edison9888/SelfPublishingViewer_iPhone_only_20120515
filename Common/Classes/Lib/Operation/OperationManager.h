//
//  OperationManager.h
//  ScanBookShelfReader
//
//  Created by Vlatko Georgievski on 11/2/11.
//  Copyright (c) 2011 Smartebook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OperationManager : NSObject
{
    NSThread *                      _runLoopThread;
    NSOperationQueue *              _queueForCPU;
    CFMutableDictionaryRef          _runningOperationToTargetMap;
    CFMutableDictionaryRef          _runningOperationToActionMap;
    CFMutableDictionaryRef          _runningOperationToThreadMap;
}

+ (OperationManager *)sharedManager;

- (void)addCPUOperation:(NSOperation *)operation finishedTarget:(id)target action:(SEL)action;
- (void)cancelOperation:(NSOperation *)operation;

@end
