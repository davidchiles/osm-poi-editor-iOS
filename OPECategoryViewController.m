//
//  OPECategoryViewController.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OPECategoryViewController.h"
#import "OPETagInterpreter.h"

@implementation OPECategoryViewController

@synthesize mainTableView,searchBar,searchDisplayController;
@synthesize categoriesAndTypes,searchResults,types;
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    OPETagInterpreter * tagInterpreter = [OPETagInterpreter sharedInstance];
    categoriesAndTypes = tagInterpreter.categoryAndType;
    NSMutableDictionary * tempTypes = [[NSMutableDictionary alloc] init];
    for (NSString * category in categoriesAndTypes)
    {
        for (NSString * type in [categoriesAndTypes objectForKey:category]) {
            [tempTypes setObject:category forKey:type];
        }
        
    }
    types = [tempTypes copy];
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
        for (NSString * currentString in types)
        {
            //NSLog(@"CurrentString: %@",currentString);
            if ([currentString rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                NSLog(@"Match: %d",[currentString rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location);
                NSNumber * location = [NSNumber numberWithInteger: [currentString rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location];
                NSDictionary * match = [[NSDictionary alloc] initWithObjectsAndKeys:currentString,@"type",[types objectForKey:currentString],@"category",location,@"location", nil];
                [searchResults addObject:match];
                
            }
        }
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"location"  ascending:YES];
        NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
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
    return [categoriesAndTypes count];
    //return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (tableView == [[self searchDisplayController] searchResultsTableView]) {
        cell.textLabel.text = [[self.searchResults objectAtIndex:indexPath.row] objectForKey:@"type"];
        return cell;
    }
    
    NSArray * categories = [[categoriesAndTypes allKeys]sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    cell.textLabel.text = [categories objectAtIndex:indexPath.row];
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
     if (tableView == [[self searchDisplayController] searchResultsTableView]) {
         [[self delegate] setCategoryAndType: [searchResults objectAtIndex:indexPath.row]];
         [self.navigationController popViewControllerAnimated:YES];
     }
     else {
         OPETypeViewController * viewer = [[OPETypeViewController alloc] initWithNibName:@"OPETypeViewController" bundle:nil];
         viewer.title = @"Type";
         viewer.category = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
         [viewer setDelegate: [[[self navigationController] viewControllers] objectAtIndex:1]];
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
