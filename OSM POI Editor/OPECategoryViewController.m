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
#import "OPEManagedReferenceOptionalCategory.h"
#import "OPEManagedReferencePoi.h"

@implementation OPECategoryViewController

@synthesize mainTableView,searchBar,searchDisplayController;
@synthesize categoriesArray,typesArray,searchResults;
@synthesize delegate;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    categoriesArray = [OPEManagedReferencePoiCategory allSortedCategories];
    
    typesArray = [OPEManagedReferencePoi allTypes];
    //NSLog(@"Types: %@",types);
    
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
    searchResults = [[NSMutableArray alloc] init];
    if ([searchTerm length] != 0)
    {
        for (OPEManagedReferencePoi * currentPoi in typesArray)
        {
            //NSLog(@"CurrentString: %@",currentString);
            NSString * currentString = currentPoi.name;
            if ([currentString rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                NSLog(@"Match: %d",[currentString rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location);
                NSNumber * location = [NSNumber numberWithInteger: [currentString rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location];
                // FIXME NSDictionary * match = [[NSDictionary alloc] initWithObjectsAndKeys:currentString,@"typeName",[currentPoi objectID],@"objectID",location,@"location",currentPoi.category.name,@"catName", nil];
                //[searchResults addObject:match];
                
            }
        }
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"location"  ascending:YES];
        NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"typeName" ascending:YES];
        [searchResults sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nameDescriptor,nil]];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == [[self searchDisplayController] searchResultsTableView]) {
        
        return [searchResults count];
    }
    return [categoriesArray count];
    //return 0;
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
    
    
    cell.textLabel.text = [[categoriesArray objectAtIndex:indexPath.row] name];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
     if (tableView == [[self searchDisplayController] searchResultsTableView]) {
         [[self delegate] setNewType: [[searchResults objectAtIndex:indexPath.row] objectForKey:@"objectID"]];
         [self.navigationController popViewControllerAnimated:YES];
     }
     else {
         OPETypeViewController * viewer = [[OPETypeViewController alloc] initWithNibName:@"OPETypeViewController" bundle:nil];
         viewer.title = @"Type";
         //viewer.category = [categoriesArray objectAtIndex:indexPath.row];
         viewer.categoryManagedObjectID = [[categoriesArray objectAtIndex:indexPath.row] objectID];
         [viewer setDelegate: [[[self navigationController] viewControllers] objectAtIndex:0]];
         [self.navigationController pushViewController:viewer animated:YES];
     }  
}

#pragma mark - search delegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller 
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self handleSearchForTerm:searchString];
    
    return YES;
}


@end
