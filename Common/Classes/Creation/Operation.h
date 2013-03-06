#import "ResourceToken.h"

@interface Operation: NSOperation <ResourceToken> {
	NSObject *object;
	SEL selector;
	id delegate;
}

- (id)initWithObject:(NSObject *)_object withSelector:(SEL)_selector delegate:(id)delegate;

@end
