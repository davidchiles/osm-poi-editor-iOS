//
//  OPEBinaryCell.m
//  OSM POI Editor
//
//  Created by David Chiles on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OPEBinaryCell.h"

@implementation OPEBinaryCell

@synthesize leftText,binaryControl;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //cell.textLabel.text = [cellDictionary objectForKey:@"name"];
        leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, 79, 30)];
        leftLabel.backgroundColor = [UIColor clearColor];
        leftLabel.text = leftText;
        leftLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
        leftLabel.textColor = [UIColor colorWithRed:.32 green:.4 blue:.57 alpha:1];
        leftLabel.textAlignment = UITextAlignmentRight;
        [self addSubview:leftLabel];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        //UISwitch * theSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        NSArray *itemArray = [NSArray arrayWithObjects: @"Yes", @"No", @"Unknown", nil];
        binaryControl = [[UISegmentedControl alloc] initWithItems:itemArray];
        binaryControl.frame = CGRectMake(0, 0, 200, 35);
        [binaryControl setWidth:50 forSegmentAtIndex:0];
        [binaryControl setWidth:50 forSegmentAtIndex:1];
        [binaryControl setWidth:100 forSegmentAtIndex:2];
        binaryControl.segmentedControlStyle = UISegmentedControlStylePlain;
        //binaryControl.selectedSegmentIndex = 1;
        //RCSwitchOnOff *theSwitch = [[RCSwitchOnOff alloc] initWithFrame:CGRectMake(220, 8, 94, 27)];
        //RCSwitch * theSwitch = [[RCSwitch alloc] initWithFrame:CGRectMake(0, 0, 94, 27)];
        //[[RCSwitch alloc] initWithFrame:CGRectMake(0, 0, 94, 27)];
        self.accessoryView = binaryControl;
    }
    return self;
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
