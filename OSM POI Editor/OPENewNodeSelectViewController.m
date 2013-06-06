//
//  OPENewNodeSelectViewController.m
//  OSM POI Editor
//
//  Created by David on 5/30/13.
//
//

#import "OPENewNodeSelectViewController.h"
#import "OPEOSMSearchManager.h"
#import "OPENodeViewController.h"
#import "OPEOSMData.h"

@interface OPENewNodeSelectViewController ()

@end

@implementation OPENewNodeSelectViewController
@synthesize nodeViewDelegate;

-(id)initWithNewElement:(OPEManagedOsmElement *)element
{
    if (self = [super init]) {
        newElement = element;
        OPEOSMSearchManager * searchManager = [[OPEOSMSearchManager alloc] init];
        recentlyUsedPoisArray = [searchManager recentlyUsedPoisArrayWithLength:3];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"New Node";
    
    UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}
-(void)cancelButtonPressed:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(UITableViewStyle)tableViewStyle
{
    if ([recentlyUsedPoisArray count]) {
        return UITableViewStyleGrouped;
    }
    return UITableViewStylePlain;
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && [recentlyUsedPoisArray count] && tableView != [[self searchDisplayController] searchResultsTableView] )
    {
        [self newType:recentlyUsedPoisArray[indexPath.row]];
        
    }
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}


#pragma mark - type delegate
-(void)newType:(OPEManagedReferencePoi *)type
{
    [[[OPEOSMData alloc] init] setNewType:type forElement:newElement];
    OPENodeViewController * nodeViewController = [[OPENodeViewController alloc] initWithOsmElement:newElement delegate:nodeViewDelegate];
    
    [self.navigationController setViewControllers:@[nodeViewController] animated:YES];
}


@end
