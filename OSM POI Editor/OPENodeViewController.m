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
#import "OPEInfoViewController.h"
#import "OPEBinaryCell.h"



@implementation OPENodeViewController

@synthesize node, theNewNode, type;
@synthesize tableView;
@synthesize catAndType;
@synthesize deleteButton, saveButton;
@synthesize delegate;
@synthesize nodeIsEdited;
@synthesize HUD;
@synthesize tableSections;

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
    
    self.saveButton = [[UIBarButtonItem alloc] initWithTitle: @"Save" style: UIBarButtonItemStyleBordered target: self action: @selector(saveButtonPressed)];
    
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
    //self.deleteButton.frame = CGRectMake(0, 0, 300, 44);
    [self.deleteButton addTarget:self action:@selector(deleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    
    theNewNode = [[OPENode alloc] initWithNode:node];
    [self checkSaveButton];
    
    
    tagInterpreter = [OPETagInterpreter sharedInstance];
    
    NSLog(@"Tags: %@",theNewNode.tags);
    //NSLog(@"new Category and Type: %@",[tagInterpreter getCategoryandType:theNewNode]);
    catAndType = [[NSArray alloc] initWithObjects:[tagInterpreter getCategory:theNewNode],[tagInterpreter getType:theNewNode], nil];
    //osmKeyValue =  [[NSDictionary alloc] initWithDictionary: [tagInterpreter getPrimaryKeyValue:theNewNode]];
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.HUD.delegate = self;
    
    
    [self reloadTags];
    
    
    
}
-(void) reloadTags
{
    NSDictionary * nameSection = [[NSDictionary alloc] initWithObjectsAndKeys:@"Name",@"section",[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:@"text",@"values",@"name",@"osmKey",@"Name",@"name", nil]],@"rows", nil];
    tableSections = [NSMutableArray arrayWithObject:nameSection];
    
    NSArray * ct = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"category",@"values", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"category",@"values", nil], nil];
    NSDictionary * categorySection = [[NSDictionary alloc] initWithObjectsAndKeys:@"Category",@"section",ct,@"rows", nil];
    [tableSections addObject:categorySection];
    
    //add optional
    [self addOptionalTags];
    
    NSDictionary * noteSection = [[NSDictionary alloc] initWithObjectsAndKeys:@"Note",@"section",[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:@"text",@"values",@"note",@"osmKey",@"Note",@"name", nil]],@"rows", nil];
    [tableSections addObject: noteSection];
    
    if (node.ident>0) {
        NSDictionary * deleteSection = [[NSDictionary alloc] initWithObjectsAndKeys:@"",@"section",[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:@"deleteButton",@"values", nil]],@"rows", nil];
        [tableSections addObject: deleteSection];
    }
    NSLog(@"Table sections: %@",tableSections);
    
}

