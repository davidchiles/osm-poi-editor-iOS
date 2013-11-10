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
        NSDate * date = datePicker.date;
        NSLog(@"Date Changed: %@",date);
    }
    
}

- (void)buttonPressed:(id)sender {
    if ([sender isEqual:sunsetButton]) {
        NSLog(@"Sunset Button");
    }
    else if([sender isEqual:sunriseButton]) {
        NSLog(@"Sunrise Button");
    }
}

- (NSDate *)date {
    return datePicker.date;
}

- (void)setDate:(NSDate *)date
{
    [datePicker setDate:date animated:YES];
}

- (void)applyConstraints {
    
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:sunriseButton
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.contentView
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1.0
                                                                    constant:6];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:sunriseButton
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1.0
                                               constant:6];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:sunsetButton
                                              attribute:NSLayoutAttributeRight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeRight
                                             multiplier:1.0
                                               constant:6];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:sunsetButton
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1.0
                                               constant:6];
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
