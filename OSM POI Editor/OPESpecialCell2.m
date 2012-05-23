//
//  OPESpecialCell2.m
//  OSM POI Editor
//
//  Created by David Chiles on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OPESpecialCell2.h"

@implementation OPESpecialCell2

@synthesize leftText,rightText;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, 104, 30)];
        leftLabel.backgroundColor = [UIColor clearColor];
        leftLabel.text = leftText;
        leftLabel.font = [UIFont boldSystemFontOfSize:12.0];
        leftLabel.textColor = [UIColor colorWithRed:.32 green:.4 blue:.57 alpha:1];
        leftLabel.textAlignment = UITextAlignmentRight;
        
        rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(118, 7, 182, 30)];
        rightLabel.backgroundColor = [UIColor clearColor];
        rightLabel.font = [UIFont boldSystemFontOfSize:16.0];
        rightLabel.text = rightText;
        rightLabel.textAlignment = UITextAlignmentLeft;
        
        
        
        
        [self addSubview:rightLabel];
        [self addSubview:leftLabel];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setLeftText:(NSString *)txt
{
    leftLabel.text=txt;
}
-(void)setRightText:(NSString *)txt
{
    rightLabel.text=txt;
}


@end
