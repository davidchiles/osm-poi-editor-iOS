    //
//  OPENodeViewController.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/8/12.
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

#import "OPENodeViewController.h"
#import "OPETextEdit.h"
#import "OPECategoryViewController.h"
#import "OPEOSMData.h"
#import "OPEInfoViewController.h"
#import "OPEBinaryCell.h"
#import "OPEConstants.h"
#import "OPEAPIConstants.h"
#import "OPESpecialCell2.h"
#import "OPEMRUtility.h"
#import "OPEManagedReferenceOptional.h"
#import "OPEManagedReferencePoi.h"
#import "OPEManagedReferenceOptional.h"
#import "OPEManagedOsmTag.h"
#import "OPEManagedReferenceOsmTag.h"
#import "OPEManagedOsmNode.h"
#import "OPETagEditViewController.h"
#import "OPEStrings.h"



@implementation OPENodeViewController

@synthesize nodeInfoTableView;
@synthesize deleteButton, saveButton;
@synthesize delegate;
@synthesize tableSections;
@synthesize managedOsmElement;
@synthesize newElement;
@synthesize optionalSectionsArray;


-(id)init
{
    self = [super init];
    if(self){
        self.title = INFO_TITLE_STRING;
    }
    return self;
}
- (id)initWithOsmElement:(OPEManagedOsmElement *)element delegate:(id<OPENodeViewDelegate>)newDelegate;
{
    self = [self init];
    if(self)
    {
        osmData = [[OPEOSMData alloc] init];
        self.delegate = newDelegate;
        
        self.managedOsmElement = element;
        
        //LOAD ALL DATA FROM DATABASE
        [osmData getTagsForElement:self.managedOsmElement];
        [osmData getTypeFor:self.managedOsmElement];
        [osmData getOptionalsFor:self.managedOsmElement.type];
        
        originalTags = [self.managedOsmElement.element.tags copy];
        originalTypeID = self.managedOsmElement.typeID;
        [self.osmData updateLegacyTags:managedOsmElement];
        
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: CANCEL_STRING style: UIBarButtonItemStyleBordered target: self action:@selector(cancelButtonPressed:)];
        
        [[self navigationItem] setLeftBarButtonItem: newBackButton];
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)cancelButtonPressed:(id)sender
{
    if (self.managedOsmElement.element.elementID < 0) {
        self.managedOsmElement = nil;
    }
    else
    {
        self.managedOsmElement.element.tags = [originalTags mutableCopy];
        self.managedOsmElement.typeID = originalTypeID;
        [osmData getTypeFor:managedOsmElement];
    }
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.saveButton = [[UIBarButtonItem alloc] initWithTitle: SAVE_STRING style: UIBarButtonItemStyleBordered target: self action: @selector(saveButtonPressed)];
    
    [[self navigationItem] setRightBarButtonItem:saveButton];
    
    nodeInfoTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [nodeInfoTableView setDataSource:self];
    [nodeInfoTableView setDelegate:self];
    nodeInfoTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    if (self.managedOsmElement.element.elementID > 0 && [managedOsmElement isKindOfClass:[OPEManagedOsmNode class]] && ![self.osmData hasParentElement:self.managedOsmElement]) {
        
        
        deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [deleteButton setTitle:DELETE_STRING forState:UIControlStateNormal];
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
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    self.HUD.delegate = self;
    
    
    [self reloadTags];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadComplete:) name:@"uploadComplete" object:nil];
    
    
    
}
-(void) reloadTags
{
    self.optionalSectionsArray = [self sortedOptionalDisplayNames];
    
    optionalTagWidth = [self getWidth];
    
}

-(float)getWidth;
{
    float maxWidth = 0.0;
    
    for(NSArray * optionalArray in self.optionalSectionsArray)
    {
        for(OPEManagedReferenceOptional * optional in optionalArray)
        {
            NSString * name = optional.displayName;
            float currentWidth = [name sizeWithFont:[UIFont boldSystemFontOfSize:12.0]].width;
            maxWidth = MAX(maxWidth, currentWidth);
        }
        
    }
    return maxWidth;
    
}

