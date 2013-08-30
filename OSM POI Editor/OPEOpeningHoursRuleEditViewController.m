//
//  OPEOpeningHoursRuleEditViewController.m
//  OSM POI Editor
//
//  Created by David on 8/29/13.
//
//

#import "OPEOpeningHoursRuleEditViewController.h"

#import "OPEOpeningHoursParser.h"
#import "OPEOpeningHoursMonths+DaysOfWeekViewController.h"
#import "OPEOpeningHoursTimeRangesViewController.h"

@interface OPEOpeningHoursRuleEditViewController ()


@end

@implementation OPEOpeningHoursRuleEditViewController

- (id)initWithRule:(OPEOpeningHourRule *)newRule
{
    if (self = [self init]) {
        originalRule = [newRule copy];
        if (!newRule) {
            newRule = [[OPEOpeningHourRule alloc] init];
        }
        self.rule = newRule;
        openingHoursParser = [[OPEOpeningHoursParser alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	ruleTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    ruleTableView.dataSource = self;
    ruleTableView.delegate = self;
    ruleTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:ruleTableView];
    
    twentyFourSevenSwitch = [[UISwitch alloc] init];
    [twentyFourSevenSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    twentyFourSevenSwitch.on = self.rule.isTwentyFourSeven;
    
    openCloseSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Open",@"Close"]];
    if (self.rule.isOpen) {
        [openCloseSegmentedControl setSelectedSegmentIndex:0];
    }
    else {
        [openCloseSegmentedControl setSelectedSegmentIndex:1];
    }
    [openCloseSegmentedControl addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    
}

#pragma mark TableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * view = nil;
    if (section == 0) {
        view =  openCloseSegmentedControl;
    }
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSString * cellIdentifierTwentyFourSeven = @"cellIdentifierTwentyFourSeven";
    NSString * cellIdentiferSpecial = @"cellIdentiferSpecial";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentiferSpecial];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIdentiferSpecial];
    }
    
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Open 24/7";
                cell.accessoryView = twentyFourSevenSwitch;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                break;
            case 1:
                cell.textLabel.text = @"Months";
                cell.detailTextLabel.text = [openingHoursParser stringWithMonthsOrderedSet:self.rule.monthsOrderedSet];
                if (![cell.detailTextLabel.text length]) {
                    cell.detailTextLabel.text = @"All Months";
                }
                break;
            case 2:
                cell.textLabel.text = @"Days";
                cell.detailTextLabel.text = [openingHoursParser stringWithDaysOfWeekOrderedSet:self.rule.daysOfWeekOrderedSet];
                if (![cell.detailTextLabel.text length]) {
                    cell.detailTextLabel.text = @"All Days";
                }
                break;
            case 3:
                cell.textLabel.text = @"Times";
                cell.detailTextLabel.text = [openingHoursParser stringWithTimeRangesOrderedSet:self.rule.timeRangesOrderedSet];
                break;
                
            default:
                break;
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        UIViewController * viewController = nil;
        switch (indexPath.row) {
            case 1:
                viewController = [[OPEOpeningHoursMonths_DaysOfWeekViewController alloc] initWithType:OPETypeMonth forDateComponents:self.rule.monthsOrderedSet];
                break;
            case 2:
                viewController = [[OPEOpeningHoursMonths_DaysOfWeekViewController alloc] initWithType:OPETypeDaysOfWeek forDateComponents:self.rule.daysOfWeekOrderedSet];
                break;
            case 3:
                viewController = [[OPEOpeningHoursTimeRangesViewController alloc] initWithTimeRanges:self.rule.timeRangesOrderedSet];
                break;
                
            default:
                break;
        }
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

-(void)switchChanged:(id)sender
{
    if ([sender isEqual:twentyFourSevenSwitch]) {
        self.rule.isTwentyFourSeven = twentyFourSevenSwitch.on;
        if (self.rule.isTwentyFourSeven) {
            self.rule.monthsOrderedSet = nil;
            self.rule.daysOfWeekOrderedSet = nil;
            self.rule.timeRangesOrderedSet = nil;
        }
        [ruleTableView reloadData];
    }
    else if ([sender isEqual:openCloseSegmentedControl]) {
        NSInteger selectedIndex = openCloseSegmentedControl.selectedSegmentIndex;
        if (selectedIndex == 0) {
            self.rule.isOpen = YES;
        }
        else {
            self.rule.isOpen = NO;
        }
    }
    
}


@end
