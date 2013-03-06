#import "ResourceLoader.h"
#import "Operation.h"

static ResourceLoader* sharedResourceLoader = nil;

@implementation ResourceLoader

- (id)init {
	if(![super init]) return nil;
	queue = [NSOperationQueue new];
	return self;
}


- (id<ResourceToken>)queueOperation:(Operation*)op waitUntilFinished:(BOOL)wait {
	if (wait) {
		if ([queue respondsToSelector:@selector(addOperations: waitUntilFinished:)])	// supported on iOS 4.0 & greater
			 [queue addOperations:[NSArray arrayWithObject:op] waitUntilFinished:YES];
		else 
			[queue addOperation:op];
	}
	else
		[queue addOperation:op];
	
	return op;
}

- (id<ResourceToken>)queueOperation:(Operation*)op {	
	return [self queueOperation:op waitUntilFinished:NO];
}


- (id<ResourceToken>)loadOperationWithObject:(NSObject *)object forDelegate:(id)delegate 
								withSelector:(SEL)sel {
	
	Operation *operation = [[[Operation alloc] initWithObject:object withSelector:sel delegate:delegate] autorelease];
	[operation setQueuePriority:NSOperationQueuePriorityNormal];
	[operation setThreadPriority:0.5];

	return [self queueOperation:operation];
}


- (id<ResourceToken>)loadOperationWithObject:(NSObject *)object forDelegate:(id)delegate 
								withSelector:(SEL)sel waitUntilFinished:(BOOL)wait {

	return [self loadOperationWithObject:object 
							 forDelegate:delegate 
							withSelector:sel 
					   waitUntilFinished:wait 
						   queuePriority:NSOperationQueuePriorityNormal];
}


- (id<ResourceToken>)loadOperationWithObject:(NSObject *)object forDelegate:(id)delegate 
								withSelector:(SEL)sel waitUntilFinished:(BOOL)wait queuePriority:(NSOperationQueuePriority)priority {

	Operation *operation = [[[Operation alloc] initWithObject:object withSelector:sel delegate:delegate] autorelease];
	[operation setQueuePriority:priority];
	
	switch (priority) {
		case NSOperationQueuePriorityVeryLow:
			[operation setThreadPriority:0.0];
			break;
		case NSOperationQueuePriorityLow:
			[operation setThreadPriority:0.25];
			break;
		case NSOperationQueuePriorityNormal:
			[operation setThreadPriority:0.5];
			break;
		case NSOperationQueuePriorityHigh:
			[operation setThreadPriority:0.75];
			break;
		case NSOperationQueuePriorityVeryHigh:
			[operation setThreadPriority:1.0];
			break;
		default:
			[operation setThreadPriority:0.5];
			break;
	}
	
	return [self queueOperation:operation waitUntilFinished:wait];
}


- (void)cancelAllOperation {
	[queue cancelAllOperations];
}


- (void)suspendQueue {
	[queue setSuspended:YES];
}


- (void)resumeQueue {
	[queue setSuspended:NO];
}


- (void)pauseOperations {
}

#pragma mark singleton methods

+ (ResourceLoader *)sharedResourceLoader {
	@synchronized(self) {
		if(!sharedResourceLoader) {
			sharedResourceLoader = [[ResourceLoader new] autorelease];
		}
	}
	return sharedResourceLoader;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if(!sharedResourceLoader) {
			sharedResourceLoader = [[super allocWithZone:zone] autorelease];
			return sharedResourceLoader;
		} 
	}
	return nil; 
}

- (id)copyWithZone:(NSZone *)zone {	return self; }
- (id)retain { return self;	}
- (unsigned)retainCount { return UINT_MAX; }
- (void)release { }
- (id)autorelease {	return self; }

- (void)dealloc {
	[queue cancelAllOperations];
	[queue release];
	[super dealloc];
}

@end
