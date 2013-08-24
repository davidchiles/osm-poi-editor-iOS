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
#import "BButton.h"
#import "OPEOSMSearchManager.h"
#import "OPEMoveNodeViewController.h"
#import "OPEButtonCell.h"



@implementation OPENodeViewController

@synthesize nodeInfoTableView;
@synthesize deleteButton = _deleteButton, saveButton, moveButton = _moveButton;
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
        showDeleteButton = NO;
        showMoveButton = NO;
    }
    return self;
}
- (id)initWithOsmElement:(OPEManagedOsmElement *)element delegate:(id<OPENodeViewDelegate>)newDelegate;
{
    self = [self init];
    if(self)
    {
        self.delegate = newDelegate;
        
        self.managedOsmElement = element;
        
        //LOAD ALL DATA FROM DATABASE
        [self.osmData getTagsForElement:self.managedOsmElement];
        [self.osmData getTypeFor:self.managedOsmElement];
        originalTypeID = self.managedOsmElement.typeID;
        
        originalTags = [self.managedOsmElement.element.tags copy];
        if ([self.managedOsmElement isKindOfClass:[OPEManagedOsmNode class]]) {
            originalLocation = ((OPEManagedOsmNode *)self.managedOsmElement).element.coordinate;
        }
        [self.osmData updateLegacyTags:managedOsmElement];
        
        [self.osmData getOptionalsFor:self.managedOsmElement.type];
        
        
        //self.apiManager.delegate = self;
        
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
        if ([self.managedOsmElement isKindOfClass:[OPEManagedOsmNode class]]) {
            ((OPEManagedOsmNode *)self.managedOsmElement).element.coordinate = originalLocation;
        }
        self.managedOsmElement.typeID = originalTypeID;
        [self.osmData getTypeFor:managedOsmElement];
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
    
    
    if ([managedOsmElement isKindOfClass:[OPEManagedOsmNode class]] && ![self.osmData hasParentElement:self.managedOsmElement]) {
        if (self.managedOsmElement.element.elementID > 0) {
            /*
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
            */
            showDeleteButton = YES;
        }
        showMoveButton = YES;
        
        //self.nodeInfoTableView.tableFooterView.frame = CGRectMake(0, 0, 300, 50);
        //[nodeInfoTableView setContentOffset:CGPointMake(0, nodeInfoTableView.contentSize.height-50) animated:YES];
    }
    
    
    

    [self checkSaveButton];
    
    [self.view addSubview:nodeInfoTableView];
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.HUD.delegate = self;
    
    
    [self reloadTags];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadComplete:) name:@"uploadComplete" object:nil];
    
    
    
}

