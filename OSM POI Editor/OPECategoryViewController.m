//
//  OPECategoryViewController.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/13/12.
//  Copyright (c) 2011 David Chiles. All rights reserved.
//
//  This file is part of POI+.
//
//  POI+ is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  POI+ is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with POI+.  If not, see <http://www.gnu.org/licenses/>.

#import "OPECategoryViewController.h"
#import "OPEReferencePoi.h"
#import "OPEOSMData.h"

@interface OPECategoryViewController ()

@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;

@end

@implementation OPECategoryViewController

@synthesize searchDisplayController;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    osmData = [[OPEOSMData alloc] init];
    self.categoriesArray = [osmData allSortedCategories];
    self.typesArray = [osmData allTypesIncludeLegacy:NO];
    
    
    UITableView * tableView  = [[UITableView alloc] initWithFrame:self.view.bounds style:[self tableViewStyle]];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    
    
    UISearchBar * searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
    tableView.tableHeaderView = searchBar;
    
    self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    
    [self.view addSubview:tableView];
    
}

-(UITableViewStyle)tableViewStyle
{
    return UITableViewStylePlain;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)handleSearchForTerm:(NSString *)searchTerm
{
    self.searchResults = [[NSMutableArray alloc] init];
    if ([searchTerm length] != 0)
    {
        for (OPEReferencePoi * currentPoi in self.typesArray)
        {
            NSString * currentString = currentPoi.name;
            NSRange range = [currentString rangeOfString:searchTerm options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound)
            {
                NSNumber * location = [NSNumber numberWithInteger: range.location];
                NSDictionary * match = [[NSDictionary alloc] initWithObjectsAndKeys:currentString,@"typeName",currentPoi,@"poi",location,@"location",currentPoi.categoryName,@"catName", nil];
                [self.searchResults addObject:match];
                
            }
        }
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"location"  ascending:YES];
        NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"typeName" ascending:YES];
        [self.searchResults sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nameDescriptor,nil]];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == [[self searchDisplayController] searchResultsTableView]) {
        
        return [self.searchResults count];
    }
    return [self.categoriesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (tableView == [[self searchDisplayController] searchResultsTableView]) {
        cell.textLabel.text = [[self.searchResults objectAtIndex:indexPath.row] objectForKey:@"typeName"];
        cell.detailTextLabel.text = [[self.searchResults objectAtIndex:indexPath.row] objectForKey:@"catName"];
        return cell;
    }
    
    
    cell.textLabel.text = [self.categoriesArray objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
     if (tableView == [[self searchDisplayController] searchResultsTableView]) {
         OPEReferencePoi * poi =[[self.searchResults objectAtIndex:indexPath.row] objectForKey:@"poi"];
         [osmData getMetaDataForType:poi];
         [self newType: poi];
         
     }
     else {
         OPETypeViewController * typeViewController = [[OPETypeViewController alloc] initWithCategory:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
         typeViewController.delegate = self;
         [self.navigationController pushViewController:typeViewController animated:YES];
     }  
}

#pragma mark - search delegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller 
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self handleSearchForTerm:searchString];
    
    return YES;
}

#pragma mark - type delegate
-(void)newType:(OPEReferencePoi *)type
{
    [self.delegate newType:type];
    [self.navigationController popToRootViewControllerAnimated:YES];
}



@end