-(void) addOptionalTags
{
    if ([catAndType count] ) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadComplete:) name:@"uploadComplete" object:nil];
        NSArray * optionalTags = [[NSArray alloc] initWithArray: [OPETagInterpreter getOptionalTagsDictionaries: [tagInterpreter.CategoryTypeandOptionalTags objectForKey:[NSDictionary dictionaryWithObject:[catAndType objectAtIndex:1] forKey:[catAndType objectAtIndex:0]]]]];
        
        NSMutableArray * tempArray = [[NSMutableArray alloc] init];
        
        NSMutableDictionary * sectionDictionary = [[NSMutableDictionary alloc] init];
        for(NSDictionary * tagDictionary in optionalTags)
        {
            
            if (!([[tagDictionary objectForKey:@"section"] isEqualToString:[sectionDictionary objectForKey:@"section"]])) {
                if ([sectionDictionary objectForKey:@"section"]) {
                    [sectionDictionary setObject:tempArray forKey:@"rows"];
                    [tableSections addObject:sectionDictionary];
                    sectionDictionary = [[NSMutableDictionary alloc] init];
                    tempArray = [[NSMutableArray alloc] init];
                }
                [sectionDictionary setObject:[tagDictionary objectForKey:@"section"] forKey:@"section"];
                [tempArray addObject:tagDictionary];
            }
            else {
                [tempArray addObject:tagDictionary];
            }
            
        }
        [sectionDictionary setObject:tempArray forKey:@"rows"];
        [tableSections addObject:sectionDictionary];

        
        NSLog(@"Optional tags: %@",optionalTags);
        
        
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [tableSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[[tableSections objectAtIndex:section] objectForKey:@"rows"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [[tableSections objectAtIndex:section] objectForKey:@"section"];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifierText = @"Cell_Section_1";
    NSString *CellIdentifierCategory = @"Cell_Section_2";
    NSString *CellIdentifierDelete = @"Cell_Section_3";
    NSString *CellIdentifierBinary = @"Cell_Section_4";
    
    NSArray * catAndTypeName = [[NSArray alloc] initWithObjects:@"Category",@"Type", nil];
    
    NSDictionary * cellDictionary = [NSDictionary dictionaryWithDictionary:[[[tableSections objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row]];
    
    UITableViewCell *cell;
    if([[cellDictionary objectForKey:@"values"] isKindOfClass:[NSDictionary class]])
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifierCategory];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifierCategory];
        }
        if ([[[cellDictionary objectForKey:@"values"] allKeysForObject:[theNewNode.tags objectForKey:[cellDictionary objectForKey:@"osmKey"]]] count]) {
            cell.detailTextLabel.text = [[[cellDictionary objectForKey:@"values"] allKeysForObject:[theNewNode.tags objectForKey:[cellDictionary objectForKey:@"osmKey"]]] objectAtIndex:0];
        }
        else {
            cell.detailTextLabel.text = [theNewNode.tags objectForKey:[cellDictionary objectForKey:@"osmKey"]];
        }
        
        cell.textLabel.text = [cellDictionary objectForKey:@"name"];
        
        
        cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
        
    }
    else {
        if ([[cellDictionary objectForKey:@"values"] isEqualToString:@"text"]) { //Text editing
            cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifierText];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierText];
            }
            cell.textLabel.text = [theNewNode.tags objectForKey:[cellDictionary objectForKey:@"osmKey"]];
            cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
        }
        else if ([[cellDictionary objectForKey:@"values"] isEqualToString:@"category"]) { //special category
            cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifierCategory];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifierCategory];
            }
            cell.textLabel.text = [catAndTypeName objectAtIndex:indexPath.row];
            cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
            if ([catAndType count]==2) {
                cell.detailTextLabel.text = [catAndType objectAtIndex:indexPath.row];
            }
            else
            {
                cell.detailTextLabel.text =@"";
            }
        }
        else if ([[cellDictionary objectForKey:@"values"] isEqualToString:@"label"])
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifierCategory];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifierCategory];
            }
            cell.detailTextLabel.text = [theNewNode.tags objectForKey:[cellDictionary objectForKey:@"osmKey"]];
            cell.textLabel.text = [cellDictionary objectForKey:@"name"];
            
            cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
        }
        else if ([[cellDictionary objectForKey:@"values"] isEqualToString:@"binary"])
        {
            OPEBinaryCell * aCell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifierBinary];
            if (aCell == nil) {
                aCell = [[OPEBinaryCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifierBinary];
            }
            [aCell setLeftText: [cellDictionary objectForKey:@"name"]];
            if ([theNewNode.tags objectForKey:[cellDictionary objectForKey:@"osmKey"]]) {
                if ([[theNewNode.tags objectForKey:[cellDictionary objectForKey:@"osmKey"]] isEqualToString:@"yes"]) {
                     [aCell.binaryControl setSelectedSegmentIndex:0];
                }
                else if([[theNewNode.tags objectForKey:[cellDictionary objectForKey:@"osmKey"]] isEqualToString:@"no"])
                {
                     [aCell.binaryControl setSelectedSegmentIndex:1];
                }
            }
            else {
                [aCell.binaryControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
            }
            [aCell.binaryControl addTarget:self action:@selector(binaryChanged:) forControlEvents:UIControlEventValueChanged];
            aCell.tag = indexPath.section;
            aCell.binaryControl.tag = indexPath.row;
            return aCell;
        }
        else if ([[cellDictionary objectForKey:@"values"] isEqualToString:@"deleteButton"])
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifierDelete];
            if(cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierDelete];
            }
            
            deleteButton.frame = cell.contentView.bounds;
            NSLog(@"bounds: %f",cell.contentView.bounds.size.width);
            NSLog(@"button: %f",deleteButton.frame.size.width);
            deleteButton.frame = CGRectMake(deleteButton.frame.origin.x, deleteButton.frame.origin.y, 300.0f, deleteButton.frame.size.height);
            
            [cell.contentView addSubview:deleteButton];
        }
    }

    return cell;
}