-(UIButton *)deleteButton
{
    if(!_deleteButton)
    {
        BButton * button = [[BButton alloc] initWithFrame:CGRectZero type:BButtonTypeDanger];
        [button setTitle:DELETE_STRING forState:UIControlStateNormal];
        [button addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _deleteButton = button;
    }
    return _deleteButton;
}
-(UIButton *)moveButton
{
    if(!_moveButton)
    {
        BButton * button = [[BButton alloc] initWithFrame:CGRectZero type:BButtonTypePrimary];
        [button setTitle:MOVE_NODE_STRING forState:UIControlStateNormal];
        [button addTarget:self action:@selector(moveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _moveButton = button;
    }
    return _moveButton;
}
-(void) reloadTags
{
    self.optionalSectionsArray = [self sortedOptionalDisplayNames];
    
    optionalTagWidth = [self getWidth];
    
}

-(float)getWidth;
{
    CGFloat maxWidth = 0.0;
    
    for(NSArray * optionalArray in self.optionalSectionsArray)
    {
        for(OPEManagedReferenceOptional * optional in optionalArray)
        {
            NSString * name = optional.displayName;
            //float currentWidth = [name sizeWithFont:[UIFont systemFontSize:[UIFont systemFontSize]]].width;
            UIFont * font =[UIFont systemFontOfSize:[UIFont systemFontSize]];
            CGFloat currentWidth = [name sizeWithAttributes:@{NSFontAttributeName:font}].width;
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
    return [self.managedOsmElement.type numberOfOptionalSections] + 2 + [[NSNumber numberWithBool:showDeleteButton] intValue] + [[NSNumber numberWithBool:showMoveButton] intValue];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if (section == 0) {
        return 1;
    }
    else if(section == 1)
    {
        return 2;
    }
    else if(section > 1 && section < [self.managedOsmElement.type numberOfOptionalSections] + 2)
    {
        return [[optionalSectionsArray objectAtIndex:(section - 2)] count];
    }
    return 0;
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
    else if(section < [self.managedOsmElement.type numberOfOptionalSections] + 2)
    {
        NSInteger index = section-2;
        OPEManagedReferenceOptional * tempOptional = [[self.optionalSectionsArray objectAtIndex:index] lastObject];
        return tempOptional.sectionName;
    }
    
    return @"";
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section < [self.managedOsmElement.type numberOfOptionalSections] + 2 && section > 1)
    {
        NSInteger index = section-2;
        OPEManagedReferenceOptional * tempOptional = [[self.optionalSectionsArray objectAtIndex:index] lastObject];
        if ([tempOptional.sectionName isEqualToString:@"Address"]) {
            return 45;
        }
    }
    else if (section > [self.managedOsmElement.type numberOfOptionalSections])
    {
        return 45;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * footerView = nil;
    CGSize cellSize = CGSizeMake(tableView.frame.size.width, 40);
    if(section < [self.managedOsmElement.type numberOfOptionalSections] + 2 && section > 1)
    {
        NSInteger index = section-2;
        OPEManagedReferenceOptional * tempOptional = [[self.optionalSectionsArray objectAtIndex:index] lastObject];
        if ([tempOptional.sectionName isEqualToString:@"Address"]) {
            CGFloat buttonWidth = 150;
            
            BButton * lookupButton = [[BButton alloc] initWithFrame:CGRectZero type:BButtonTypePrimary];
            lookupButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            [lookupButton setTitle:@"Nominatim" forState:UIControlStateNormal];
            [lookupButton addTarget:self action:@selector(nominatimLookupAddress) forControlEvents:UIControlEventTouchUpInside];
            
            
            BButton * localLookupButton = [[BButton alloc]initWithFrame:CGRectZero type:BButtonTypePrimary];
            localLookupButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            [localLookupButton setTitle:LOCA_DATA_STRING forState:UIControlStateNormal];
            [localLookupButton addTarget:self action:@selector(localLookupAddress) forControlEvents:UIControlEventTouchUpInside];
            
            localLookupButton.frame = CGRectMake(5, 5, buttonWidth, cellSize.height);
            lookupButton.frame = CGRectMake(cellSize.width-buttonWidth-5, 5, buttonWidth, cellSize.height);
            localLookupButton.autoresizingMask  = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin  ;
            lookupButton.autoresizingMask =UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin ;
            
            footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cellSize.width, cellSize.height)];
            [footerView addSubview:lookupButton];
            [footerView addSubview:localLookupButton];
        }
    }
    else if (section >= [self.managedOsmElement.type numberOfOptionalSections]+2) {
        footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cellSize.width, cellSize.height)];
        CGRect buttonRect = CGRectMake(0, 0, cellSize.width-10, cellSize.height);
        if (section == [tableView numberOfSections]-1 && showDeleteButton)
        {
            self.deleteButton.frame = buttonRect;
            [footerView addSubview:self.deleteButton];

        }
        else if (showMoveButton)
        {
            self.moveButton.frame = buttonRect;
            [footerView addSubview:self.moveButton];
        }

    }
    return footerView;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifierText = @"CellIdentifierText";
    NSString *CellIdentifierCategory = @"CellIdentifierCategory";
    NSString *CellIdentifierSpecialBinary = @"CellIdentifierSpecialBinary";
    NSString *CellIdentifierSpecial2 = @"CellIdentifierSpecial2";
    NSString *cellIdentifierAddressButton = @"cellIdentifierAddressButton";
    NSString *cellIdentifierButton = @"cellIdentifierButton";
    
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
    else if(indexPath.section < [self.managedOsmElement.type numberOfOptionalSections] + 2)
    {
        if([[self.optionalSectionsArray objectAtIndex:(indexPath.section-2) ] count] > indexPath.row)
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
                    aCell = [[OPEBinaryCell alloc] initWithArray:[managedOptionalTag.optionalTags allObjects] reuseIdentifier:CellIdentifierSpecialBinary withTextWidth:optionalTagWidth];
                }
                aCell.leftLabel.text = managedOptionalTag.displayName;
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

-(void)moveButtonPressed:(id)sender
{
    OPEMoveNodeViewController * moveNodeViewController = [[OPEMoveNodeViewController alloc] initWithNode:(OPEManagedOsmNode *)self.managedOsmElement];
    
    [self.navigationController pushViewController:moveNodeViewController animated:YES];
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

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}
- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.section == 0) {
            [self.osmData removeOsmKey:@"name" forElement:self.managedOsmElement];
        }
        else{
            OPEManagedReferenceOptional * optional = [self optionalAtIndexPath:indexPath];
            NSString * osmKey = optional.osmKey;
            [self.osmData removeOsmKey:osmKey forElement:self.managedOsmElement];
        }
        
        
        [nodeInfoTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self checkSaveButton];
    }
    
}

-(void)nominatimLookupAddress
{
    [self lookupAddress:NO];
}
-(void)localLookupAddress
{
    [self lookupAddress:YES];
}