-(OPEManagedReferenceOptional *)optionalAtIndexPath:(NSIndexPath *)indexPath
{
    return self.optionalSectionsArray[indexPath.section-2][indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.managedOsmElement.type numberOfOptionalSections] + 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if(section == 0)
    {
       return 1;
    }
    else if(section == 1)
    {
        return 2;
    }
    else
    {
        return [[optionalSectionsArray objectAtIndex:(section - 2)] count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if(section == 0)
    {
        return NAME_STRING;
    }
    else if(section == 1)
    {
        return CATEGORY_STRING;
    }
    else
    {
        NSInteger index = section-2;
        OPEManagedReferenceOptional * tempOptional = [[self.optionalSectionsArray objectAtIndex:index] lastObject];
        return tempOptional.sectionName;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifierText = @"Cell_Section_1";
    NSString *CellIdentifierCategory = @"Cell_Section_2";
    NSString *CellIdentifierSpecialBinary = @"Cell_Section_5";
    NSString *CellIdentifierSpecial2 = @"Cell_Section_6";
    
    UITableViewCell *cell;
    
    
    ///ALWAYS NAME CELL
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierText];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierText];
        }
        
        cell.textLabel.text = [self.managedOsmElement valueForOsmKey:@"name"];
        cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    ///ALWAYS CATEGORY AND TYPE
    else if(indexPath.section == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierCategory];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifierCategory];
        }
        //cell.textLabel.text = [catAndTypeName objectAtIndex:indexPath.row];
        cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.row == 0) {
            cell.textLabel.text = CATEGORY_STRING;
            cell.detailTextLabel.text = self.managedOsmElement.type.categoryName;
        }
        else{
            cell.textLabel.text = TYPE_STRING;
            cell.detailTextLabel.text = self.managedOsmElement.type.name;
        }
        return cell;
    }
    //OPTIONAL TAGS
    else if(indexPath.section>1 && indexPath.section<[self.optionalSectionsArray count]+2)
    {
        OPEManagedReferenceOptional * managedOptionalTag = [[self.optionalSectionsArray objectAtIndex:(indexPath.section-2)]objectAtIndex:indexPath.row];
        
        NSString * valueForOptional = [self.managedOsmElement valueForOsmKey:managedOptionalTag.osmKey];
        NSString * displayValueForOptional = [managedOptionalTag displayNameForKey:managedOptionalTag.osmKey withValue:valueForOptional];
        
        //more than 3 tags just show value not switch or Address
        if ([managedOptionalTag.optionalTags count]>3 || ![managedOptionalTag.optionalTags count]) {
            OPESpecialCell2 * specialCell;
            specialCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSpecial2];
            if (specialCell == nil) {
                specialCell = [[OPESpecialCell2 alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifierSpecial2 withTextWidth:optionalTagWidth];
            }
            specialCell.leftText = managedOptionalTag.displayName;
            specialCell.rightText = displayValueForOptional;
            return specialCell;
        }
        //Show switch
        else if([managedOptionalTag.optionalTags count] > 0)
        {
            OPEBinaryCell * aCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSpecialBinary];
            if (aCell == nil) {
                aCell = [[OPEBinaryCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifierSpecialBinary array:[managedOptionalTag.optionalTags allObjects] withTextWidth:optionalTagWidth];
                
            }
            [aCell setLeftText: managedOptionalTag.displayName];
            [aCell setupBinaryControl:[managedOptionalTag.optionalTags allObjects]];
            //aCell.controlArray = [[cellDictionary objectForKey:@"values"] allKeys];
            
            [aCell.binaryControl addTarget:self action:@selector(binaryChanged:) forControlEvents:UIControlEventValueChanged];
            aCell.tag = indexPath.section-2;
            aCell.binaryControl.tag = indexPath.row;
            if (![valueForOptional isEqualToString:displayValueForOptional] && [valueForOptional length]) {
                [aCell selectSegmentWithTitle:displayValueForOptional];
            }
            else {
                aCell.binaryControl.selectedSegmentIndex = UISegmentedControlNoSegment;
            }
            return aCell;

        }
    }

    return cell;
}