-(void)binaryChanged:(id)sender
{
    if (sender) {
        
        
        NSDictionary * cellDictionary = [NSDictionary dictionaryWithDictionary:[[[tableSections objectAtIndex:[[sender superview] tag]] objectForKey:@"rows"] objectAtIndex:[sender tag]]];
        NSLog(@"Binary Changed: %@",cellDictionary);
        if ([sender selectedSegmentIndex] == 0) {
            //Yes
            [self newTag:[NSDictionary dictionaryWithObjectsAndKeys:[cellDictionary objectForKey:@"osmKey"],@"osmKey",@"yes",@"osmValue", nil]];
        }
        else if ([sender selectedSegmentIndex] == 1){
            //No
            [self newTag:[NSDictionary dictionaryWithObjectsAndKeys:[cellDictionary objectForKey:@"osmKey"],@"osmKey",@"no",@"osmValue", nil]];
        }
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary * cellDictionary = [NSDictionary dictionaryWithDictionary:[[[tableSections objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row]];
    if([[cellDictionary objectForKey:@"values"] isKindOfClass:[NSDictionary class]])
    {
        //list view cell 
        OPETagValueList * viewer = [[OPETagValueList alloc] initWithNibName:@"OPETagValueList" bundle:nil];
        viewer.title = [cellDictionary objectForKey:@"name"];
        viewer.osmValue = [theNewNode.tags objectForKey:[cellDictionary objectForKey:@"osmKey"]];
        viewer.osmKey = [cellDictionary objectForKey:@"osmKey"];
        viewer.values = [cellDictionary objectForKey:@"values"];
        [viewer setDelegate:self];
        [self.navigationController pushViewController:viewer animated:YES];

        
    }
    else {
        if ([[cellDictionary objectForKey:@"values"] isEqualToString:@"text"] || [[cellDictionary objectForKey:@"values"] isEqualToString:@"label"] ) { //Text editing
            OPETextEdit * viewer = [[OPETextEdit alloc] initWithNibName:@"OPETextEdit" bundle:nil];
            viewer.title = [cellDictionary objectForKey:@"name"];
            viewer.osmValue = [theNewNode.tags objectForKey:[cellDictionary objectForKey:@"osmKey"]];
            viewer.osmKey = [cellDictionary objectForKey:@"osmKey"];
            [viewer setDelegate:self];
            [self.navigationController pushViewController:viewer animated:YES];
        }
        else if([[cellDictionary objectForKey:@"values"] isEqualToString:@"category"])
        {
            if(indexPath.row == 1)
            {
                if ([catAndType count]==2) 
                {
                    OPETypeViewController * viewer = [[OPETypeViewController alloc] initWithNibName:@"OPETypeViewController" bundle:[NSBundle mainBundle]];
                    viewer.title = @"Type";
                    
                    viewer.category = [catAndType objectAtIndex:0];
                    [viewer setDelegate:self];
                    NSLog(@"category previous: %@",viewer.category);
                    
                    [self.navigationController pushViewController:viewer animated:YES];
                }
                else {
                    OPECategoryViewController * viewer = [[OPECategoryViewController alloc] initWithNibName:@"OPECategoryViewController" bundle:[NSBundle mainBundle]];
                    viewer.title = @"Category";
                    [viewer setDelegate:self];
                    
                    [self.navigationController pushViewController:viewer animated:YES];
                }
            }
            else
            {
                OPECategoryViewController * viewer = [[OPECategoryViewController alloc] initWithNibName:@"OPECategoryViewController" bundle:[NSBundle mainBundle]];
                viewer.title = @"Category";
                [viewer setDelegate:self];
                
                [self.navigationController pushViewController:viewer animated:YES];
            }
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
     NSDictionary * cellDictionary = [NSDictionary dictionaryWithDictionary:[[[tableSections objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row]];
    if ([[cellDictionary objectForKey:@"values"] isKindOfClass:[NSString class]]) {
        if ([[cellDictionary objectForKey:@"values"] isEqualToString:@"category"]) {
            return NO;
        }
    }
  
    return YES;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Remove";
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
         NSDictionary * cellDictionary = [NSDictionary dictionaryWithDictionary:[[[tableSections objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row]];
        [self newTag:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"osmValue",[cellDictionary objectForKey:@"osmKey"],@"osmKey", nil]];
    }
    
}
-(void) showOauthError
{
    if (HUD)
    {
        [HUD hide:YES];
    }
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"OAuth Error"
                                                      message:@"You need to login to OpenStreetMap"
                                                     delegate:self
                                            cancelButtonTitle:@"Login"
                                            otherButtonTitles:@"Cancel", nil];
    message.tag = 0;
    [message show];
}

- (void) saveButtonPressed
{
    OPEOSMData* data = [[OPEOSMData alloc] init];
    if (![data canAuth])
    {
        [self showOauthError];
    }
    else if (![theNewNode isEqualToNode:node]) 
    {
        [self.view addSubview:HUD];
        [HUD setLabelText:@"Saving..."];
        [HUD show:YES];
        dispatch_queue_t q = dispatch_queue_create("queue", NULL);
        dispatch_async(q, ^{
            NSLog(@"saveBottoPressed");
            
            [OPEOSMData backToHTML:theNewNode];
            
            if(theNewNode.ident<0)
            {
                NSLog(@"Create Node");
                int newIdent = [data createNode:theNewNode];
                NSLog(@"New Id: %d", newIdent);
                theNewNode.ident = newIdent;
                theNewNode.version = 1;
                node = theNewNode;
                if(delegate)
                {
                    [OPEOSMData HTMLFix:theNewNode];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate createdNode:node];
                    });
                }
            }
            else
            {
                NSLog(@"Update Node");
                int version = [data updateNode:theNewNode];
                NSLog(@"Version after update: %d",version);
                theNewNode.version = version;
                node = theNewNode;
                if(delegate)
                {
                    [OPEOSMData HTMLFix:theNewNode];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate updatedNode:node];
                    });
                }
            }
            
        });
        
        dispatch_release(q);

        
    }
    else {
        NSLog(@"NO CHANGES TO UPLOAD");
    }
     nodeIsEdited = NO;
}

