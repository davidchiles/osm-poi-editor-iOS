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
#import "OPEConstants.h"
#import "OPEAPIConstants.h"
#import "OPESpecialCell2.h"
#import "OPEWay.h"



@implementation OPENodeViewController

@synthesize point, theNewPoint;
@synthesize nodeInfoTableView;
@synthesize deleteButton, saveButton;
@synthesize delegate;
@synthesize nodeIsEdited;
@synthesize HUD;
@synthesize tableSections;
@synthesize nodeType;

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
    
    nodeInfoTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [nodeInfoTableView setDataSource:self];
    [nodeInfoTableView setDelegate:self];
    nodeInfoTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    if (point.ident>0) {
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
        self.deleteButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, nodeInfoTableView.frame.size.width, 50)];
        self.deleteButton.frame = CGRectMake(10, 0, nodeInfoTableView.frame.size.width-20, 46);
        footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [footerView addSubview:deleteButton];
        
        
        self.nodeInfoTableView.tableFooterView = footerView;
        //self.nodeInfoTableView.tableFooterView.frame = CGRectMake(0, 0, 300, 50);
        //[nodeInfoTableView setContentOffset:CGPointMake(0, nodeInfoTableView.contentSize.height-50) animated:YES];
    }
    
    
    

    [self checkSaveButton];
    
    [self.view addSubview:nodeInfoTableView];
    
    tagInterpreter = [OPETagInterpreter sharedInstance];
    
    theNewPoint = [point copy];
    
    NSLog(@"Tags: %@",theNewPoint.tags);
    //NSLog(@"new Category and Type: %@",[tagInterpreter getCategoryandType:theNewPoint]);
    nodeType = [tagInterpreter type:theNewPoint];
    //osmKeyValue =  [[NSDictionary alloc] initWithDictionary: [tagInterpreter getPrimaryKeyValue:theNewPoint]];
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    self.HUD.delegate = self;
    
    
    [self reloadTags];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadComplete:) name:@"uploadComplete" object:nil];
    
    
    
}
-(void) reloadTags
{
    NSDictionary * nameSection = [[NSDictionary alloc] initWithObjectsAndKeys:@"Name",@"section",[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:KTypeName,@"values",@"name",@"osmKey",@"Name",@"name", nil]],@"rows", nil];
    tableSections = [NSMutableArray arrayWithObject:nameSection];
    
    NSArray * ct = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"category",@"values", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"category",@"values", nil], nil];
    NSDictionary * categorySection = [[NSDictionary alloc] initWithObjectsAndKeys:@"Category",@"section",ct,@"rows", nil];
    [tableSections addObject:categorySection];
    
    //add optional
    [self addOptionalTags];
    
    NSDictionary * noteSection = [[NSDictionary alloc] initWithObjectsAndKeys:@"Note",@"section",[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:@"text",@"values",@"note",@"osmKey",@"Note",@"name", nil]],@"rows", nil];
    [tableSections addObject: noteSection];
    
    
    //NSLog(@"Table sections: %@",tableSections);
    
}

-(void) addOptionalTags
{
    if (nodeType) {
        NSArray * optionalTags = [OPETagInterpreter getOptionalTagsDictionaries:nodeType.optionalTags];
        
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
                if ([tagDictionary objectForKey:@"section_order"]) {
                     [sectionDictionary setObject:[tagDictionary objectForKey:@"section_order"] forKey:@"section_order"];
                }
                [tempArray addObject:tagDictionary];
            }
            else {
                [tempArray addObject:tagDictionary];
            }
            
        }
        NSSortDescriptor *sortByNumber = [NSSortDescriptor sortDescriptorWithKey:@"section_order" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByNumber];
        NSArray *sortedArray = [tempArray sortedArrayUsingDescriptors:sortDescriptors];
        [sectionDictionary setObject:sortedArray forKey:@"rows"];
        [tableSections addObject:sectionDictionary];

        
        NSLog(@"Optional tags: %@",optionalTags);
        
        optionalTagWidth = [self getWidth:optionalTags];
    }
}

