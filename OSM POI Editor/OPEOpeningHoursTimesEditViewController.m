//
//  OPEHoursTimesEditViewController.m
//  OSM POI Editor
//
//  Created by David on 9/5/13.
//
//

#import "OPEOpeningHoursTimesEditViewController.h"
#import "OPEOpeningHoursParser.h"
#import "OPEStrings.h"

@interface OPEOpeningHoursTimesEditViewController ()

@end

@implementation OPEOpeningHoursTimesEditViewController


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * addCellIdentifier = @"addCellIdentifier";
    NSString * timeCelIdentifier = @"timeCelIdentifier";
    NSString * datePickerCellIdentifier = @"datePickerCellIdentifier";
    UITableViewCell * cell = nil;
    if ([[self lastIndexPathForTableView:tableView] isEqual:indexPath]) {
        cell = [tableView dequeueReusableCellWithIdentifier:addCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addCellIdentifier];
        }
        cell.textLabel.text = ADD_TIME_STIRNG;
        UIButton * button = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [button addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = button;
    }
    else if (indexPath.row == datePickerPath.row && [self hasInlineDatePicker])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:datePickerCellIdentifier];
        if (!cell) {
            cell = [[OPEDatePickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:datePickerCellIdentifier];
        }
        ((OPEDatePickerCell *)cell).delegate = self;
        ((OPEDatePickerCell *)cell).date = currentDateComponent.date;
        
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:timeCelIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:timeCelIdentifier];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %ld",TIMES_STRING,[self indexForPropertiesFromIndexPath:indexPath]+1];
        OPEDateComponents * timeComponent = self.propertiesArray[[self indexForPropertiesFromIndexPath:indexPath]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",timeComponent];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([indexPath isEqual:[self lastIndexPathForTableView:tableView]]) {
        [self addButtonPressed:tableView];
    }
    
    if([indexPath compare:datePickerPath] != NSOrderedSame)
    {
        currentDateComponent = self.propertiesArray[[self indexForPropertiesFromIndexPath:indexPath]];
        [self showDatePickerForIndexPath:indexPath withDateComponent:currentDateComponent];
    }
}

- (void)addButtonPressed:(id)sender
{
    newDateComponent = [[OPEDateComponents alloc] init];
    
    newDateComponent.hour = 10;
    newDateComponent.minute = 0;
    
    currentDateComponent = newDateComponent;
    [self.propertiesArray addObject:currentDateComponent];
    [self.propertiesTableView insertRowsAtIndexPaths:@[[self lastIndexPathForTableView:self.propertiesTableView]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)showDatePickerForIndexPath:(NSIndexPath *)indexPath withDateComponent:(OPEDateComponents *)dateComponent
{
    if (![self hasPickerForIndexPath:indexPath]) {
        [self displayInlineDatePickerForRowAtIndexPath:indexPath];
    }
}

-(void)didSelectDate:(OPEDateComponents *)dateComponent withCell:(UITableViewCell *)cell
{
    currentDateComponent.hour = dateComponent.hour;
    currentDateComponent.minute = dateComponent.minute;
    currentDateComponent.isSunset = dateComponent.isSunset;
    currentDateComponent.isSunrise = dateComponent.isSunrise;
    NSIndexPath * indexPath = [self.propertiesTableView indexPathForCell:cell];
    indexPath = [NSIndexPath indexPathForItem:indexPath.row-1 inSection:indexPath.section];
    UITableViewCell * timeCell = (UITableViewCell *)[self.propertiesTableView cellForRowAtIndexPath:indexPath];
    OPEDateComponents * timeComponent = self.propertiesArray[[self indexForPropertiesFromIndexPath:indexPath]];
    timeCell.detailTextLabel.text = [NSString stringWithFormat:@"%@",timeComponent];
}

@end
