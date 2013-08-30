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


@interface OPEOpeningHoursTimeRangesViewController ()

@end

@implementation OPEOpeningHoursTimeRangesViewController

- (id)initWithTimeRanges:(NSOrderedSet *)timeRanges
{
    if (self = [self init]) {
        originalOrderedSet = timeRanges;
        self.timeRangesOrderedSet = [NSMutableOrderedSet orderedSet];
        if ([timeRanges count]) {
            self.timeRangesOrderedSet = [timeRanges mutableCopy];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITableView * tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:tableView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.timeRangesOrderedSet count]+1;
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
        OPEDateRange * timeRange = self.timeRangesOrderedSet[indexPath.row];
        timeRangeCell.dateRange = timeRange;
        timeRangeCell.didSelectDateButtonBlock = ^(UITableViewCell * cell,BOOL isStartButton) {
            [self didSelecButtonAtIndex:[tableView indexPathForCell:cell] isStartButton:isStartButton];
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
        
    }
}

-(void)didSelecButtonAtIndex:(NSInteger)index isStartButton:(BOOL)isStartButton
{
    
    ActionSheetDatePicker * datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Time" datePickerMode:UIDatePickerModeTime selectedDate:nil target:nil action:nil origin:self.view];
    [datePicker showActionSheetPicker];
    
}

-(NSIndexPath *)lastIndexPathForTableView:(UITableView *)tableView
{
    NSInteger lastSectionIndex = [tableView numberOfSections] - 1;
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:([tableView numberOfRowsInSection:lastSectionIndex] - 1) inSection:lastSectionIndex];
    
    return lastIndexPath;
}

@end