- (void) deleteButtonPressed
{
    OPEOSMData* data = [[OPEOSMData alloc] init];
    if (![data canAuth])
    {
        [self showOauthError];
    }
    else {
        NSLog(@"Delete Button Pressed");
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Delete Point of Interest"
                                                          message:@"Are you Sure you want to delete this node?"
                                                         delegate:self
                                                cancelButtonTitle:@"Yes"
                                                otherButtonTitles:@"Cancel",nil];
        message.tag = 1;
        
        [message show];
    }
   
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    NSLog(@"AlertView Tag %d",alertView.tag);
    if(alertView.tag == 0)
    {
        if([title isEqualToString:@"Login"])
        {
            NSLog(@"SignInToOSM");
            [self signInToOSM];
        }
        
    }
    else if (alertView.tag == 1) {
        if([title isEqualToString:@"Yes"])
        {
            NSLog(@"Button OK was selected.");
            
            [self.view addSubview:HUD];
            [HUD setLabelText:@"Deleting..."];
            [HUD show:YES];
            dispatch_queue_t q = dispatch_queue_create("queue", NULL);
            dispatch_async(q, ^{
                [OPEOSMData backToHTML:node];
                
                OPEOSMData* data = [[OPEOSMData alloc] init];
                [data deleteNode:node];
                if(delegate)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate deletedNode:node];
                    });
                    
                }
            });
            
            dispatch_release(q);
            
        }
        else if([title isEqualToString:@"Cancel"])
        {
            NSLog(@"Button Cancel was selected.");
        }
    }
    
   
    
}

