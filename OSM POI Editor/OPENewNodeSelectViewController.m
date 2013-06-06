//
//  OPENewNodeSelectViewController.m
//  OSM POI Editor
//
//  Created by David on 5/30/13.
//
//

#import "OPENewNodeSelectViewController.h"
#import "OPEOSMSearchManager.h"

@interface OPENewNodeSelectViewController ()

@end

@implementation OPENewNodeSelectViewController
@synthesize location;

-(id)initWithLocation:(CLLocationCoordinate2D)newLocation
{
    if (self = [super init]) {
        self.location = newLocation;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    OPEOSMSearchManager * searchManager = [[OPEOSMSearchManager alloc] init];
    recentlyUsedPoisArray = [searchManager recentlyUsedPoisArrayWithLength:3];
    
}
-(UITableViewStyle)tableViewStyle
{
    return UITableViewStyleGrouped;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([recentlyUsedPoisArray count] && tableView != [[self searchDisplayController] searchResultsTableView]) {
        return 2;
    }
    return [super numberOfSectionsInTableView:tableView];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 && [recentlyUsedPoisArray count] && tableView != [[self searchDisplayController] searchResultsTableView]){
        return [recentlyUsedPoisArray count];
    }
    return [super tableView:tableView numberOfRowsInSection:section];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([recentlyUsedPoisArray count] && tableView != [[self searchDisplayController] searchResultsTableView]){
        if (section == 0) {
            return @"Recently Used";
        }
        else
        {
            return @"Categories";
        }
    }
    else
    {
        return @"";
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellIdentifierString = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierString];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifierString];
    }
    
    if (indexPath.section == 0 && [recentlyUsedPoisArray count] && tableView != [[self searchDisplayController] searchResultsTableView] ) {
        OPEManagedReferencePoi * poi = recentlyUsedPoisArray[indexPath.row];
        cell.textLabel.text = poi.name;
        cell.detailTextLabel.text = poi.categoryName;
    }
    else
    {
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    return cell;
}



@end
