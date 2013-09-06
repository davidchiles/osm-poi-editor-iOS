//
//  OPEHoursTimesEditViewController.m
//  OSM POI Editor
//
//  Created by David on 9/5/13.
//
//

#import "OPEOpeningHoursTimesEditViewController.h"
#import "OPEOpeningHoursParser.h"

@interface OPEOpeningHoursTimesEditViewController ()

@end

@implementation OPEOpeningHoursTimesEditViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * addCellIdentifier = @"addCellIdentifier";
    NSString * timeCelIdentifier = @"timeCelIdentifier";
    UITableViewCell * cell = nil;
    if ([[self lastIndexPathForTableView:tableView] isEqual:indexPath]) {
        cell = [tableView dequeueReusableCellWithIdentifier:addCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addCellIdentifier];
        }
        cell.textLabel.text = @"Add Time";
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:timeCelIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:timeCelIdentifier];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"Time %d",indexPath.row+1];
        OPEDateComponents * timeComponent = [self.propertiesArray objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",timeComponent];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([indexPath isEqual:[self lastIndexPathForTableView:tableView]]) {
        newDateComponent = [[OPEDateComponents alloc] init];
        
        newDateComponent.hour = 10;
        newDateComponent.minute = 0;
        
        
        currentDateComponent = newDateComponent;
        [self.propertiesArray addObject:currentDateComponent];
        [self.propertiesTableView insertRowsAtIndexPaths:@[[self lastIndexPathForTableView:self.propertiesTableView]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        currentDateComponent = [self.propertiesArray objectAtIndex:indexPath.row];
    }
    
    [self showDatePickerWithTitle:@"Time" withDate:[currentDateComponent date] withIndex:indexPath.row];
}

@end
