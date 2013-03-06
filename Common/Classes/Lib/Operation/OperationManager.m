//
//  OperationManager.m
//  ScanBookShelfReader
//
//  Created by Vlatko Georgievski on 11/2/11.
//  Copyright (c) 2011 Smartebook. All rights reserved.
//

#import "OperationManager.h"


@interface OperationManager ()


@property (nonatomic, retain, readonly ) NSThread *             runLoopThread;

@property (nonatomic, retain, readonly ) NSOperationQueue *     queueForCPU;

@end

@implementation OperationManager

+ (OperationManager *)sharedManager
{
    static OperationManager * sOperationManager;


    if (sOperationManager == nil) {
        @synchronized (self) {
            sOperationManager = [[OperationManager alloc] init];
            assert(sOperationManager != nil);
        }
    }
    return sOperationManager;
}

- (id)init
{
    self = [super init];
    if (self != nil) {

        
        
        self->_queueForCPU = [[NSOperationQueue alloc] init];
        assert(self->_queueForCPU != nil);
        

        self->_runningOperationToTargetMap = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        assert(self->_runningOperationToTargetMap != NULL);
        self->_runningOperationToActionMap = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, NULL);
        assert(self->_runningOperationToActionMap != NULL);
        self->_runningOperationToThreadMap = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        assert(self->_runningOperationToThreadMap != NULL);
        
        
        self->_runLoopThread = [[NSThread alloc] initWithTarget:self selector:@selector(runLoopThreadEntry) object:nil];
        assert(self->_runLoopThread != nil);

        [self->_runLoopThread setName:@"runLoopThread"];
        if ( [self->_runLoopThread respondsToSelector:@selector(setThreadPriority)] ) {
            [self->_runLoopThread setThreadPriority:0.3];
        }

        [self->_runLoopThread start];
    }
    return self;
}

- (void)dealloc
{
    assert(NO);
    [super dealloc];
}


#pragma mark * Operation dispatch

@synthesize runLoopThread = _runLoopThread;

- (void)runLoopThreadEntry
{
    assert( ! [NSThread isMainThread] );
    while (YES) {
        NSAutoreleasePool * pool;

        pool = [[NSAutoreleasePool alloc] init];
        assert(pool != nil);

        [[NSRunLoop currentRunLoop] run];

        [pool drain];
    }
    assert(NO);
}


@synthesize queueForCPU               = _queueForCPU;

- (void)addOperation:(NSOperation *)operation toQueue:(NSOperationQueue *)queue finishedTarget:(id)target action:(SEL)action
{
    assert(operation != nil);
    assert(target != nil);
    assert(action != nil);

    
    
    @synchronized (self) {
        assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToActionMap) );
        assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToThreadMap) );

        assert( CFDictionaryGetValue(self->_runningOperationToTargetMap, operation) == NULL ); 
        assert( CFDictionaryGetValue(self->_runningOperationToActionMap, operation) == NULL ); 
        assert( CFDictionaryGetValue(self->_runningOperationToThreadMap, operation) == NULL );
        
        
        CFDictionarySetValue(self->_runningOperationToTargetMap, operation, target);
        CFDictionarySetValue(self->_runningOperationToActionMap, operation, action);
        CFDictionarySetValue(self->_runningOperationToThreadMap, operation, [NSThread currentThread]);

        assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToActionMap) );
        assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToThreadMap) );
    }
    
    
    [operation addObserver:self forKeyPath:@"isFinished" options:0 context:queue];
    
    
    [queue addOperation:operation];
}


- (void)addCPUOperation:(NSOperation *)operation finishedTarget:(id)target action:(SEL)action
{
    [self addOperation:operation toQueue:self.queueForCPU finishedTarget:target action:action];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if ( [keyPath isEqual:@"isFinished"] ) {
        
        NSOperation *       operation;
        NSOperationQueue *  queue;
        NSThread *          thread;
        
        operation = (NSOperation *) object;
        assert([operation isKindOfClass:[NSOperation class]]);
        assert([operation isFinished]);

        queue = (NSOperationQueue *) context;
        assert([queue isKindOfClass:[NSOperationQueue class]]);

        [operation removeObserver:self forKeyPath:@"isFinished"];
        
        @synchronized (self) {
            

            assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToActionMap) );
            assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToThreadMap) );

            thread = (NSThread *) CFDictionaryGetValue(self->_runningOperationToThreadMap, operation);
            if (thread != nil) {
                [thread retain];
            }
        }

        if (thread != nil) {
            
            [self performSelector:@selector(operationDone:) onThread:thread withObject:operation waitUntilDone:NO];
            
            [thread release];

        }
    } else if (NO) {  
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)operationDone:(NSOperation *)operation
{
    id          target;
    SEL         action;
    NSThread *  thread;

    assert(operation != nil);


    @synchronized (self) {
        
        NSLog(@"survived operation !=nil observer isFinished");

        assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToActionMap) );
        assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToThreadMap) );

        target =         (id) CFDictionaryGetValue(self->_runningOperationToTargetMap, operation);
        action =        (SEL) CFDictionaryGetValue(self->_runningOperationToActionMap, operation);
        thread = (NSThread *) CFDictionaryGetValue(self->_runningOperationToThreadMap, operation);
        assert( (target != nil) == (action != nil) );
        assert( (target != nil) == (thread != nil) );


        if (target != nil) {
            [target retain];

            assert( thread == [NSThread currentThread] );

            CFDictionaryRemoveValue(self->_runningOperationToTargetMap, operation);
            CFDictionaryRemoveValue(self->_runningOperationToActionMap, operation);
            CFDictionaryRemoveValue(self->_runningOperationToThreadMap, operation);
        }
        assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToActionMap) );
        assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToThreadMap) );
    }
   
    
    if (target != nil) {
        if ( ! [operation isCancelled] ) {
            NSLog(@"Will call the action select on MainThread");

            [target performSelector:action withObject:operation];
        }
        
        [target release];
    }
}

- (void)cancelOperation:(NSOperation *)operation
{
    id          target;
    SEL         action;
    NSThread *  thread;

    
    if (operation != nil) {

        [operation cancel];

        
        @synchronized (self) {
            assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToActionMap) );
            assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToThreadMap) );

            target =         (id) CFDictionaryGetValue(self->_runningOperationToTargetMap, operation);
            action =        (SEL) CFDictionaryGetValue(self->_runningOperationToActionMap, operation);
            thread = (NSThread *) CFDictionaryGetValue(self->_runningOperationToThreadMap, operation);
            assert( (target != nil) == (action != nil) );
            assert( (target != nil) == (thread != nil) );


            if (target != nil) {
                CFDictionaryRemoveValue(self->_runningOperationToTargetMap, operation);
                CFDictionaryRemoveValue(self->_runningOperationToActionMap, operation);
                CFDictionaryRemoveValue(self->_runningOperationToThreadMap, operation);
            }
            assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToActionMap) );
            assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToThreadMap) );
        }
    }
}

@end
