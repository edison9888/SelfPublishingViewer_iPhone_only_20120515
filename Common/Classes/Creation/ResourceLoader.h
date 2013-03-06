#import "ResourceToken.h"

@protocol ResourceLoaderDelegate <NSObject>

- (void)loadingResource:(id)resource didFinishWithError:(NSError*)e;
- (void)loadingResourceDidFinish:(id)resource;

@optional
- (void)tokenFinish:(id)token;

@end

@interface ResourceLoader : NSObject {
	NSOperationQueue *queue;
	id userInfo;
}

- (void)cancelAllOperation;
- (void)suspendQueue;
- (void)resumeQueue;

+ (ResourceLoader *)sharedResourceLoader;

- (id<ResourceToken>)loadOperationWithObject:(NSObject *)object forDelegate:(id)delegate 
								withSelector:(SEL)sel;

- (id<ResourceToken>)loadOperationWithObject:(NSObject *)object forDelegate:(id)delegate 
								withSelector:(SEL)sel waitUntilFinished:(BOOL)wait;

- (id<ResourceToken>)loadOperationWithObject:(NSObject *)object forDelegate:(id)delegate 
								withSelector:(SEL)sel waitUntilFinished:(BOOL)wait queuePriority:(NSOperationQueuePriority)priority;

@end