-(void)lookupAddress:(BOOL)local
{
    void (^saveDict)(NSDictionary *) = ^(NSDictionary * addressDictionary) {
        [self.osmData setOsmKey:@"addr:city" andValue:[addressDictionary objectForKey:@"city"] forElement:self.managedOsmElement];
        //[self.osmData setOsmKey:@"addr:postcode" andValue:[addressDictionary objectForKey:@"postcode"] forElement:self.managedOsmElement];
        [self.osmData setOsmKey:@"addr:street" andValue:[addressDictionary objectForKey:@"road"] forElement:self.managedOsmElement];
        
        [nodeInfoTableView reloadData];
    };
    CLLocationCoordinate2D center = [self.osmData centerForElement:self.managedOsmElement];
    if (local) {
        NSDictionary * dict = [[[OPEOSMSearchManager alloc] init] localReverseGeocode:center];
        saveDict(dict);
        
    }
    else{
        [self.apiManager reverseLookupAddress:center success:saveDict failure:^(NSError *error) {
             NSLog(@"error");
        }];
    }
}

- (void) saveButtonPressed
{
    self.managedOsmElement.action = kActionTypeModify;
    [self.osmData saveDate:[NSDate date] forType:self.managedOsmElement.type];
    
    if (![self.apiManager canAuth])
    {
        [self showAuthError];
    }
    else if ([self elementModified] || (self.managedOsmElement.elementID < 0 && [self.managedOsmElement.element.tags count]))
    {
        [self startSave];
        
        [self.apiManager uploadElement:self.managedOsmElement withChangesetComment:[self.osmData changesetCommentfor:self.managedOsmElement] openedChangeset:^(int64_t changesetID) {
            [self didOpenChangeset:changesetID withMessage:nil];
        } updatedElements:^(NSArray *updatedElements) {
            [self.osmData updateElements:updatedElements];
            [delegate updateAnnotationForOsmElements:updatedElements];
        } closedChangeSet:^(int64_t changesetID) {
            
            [super didCloseChangeset:changesetID ];
            [self checkSaveButton];
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissViewController) userInfo:nil repeats:nil];
        } failure:^(NSError *error) {
            [super uploadFailed:error];
            [self checkSaveButton];
        }];
        /*
        dispatch_queue_t q = dispatch_queue_create("queue", NULL);
        dispatch_async(q, ^{
            NSLog(@"saveBottonPressed");
            
            [self.osmData uploadElement:self.managedOsmElement];
            
        });
        //[self didCloseChangeset:1];
        //dispatch_release(q);
         */
        
    }
    else {
        NSLog(@"NO CHANGES TO UPLOAD");
    }
}

- (void) deleteButtonPressed:(id)sender
{
    if (![self.apiManager canAuth])
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
            
            [self.apiManager uploadElement:self.managedOsmElement withChangesetComment:[self.osmData changesetCommentfor:self.managedOsmElement] openedChangeset:^(int64_t changesetID) {
                [self didOpenChangeset:changesetID withMessage:nil];
            } updatedElements:^(NSArray *updatedElements) {
                [self.osmData updateElements:updatedElements];
                [delegate updateAnnotationForOsmElements:updatedElements];
            } closedChangeSet:^(int64_t changesetID) {
                [super didCloseChangeset:changesetID ];
                [self checkSaveButton];
                [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissViewController) userInfo:nil repeats:nil];
            } failure:^(NSError *error) {
                [super uploadFailed:error];
                [self checkSaveButton];
            }];
            
            /*
            if ([self.managedOsmElement isKindOfClass:[OPEManagedOsmNode class]]) {
                dispatch_queue_t q = dispatch_queue_create("queue", NULL);
                dispatch_async(q, ^{
                    
                    
                    [self.osmData deleteElement:self.managedOsmElement];
                });
                //dispatch_release(q);
            }
             */
        }
        else
        {
            NSLog(@"Button Cancel was selected.");
        }
    }
    
   
    
}

- (void) newOsmKey:(NSString *)key value:(NSString *)value
{
    [self.osmData setOsmKey:key andValue:value forElement:self.managedOsmElement];
    [self checkSaveButton];
    [nodeInfoTableView reloadData];
}

-(void)newType:(OPEManagedReferencePoi *)newType;
{
    [self.osmData setNewType:newType forElement:self.managedOsmElement];
    [self.osmData getOptionalsFor:self.managedOsmElement.type];
    [self reloadTags];
    [nodeInfoTableView reloadData];
}

-(BOOL)tagsHaveChanged
{
    return ![originalTags isEqualToDictionary:self.managedOsmElement.element.tags];
}
-(BOOL)locationChanged
{
    if ([self.managedOsmElement isKindOfClass:[OPEManagedOsmNode class]]) {
        CLLocationCoordinate2D currentCoordinate = ((OPEManagedOsmNode *)self.managedOsmElement).element.coordinate;
        if (currentCoordinate.latitude != originalLocation.latitude || currentCoordinate.longitude != originalLocation.longitude) {
            return YES;
        }
    }
    return NO;
}
-(BOOL)elementModified
{
    if ([self tagsHaveChanged] || [self locationChanged]) {
        return YES;
    }
    return NO;
}


- (void)checkSaveButton
{
    //NSLog(@"cAndT count %d",[catAndType count]);
    if (([self elementModified] && managedOsmElement.type) || managedOsmElement.elementID < 0) {
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
    
    __block NSDictionary * sortDictioanry = [self.osmData optionalSectionSortOrder];
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

#pragma OPEosmDataDelegate

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
