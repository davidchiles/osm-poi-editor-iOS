//
//  OPENodeViewController.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OPENodeViewController.h"
#import "OPETagInterpreter.h"
#import "OPETextEdit.h"
#import "OPECategoryViewController.h"
#import "OPEOSMData.h"



@implementation OPENodeViewController

@synthesize node, theNewNode, type;
@synthesize tableView;
@synthesize catAndType;
@synthesize deleteButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

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
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle: @"Save" style: UIBarButtonItemStyleBordered target: self action: @selector(saveButtonPressed)];
    
    [[self navigationItem] setRightBarButtonItem:saveButton];
    
    
    deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    [self.deleteButton setBackgroundImage:[[UIImage imageNamed:@"iphone_delete_button.png"]
                                           stretchableImageWithLeftCapWidth:8.0f
                                           topCapHeight:0.0f]
                                 forState:UIControlStateNormal];
    
    [self.deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.deleteButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.deleteButton.titleLabel.shadowColor = [UIColor lightGrayColor];
    self.deleteButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    [self.deleteButton addTarget:self action:@selector(deleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    
    theNewNode = [[OPENode alloc] initWithNode:node];
    
    tagInterpreter = [OPETagInterpreter sharedInstance];
    
    catAndType = [[NSArray alloc] initWithObjects:[tagInterpreter getCategory:theNewNode],[tagInterpreter getType:theNewNode], nil];
    osmKeyValue =  [[NSDictionary alloc] initWithDictionary: [tagInterpreter getPrimaryKeyValue:theNewNode]];
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section == 1)
        return 2;
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Name";
	}
	else if (section == 1) {
		return @"Category";
	}
	else if (section == 2) {
		return @""; //Delete Button Header
	}
	else {
		return @"Subtitle Style";
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier1 = @"Cell_Section_1";
    NSString *CellIdentifier2 = @"Cell_Section_2";
    NSString *CellIdentifier3 = @"Cell_Section_3";
    
    NSArray * catAndTypeName = [[NSArray alloc] initWithObjects:@"Category",@"Type", nil];

    
    
    UITableViewCell *cell;
	if (indexPath.section == 0) {
		cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
		}
        cell.textLabel.text = [theNewNode.tags objectForKey:@"name"];
        cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;

	}
	else if (indexPath.section == 1) {
		cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier2];
        }
        cell.textLabel.text = [catAndTypeName objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [catAndType objectAtIndex:indexPath.row];
        cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
        //cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",indexPath.row];
	}
    else if (indexPath.section == 2) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier3];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier3];
        }
        
        deleteButton.frame = cell.contentView.bounds;
       
        [cell.contentView addSubview:deleteButton];
    }
    
	
	// Configure the cell...
	//cell.textLabel.text = @"Text Label";
	//cell.detailTextLabel.text = @"Detail Text Label";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        OPETextEdit * viewer = [[OPETextEdit alloc] initWithNibName:@"OPETextEdit" bundle:nil];
        
        viewer.title = @"Name";
        viewer.text = [theNewNode.tags objectForKey:@"name"];
        [viewer setDelegate:self];
        
        [self.navigationController pushViewController:viewer animated:YES];
    }
    else if(indexPath.section == 1)
    {
        
        if(indexPath.row == 1)
        {
            OPETypeViewController * viewer = [[OPETypeViewController alloc] initWithNibName:@"OPETypeViewController" bundle:nil];
            viewer.title = @"Type";
            viewer.category = [catAndType objectAtIndex:0];
            [viewer setDelagate:self];
            NSLog(@"category previous: %@",viewer.category);
            
            [self.navigationController pushViewController:viewer animated:YES];
            
        }
        else
        {
            OPECategoryViewController * viewer = [[OPECategoryViewController alloc] initWithNibName:@"OpeCategoryViewController" bundle:nil];
            viewer.title = @"Category";
            
            [self.navigationController pushViewController:viewer animated:YES];
        }
    }
}

- (void) saveButtonPressed
{
    NSLog(@"saveBottoPressed");
    OPEOSMData* data = [[OPEOSMData alloc] init];
    NSInteger change = 420;
    NSLog(@"save button change: %d",change);
    [data deleteXmlNode:node withChangeset:change];
}

- (void) deleteButtonPressed
{
    NSLog(@"Delete Button Pressed");
}

- (void) setText:(NSString *)text
{
    [theNewNode.tags setObject:text forKey:@"name"];
    //NSLog(@"we're back %@", text);
    //[self.tableView reloadData];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void) setCategoryAndType:(NSArray *)cAndT
{
    catAndType = cAndT;
    NSArray * KV = [tagInterpreter getOsmKeyValue:[[NSDictionary alloc] initWithObjectsAndKeys:[cAndT objectAtIndex:1],[cAndT objectAtIndex:0], nil]];
    NSLog(@"catAndType: %@",catAndType);
    NSLog(@"KV: %@",KV);
    NSString * theNewKey;
    NSString * theNewValue;
    
    for (NSString * k in [KV objectAtIndex:0])
    {
        theNewKey = k;
        theNewValue = [[KV objectAtIndex:0] objectForKey:k];
    }
    
    NSLog(@"ID: %d",node.ident);
    NSLog(@"Version: %d",node.version);
    NSLog(@"Lat: %f",node.coordinate.latitude);
    NSLog(@"Lon: %f",node.coordinate.longitude);
    NSLog(@"Tags: %@",node.tags);
    
    [theNewNode.tags removeObjectsForKeys:[osmKeyValue allKeys]];
    [theNewNode.tags setObject:theNewValue forKey:theNewKey];
    //NSLog(@"id: %@ \n version: %@ \n lat: %f \n lon: %f \n newTags: %@ \n ",theNewNode.ident,theNewNode.version,theNewNode.coordinate.latitude,theNewNode.coordinate.longitude,theNewNode.tags);
    NSLog(@"ID: %d",theNewNode.ident);
    NSLog(@"Version: %d",theNewNode.version);
    NSLog(@"Lat: %f",theNewNode.coordinate.latitude);
    NSLog(@"Lon: %f",theNewNode.coordinate.longitude);
    NSLog(@"Tags: %@",theNewNode.tags);
    
    //[self.tableView reloadData];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