- (void) newTag:(NSDictionary *)tag
{
    NSString * osmKey = [tag objectForKey:@"osmKey"];
    NSString * osmValue = [tag objectForKey:@"osmValue"];
    
    if (![osmValue isEqualToString:@""]) 
    {
        [theNewNode.tags setObject:osmValue forKey:osmKey];
    }
    else {
        [theNewNode.tags removeObjectForKey:osmKey];
    }
    [self reloadTags];
    [self.tableView reloadData];
    NSLog(@"NewNode: %@",theNewNode.tags);
}
/*
- (void) setText:(NSString *)text
{
    NSString * newName = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString * oldName = [theNewNode.tags objectForKey:@"name"];
    if (![newName isEqualToString:@""]) 
    {
        NSLog(@"check string: %@",newName);
        if (oldName) 
        {
            if(![oldName isEqualToString:newName])
            {
                [theNewNode.tags setObject:text forKey:@"name"];
                nodeIsEdited = YES;
            }
        }
        else {
            [theNewNode.tags setObject:text forKey:@"name"];
            nodeIsEdited = YES;
        }
    }
    else {
        if (oldName) {
            [theNewNode.tags removeObjectForKey:@"name"];
            nodeIsEdited = YES;
        }
        NSLog(@"emptyString");
        
    }
    NSLog(@"NewNode: %@",theNewNode.tags);
    
    //NSLog(@"we're back %@", text);
    //[self.tableView reloadData];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}
*/
- (void) setCategoryAndType:(NSDictionary *)cAndT
{
    if ([catAndType count]==2) {
        [tagInterpreter removeCatAndType:[[NSDictionary alloc] initWithObjectsAndKeys:[catAndType objectAtIndex:1],[catAndType objectAtIndex:0], nil] fromNode:theNewNode];
    }
    NSString * newCategory = [cAndT objectForKey:@"category"];
    NSString * newType = [cAndT objectForKey:@"type"];
    
    
    NSDictionary * KV = [tagInterpreter getOSmKeysValues:[[NSDictionary alloc] initWithObjectsAndKeys:newType,newCategory, nil]];
    NSLog(@"catAndType: %@",cAndT);
    //NSLog(@"KV: %@",osmKeyValue);
    
    
    NSLog(@"ID: %d",theNewNode.ident);
    NSLog(@"Version: %d",theNewNode.version);
    NSLog(@"Lat: %f",theNewNode.coordinate.latitude);
    NSLog(@"Lon: %f",theNewNode.coordinate.longitude);
    NSLog(@"Tags: %@",theNewNode.tags);
    
    [theNewNode.tags addEntriesFromDictionary:KV];
    
    
    //NSLog(@"id: %@ \n version: %@ \n lat: %f \n lon: %f \n newTags: %@ \n ",theNewNode.ident,theNewNode.version,theNewNode.coordinate.latitude,theNewNode.coordinate.longitude,theNewNode.tags);
    NSLog(@"ID: %d",theNewNode.ident);
    NSLog(@"Version: %d",theNewNode.version);
    NSLog(@"Lat: %f",theNewNode.coordinate.latitude);
    NSLog(@"Lon: %f",theNewNode.coordinate.longitude);
    NSLog(@"Tags: %@",theNewNode.tags);
    theNewNode.image = [tagInterpreter getImageForNode:theNewNode];
    
    catAndType = [[NSArray alloc] initWithObjects: newCategory ,newType, nil];
    //[self.tableView reloadData];
    [self reloadTags];
    [self.tableView reloadData];
}



