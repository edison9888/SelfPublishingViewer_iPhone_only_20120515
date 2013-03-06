
#import "UIView+NIB.h"


@implementation UIView (NIB)

+(id)loadView{
	
	NSArray* objects = [[NSBundle mainBundle] loadNibNamed:[self nibName] owner:self options:nil];
	
	for (id object in objects) {
		if ([object isKindOfClass:self]) {
			UIView *view = object;	
			return view;
		}
	}
	
	[NSException raise:@"WrongNibFormat" format:@"Nib for '%@' must contain one TableViewCell, and its class must be '%@'", [self nibName], [self class]];	
	
	return nil;
}

+ (NSString*)nibName {return [self description]; }

@end
