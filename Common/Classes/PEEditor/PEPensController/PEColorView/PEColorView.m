//
//  PEColorView.m
//  PEEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import "PEColorView.h"


@implementation PEColorView
@synthesize colorImgView;
@synthesize selectedHvrImgView;
@synthesize coloName;
@synthesize delegate;
@synthesize _color;
@synthesize isViewWithColor;

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
    [super layoutSubviews];

    if (nil == self.colorImgView.superview) {
        UIImageView *_imageView = [[UIImageView alloc] init];//WithImage:[UIImage imageNamed:self.coloName]];
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
              _imageView.frame = CGRectMake(0, 0, 64, 60);
        }
        else{
           _imageView.frame = CGRectMake(0, 0, 32, 30);   
        }
        _imageView.backgroundColor = [UIColor clearColor];
        self.colorImgView=_imageView;
        [self addSubview:_imageView];
        [_imageView release];
    }

}
- (void)dealloc
{
    self.coloName=nil;
    [colorImgView release];
    [selectedHvrImgView release];
    [super dealloc];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if([self.delegate respondsToSelector:@selector(didColorSelected:andTag:)]){
        [self.delegate didColorSelected:self andTag:self.tag];
    }
}
@end
