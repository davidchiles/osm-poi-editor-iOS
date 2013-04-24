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
#import "OPEManagedReferenceOsmTag.h"
#import "OPEManagedOsmTag.h"

@implementation OPEBinaryCell

@synthesize leftText,binaryControl;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTextWidth:(float)textWidth
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //cell.textLabel.text = [cellDictionary objectForKey:@"name"];
        if(textWidth > kLeftTextDefaultSize)
        {
            leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, textWidth, 30)];
        }
        else {
            leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, kLeftTextDefaultSize, 30)];
        }
        
        
        leftLabel.backgroundColor = [UIColor clearColor];
        leftLabel.text = leftText;
        leftLabel.font = [UIFont boldSystemFontOfSize:12.0];
        leftLabel.textColor = [UIColor colorWithRed:.32 green:.4 blue:.57 alpha:1];
        leftLabel.textAlignment = UITextAlignmentRight;
        [self addSubview:leftLabel];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier array:(NSArray *)array withTextWidth:(float)textWidth
{
    self = [self initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTextWidth:(float)textWidth];
    if(self)
    {
        NSArray * controlArray = [NSArray arrayWithArray:[self orderArray:array]];
        binaryControl = [[UISegmentedControl alloc] initWithItems:[controlArray valueForKey:@"name"]];
        binaryControl.segmentedControlStyle = UISegmentedControlStylePlain;
        switch ([controlArray count]) {
            case 1:
                binaryControl.frame = CGRectMake(0, 0, 50, 40);
                break;
            case 2:
                 binaryControl.frame = CGRectMake(0, 0, 100, 40);
                break;
            case 3:
                binaryControl.frame = CGRectMake(0, 0, 190, 40);
                [binaryControl setWidth:44 forSegmentAtIndex:0];
                [binaryControl setWidth:44 forSegmentAtIndex:1];
                [binaryControl setWidth:100 forSegmentAtIndex:2];
                break;
            default:
                break;
        }
        self.accessoryView = binaryControl;
        
        
    }
    return self;
    
    
}
-(NSArray *)orderArray:(NSArray *) array
{
    
    return [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        OPEManagedReferenceOsmTag * tag1 = (OPEManagedReferenceOsmTag *)obj1;
        OPEManagedReferenceOsmTag * tag2 = (OPEManagedReferenceOsmTag *)obj2;
        
        if([tag1.tag.value isEqualToString:@"yes"])
        {
            return NSOrderedAscending;
        }
        else if ([tag2.tag.value isEqualToString:@"yes"])
        {
            return NSOrderedDescending;
        }
        else if([tag1.tag.value isEqualToString:@"no"])
        {
            return NSOrderedAscending;
        }
        else if ([tag2.tag.value isEqualToString:@"no"])
        {
            return NSOrderedDescending;
        }
        
        if ([tag1.name length] > [tag2.name length]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([tag1.name length] < [tag2.name length]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
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
-(void) setLeftText:(NSString *)txt
{
    leftLabel.text=txt;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
