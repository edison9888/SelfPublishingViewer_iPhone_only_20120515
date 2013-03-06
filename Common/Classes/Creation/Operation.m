#import "Operation.h"
#import "ResourceToken.h"

@implementation Operation

- (id)initWithObject:(NSObject *)_object withSelector:(SEL)_selector delegate:(id)_delegate {
	if(![super init]) return nil;
	object = [_object retain];
	selector = _selector;	
	delegate = _delegate;
	return self;
}

- (void)cancel {
	delegate = nil;
	if ([object respondsToSelector:@selector(cancel)])
		[object performSelector:@selector(cancel)];
	
	[super cancel];
}

#define RETURN_IF_CANCELED(x) if ([self isCancelled]) { [x release]; return; }

- (void)notifyDelegate:(NSError*)error {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];

	RETURN_IF_CANCELED(pool)
	
	if(!delegate) {
		[pool release];
		return;
	}
	
	if(error) {
		if ([delegate respondsToSelector:@selector(loadingResource:didFinishWithError:)])
			[delegate performSelector:@selector(loadingResource:didFinishWithError:) withObject:object withObject:error];
	} else {
		if ([delegate respondsToSelector:@selector(loadingResourceDidFinish:)])
			[delegate performSelector:@selector(loadingResourceDidFinish:) withObject:object];
	}
	
	if ([delegate respondsToSelector:@selector(tokenFinish:)])
		 [delegate performSelector:@selector(tokenFinish:) withObject:self];
	
	[pool release];
}
- (void)main {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	RETURN_IF_CANCELED(pool)
	NSError *error = [object performSelector:selector];
	RETURN_IF_CANCELED(pool)
//	[self performSelectorOnMainThread:@selector(notifyDelegate:) withObject:error waitUntilDone:NO];
	[self performSelectorInBackground:@selector(notifyDelegate:) withObject:error];
	[pool release];	
} 

- (void)dealloc {
	[object release];
	[super dealloc];
}

@end