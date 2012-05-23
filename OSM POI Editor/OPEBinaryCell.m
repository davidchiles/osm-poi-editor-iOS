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
        leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, 104, 30)];
        leftLabel.backgroundColor = [UIColor clearColor];
        leftLabel.text = leftText;
        leftLabel.font = [UIFont boldSystemFontOfSize:12.0];
        leftLabel.textColor = [UIColor colorWithRed:.32 green:.4 blue:.57 alpha:1];
        leftLabel.textAlignment = UITextAlignmentRight;
        [self addSubview:leftLabel];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        //UISwitch * theSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        NSArray *itemArray = [NSArray arrayWithObjects: @"Yes", @"No", nil];
        binaryControl = [[UISegmentedControl alloc] initWithItems:itemArray];
        binaryControl.frame = CGRectMake(0, 0, 100, 35);
        binaryControl.segmentedControlStyle = UISegmentedControlStylePlain;
        //binaryControl.selectedSegmentIndex = 1;
        //RCSwitchOnOff *theSwitch = [[RCSwitchOnOff alloc] initWithFrame:CGRectMake(220, 8, 94, 27)];
        //RCSwitch * theSwitch = [[RCSwitch alloc] initWithFrame:CGRectMake(0, 0, 94, 27)];
        //[[RCSwitch alloc] initWithFrame:CGRectMake(0, 0, 94, 27)];
        self.accessoryView = binaryControl;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier array:(NSArray *)array
{
    self = [self initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier];
    if(self)
    {
        NSArray * controlArray = [NSArray arrayWithArray:[self orderArray:array]];
        binaryControl = [[UISegmentedControl alloc] initWithItems:controlArray];
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
    NSMutableArray * tempArray = [array mutableCopy];
    NSMutableArray * resultArray = [[NSMutableArray alloc] init ];
    
    NSString *search = @"Yes";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[c] %@", search];
    [resultArray addObjectsFromArray: [array filteredArrayUsingPredicate:predicate]];
    
    search = @"No";
    predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[c] %@", search];
    [resultArray addObjectsFromArray: [array filteredArrayUsingPredicate:predicate]];
    
    for (NSString * item in resultArray) {
        [tempArray removeObject:item];
    }
    
    [resultArray addObjectsFromArray:tempArray];
    return [resultArray copy];
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
