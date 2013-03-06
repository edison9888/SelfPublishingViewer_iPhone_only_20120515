//
//  PEPenView.m
//  PEEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import "PEPenView.h"


@implementation PEPenView
@synthesize penStyleNameLbl,penImgView;
@synthesize penName,penImgName;
@synthesize delegate;
@synthesize penImgForDrawing;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		//statement
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)layoutSubviews{
    if (nil == self.penImgView.superview) {
        NSLog(@"self.penImgName: %@", self.penImgName);
        UIImageView *_imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.penImgName]];
        self.penImgView=_imageView;
        [self addSubview:_imageView];
        [_imageView release];
        UILabel *_lbl;
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
          _lbl = [[UILabel alloc] initWithFrame:CGRectMake(self.penImgView.frame.origin.x+self.penImgView.frame.size.width+30, self.penImgView.frame.origin.y-self.penImgView.frame.size.height+16, 400, 100)];   
        }
        else{
           _lbl = [[UILabel alloc] initWithFrame:CGRectMake(self.penImgView.frame.origin.x+self.penImgView.frame.size.width+30, self.penImgView.frame.origin.y-self.penImgView.frame.size.height-25, 100, 100)];  
        }
        _lbl.backgroundColor=[UIColor clearColor];
        _lbl.textColor = [UIColor whiteColor];
        self.penStyleNameLbl = _lbl;
        self.penStyleNameLbl.text = self.penName;
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
            self.penStyleNameLbl.font=[UIFont  boldSystemFontOfSize:30.0f];
        }
        else{
            self.penStyleNameLbl.font=[UIFont  boldSystemFontOfSize:15.0f];
            }
       // self.penStyleNameLbl.font=[UIFont fontWithName:@"Helvetica Bold"size:15];
        [self addSubview:_lbl];
        [_lbl release];
    }
    [super layoutSubviews];
}
- (void)dealloc
{
    self.penImgView=nil;
    self.penStyleNameLbl=nil;
    self.penName=nil;
    self.penImgName=nil;
    self.penImgForDrawing=nil;
    [super dealloc];
}
#pragma mark - 
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if([self.delegate respondsToSelector:@selector(didPenStyleSelected:andTag:)]){
        [self.delegate didPenStyleSelected:self andTag:self.tag];
    }
}
@end
