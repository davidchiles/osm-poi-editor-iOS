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
#import "OPEOpeningHoursTimesEditViewController.h"
#import "OPEStrings.h"

@interface OPEOpeningHoursRuleEditViewController ()


@end

@implementation OPEOpeningHoursRuleEditViewController

@synthesize doneBlock,ruleEditType,rule;

- (id)initWithRule:(OPEOpeningHourRule *)newRule
{
    if (self = [self initShowCancel:YES showDone:YES]) {
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
    self.title = RULE_STRING;
	ruleTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    ruleTableView.dataSource = self;
    ruleTableView.delegate = self;
    ruleTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:ruleTableView];
    
    twentyFourSevenSwitch = [[UISwitch alloc] init];
    [twentyFourSevenSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    twentyFourSevenSwitch.on = self.rule.isTwentyFourSeven;
    
    openCloseSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[OPEN_STRING,CLOSED_STRING]];
    if (self.rule.isOpen) {
        [openCloseSegmentedControl setSelectedSegmentIndex:0];
    }
    else {
        [openCloseSegmentedControl setSelectedSegmentIndex:1];
    }
    [openCloseSegmentedControl addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [ruleTableView reloadData];
}

#pragma mark TableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 3;
    
    if([self hasTimeRangesCell])  {
        numRows +=1;
    }
    
    if([self hasTimesCell])
    {
        numRows +=1;
    }
    
    return numRows;
}

-(BOOL)hasTimeRangesCell {
    return (self.ruleEditType == OPERuleEditTypeTimeRange ||self.ruleEditType == OPERuleEditTypeDefault || [self.rule.timeRangesOrderedSet count] );
}
-(BOOL)hasTimesCell {
    return (self.ruleEditType == OPERuleEditTypeTime ||self.ruleEditType == OPERuleEditTypeDefault || [self.rule.timesOrderedSet count]);
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
        if (indexPath.row == 0) {
            cell.textLabel.text = OPEN_TWENTY_FOUR_SEVEN_STRING;
            cell.accessoryView = twentyFourSevenSwitch;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = MONTHS_STRING;
            cell.detailTextLabel.text = [openingHoursParser stringWithMonthsOrderedSet:self.rule.monthsOrderedSet];
            if (![cell.detailTextLabel.text length]) {
                cell.detailTextLabel.text = ALL_MONTHS_STRING;
            }
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = DAYS_OF_WEEK_STRING;
            cell.detailTextLabel.text = [openingHoursParser stringWithDaysOfWeekOrderedSet:self.rule.daysOfWeekOrderedSet];
            if (![cell.detailTextLabel.text length]) {
                cell.detailTextLabel.text = ALL_DAYS_STRING;
            }
        }
        else if (indexPath.row == 3) {
            if ([self hasTimeRangesCell]) {
                [self formatTimeRangesCell:cell];
            }
            else {
                [self formatTimesCell:cell];
            }
        }
        else if (indexPath.row == 4) {
            [self formatTimesCell:cell];
        }
    }
    return cell;
}

-(void)formatTimeRangesCell:(UITableViewCell *)cell
{
    cell.textLabel.text = TIME_RANGES_STRING;
    cell.detailTextLabel.text = [openingHoursParser stringWithTimeRangesOrderedSet:self.rule.timeRangesOrderedSet];
}

-(void)formatTimesCell:(UITableViewCell *)cell
{
    cell.textLabel.text = TIMES_STRING;
    cell.detailTextLabel.text = [openingHoursParser stringWithTimeRangesOrderedSet:self.rule.timesOrderedSet];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        OPEOpeningHoursBaseTimeEditViewController * viewController = nil;
        if (indexPath.row == 1) {
            viewController = [[OPEOpeningHoursMonths_DaysOfWeekViewController alloc] initWithType:OPETypeMonth forDateComponents:self.rule.monthsOrderedSet];
            viewController.doneBlock = ^(NSOrderedSet * orderedSet){
                self.rule.monthsOrderedSet = [orderedSet mutableCopy];
                [tableView reloadData];
            };
        }
        else if (indexPath.row == 2) {
            viewController = [[OPEOpeningHoursMonths_DaysOfWeekViewController alloc] initWithType:OPETypeDaysOfWeek forDateComponents:self.rule.daysOfWeekOrderedSet];
            viewController.doneBlock = ^(NSOrderedSet * orderedSet){
                self.rule.daysOfWeekOrderedSet = [orderedSet mutableCopy];
                [tableView reloadData];
            };
        }
        else if (indexPath.row == 3) {
            if ([self hasTimeRangesCell]) {
                viewController = [[OPEOpeningHoursTimeRangesViewController alloc] initWithOrderedSet:self.rule.timeRangesOrderedSet];
                viewController.doneBlock = ^(NSOrderedSet * timeRanges){
                    self.rule.timeRangesOrderedSet = [timeRanges mutableCopy];
                    [tableView reloadData];
                };
            }
            else {
                viewController = [self TimesEditViewControllerwithTableView:tableView];
            }
        }
        else if (indexPath.row == 4) {
            viewController = [self TimesEditViewControllerwithTableView:tableView];
        }
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

-(OPEOpeningHoursTimesEditViewController *)TimesEditViewControllerwithTableView:(UITableView *)tableView
{
    OPEOpeningHoursTimesEditViewController *viewController = [[OPEOpeningHoursTimesEditViewController alloc] initWithOrderedSet:self.rule.timesOrderedSet];
    viewController.doneBlock = ^(NSOrderedSet * times) {
        self.rule.timesOrderedSet = [times mutableCopy];
        [tableView reloadData];
    };
    return viewController;
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

-(void)doneButtonPressed:(id)sender
{
    if (doneBlock) {
        if([self.rule isEmpty]) {
            self.rule= nil;
        }
        doneBlock(self.rule);
    }
    [super doneButtonPressed:sender];
}


@end