-(float)getWidth:(NSArray *)optionalTags
{
    float maxWidth = 0.0;
    
    for(NSDictionary * keyDictionary in optionalTags)
    {
        NSString * name = [keyDictionary objectForKey:@"name"];
        float currentWidth = [name sizeWithFont:[UIFont boldSystemFontOfSize:12.0]].width;
        maxWidth = MAX(maxWidth, currentWidth);
        
    }
    return maxWidth;
    
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
    NSString *CellIdentifierSpecialBinary = @"Cell_Section_5";
    NSString *CellIdentifierSpecial2 = @"Cell_Section_6";
    
    NSArray * catAndTypeName = [[NSArray alloc] initWithObjects:@"Category",@"Type", nil];
    
    NSDictionary * cellDictionary = [NSDictionary dictionaryWithDictionary:[[[tableSections objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row]];
    
    UITableViewCell *cell;
    if([[cellDictionary objectForKey:@"values"] isKindOfClass:[NSDictionary class]])
    {
        if ([[cellDictionary objectForKey:@"values"]  count] <= 3)
        {
            OPEBinaryCell * aCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSpecialBinary];
            if (aCell == nil) {
                aCell = [[OPEBinaryCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifierSpecialBinary array:[[cellDictionary objectForKey:@"values"] allKeys] withTextWidth:optionalTagWidth];
                
            }
            [aCell setLeftText: [cellDictionary objectForKey:@"name"]];
            //aCell.controlArray = [[cellDictionary objectForKey:@"values"] allKeys];
            
            [aCell.binaryControl addTarget:self action:@selector(binaryChanged:) forControlEvents:UIControlEventValueChanged];
            aCell.tag = indexPath.section;
            aCell.binaryControl.tag = indexPath.row;
            if ([theNewPoint.tags objectForKey:[cellDictionary objectForKey:@"osmKey"]]) {
                //[aCell selectSegmentWithTitle:[[cellDictionary objectForKey:@"values"] allKeysForObject:[theNewPoint.tags objectForKey:[cellDictionary objectForKey:@"osmKey"]objectAtIndex:0]];
                NSString * title = [[[cellDictionary objectForKey:@"values"] allKeysForObject:[theNewPoint.tags objectForKey:[cellDictionary objectForKey:@"osmKey"]]] objectAtIndex:0];
                [aCell selectSegmentWithTitle:title];
            }
            else {
                aCell.binaryControl.selectedSegmentIndex = UISegmentedControlNoSegment;
            }
            return aCell;
        }
        else {
            OPESpecialCell2 * specialCell;
            specialCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSpecial2];
            if (specialCell == nil) {
                specialCell = [[OPESpecialCell2 alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifierSpecial2 withTextWidth:optionalTagWidth];
            }
            if ([[[cellDictionary objectForKey:@"values"] allKeysForObject:[theNewPoint.tags objectForKey:[cellDictionary objectForKey:@"osmKey"]]] count]) {
                specialCell.rightText = [[[cellDictionary objectForKey:@"values"] allKeysForObject:[theNewPoint.tags objectForKey:[cellDictionary objectForKey:@"osmKey"]]] objectAtIndex:0];
            }
            else {
                specialCell.rightText = [theNewPoint.tags objectForKey:[cellDictionary objectForKey:@"osmKey"]];
            }
            
            specialCell.leftText = [cellDictionary objectForKey:@"name"];
            
            return specialCell;
        }
        
        
    }
    else {
        if ([[cellDictionary objectForKey:@"values"] isEqualToString:kTypeText] || [[cellDictionary objectForKey:@"values"] isEqualToString:KTypeName]) { //Text editing
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierText];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierText];
            }
            cell.textLabel.text = [theNewPoint.tags objectForKey:[cellDictionary objectForKey:@"osmKey"]];
            cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
        }
        else if ([[cellDictionary objectForKey:@"values"] isEqualToString:@"category"]) { //special category
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierCategory];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifierCategory];
            }
            cell.textLabel.text = [catAndTypeName objectAtIndex:indexPath.row];
            cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
            if (nodeType) {
                if (indexPath.row == 0)
                    cell.detailTextLabel.text = nodeType.categoryName;
                else
                    cell.detailTextLabel.text = nodeType.displayName;
            }
            else
            {
                cell.detailTextLabel.text =@"";
            }
        }
        else if ([[cellDictionary objectForKey:@"values"] isEqualToString:kTypeLabel] || [[cellDictionary objectForKey:@"values"] isEqualToString:kTypeNumber] || [[cellDictionary objectForKey:@"values"] isEqualToString:kTypeUrl] ||[[cellDictionary objectForKey:@"values"] isEqualToString:kTypePhone])
        {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierCategory];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifierCategory];
            }
            cell.detailTextLabel.text = [theNewPoint.tags objectForKey:[cellDictionary objectForKey:@"osmKey"]];
            cell.textLabel.text = [cellDictionary objectForKey:@"name"];
            
            cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
        }
        else if ([[cellDictionary objectForKey:@"values"] isEqualToString:kTypeBinary])
        {
            OPEBinaryCell * aCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierBinary];
            if (aCell == nil) {
                aCell = [[OPEBinaryCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifierBinary];
            }
            [aCell setLeftText: [cellDictionary objectForKey:@"name"]];
            if ([theNewPoint.tags objectForKey:[cellDictionary objectForKey:@"osmKey"]]) {
                
                [aCell selectSegmentWithTitle:[cellDictionary objectForKey:@"osmKey"]];
                /*
                if ([[theNewPoint.tags objectForKey:[cellDictionary objectForKey:@"osmKey"]] isEqualToString:@"yes"]) {
                     [aCell.binaryControl setSelectedSegmentIndex:0];
                }
                else if([[theNewPoint.tags objectForKey:[cellDictionary objectForKey:@"osmKey"]] isEqualToString:@"no"])
                {
                     [aCell.binaryControl setSelectedSegmentIndex:1];
                }
                 */
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
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierDelete];
            if(cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierDelete];
            }
            
            //deleteButton.frame = cell.contentView.bounds;
            NSLog(@"bounds: %f",cell.contentView.bounds.size.width);
            NSLog(@"button: %f",deleteButton.frame.size.width);
            //deleteButton.frame = CGRectMake(deleteButton.frame.origin.x, deleteButton.frame.origin.y, 300.0f, deleteButton.frame.size.height);
            
            //[cell.contentView addSubview:deleteButton];
        }
    }

    return cell;
}

