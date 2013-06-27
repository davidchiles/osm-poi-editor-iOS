//
//  OPEButtonCell.m
//  OSM POI Editor
//
//  Created by David on 6/26/13.
//
//

#import "OPEButtonCell.h"

@implementation OPEButtonCell
@synthesize button = _button;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return self;
}

-(void)setButton:(UIButton *)newButton
{
    [_button removeFromSuperview];
    _button = newButton;
    CGRect contentViewFrame = self.contentView.frame;
    CGRect buttonFrame = CGRectMake(0, 0, contentViewFrame.size.width, contentViewFrame.size.height);
    newButton.frame = buttonFrame;
    newButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.contentView addSubview:_button];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
