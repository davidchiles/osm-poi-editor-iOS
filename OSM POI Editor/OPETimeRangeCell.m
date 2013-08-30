//
//  OpeTimeRangeCell.m
//  OSM POI Editor
//
//  Created by David on 8/29/13.
//
//

#import "OpeTimeRangeCell.h"
#import "ActionSheetDatePicker.h"

@implementation OPETimeRangeCell

@synthesize delegate,dateRange;

-(id)initWithTimeRange:(OPEDateRange *)newDateRange withDelegate:(id<OPETimeRangeCellDelegate>)delegate reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.dateRange = newDateRange;
        self.delegate = delegate;
        
        startTimeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        startTimeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [startTimeButton addTarget:self action:@selector(didSelectStartTimeButton:) forControlEvents:UIControlEventTouchUpInside];
        
        endTimeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        startTimeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [endTimeButton addTarget:self action:@selector(didSelectEndTimeButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self datesWithTimeRange:self.dateRange completionBlock:^(NSDate *startDate, NSDate *endDate) {
            
        }];
        
        [self.contentView addSubview:startTimeButton];
        [self.contentView addSubview:endTimeButton];
        
        toLabel = [[UILabel alloc] init];
        toLabel.translatesAutoresizingMaskIntoConstraints = NO;
        toLabel.text = @"to";
        
        [self.contentView addSubview:toLabel];
        [self needsUpdateConstraints];
        
    }
    return self;
}

-(void)datesWithTimeRange:(OPEDateRange *)dateRange
          completionBlock:(void (^)(NSDate *startDate,NSDate *endDate))dates {
    //convert date range to dates
    
    
}

-(void)didSelectStartTimeButton:(id)sender
{
    
}

-(void)didSelectEndTimeButton:(id)sender
{
    
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
                                              attribute:NSLayoutAttributeLeft
                                             multiplier:1.0
                                               constant:0];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:endTimeButton
                                              attribute:NSLayoutAttributeCenterY
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
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
                                              attribute:NSLayoutAttributeLeft
                                             multiplier:1.0
                                               constant:0];
    [self.contentView addConstraint:constraint];
    
}

@end
