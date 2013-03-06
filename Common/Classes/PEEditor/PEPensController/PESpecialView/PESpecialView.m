//
//  PESpecialView.m
//  PEEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import "PESpecialView.h"

@implementation PESpecialView
@synthesize colorName;
@synthesize delegate;
@synthesize specialImageView;
@synthesize selectedSpecialImgView;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
    if (nil == self.specialImageView.superview) {
        UIImageView *_imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.colorName]];
        self.specialImageView=_imageView;
        [self addSubview:_imageView];
        [_imageView release];
        
        UIImageView *_selectedImageView = [[UIImageView alloc] init];
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
            _selectedImageView.frame = CGRectMake(0, 0, 112, 112);
        }
        else{
            _selectedImageView.frame = CGRectMake(0, 0, 57, 57);
        }
        _selectedImageView.backgroundColor = [UIColor clearColor];
        self.selectedSpecialImgView=_selectedImageView;
        [self addSubview:_selectedImageView];
        [_selectedImageView release];
        
    }
    [super layoutSubviews];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if([self.delegate respondsToSelector:@selector(didSpecialSelected:andTag:)]){
        [self.delegate didSpecialSelected:self andTag:self.tag];
    }
}

- (void)dealloc
{
    self.specialImageView=nil;
    self.colorName=nil;
    self.selectedSpecialImgView=nil;
    
    [super dealloc];
}

@end
