//
//  OPESpecialCell2.m
//  OSM POI Editor
//
//  Created by David Chiles on 5/22/12.
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

#import "OPESpecialCell2.h"
#import "OPEConstants.h"

@implementation OPESpecialCell2

@synthesize rightLabel;

- (id)initWithTextWidth:(CGFloat)newTextWidth reuseIdentifier:(NSString *)identifier
{
    self = [super initWithTextWidth:newTextWidth reuseIdentifier:identifier];
    if (self) {
        
        
        self.rightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.rightLabel.backgroundColor = [UIColor clearColor];
        self.rightLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        self.rightLabel.textAlignment = NSTextAlignmentLeft;
        self.rightLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        
        
        
        [self.contentView addSubview:rightLabel];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self needsUpdateConstraints];
        
        
        

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateConstraints
{
    [super updateConstraints];
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:self.rightLabel
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.leftLabel
                                                                   attribute:NSLayoutAttributeRight
                                                                  multiplier:1.0
                                                                    constant:6];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.rightLabel
                                              attribute:NSLayoutAttributeCenterY
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.leftLabel
                                              attribute:NSLayoutAttributeCenterY
                                             multiplier:1.0
                                               constant:0];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.rightLabel
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.leftLabel
                                              attribute:NSLayoutAttributeHeight
                                             multiplier:1.0
                                               constant:0];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.rightLabel
                                              attribute:NSLayoutAttributeRight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeRight
                                             multiplier:1.0
                                               constant:0];
    [self.contentView addConstraint:constraint];
}


@end
