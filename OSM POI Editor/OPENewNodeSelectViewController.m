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
#import "OPENoteViewController.h"
#import "OPEOSMData.h"
#import "OPEStrings.h"

@interface OPENewNodeSelectViewController ()

@end

@implementation OPENewNodeSelectViewController
@synthesize nodeViewDelegate,location;

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
    
    self.title = NEW_NODE_STRING;
    
    UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}
-(void)cancelButtonPressed:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(UITableViewStyle)tableViewStyle
{
    if ([recentlyUsedPoisArray count]) {
        return UITableViewStyleGrouped;
    }
    return UITableViewStylePlain;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([self.searchDisplayController.searchResultsTableView isEqual:tableView]) {
        return [super numberOfSectionsInTableView:tableView];
    }
    if ([recentlyUsedPoisArray count]) {
        return 3;
    }
    return [super numberOfSectionsInTableView:tableView]+1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.searchDisplayController.searchResultsTableView isEqual:tableView]) {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    
    if ([recentlyUsedPoisArray count]){
        if (section == 0) {
            return [recentlyUsedPoisArray count];
        }
        else if(section == 1){
            return 1;
        }
    }
    else if (section == 0)
    {
        return 1;
    }
    return [super tableView:tableView numberOfRowsInSection:section];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self.searchDisplayController.searchResultsTableView isEqual:tableView]) {
        return @"";
    }
    
    if ([recentlyUsedPoisArray count]){
        if (section == 0) {
            return RECENTLY_USED_STRING;
        }
        else if(section == 1)
        {
            return NOTE_STRING;
        }
        else
        {
            return CATEGORIES_STRING;
        }
    }
    else
    {
        if(section == 0)
        {
            return NOTE_STRING;
        }
        else
        {
            return CATEGORIES_STRING;
        }
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
    else if (((indexPath.section == 0 && ![recentlyUsedPoisArray count]) || (indexPath.section == 1 && [recentlyUsedPoisArray count]))&& tableView != [[self searchDisplayController] searchResultsTableView])
    {
        cell.textLabel.text = CREATE_NEW_NOTE_STRING;
        cell.detailTextLabel.text = @"";
    }
    else
    {
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && [recentlyUsedPoisArray count] && tableView != [[self searchDisplayController] searchResultsTableView] )
    {
        [self newType:recentlyUsedPoisArray[indexPath.row]];
        
    }
    else if (((indexPath.section == 0 && ![recentlyUsedPoisArray count]) || (indexPath.section == 1 && [recentlyUsedPoisArray count]))&& tableView != [[self searchDisplayController] searchResultsTableView])
    {
        Note * note = [[Note alloc] init];
        note.coordinate = self.location;
        OPENoteViewController * viewController = [[OPENoteViewController alloc] initWithNote:note];
        [self.navigationController setViewControllers:@[viewController] animated:YES];
    }
    else{
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}


#pragma mark - type delegate
-(void)newType:(OPEManagedReferencePoi *)type
{
    [[[OPEOSMData alloc] init] setNewType:type forElement:newElement];
    OPENodeViewController * nodeViewController = [[OPENodeViewController alloc] initWithOsmElement:newElement delegate:nodeViewDelegate];
    
    [self.navigationController setViewControllers:@[nodeViewController] animated:YES];
}


@end