-(void)binaryChanged:(UISegmentedControl *)sender
{
    if (sender) {
        
        NSInteger section = [[sender superview] tag];
        NSInteger row = sender.tag;
        
        OPEManagedReferenceOptional * referenceOptional = [[self.optionalSectionsArray objectAtIndex:section] objectAtIndex:row];
        NSString * title = [sender titleForSegmentAtIndex:[sender selectedSegmentIndex]];
        OPEManagedReferenceOsmTag * managedReferenceOsmTag = [referenceOptional managedReferenceOsmTagWithName:title];
        
        [self newOsmKey:managedReferenceOsmTag.key value:managedReferenceOsmTag.value];
        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[tableView cellForRowAtIndexPath: indexPath] isKindOfClass:[OPEBinaryCell class]]) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    if (indexPath.section == 0) {
        OPETagEditViewController * viewController = nil;
        viewController = [OPETagEditViewController viewControllerWithOsmKey:@"name" andType:nil delegate:self];
        viewController.title = NAME_STRING;
        viewController.currentOsmValue = [self.managedOsmElement valueForOsmKey:@"name"];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else if(indexPath.section ==1)
    {
        if(indexPath.row == 0 || !self.managedOsmElement.type)
        {
            OPECategoryViewController * viewer = [[OPECategoryViewController alloc] init];
            viewer.title = @"Category";
            [viewer setDelegate:self];
            
            [self.navigationController pushViewController:viewer animated:YES];
            
        }
        else{
            OPETypeViewController * viewer = [[OPETypeViewController alloc] initWithCategory:self.managedOsmElement.type.categoryName];
            [viewer setDelegate:self];
            [self.navigationController pushViewController:viewer animated:YES];
        }
        
    }
    else{
        OPEManagedReferenceOptional * managedOptionalTag = [[self.optionalSectionsArray objectAtIndex:(indexPath.section-2)]objectAtIndex:indexPath.row];
        
        OPETagEditViewController * viewController = nil;
        viewController = [OPETagEditViewController viewControllerWithOsmKey:managedOptionalTag.osmKey andType:managedOptionalTag.type delegate:self];
        viewController.title = managedOptionalTag.displayName;
        viewController.managedOptional = managedOptionalTag;
        viewController.element = self.managedOsmElement;
        viewController.currentOsmValue = [self.managedOsmElement valueForOsmKey:managedOptionalTag.osmKey];
        [self.navigationController pushViewController:viewController animated:YES];
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return NO;
    }
    return YES;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return REMOVE_STRING;
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        OPEManagedReferenceOptional * optional = [self optionalAtIndexPath:indexPath];
        NSString * osmKey = optional.osmKey;
        [osmData removeOsmKey:osmKey forElement:self.managedOsmElement];
        [nodeInfoTableView reloadData];
        [self checkSaveButton];
    }
    
}

- (void) saveButtonPressed
{
    self.managedOsmElement.action = kActionTypeModify;
    [osmData saveDate:[NSDate date] forType:self.managedOsmElement.type];
    
    if (![self.osmData canAuth])
    {
        [self showAuthError];
    }
    else if ([self tagsHaveChanged])
    {
        [self startSave];
        dispatch_queue_t q = dispatch_queue_create("queue", NULL);
        dispatch_async(q, ^{
            NSLog(@"saveBottonPressed");
            
            [self.osmData uploadElement:self.managedOsmElement];
            
        });
        //[self didCloseChangeset:1];
        //dispatch_release(q);

        
    }
    else {
        NSLog(@"NO CHANGES TO UPLOAD");
    }
}

