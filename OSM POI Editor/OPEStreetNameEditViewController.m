//
//  OPEStreetNameEditViewController.m
//  OSM POI Editor
//
//  Created by David on 3/25/13.
//
//

#import "OPEStreetNameEditViewController.h"
#import "OPEnearbyViewController.h"

@interface OPEStreetNameEditViewController ()

@end

@implementation OPEStreetNameEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section ==1) {
        if (self.recentControl) {
            return 2;
        }
        return 1;
    }
    else
    {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = nil;
    if (indexPath.section == 1) {
        if (indexPath.row == 0 && self.recentControl) {
            cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"nearbyCell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"nearbyCell"];
            }
            cell.textLabel.text = @"Nearby Streets";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else{
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && ((indexPath.row == 0 && !self.recentControl) || (indexPath.row == 1 && self.recentControl))) {
        OPEnearbyViewController * nearbyViewController = [[OPEnearbyViewController alloc] initWithManagedObjectID:self.managedObjectID];
        [self.navigationController pushViewController:nearbyViewController animated:YES];
        
    }
    else
    {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

@end
