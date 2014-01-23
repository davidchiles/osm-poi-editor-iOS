//
//  OPERecent+NearbyViewController.m
//  OSM POI Editor
//
//  Created by David on 3/26/13.
//
//

#import "OPERecent+NearbyViewController.h"
#import "OPEUtility.h"
#import "OPEOsmElement.h"
#import "OPEOSMSearchManager.h"
#import "OPEStrings.h"

@interface OPERecent_NearbyViewController ()

@end

@implementation OPERecent_NearbyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //nearbyDictionary = [self.element nearbyValuesForOsmKey:self.osmKey];
    distances = [OPEOSMSearchManager sortedNearbyValuesForElement:self.element withOsmKey:self.osmKey];
    
    if ([distances count]) {
        [self.textField resignFirstResponder];
    }
    
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger num = [super numberOfSectionsInTableView:tableView];
    
    if ([distances count]) {
        num+=1;
    }
    return num;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ((section == 1 && [recentValues count]) || section == 0)
    {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    else if ((section == 1 && [distances count]) || section == 2)
    {
        return [distances count];
    }
    return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString * title = nil;
    if ((section == 1 && [recentValues count]) || section == 0)
    {
        title = [super tableView:tableView titleForHeaderInSection:section];
    }
    else if ((section == 1 && [distances count]) || section == 2)
    {
        return NEARBY_STRING;
    }
    return  title;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = nil;
    static NSString * nearbyCellIdentifier = @"nearbyCell";
    if ((indexPath.section == 1 && recentValues) || indexPath.section == 0)
    {
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    else if ((indexPath.section == 1 && distances) || indexPath.section == 2)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:nearbyCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nearbyCellIdentifier];
        }
        cell.textLabel.text = [[distances objectAtIndex:indexPath.row] objectForKey:@"value"];
        cell.detailTextLabel.text = [OPEUtility formatDistanceMeters:[[[distances objectAtIndex:indexPath.row] objectForKey:@"distance"]doubleValue]];
        
        
    }
    
    return cell;
}

@end