- (void) deleteButtonPressed
{
    if (![self.osmData canAuth])
    {
        [self showAuthError];
    }
    else {
        NSLog(@"Delete Button Pressed");
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:DELETE_ALERT_TITLE_STRING
                                                          message:DELETE_ALERT_STRING
                                                         delegate:self
                                                cancelButtonTitle:CANCEL_STRING
                                                otherButtonTitles:DELETE_STRING,nil];
        message.tag = 1;
        
        [message show];
    }
   
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    NSLog(@"AlertView Tag %d",alertView.tag);
    if (alertView.tag == 1) {
        if(buttonIndex != alertView.cancelButtonIndex)
        {
            self.managedOsmElement.action = kActionTypeDelete;
            
            NSLog(@"Button YES was selected.");
            
            
            [self.navigationController.view addSubview:self.HUD];
            [self.HUD setLabelText:[NSString stringWithFormat:@"%@ ...",DELETING_STRING]];
            [self.HUD show:YES];
            
            if ([self.managedOsmElement isKindOfClass:[OPEManagedOsmNode class]]) {
                dispatch_queue_t q = dispatch_queue_create("queue", NULL);
                dispatch_async(q, ^{
                    
                    
                    [self.osmData deleteElement:self.managedOsmElement];
                });
                //dispatch_release(q);
            }
        }
        else
        {
            NSLog(@"Button Cancel was selected.");
        }
    }
    
   
    
}

- (void) newOsmKey:(NSString *)key value:(NSString *)value
{
    [osmData setOsmKey:key andValue:value forElement:self.managedOsmElement];
    [self checkSaveButton];
    [nodeInfoTableView reloadData];
}

-(void)newType:(OPEManagedReferencePoi *)newType;
{
    [osmData setNewType:newType forElement:self.managedOsmElement];
    [osmData getOptionalsFor:self.managedOsmElement.type];
    [self reloadTags];
    [nodeInfoTableView reloadData];
}

-(BOOL)tagsHaveChanged
{
    return ![originalTags isEqualToDictionary:self.managedOsmElement.element.tags];
}


- (void)checkSaveButton
{
    //NSLog(@"cAndT count %d",[catAndType count]);
    if (([self tagsHaveChanged] && managedOsmElement.type) || managedOsmElement.elementID < 0) {
        self.saveButton.enabled = YES;
    }
    else
    {
        self.saveButton.enabled= NO;
    }

}

-(NSArray *)sortedOptionalDisplayNames
{
    NSMutableArray * displayNameArray = [NSMutableArray array];
    NSArray * tempArray = [[self.managedOsmElement.type.optionalsSet valueForKeyPath:@"@distinctUnionOfObjects.sectionName"] allObjects];
    
    __block NSDictionary * sortDictioanry = [osmData optionalSectionSortOrder];
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
        return [[sortDictioanry objectForKey:obj1] compare:[sortDictioanry objectForKey:obj2]];
    }];
    NSArray * uniqueSections = [tempArray sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"sectionSortOrder"  ascending:YES];
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
    
    
    for(NSString * sectionName in uniqueSections)
    {
        //NSString * sectionName = managedOptionalCategory.displayName;
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sectionName == %@", sectionName];
        NSArray * names = [[[self.managedOsmElement.type.optionalsSet filteredSetUsingPredicate:predicate] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nameDescriptor, nil]];
        [displayNameArray addObject:names];
    }
    
    return displayNameArray;
}

- (void) viewDidAppear:(BOOL)animated
{
    [nodeInfoTableView reloadData];
    [self checkSaveButton];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma OPEOsmDataDelegate

-(void)didCloseChangeset:(int64_t)changesetNumber
{
    [delegate updateAnnotationForOsmElement:self.managedOsmElement];
    [super didCloseChangeset:changesetNumber];
    [self checkSaveButton];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissViewController) userInfo:nil repeats:nil];
    //[self.navigationController dismissModalViewControllerAnimated: YES];
    
}
-(void)uploadFailed:(NSError *)error
{
    [super uploadFailed:error];
    [self checkSaveButton];
    
}

-(void)dismissViewController
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
