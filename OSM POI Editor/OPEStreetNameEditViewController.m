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
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section ==1 && !self.recentControl) {
        return 0;
    }
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = nil;
    if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"nearbyCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"nearbyCell"];
        }
        cell.textLabel.text = @"Nearby Streets";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else{
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        OPEnearbyViewController * nearbyViewController = [[OPEnearbyViewController alloc] initWithManagedObjectID:self.managedObjectID];
        nearbyViewController.delegate=self.delegate;
        nearbyViewController.osmKey = self.osmKey;
        [self.navigationController pushViewController:nearbyViewController animated:YES];
        
    }
    else
    {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

@end
