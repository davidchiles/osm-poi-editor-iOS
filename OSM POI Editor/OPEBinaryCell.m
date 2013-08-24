//
//  OPEBinaryCell.m
//  OSM POI Editor
//
//  Created by David Chiles on 4/17/12.
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

#import "OPEBinaryCell.h"
#import "OPEConstants.h"

@implementation OPEBinaryCell

@synthesize binaryControl;

- (id)initWithArray:(NSArray *)array reuseIdentifier:(NSString *)reuseIdentifier  withTextWidth:(CGFloat)newTextWidth
{
    self = [self initWithTextWidth:newTextWidth reuseIdentifier:reuseIdentifier];
    if(self)
    {
        [self setupBinaryControl:array];
    }
    return self;
    
    
}
-(NSArray *)orderArray:(NSArray *) array
{
    NSMutableArray * tempArray = [array mutableCopy];
    NSMutableArray * resultArray = [[NSMutableArray alloc] init ];
    
    NSString *search = @"yes";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.value BEGINSWITH[c] %@", search];
    [resultArray addObjectsFromArray: [array filteredArrayUsingPredicate:predicate]];
    
    search = @"no";
    predicate = [NSPredicate predicateWithFormat:@"SELF.value BEGINSWITH[c] %@", search];
    [resultArray addObjectsFromArray: [array filteredArrayUsingPredicate:predicate]];
    
    for (NSString * item in resultArray) {
        [tempArray removeObject:item];
    }
    
    [resultArray addObjectsFromArray:tempArray];
    return [[resultArray copy] valueForKeyPath:@"name"];
}
-(void)selectSegmentWithTitle:(NSString *)title
{
    int item = -1;
    for( int i =0; i < [binaryControl numberOfSegments]; i++)
    {
        if([title isEqualToString:[binaryControl titleForSegmentAtIndex:i]])
        {
            item = i;
        }
    }
    if( item != -1)
    {
        binaryControl.selectedSegmentIndex = item;
    }
    else if ([title isEqualToString:@"yes"])
    {
        binaryControl.selectedSegmentIndex = 0;
    }
    else if ([title isEqualToString:@"no"])
    {
        binaryControl.selectedSegmentIndex = 0;
    }
    else {
        binaryControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    }
}

-(void)setupBinaryControl:(NSArray *)array
{
    [self.binaryControl removeFromSuperview];
    NSArray * controlArray = [NSArray arrayWithArray:[self orderArray:array]];
    self.binaryControl = [[UISegmentedControl alloc] initWithItems:controlArray];
    self.binaryControl.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    [self.contentView addSubview:self.binaryControl];
    [self setNeedsUpdateConstraints];
    
    
    //binaryControl.segmentedControlStyle = UISegmentedControlStylePlain;
    
    if ([controlArray count] == 3) {
        [self.binaryControl setWidth:44 forSegmentAtIndex:0];
        [self.binaryControl setWidth:44 forSegmentAtIndex:1];
        //[binaryControl setWidth:100 forSegmentAtIndex:2];
    }
    
    
}

-(void)updateConstraints
{
    [super updateConstraints];
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:binaryControl
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.leftLabel
                                                                   attribute:NSLayoutAttributeRight
                                                                  multiplier:1.0
                                                                    constant:6];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:binaryControl
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:1.0
                                               constant:40];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:binaryControl
                                              attribute:NSLayoutAttributeRight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeRight
                                             multiplier:1.0
                                               constant:-6];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:binaryControl
                                              attribute:NSLayoutAttributeCenterY
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeCenterY
                                             multiplier:1.0
                                               constant:0];
    [self.contentView addConstraint:constraint];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void) prepareForReuse
{
    [self setNeedsUpdateConstraints];
}

@end
