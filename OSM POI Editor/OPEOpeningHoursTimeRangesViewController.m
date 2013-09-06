//
//  OPEOpeningHoursTimeRangesViewController.m
//  OSM POI Editor
//
//  Created by David on 8/29/13.
//
//

#import "OPEOpeningHoursTimeRangesViewController.h"
#import "OPEOpeningHoursParser.h"
#import "OPETimeRangeCell.h"
#import "ActionSheetDatePicker.h"
#import "OPEStrings.h"


@interface OPEOpeningHoursTimeRangesViewController ()

@end

@implementation OPEOpeningHoursTimeRangesViewController

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.propertiesArray count]+1;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ![indexPath isEqual:[self lastIndexPathForTableView:tableView]];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.propertiesArray removeObjectAtIndex:indexPath.row];
        [tableView beginUpdates];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        //[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * addCellIdentifier = @"addCellIdentifier";
    NSString * timeCelIdentifier = @"timeCelIdentifier";
    UITableViewCell * cell = nil;
    if ([[self lastIndexPathForTableView:tableView] isEqual:indexPath]) {
        cell = [tableView dequeueReusableCellWithIdentifier:addCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addCellIdentifier];
        }
        cell.textLabel.text = @"Add Time Range";
    }
    else {
        OPETimeRangeCell * timeRangeCell = (OPETimeRangeCell *)[tableView dequeueReusableCellWithIdentifier:timeCelIdentifier];
        if (!timeRangeCell) {
            timeRangeCell = [[OPETimeRangeCell alloc] initWithIdentifier:timeCelIdentifier];
        }
        OPEDateRange * timeRange = self.propertiesArray[indexPath.row];
        timeRangeCell.dateRange = timeRange;
        timeRangeCell.didSelectDateButtonBlock = ^(UITableViewCell * cell,BOOL isStartButton) {
            [self didSelecButtonAtIndex:[tableView indexPathForCell:cell].row isStartButton:isStartButton withTableView:tableView];
        };
        timeRangeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell = timeRangeCell;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([indexPath isEqual:[self lastIndexPathForTableView:tableView]]) {
        OPEDateComponents * startDateComponent = [[OPEDateComponents alloc] init];
        OPEDateComponents * endDateComponent = [[OPEDateComponents alloc] init];
        
        startDateComponent.hour = 12;
        startDateComponent.minute = 0;
        endDateComponent.hour = 12;
        endDateComponent.minute = 0;
        
        OPEDateRange * dateRange = [[OPEDateRange alloc] init];
        
        dateRange.startDateComponent = startDateComponent;
        dateRange.endDateComponent = endDateComponent;
        
        [self.propertiesArray addObject:dateRange];
        
        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void)didSelecButtonAtIndex:(NSInteger)index isStartButton:(BOOL)isStartButton withTableView:(UITableView *)tableView;
{
    OPEDateRange * dateRange = self.propertiesArray[index];
    NSDate * currentDate = nil;
    currentDateComponent = nil;
    NSString * pickerTitle = @"";
    if (isStartButton) {
        currentDate = [dateRange.startDateComponent date];
        currentDateComponent = dateRange.startDateComponent;
        pickerTitle = @"Start Time";
    }
    else {
        currentDate = [dateRange.endDateComponent date];
        currentDateComponent = dateRange.endDateComponent;
        pickerTitle = @"End Time";
    }
    
    if (!currentDate) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents* todayComponents = [[NSDateComponents alloc] init];
        
        todayComponents.hour = 12;
        todayComponents.minute = 0;

        currentDate = [gregorian dateFromComponents:todayComponents];
    }
    
    [self showDatePickerWithTitle:pickerTitle withDate:currentDate withIndex:index];
}

-(void)showDatePickerWithTitle:(NSString *)pickerTitle withDate:(NSDate *)currentDate withIndex:(NSInteger)index
{
    ActionSheetDatePicker * datePicker = [[ActionSheetDatePicker alloc] initWithTitle:pickerTitle datePickerMode:UIDatePickerModeTime selectedDate:currentDate target:self action:@selector(dateWasSelected:element:) origin:self.view];
    datePicker.hideCancel = YES;
    __weak ActionSheetDatePicker * weakDatepicker = datePicker;
    [datePicker addCustomButtonWithTitle:SUNRISE_STRING didSelectBlock:^{
        NSLog(@"SUNRISE BUTTON");
        currentDateComponent.isSunrise = YES;
        [weakDatepicker dismissActionPicker];
        [self.propertiesTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
    }];
    //[datePicker addCustomButtonWithTitle:SUNSET_STRING value:SUNSET_STRING];
    [datePicker addCustomButtonWithTitle:SUNSET_STRING didSelectBlock:^{
        NSLog(@"SUNSET BUTTON");
        currentDateComponent.isSunset = YES;
        [weakDatepicker dismissActionPicker];
        [self.propertiesTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }];
    [datePicker showActionSheetPicker];
}

- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:selectedDate];
    currentDateComponent.hour = components.hour;
    currentDateComponent.minute = components.minute;
    currentDateComponent.isSunset = NO;
    currentDateComponent.isSunrise = NO;
    [self.propertiesTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

@end
