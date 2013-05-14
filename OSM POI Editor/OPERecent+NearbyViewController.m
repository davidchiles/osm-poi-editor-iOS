//
//  OPERecent+NearbyViewController.m
//  OSM POI Editor
//
//  Created by David on 3/26/13.
//
//

#import "OPERecent+NearbyViewController.h"
#import "OPEUtility.h"
#import "OPEMRUtility.h"
#import "OPEManagedOsmElement.h"
#import "OPEOSMSearchManager.h"

@interface OPERecent_NearbyViewController ()

@end

@implementation OPERecent_NearbyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //nearbyDictionary = [self.element nearbyValuesForOsmKey:self.osmKey];
    nearbyDictionary = [OPEOSMSearchManager nearbyValuesForElement:self.element withOsmKey:self.osmKey];
    
    if (nearbyDictionary) {
        NSMutableArray * array = [NSMutableArray array];
        for (NSString * key in nearbyDictionary)
        {
            [array addObject:@{@"name": key,@"distance":[nearbyDictionary objectForKey:key]}];
        }
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"distance"  ascending:YES];
        NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        
        distances = [array sortedArrayUsingDescriptors:@[descriptor,nameDescriptor]];
        [self.textField resignFirstResponder];
    }
    
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger num = [super numberOfSectionsInTableView:tableView];
    
    if ([nearbyDictionary count]) {
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
    else if ((section == 1 && [nearbyDictionary count]) || section == 2)
    {
        return [nearbyDictionary count];
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
    else if ((section == 1 && [nearbyDictionary count]) || section == 2)
    {
        return @"Nearby";
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
    else if ((indexPath.section == 1 && nearbyDictionary) || indexPath.section == 2)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:nearbyCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nearbyCellIdentifier];
        }
        cell.textLabel.text = [[distances objectAtIndex:indexPath.row] objectForKey:@"name"];
        cell.detailTextLabel.text = [OPEUtility formatDistanceMeters:[[[distances objectAtIndex:indexPath.row] objectForKey:@"distance"]doubleValue]];
        
        
    }
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
