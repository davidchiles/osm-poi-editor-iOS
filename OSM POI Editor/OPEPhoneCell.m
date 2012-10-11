//
//  OPEPhoneCell.m
//  OSM POI Editor
//
//  Created by David Chiles on 4/24/12.
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

#import "OPEPhoneCell.h"



@implementation OPEPhoneCell

@synthesize leftText,textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, 100, 30)];
        leftLabel.backgroundColor = [UIColor clearColor];
        leftLabel.text = leftText;
        leftLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
        leftLabel.textColor = [UIColor colorWithRed:.32 green:.4 blue:.57 alpha:1];
        leftLabel.textAlignment = UITextAlignmentRight;
        [self addSubview:leftLabel];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(void) setLeftText:(NSString *)text
{
    [leftLabel setText:text];
}

-(void) setTextField:(UITextField *)txtField
{
    txtField.frame = CGRectMake(100, 9, 190, 44);
    txtField.font = [UIFont systemFontOfSize:24.0];
    txtField.textAlignment = UITextAlignmentRight;
    
    [self.contentView addSubview:txtField];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