-(void)binaryChanged:(id)sender
{
    if (sender) {
        
        
        NSDictionary * cellDictionary = [NSDictionary dictionaryWithDictionary:[[[tableSections objectAtIndex:[[sender superview] tag]] objectForKey:@"rows"] objectAtIndex:[sender tag]]];
        NSLog(@"Binary Changed: %@",cellDictionary);
        [self newTag:[NSDictionary dictionaryWithObjectsAndKeys:[cellDictionary objectForKey:@"osmKey"],@"osmKey",[[cellDictionary objectForKey:@"values"] objectForKey:[sender titleForSegmentAtIndex:[sender selectedSegmentIndex]]],@"osmValue", nil]];
        /*
        if ([sender selectedSegmentIndex] == 0) {
            //Yes
            [self newTag:[NSDictionary dictionaryWithObjectsAndKeys:[cellDictionary objectForKey:@"osmKey"],@"osmKey",@"yes",@"osmValue", nil]];
        }
        else if ([sender selectedSegmentIndex] == 1){
            //No
            [self newTag:[NSDictionary dictionaryWithObjectsAndKeys:[cellDictionary objectForKey:@"osmKey"],@"osmKey",@"no",@"osmValue", nil]];
        }
        else if([sender selectedSegmentIndex] ==2){
            [self newTag:[NSDictionary dictionaryWithObjectsAndKeys:[cellDictionary objectForKey:@"osmKey"],@"osmKey",[[cellDictionary objectForKey:@"values"] objectForKey:[sender titleForSegmentAtIndex:[sender selectedSegmentIndex]]],@"osmValue", nil]];
        }
        */
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary * cellDictionary = [NSDictionary dictionaryWithDictionary:[[[tableSections objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row]];
    if ([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[OPEBinaryCell class]])
    {
        //binary or 3 way type
    }
    else if([[cellDictionary objectForKey:@"values"] isKindOfClass:[NSDictionary class]])
    {
        //list view cell 
        OPETagValueList * viewer = [[OPETagValueList alloc] initWithNibName:@"OPETagValueList" bundle:nil];
        viewer.title = [cellDictionary objectForKey:@"name"];
        viewer.osmValue = [theNewPoint.tags objectForKey:[cellDictionary objectForKey:@"osmKey"]];
        viewer.osmKey = [cellDictionary objectForKey:@"osmKey"];
        viewer.values = [cellDictionary objectForKey:@"values"];
        [viewer setDelegate:self];
        [self.navigationController pushViewController:viewer animated:YES];

        
    }
    else {
        if ([[cellDictionary objectForKey:@"values"] isEqualToString:kTypeText] || [[cellDictionary objectForKey:@"values"] isEqualToString:kTypeLabel] || [[cellDictionary objectForKey:@"values"] isEqualToString:kTypeNumber] || [[cellDictionary objectForKey:@"values"] isEqualToString:kTypeUrl] || [[cellDictionary objectForKey:@"values"] isEqualToString:kTypePhone] || [[cellDictionary objectForKey:@"values"] isEqualToString:KTypeName] ){ //Text editing
            OPETextEdit * viewer = [[OPETextEdit alloc] initWithNibName:@"OPETextEdit" bundle:nil];
            viewer.title = [cellDictionary objectForKey:@"name"];
            viewer.osmValue = [theNewPoint.tags objectForKey:[cellDictionary objectForKey:@"osmKey"]];
            viewer.osmKey = [cellDictionary objectForKey:@"osmKey"];
            viewer.type = [cellDictionary objectForKey:@"values"];
            [viewer setDelegate:self];
            [self.navigationController pushViewController:viewer animated:YES];
        }
        else if([[cellDictionary objectForKey:@"values"] isEqualToString:@"category"])
        {
            if(indexPath.row == 1)
            {
                if (nodeType)
                {
                    OPETypeViewController * viewer = [[OPETypeViewController alloc] initWithNibName:@"OPETypeViewController" bundle:[NSBundle mainBundle]];
                    viewer.title = @"Type";
                    
                    viewer.category = [tagInterpreter.nameAndCategory objectForKey:nodeType.categoryName];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
     NSDictionary * cellDictionary = [NSDictionary dictionaryWithDictionary:[[[tableSections objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row]];
    if ([[cellDictionary objectForKey:@"values"] isKindOfClass:[NSString class]]) {
        if ([[cellDictionary objectForKey:@"values"] isEqualToString:@"category"]) {
            return NO;
        }
    }
    //NSString * cellText = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
  
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
    else if (![theNewPoint isequaltToPoint:point]) 
    {
        [self.navigationController.view addSubview:HUD];
        [HUD setLabelText:@"Saving..."];
        [HUD show:YES];
        dispatch_queue_t q = dispatch_queue_create("queue", NULL);
        dispatch_async(q, ^{
            NSLog(@"saveBottoPressed");
            
            [OPEOSMData backToHTML:theNewPoint];
            
            if(theNewPoint.ident<0)
            {
                NSLog(@"Create Node");
                int newIdent = [data createNode:theNewPoint];
                NSLog(@"New Id: %d", newIdent);
                theNewPoint.ident = newIdent;
                theNewPoint.version = 1;
                point = theNewPoint;
                if(delegate)
                {
                    [OPEOSMData HTMLFix:theNewPoint];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate createdNode:point];
                    });
                }
            }
            else
            {
                NSLog(@"Update Node");
                int version = [data updateNode:theNewPoint];
                NSLog(@"Version after update: %d",version);
                theNewPoint.version = version;
                point = theNewPoint;
                if(delegate)
                {
                    [OPEOSMData HTMLFix:theNewPoint];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate updatedNode:point];
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
            NSLog(@"Button YES was selected.");
            
            [self.navigationController.view addSubview:HUD];
            [HUD setLabelText:@"Deleting..."];
            [HUD show:YES];
            
            if ([theNewPoint isKindOfClass:[OPEWay class]]) {
                OPEOSMData* data = [[OPEOSMData alloc] init];
                NSMutableArray * keysToRemove = [NSMutableArray arrayWithArray:[nodeType.tags allKeys]];
                [keysToRemove addObject:@"name"];
                [keysToRemove addObjectsFromArray:[OPETagInterpreter getOptionalTagsKeys:nodeType.optionalTags]];
                [theNewPoint.tags removeObjectsForKeys:keysToRemove];
                NSLog(@"Update Node");
                int version = [data updateNode:theNewPoint];
                NSLog(@"Version after update: %d",version);
                theNewPoint.version = version;
                point = theNewPoint;
                if(delegate)
                {
                    [OPEOSMData HTMLFix:theNewPoint];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [delegate deletedNode:point];
                    });
                }

            }
            else
            {
                dispatch_queue_t q = dispatch_queue_create("queue", NULL);
                dispatch_async(q, ^{
                    [OPEOSMData backToHTML:point];
                    
                    OPEOSMData* data = [[OPEOSMData alloc] init];
                    [data deleteNode:point];
                    if(delegate)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [delegate deletedNode:point];
                        });
                        
                    }
                });
                
                dispatch_release(q);
            }
            
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
        [theNewPoint.tags setObject:osmValue forKey:osmKey];
    }
    else {
        [theNewPoint.tags removeObjectForKey:osmKey];
    }
    [self reloadTags];
    [self checkSaveButton];
    [nodeInfoTableView reloadData];
    NSLog(@"NewNode: %@",theNewPoint.tags);
}
-(void) removeOptionalTags:(NSArray *)oldTableSections
{
    for(int i = 2; i<[oldTableSections count]-2; i++)
    {
        NSDictionary * oldSectionDictionary = [oldTableSections objectAtIndex:i];
        if (![[oldSectionDictionary objectForKey:@"section"] isEqualToString:@"Address"]) {
            NSArray * oldRowArray = [ oldSectionDictionary objectForKey:@"rows"];
            for (NSDictionary * oldRowDictionary in oldRowArray)
            {
                if(![self tableSectionsContainsOsmKey:[oldRowDictionary objectForKey:@"osmKey"]])
                {
                    [self.theNewPoint.tags removeObjectForKey:[oldRowDictionary objectForKey:@"osmKey"]];
                    NSLog(@"Removed: %@",[oldRowDictionary objectForKey:@"osmKey"]);
                }
                    
            }
            
        }
    }
}
-(BOOL) tableSectionsContainsOsmKey:(NSString *)osmKey
{
    for(int i = 2; i<[tableSections count]-2; i++)
    {
        NSDictionary * sectionDictioanry = [tableSections objectAtIndex:i];
        if (![[sectionDictioanry objectForKey:@"section"] isEqualToString:@"Address"]) {
            NSArray * rowArray = [ sectionDictioanry objectForKey:@"rows"];
            for (NSDictionary * rowDictionary in rowArray)
            {
                if ([[rowDictionary objectForKey:@"osmKey"] isEqualToString:osmKey]) {
                    return YES;
                }
            }
            
        }
    }
    return NO;
}

- (void) setNewType:(OPEType *)newType
{
    
    if (nodeType) {
        if (![nodeType isEqual:newType]) {
            [tagInterpreter removeTagsForType:nodeType withNode:theNewPoint];
            
        }
    }
    
    
    

    nodeType = newType;
    NSArray * oldTableSections = [tableSections copy];
    [self reloadTags];
    [self removeOptionalTags:oldTableSections];
    
    NSLog(@"catAndType: %@",newType.description);
    //NSLog(@"KV: %@",osmKeyValue);
    
    
    NSLog(@"ID: %d",theNewPoint.ident);
    NSLog(@"Version: %d",theNewPoint.version);
    NSLog(@"Lat: %f",theNewPoint.coordinate.latitude);
    NSLog(@"Lon: %f",theNewPoint.coordinate.longitude);
    NSLog(@"Tags: %@",theNewPoint.tags);
    
    [self.theNewPoint.tags addEntriesFromDictionary:newType.tags];
    
    //NSLog(@"id: %@ \n version: %@ \n lat: %f \n lon: %f \n newTags: %@ \n ",theNewPoint.ident,theNewPoint.version,theNewPoint.coordinate.latitude,theNewPoint.coordinate.longitude,theNewPoint.tags);
    NSLog(@"ID: %d",theNewPoint.ident);
    NSLog(@"Version: %d",theNewPoint.version);
    NSLog(@"Lat: %f",theNewPoint.coordinate.latitude);
    NSLog(@"Lon: %f",theNewPoint.coordinate.longitude);
    NSLog(@"Tags: %@",theNewPoint.tags);
    theNewPoint.image = [tagInterpreter getImageForNode:theNewPoint];
    
    //catAndType = [[NSArray alloc] initWithObjects: newCategory ,newType, nil];
    //[self.tableView reloadData];
    
    [nodeInfoTableView reloadData];
}



- (void)checkSaveButton
{
    //NSLog(@"cAndT count %d",[catAndType count]);
    if([theNewPoint isequaltToPoint:point] || !nodeType)
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
    point = theNewPoint;
    [self checkSaveButton];
    [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void) viewDidAppear:(BOOL)animated
{
    [nodeInfoTableView reloadData];
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
    NSString *myConsumerKey = osmConsumerKey     // pre-registered with service
    NSString *myConsumerSecret = osmConsumerSecret // pre-assigned by service
    
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