- (void)checkSaveButton
{
    NSLog(@"cAndT count %d",[catAndType count]);
    if([theNewNode isEqualToNode:node] || [catAndType count]!=2)
    {
        NSLog(@"NO CHANGES YET");
        self.saveButton.enabled= NO;
    }
    else {
        self.saveButton.enabled = YES;
    }
}
-(void) uploadComplete:(NSNotification *)notification
{
    NSLog(@"got notification");
    
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.HUD hide:YES];
    node = theNewNode;
    [self checkSaveButton];
    [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void) viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
    [self checkSaveButton];
    
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

#pragma - OAuth
- (void)viewController:(GTMOAuthViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuthAuthentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        // Authentication failed (perhaps the user denied access, or closed the
        // window before granting access)
        NSLog(@"Authentication error: %@", error);
        NSData *responseData = [[error userInfo] objectForKey:@"data"];// kGTMHTTPFetcherStatusDataKey
        if ([responseData length] > 0) {
            // show the body of the server's authentication failure response
            NSString *str = [[NSString alloc] initWithData:responseData
                                                  encoding:NSUTF8StringEncoding];
            NSLog(@"%@", str);
        }
        
        //[self setAuthentication:nil];
    } else {
        // Authentication succeeded
        //
        // At this point, we either use the authentication object to explicitly
        // authorize requests, like
        //
        //   [auth authorizeRequest:myNSURLMutableRequest]
        //
        // or store the authentication object into a GTM service object like
        //
        //   [[self contactService] setAuthorizer:auth];
        
        // save the authentication object
        //[self setAuthentication:auth];
        
        // Just to prove we're signed in, we'll attempt an authenticated fetch for the
        // signed-in user
        //[self doAnAuthenticatedAPIFetch];
        NSLog(@"Suceeed");
        //[self dismissModalViewControllerAnimated:YES];
    }
    
    //[self updateUI];
}


- (GTMOAuthAuthentication *)osmAuth {
    NSString *myConsumerKey = @"pJbuoc7SnpLG5DjVcvlmDtSZmugSDWMHHxr17wL3";    // pre-registered with service
    NSString *myConsumerSecret = @"q5qdc9DvnZllHtoUNvZeI7iLuBtp1HebShbCE9Y1"; // pre-assigned by service
    
    GTMOAuthAuthentication *auth;
    auth = [[GTMOAuthAuthentication alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1
                                                       consumerKey:myConsumerKey
                                                        privateKey:myConsumerSecret];
    
    // setting the service name lets us inspect the auth object later to know
    // what service it is for
    auth.serviceProvider = @"OSMPOIEditor";
    
    return auth;
}

- (void)signInToOSM {
    
    NSURL *requestURL = [NSURL URLWithString:@"http://www.openstreetmap.org/oauth/request_token"];
    NSURL *accessURL = [NSURL URLWithString:@"http://www.openstreetmap.org/oauth/access_token"];
    NSURL *authorizeURL = [NSURL URLWithString:@"http://www.openstreetmap.org/oauth/authorize"];
    NSString *scope = @"http://api.openstreetmap.org/";
    
    GTMOAuthAuthentication *auth = [self osmAuth];
    if (auth == nil) {
        // perhaps display something friendlier in the UI?
        NSLog(@"A valid consumer key and consumer secret are required for signing in to OSM");
    }
    
    // set the callback URL to which the site should redirect, and for which
    // the OAuth controller should look to determine when sign-in has
    // finished or been canceled
    //
    // This URL does not need to be for an actual web page
    [auth setCallback:@"http://www.google.com/OAuthCallback"];
    
    // Display the autentication view
    GTMOAuthViewControllerTouch * viewController = [[GTMOAuthViewControllerTouch alloc] initWithScope:scope
                                                                                             language:nil
                                                                                      requestTokenURL:requestURL
                                                                                    authorizeTokenURL:authorizeURL
                                                                                       accessTokenURL:accessURL
                                                                                       authentication:auth
                                                                                       appServiceName:@"OSMPOIEditor"
                                                                                             delegate:self
                                                                                     finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    [[self navigationController] pushViewController:viewController animated:YES];
}

@end
