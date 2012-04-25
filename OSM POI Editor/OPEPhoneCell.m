//
//  OPEPhoneCell.m
//  OSM POI Editor
//
//  Created by David Chiles on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

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
