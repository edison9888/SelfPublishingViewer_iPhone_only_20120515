
#import "ClubView.h"


@implementation ClubView
@synthesize clubDict;
@synthesize delegate;
@synthesize nameLbl,btn,clubImg;


-(void) setImageView :(NSString *)filePath {	
	
	if (imageViewL) {
		imageViewL=nil;
		[imageViewL release];
	}
	
	imageViewL = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"placeholder.png"]];
	imageViewL.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",filePath]];
	[clubImg addSubview:imageViewL];
	[imageViewL setFrame:clubImg.bounds];
	
}


-(void) setLabelName :(NSString *)filePath {
	
	nameLbl.text = filePath;
	
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if([delegate respondsToSelector:@selector(thumbClickAction:)])
		[delegate thumbClickAction:self];
    
}


- (void)dealloc {
	
	[clubImg release];
	[nameLbl release];
    [super dealloc];
}


@end
