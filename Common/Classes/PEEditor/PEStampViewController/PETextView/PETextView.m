//
//  PETextView.m
//  PEEditor
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

#import "PETextView.h"

@implementation PETextView
@synthesize fontTypeLbl;
@synthesize delegate;
@synthesize fontName;
@synthesize fontType;
@synthesize fontSize;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)layoutSubviews{
    if (nil == self.fontTypeLbl.superview) {
        
        UILabel *_lbl = [[UILabel alloc] initWithFrame:self.bounds];
        _lbl.backgroundColor = [UIColor clearColor];
        _lbl.font = [UIFont fontWithName:self.fontType size:self.fontSize];
        self.fontTypeLbl=_lbl;
        self.fontTypeLbl.text = self.fontName;
        self.fontTypeLbl.numberOfLines = 0;
        self.fontTypeLbl.textAlignment = UITextAlignmentCenter;
        if (self.fontName==@"HuiFont") {
          self.fontTypeLbl.textAlignment = UITextAlignmentLeft;
            CGRect fontSize1=self.fontTypeLbl.frame;
            CGRect changedFontOrigin=CGRectMake(fontSize1.origin.x, fontSize1.origin.y-4, fontSize1.size.width, fontSize1.size.height);
            self.fontTypeLbl.frame=changedFontOrigin;
            
        }   
        [_lbl release];
        _lbl=nil;
        [self addSubview:self.fontTypeLbl];
        
    }
    [super layoutSubviews];
}
- (void)dealloc{
    self.fontType=nil;
    self.fontName=nil;
    [super dealloc];
}
#pragma mark - 

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    self.backgroundColor = [UIColor darkGrayColor];  
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if([self.delegate respondsToSelector:@selector(didFontTypeSelected:andTag:)]){
        [self.delegate didFontTypeSelected:self andTag:self.tag];
    }
    self.backgroundColor = [UIColor clearColor];  

    [super touchesEnded:touches withEvent:event];

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;{
    self.backgroundColor = [UIColor clearColor];  
    
    [super touchesCancelled:touches withEvent:event];
}


@end
