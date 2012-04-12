//
//  OPEMessage.m
//  OSM POI Editor
//
//  Created by David Chiles on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OPEMessage.h"
#import <QuartzCore/QuartzCore.h>

@implementation OPEMessage

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

#define HEIGHT 40.0
#define WIDTH 180.0
- (id)init
{   
    NSLog(@"super width: %f",self.superview.frame.size.width);
    float x = 320/2-WIDTH/2;
    float y = 55.0;
    CGRect frame = CGRectMake(x, y, WIDTH, HEIGHT);
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.8;
        self.layer.cornerRadius = 5.0;
        self.opaque = NO;
        UILabel * labelText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        labelText.backgroundColor = [UIColor clearColor];
        labelText.textColor = [UIColor whiteColor];
        labelText.text = @"Zoom in to load POI";
        labelText.textAlignment = UITextAlignmentCenter;
        [self addSubview:labelText];
        
    }
    return self;
}
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return [self.superview hitTest:point withEvent:event];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
