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
    NSInteger count = [self.propertiesArray count]+1;
    if ([self hasInlineDatePicker]) {
        count+=1;
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self hasInlineDatePicker] && [indexPath compare:datePickerPath] == NSOrderedSame)
    {
        return 250;
    }
    return 44;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return !([indexPath isEqual:[self lastIndexPathForTableView:tableView]] || [indexPath compare:datePickerPath] == NSOrderedSame);
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
    NSString * datePickerCellIdentifier = @"datePickerCellIdentifier";
    UITableViewCell * cell = nil;
    if ([[self lastIndexPathForTableView:tableView] isEqual:indexPath]) {
        cell = [tableView dequeueReusableCellWithIdentifier:addCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addCellIdentifier];
        }
        cell.textLabel.text = ADD_TIME_RANGE_STRING;
        UIButton * addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [addButton addTarget:self action:@selector(didSelectAddButton:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = addButton;
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
        OPETimeRangeCell * timeRangeCell = (OPETimeRangeCell *)[tableView dequeueReusableCellWithIdentifier:timeCelIdentifier];
        if (!timeRangeCell) {
            timeRangeCell = [[OPETimeRangeCell alloc] initWithIdentifier:timeCelIdentifier];
        }
        
        OPEDateRange * timeRange = self.propertiesArray[[self indexForPropertiesFromIndexPath:indexPath]];
        
        timeRangeCell.dateRange = timeRange;
        timeRangeCell.didSelectDateButtonBlock = ^(UITableViewCell * cell,BOOL isStartButton) {
            [self didSelecButtonAtIndex:[tableView indexPathForCell:cell] isStartButton:isStartButton];
        };
        timeRangeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([self hasPickerForIndexPath:indexPath]) {
            if([timeRange.startDateComponent isEqual:currentDateComponent])
            {
                [timeRangeCell setStartButtonSelected];
            }
            else if ([timeRange.endDateComponent isEqual:currentDateComponent])
            {
                [timeRangeCell setEndButtonSelected];
                
            }
        }
        else {
            [timeRangeCell setSelectedButtonNone];
        }
        
        
        cell = timeRangeCell;
        cell.accessoryView = nil;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([indexPath isEqual:[self lastIndexPathForTableView:tableView]]) {
        [self addRange];
    }
}

-(void)addRange
{
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
    
    [self.propertiesTableView insertRowsAtIndexPaths:@[[self lastIndexPathForTableView:self.propertiesTableView]] withRowAnimation:UITableViewRowAnimationAutomatic];
}
-(void)didSelectAddButton:(id)sender
{
    [self addRange];
}

-(void)didSelecButtonAtIndex:(NSIndexPath *)indexPath isStartButton:(BOOL)isStartButton;
{
    OPEDateRange * dateRange = self.propertiesArray[[self indexForPropertiesFromIndexPath:indexPath]];
    currentDateComponent = nil;
    if (isStartButton) {
        currentDateComponent = dateRange.startDateComponent;
    }
    else {
        currentDateComponent = dateRange.endDateComponent;
    }
    
    if (![self hasPickerForIndexPath:indexPath]) {
        if ([self hasInlineDatePicker]) {
            NSIndexPath * tempIndexPath = [NSIndexPath indexPathForItem:datePickerPath.row-1 inSection:datePickerPath.section];
            OPETimeRangeCell * timeRangeCell = (OPETimeRangeCell *)[self.propertiesTableView cellForRowAtIndexPath:tempIndexPath];
            [timeRangeCell setSelectedButtonNone];
        }
        [self displayInlineDatePickerForRowAtIndexPath:indexPath];
    }
    
    [[self datePickerCellForIndexPath:indexPath]setDate:currentDateComponent.date animated:YES];
    
}

- (void)displayInlineDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // display the date picker inline with the table content
    [self.propertiesTableView beginUpdates];
    
    BOOL before = NO;   // indicates if the date picker is below "indexPath", help us determine which row to reveal
    if ([self hasInlineDatePicker])
    {
        before = datePickerPath.row < indexPath.row;
    }
    
    BOOL sameCellClicked = (datePickerPath.row - 1 == indexPath.row);
    
    // remove any date picker cell if it exists
    if ([self hasInlineDatePicker])
    {
        [self.propertiesTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:datePickerPath.row inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
        datePickerPath = nil;
    }
    
    if (!sameCellClicked)
    {
        // hide the old date picker and display the new one
        NSInteger rowToReveal = (before ? indexPath.row - 1 : indexPath.row);
        NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:rowToReveal inSection:0];
        
        [self toggleDatePickerForSelectedIndexPath:indexPathToReveal];
        datePickerPath = [NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:0];
    }
    
    // always deselect the row containing the start or end date
    //[self.propertiesTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.propertiesTableView endUpdates];
    
    // inform our date picker of the current date to match the current cell
    //[self updateDatePicker];
}

- (BOOL)hasInlineDatePicker
{
    return (datePickerPath != nil);
}

- (void)toggleDatePickerForSelectedIndexPath:(NSIndexPath *)indexPath
{
    [self.propertiesTableView beginUpdates];
    
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]];
    
    // check if 'indexPath' has an attached date picker below it
    if ([self hasPickerForIndexPath:indexPath])
    {
        // found a picker below it, so remove it
        [self.propertiesTableView deleteRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        // didn't find a picker below it, so we should insert it
        [self.propertiesTableView insertRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.propertiesTableView endUpdates];
}

- (BOOL)hasPickerForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger targetedRow = indexPath.row;
    targetedRow++;
    
    UITableViewCell *checkDatePickerCell =
    [self.propertiesTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetedRow inSection:0]];
    
    return [checkDatePickerCell isKindOfClass:[OPEDatePickerCell class]];
}

-(OPEDatePickerCell *)datePickerCellForIndexPath:(NSIndexPath *)indexPath
{
    if ([self hasPickerForIndexPath:indexPath]) {
        NSInteger targetedRow = indexPath.row;
        targetedRow++;
        
        UITableViewCell *checkDatePickerCell =
        [self.propertiesTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetedRow inSection:0]];
        
        return (OPEDatePickerCell *)checkDatePickerCell;
    }
    return nil;
}

-(void)didSelectDate:(OPEDateComponents *)dateComponent withCell:(UITableViewCell *)cell
{
    currentDateComponent.hour = dateComponent.hour;
    currentDateComponent.minute = dateComponent.minute;
    currentDateComponent.isSunset = dateComponent.isSunset;
    currentDateComponent.isSunrise = dateComponent.isSunrise;
    NSIndexPath * indexPath = [self.propertiesTableView indexPathForCell:cell];
    indexPath = [NSIndexPath indexPathForItem:indexPath.row-1 inSection:indexPath.section];
    OPETimeRangeCell * timeRangeCell = (OPETimeRangeCell *)[self.propertiesTableView cellForRowAtIndexPath:indexPath];
    timeRangeCell.dateRange = self.propertiesArray[[self indexForPropertiesFromIndexPath:indexPath]];
}


- (NSInteger)indexForPropertiesFromIndexPath:(NSIndexPath *)indexPath {
    NSInteger index;
    if ([datePickerPath compare:indexPath] == NSOrderedAscending) {
        index = indexPath.row-1;
    }
    else {
        index = indexPath.row;
    }
    return index;
}
@end
