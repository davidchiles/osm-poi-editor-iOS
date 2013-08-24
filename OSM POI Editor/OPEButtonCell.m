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
    _button.translatesAutoresizingMaskIntoConstraints = NO;
    //CGRect contentViewFrame = self.contentView.frame;
    //CGRect buttonFrame = CGRectMake(0, 0, contentViewFrame.size.width, contentViewFrame.size.height);
    //newButton.frame = buttonFrame;
    //newButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.contentView addSubview:_button];
    [self needsUpdateConstraints];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateConstraints
{
    [super updateConstraints];
    
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:self.button
                                                                   attribute:NSLayoutAttributeRight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeRight
                                                                  multiplier:1.0
                                                                    constant:0.0];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.button
                                              attribute:NSLayoutAttributeLeft
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeLeft
                                             multiplier:1.0
                                               constant:20];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.button
                                              attribute:NSLayoutAttributeCenterY
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeCenterY
                                             multiplier:1.0
                                               constant:0.0];
    [self.contentView addConstraint:constraint];
    
    /*constraint = [NSLayoutConstraint constraintWithItem:self.button
                                              attribute:NSLayoutAttributeWidth
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeWidth
                                             multiplier:1.0
                                               constant:0.0];
    [self.contentView addConstraint:constraint];*/
    
    constraint = [NSLayoutConstraint constraintWithItem:self.button
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeHeight
                                             multiplier:1.0
                                               constant:0.0];
    [self.contentView addConstraint:constraint];
    
}

@end
