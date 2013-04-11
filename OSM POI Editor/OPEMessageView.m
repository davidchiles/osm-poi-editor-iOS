//
//  OPEMessage.m
//  OSM POI Editor
//
//  Created by David Chiles on 4/12/12.
//  Copyright (c) 2011 David Chiles. All rights reserved.
//
//  This file is part of POI+.
//
//  POI+ is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  POI+ is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with POI+.  If not, see <http://www.gnu.org/licenses/>.

#import "OPEMessageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation OPEMessageView
@synthesize textLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.8;
        self.layer.cornerRadius = 5.0;
        self.opaque = NO;
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.textAlignment = UITextAlignmentCenter;
        [self addSubview:self.textLabel];   
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
    self = [self initWithFrame:frame];
   
    return self;
}

-(id)initWithIndicator:(BOOL)indicator frame:(CGRect)frame
{
    if (self = [self initWithFrame:frame]) {
        if (indicator) {
            UIActivityIndicatorView * activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            
            CGRect frame = CGRectMake(0, 0, activityIndicatorView.frame.size.width, activityIndicatorView.frame.size.height);
            
            frame.origin.y = (self.frame.size.height - frame.size.height)/2;
            frame.origin.x = frame.origin.y;
            
            activityIndicatorView.frame = frame;
            frame = self.textLabel.frame;
            frame.origin.x = activityIndicatorView.frame.size.width+activityIndicatorView.frame.origin.x+2;
            frame.size.width = self.frame.size.width - frame.origin.x;
            self.textLabel.frame=frame;
            self.textLabel.textAlignment = UITextAlignmentLeft;
            
            [activityIndicatorView startAnimating];
            
            
            [self addSubview:activityIndicatorView];
            
            
        }
    }
    return self;
}

-(id)initWithMessage:(NSString *)message
{
    if(self = [self init])
    {
        self.textLabel.text = message;
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

@end
