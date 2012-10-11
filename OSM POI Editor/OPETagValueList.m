//
//  OPETagValueList.m
//  OSM POI Editor
//
//  Created by David Chiles on 4/16/12.
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

#import "OPETagValueList.h"

@interface OPETagValueList ()

@end


@implementation OPETagValueList


@synthesize osmKey,osmValue,osmValues,values;
@synthesize delegate;
@synthesize valuesCheckmarkArray,selectedArray;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (values)
    {
        return [values count];
    }
    else if (valuesCheckmarkArray)
    {
        return [valuesCheckmarkArray count];
    }
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if(values)
    {
        
        cell.textLabel.text = [[[values allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]  objectAtIndex:indexPath.row];
        
    }
    else if (valuesCheckmarkArray) {
        
        cell.textLabel.text = [[valuesCheckmarkArray objectAtIndex:indexPath.row] objectForKey:@"Name"];
        if ([selectedArray containsObject:[[valuesCheckmarkArray objectAtIndex:indexPath.row] objectForKey:@"osmKey"]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        
    }
    
    
    // Configure the cell...
    
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
-(void) donePressed:(id)sender
{
    for (NSString * omsKey in selectedArray)
    {
        [self.delegate newTag:[NSDictionary dictionaryWithObjectsAndKeys:@"yes",@"osmValue",osmKey,@"osmKey", nil]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (values) {
        NSString * value = [values objectForKey: [tableView cellForRowAtIndexPath:indexPath].textLabel.text];
        [delegate newTag:[NSDictionary dictionaryWithObjectsAndKeys:value,@"osmValue",osmKey,@"osmKey", nil]];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(valuesCheckmarkArray)
    {
        /////
        NSDictionary * selectedRowDictionary = [valuesCheckmarkArray objectAtIndex:indexPath.row];
        if ([selectedArray containsObject:[selectedRowDictionary objectForKey:@"osmKey"]]) {
            [selectedArray removeObject:[selectedRowDictionary objectForKey:@"osmKey"]];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone; 
        }
        else {
            [selectedArray addObject:[selectedRowDictionary objectForKey:@"osmKey"]];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark; 
        }
    }
    
}

@end
