//
//  OPEOpeningHoursMonths+DaysOfWeekViewController.m
//  OSM POI Editor
//
//  Created by David on 8/29/13.
//
//

#import "OPEOpeningHoursMonths+DaysOfWeekViewController.h"

@interface OPEOpeningHoursMonths_DaysOfWeekViewController ()

@end

@implementation OPEOpeningHoursMonths_DaysOfWeekViewController

@synthesize type,dateComponentsOrderedSet;

-(id)initWithType:(OPEType)newType
{
    if (self = [self init]) {
        self.type = newType;
    }
    return self;
}

-(id)initWithType:(OPEType)type forDateComponents:(NSOrderedSet *)newDateComponentsOrderedSet
{
    if (self = [self initWithType:type]) {
        originalOrderedSet = newDateComponentsOrderedSet;
        self.dateComponentsOrderedSet = [newDateComponentsOrderedSet mutableCopy];
        if (![newDateComponentsOrderedSet count]) {
            self.dateComponentsOrderedSet = [NSMutableOrderedSet orderedSet];
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
    if (self.type== OPETypeDaysOfWeek) {
        return 8;
    }
    else if (self.type == OPETypeMonth) {
        return 13;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellIdentifier = @"cellIdentifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.row == 0) {
        if (self.type == OPETypeMonth) {
            cell.textLabel.text = @"All Months";
        }
        else if (self.type == OPETypeDaysOfWeek) {
            cell.textLabel.text = @"All Days";
        }
        if (![self.dateComponentsOrderedSet count]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else {
        cell.textLabel.text = [self cellTitleForRow:indexPath.row];
        if ([self cellCheckMarkForRow:indexPath.row]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self.dateComponentsOrderedSet removeAllObjects];
        
    }
    else
    {
        NSDateComponents * dateComponent = [[NSDateComponents alloc] init];
        if (self.type == OPETypeMonth) {
            dateComponent.month = indexPath.row;
        }
        else if (self.type == OPETypeDaysOfWeek) {
            dateComponent.weekday = indexPath.row;
        }
        
        if ([self.dateComponentsOrderedSet containsObject:dateComponent]) {
            [self.dateComponentsOrderedSet removeObject:dateComponent];
        }
        else {
            [self.dateComponentsOrderedSet addObject:dateComponent];
        }
        //[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

    }
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

-(NSString *)cellTitleForRow:(NSInteger)index
{
    NSString * result = nil;
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    NSString * dateString = [NSString stringWithFormat: @"%d", index];
    if (self.type == OPETypeMonth) {
        [dateFormatter setDateFormat:@"MM"];
        NSDate* myDate = [dateFormatter dateFromString:dateString];
        [dateFormatter setDateFormat:@"MMMM"];
        result = [dateFormatter stringFromDate:myDate];
    }
    else if (self.type == OPETypeDaysOfWeek) {
        [dateFormatter setDateFormat:@"e"];
        NSDate* myDate = [dateFormatter dateFromString:dateString];
        [dateFormatter setDateFormat:@"EEEE"];
        result = [dateFormatter stringFromDate:myDate];
    }
    return result;
}
-(BOOL)cellCheckMarkForRow:(NSInteger)index
{
    NSDateComponents * dateComponent = [[NSDateComponents alloc] init];
    if (self.type == OPETypeMonth) {
        dateComponent.month = index;
    }
    else if (self.type == OPETypeDaysOfWeek) {
        dateComponent.weekday = index;
    }
    
    if ([self.dateComponentsOrderedSet containsObject:dateComponent]) {
        return YES;
    }
    return NO;
}
@end
