//
//  OPEDatePickerCell.m
//  OSM POI Editor
//
//  Created by David Chiles on 11/9/13.
//
//

#import "OPEDatePickerCell.h"
#import "OPEStrings.h"

@implementation OPEDatePickerCell

@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        sunriseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [sunriseButton setTitle:SUNRISE_STRING forState:UIControlStateNormal];
        [sunriseButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        sunriseButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        sunsetButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [sunsetButton setTitle:SUNSET_STRING forState:UIControlStateNormal];
        [sunsetButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        sunsetButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        datePicker = [[UIDatePicker alloc] init];
        datePicker.datePickerMode = UIDatePickerModeTime;
        [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        datePicker.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:sunriseButton];
        [self.contentView addSubview:sunsetButton];
        [self.contentView addSubview:datePicker];
        
        [self applyConstraints];
    }
    return self;
}

- (void)dateChanged:(id)sender
{
    if ([sender isEqual:datePicker]) {
        [self newDate:datePicker.date];
    }
    
}

- (void)buttonPressed:(id)sender {
    if([self.delegate respondsToSelector:@selector(didSelectDate:withCell:)])
    {
        OPEDateComponents * currentDateComponent = [[OPEDateComponents alloc] init];
        if ([sender isEqual:sunsetButton]) {
            currentDateComponent.isSunset = YES;
            currentDateComponent.isSunrise = NO;
        }
        else if([sender isEqual:sunriseButton]) {
            currentDateComponent.isSunrise = YES;
            currentDateComponent.isSunset = NO;
        }
        [self.delegate didSelectDate:currentDateComponent withCell:self];
    }
    
}

-(void)newDate:(NSDate *)date {
    if([self.delegate respondsToSelector:@selector(didSelectDate:withCell:)])
    {
        OPEDateComponents * currentDateComponent = [[OPEDateComponents alloc] init];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
        currentDateComponent.hour = components.hour;
        currentDateComponent.minute = components.minute;
        currentDateComponent.isSunset = NO;
        currentDateComponent.isSunrise = NO;
        [self.delegate didSelectDate:currentDateComponent withCell:self];

    }
}

- (NSDate *)date {
    return datePicker.date;
}

- (void)setDate:(NSDate *)date
{
    if(date)
    {
        [datePicker setDate:date animated:NO];
    }
    
}

- (void)setDate:(NSDate *)date animated:(BOOL)animated
{
    if(date)
    {
        [datePicker setDate:date animated:animated];
    }
}

- (void)applyConstraints {
    CGFloat topBuffer = 6;
    CGFloat sideBuffer = 18;
    
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:sunriseButton
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.contentView
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1.0
                                                                    constant:sideBuffer];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:sunriseButton
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1.0
                                               constant:topBuffer];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:sunsetButton
                                              attribute:NSLayoutAttributeRight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeRight
                                             multiplier:1.0
                                               constant:sideBuffer *-1];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:sunsetButton
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1.0
                                               constant:topBuffer];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:datePicker
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:sunsetButton
                                              attribute:NSLayoutAttributeBottom
                                             multiplier:1.0
                                               constant:2];
    [self.contentView addConstraint:constraint];
    
    
}

@end
