//
//  OpeTimeRangeCell.m
//  OSM POI Editor
//
//  Created by David on 8/29/13.
//
//

#import "OPETimeRangeCell.h"
#import "OPEOpeningHoursParser.h"


@implementation OPETimeRangeCell

@synthesize dateRange=_dateRange;

-(id)initWithIdentifier:(NSString *)reuseIdentifier
{
    if (self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        
        startTimeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        startTimeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [startTimeButton addTarget:self action:@selector(didSelectTimeButton:) forControlEvents:UIControlEventTouchUpInside];
        
        endTimeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        endTimeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [endTimeButton addTarget:self action:@selector(didSelectTimeButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:startTimeButton];
        [self.contentView addSubview:endTimeButton];
        
        toLabel = [[UILabel alloc] init];
        toLabel.translatesAutoresizingMaskIntoConstraints = NO;
        toLabel.text = @"to";
        
        [self.contentView addSubview:toLabel];
        [self setNeedsUpdateConstraints];
        
    }
    return self;
}

-(void)setDateRange:(OPEDateRange *)newDateRange
{
    _dateRange = newDateRange;
    
    [startTimeButton setTitle:[_dateRange.startDateComponent displayString] forState:UIControlStateNormal];
    [endTimeButton setTitle:[_dateRange.endDateComponent displayString] forState:UIControlStateNormal];
}

-(void)didSelectTimeButton:(id)sender
{
    if (self.didSelectDateButtonBlock) {
        if ([sender isEqual: startTimeButton]) {
            self.didSelectDateButtonBlock(self,YES);
        }
        else {
            self.didSelectDateButtonBlock(self,NO);
        }
    }
}

-(void)updateConstraints
{
    [super updateConstraints];
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:toLabel
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.contentView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.0
                                                                    constant:0];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:toLabel
                                              attribute:NSLayoutAttributeCenterY
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeCenterY
                                             multiplier:1.0
                                               constant:0];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:startTimeButton
                                              attribute:NSLayoutAttributeCenterY
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeCenterY
                                             multiplier:1.0
                                               constant:0];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:startTimeButton
                                              attribute:NSLayoutAttributeLeft
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeLeft
                                             multiplier:1.0
                                               constant:0];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:startTimeButton
                                              attribute:NSLayoutAttributeRight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:toLabel
                                              attribute:NSLayoutAttributeLeft
                                             multiplier:1.0
                                               constant:0];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:startTimeButton
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeHeight
                                             multiplier:1.0
                                               constant:0];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:endTimeButton
                                              attribute:NSLayoutAttributeCenterY
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:toLabel
                                              attribute:NSLayoutAttributeCenterY
                                             multiplier:1.0
                                               constant:0];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:endTimeButton
                                              attribute:NSLayoutAttributeLeft
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:toLabel
                                              attribute:NSLayoutAttributeRight
                                             multiplier:1.0
                                               constant:0];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:endTimeButton
                                              attribute:NSLayoutAttributeRight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeRight
                                             multiplier:1.0
                                               constant:0];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:endTimeButton
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeHeight
                                             multiplier:1.0
                                               constant:0];
    [self.contentView addConstraint:constraint];
    
}

@end
