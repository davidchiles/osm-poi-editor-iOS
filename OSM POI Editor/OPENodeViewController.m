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
#import "OPETagInterpreter.h"
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
#import "OPEManagedReferenceOptionalCategory.h"
#import "OPEManagedReferencePoiCategory.h"
#import "OPEManagedReferenceOsmTag.h"
#import "OPEManagedOsmNode.h"



@implementation OPENodeViewController

@synthesize nodeInfoTableView;
@synthesize deleteButton, saveButton;
@synthesize delegate;
@synthesize HUD;
@synthesize tableSections;
@synthesize managedOsmElement;
@synthesize newElement;
@synthesize optionalSectionsArray;


-(id)init
{
    self = [super init];
    if(self){
        self.title = @"Info";
    }
    return self;
}
- (id)initWithOsmElementObjectID:(NSManagedObjectID *)objectID delegate:(id<OPENodeViewDelegate>)newDelegate
{
    self = [self init];
    if(self)
    {
        self.delegate = newDelegate;
        editContext = [NSManagedObjectContext MR_context];
        osmData = [[OPEOSMData alloc] init];
        osmData.delegate = self;
        if (objectID) {
            
            NSError * error = nil;
            self.managedOsmElement = (OPEManagedOsmElement *)[editContext existingObjectWithID:objectID error:&error];
            if (error) {
                NSLog(@"Getting Element Error: %@",error);
            }
        }
        
        originalTags = [self.managedOsmElement.tags copy];
        
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Cancel" style: UIBarButtonItemStyleBordered target: self action:@selector(cancelButtonPressed:)];
        
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
    if (self.managedOsmElement.osmIDValue < 0) {
        [self.managedOsmElement MR_deleteInContext:editContext];
    }
    else
    {
        [editContext rollback];
    }
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [editContext MR_saveToPersistentStoreAndWait];
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
    
    
    if (self.managedOsmElement.osmIDValue > 0 && [managedOsmElement isKindOfClass:[OPEManagedOsmNode class]]) {
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
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    self.HUD.delegate = self;
    
    
    [self reloadTags];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadComplete:) name:@"uploadComplete" object:nil];
    
    
    
}
-(void) reloadTags
{
    self.optionalSectionsArray = [self.managedOsmElement.type optionalDisplayNames];
    
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
        return @"Name";
    }
    else if(section == 1)
    {
        return @"Category";
    }
    else
    {
        NSInteger index = section-2;
        OPEManagedReferenceOptional * tempOptional = [[self.optionalSectionsArray objectAtIndex:index] lastObject];
        return tempOptional.referenceSection.displayName;
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
            cell.textLabel.text = @"Category";
            cell.detailTextLabel.text = self.managedOsmElement.type.category.name;
        }
        else{
            cell.textLabel.text = @"Type";
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
        if ([managedOptionalTag.tags count]>3 || ![managedOptionalTag.tags count]) {
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
        else if([managedOptionalTag.tags count] > 0)
        {
            OPEBinaryCell * aCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSpecialBinary];
            if (aCell == nil) {
                aCell = [[OPEBinaryCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifierSpecialBinary array:[managedOptionalTag allDisplayNames] withTextWidth:optionalTagWidth];
                
            }
            [aCell setLeftText: managedOptionalTag.displayName];
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
        
        [self newTag:managedReferenceOsmTag.tag.objectID];
        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Name Selected
    if(indexPath.section == 0)
    {
        OPETextEdit * textEdit = [[OPETextEdit alloc] init];
        textEdit.osmKey = @"name";
        textEdit.osmValue = [self.managedOsmElement valueForOsmKey:@"name"];
        textEdit.type = kTypeText;
        textEdit.delegate = self;
        
        [self.navigationController pushViewController:textEdit animated:YES];
        
    }
    else if(indexPath.section ==1)
    {
        if(indexPath.row == 1)
        {
            if (self.managedOsmElement.type)
            {
                OPETypeViewController * viewer = [[OPETypeViewController alloc] initWithNibName:@"OPETypeViewController" bundle:[NSBundle mainBundle]];
                viewer.title = @"Type";
                
                //viewer.category = editableType.category;
                viewer.categoryManagedObjectID = [self.managedOsmElement.type.category objectID];
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
    else if(indexPath.section>1 && indexPath.section<[self.optionalSectionsArray count]+2)
    {
        OPEManagedReferenceOptional * managedOptionalTag = [[self.optionalSectionsArray objectAtIndex:(indexPath.section-2)]objectAtIndex:indexPath.row];
        if ([managedOptionalTag.type isEqualToString:kTypeList] && [managedOptionalTag.tags count] > 3)
        {
            OPETagValueList * viewer = [[OPETagValueList alloc] initWithNibName:@"OPETagValueList" bundle:nil];
            viewer.title = managedOptionalTag.displayName;
            viewer.referenceOptionalID = managedOptionalTag.objectID;
            [viewer setDelegate:self];
            [self.navigationController pushViewController:viewer animated:YES];
        }
        else if(![managedOptionalTag.type isEqualToString:kTypeList]) { //Text editing
            OPETextEdit * viewer = [[OPETextEdit alloc] init];
            viewer.title = managedOptionalTag.displayName;
            viewer.osmValue = [self.managedOsmElement valueForOsmKey:managedOptionalTag.osmKey];
            viewer.osmKey = managedOptionalTag.osmKey;
            viewer.type = managedOptionalTag.type;
            [viewer setDelegate:self];
            [self.navigationController pushViewController:viewer animated:YES];
        }
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
    return @"Remove";
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        OPEManagedReferenceOptional * optional = [self optionalAtIndexPath:indexPath];
        NSString * osmKey = optional.osmKey;
        [self.managedOsmElement removeTagWithOsmKey:osmKey];
        [nodeInfoTableView reloadData];
        [self checkSaveButton];
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
    self.managedOsmElement.action = kActionTypeModify;
    [editContext MR_saveToPersistentStoreAndWait];
    
    if (![osmData canAuth])
    {
        [self showOauthError];
    }
    else if ([self tagsHaveChanged])
    {
        [self.navigationController.view addSubview:HUD];
        [HUD setLabelText:@"Saving..."];
        [HUD show:YES];
        dispatch_queue_t q = dispatch_queue_create("queue", NULL);
        dispatch_async(q, ^{
            NSLog(@"saveBottoPressed");
            
            NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
            OPEManagedOsmElement * element = (OPEManagedOsmElement *)[context existingObjectWithID:self.managedOsmElement.objectID error:nil];
            
            [osmData uploadElement:element];
            
        });
        
        //dispatch_release(q);

        
    }
    else {
        NSLog(@"NO CHANGES TO UPLOAD");
    }
}

- (void) deleteButtonPressed
{
    if (![osmData canAuth])
    {
        [self showOauthError];
    }
    else {
        NSLog(@"Delete Button Pressed");
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Delete Point of Interest"
                                                          message:@"Are you Sure you want to delete this node?"
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Delete",nil];
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
        if(buttonIndex != alertView.cancelButtonIndex)
        {
            [editContext rollback];
            self.managedOsmElement.action = kActionTypeDelete;
            [editContext MR_saveToPersistentStoreAndWait];
            
            NSLog(@"Button YES was selected.");
            
            [self.navigationController.view addSubview:HUD];
            [HUD setLabelText:@"Deleting..."];
            [HUD show:YES];
            
            if ([self.managedOsmElement isKindOfClass:[OPEManagedOsmNode class]]) {
                dispatch_queue_t q = dispatch_queue_create("queue", NULL);
                dispatch_async(q, ^{
                    
                    NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
                    OPEManagedOsmElement * osmElement = (OPEManagedOsmElement *)[context existingObjectWithID:self.managedOsmElement.objectID error:nil];
                    
                    
                    [osmData deleteElement:osmElement];
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

- (void) newTag:(NSManagedObjectID *)managedOsmTagID
{
    OPEManagedOsmTag * managedOsmTag = (OPEManagedOsmTag *)[editContext existingObjectWithID:managedOsmTagID error:nil];
    
    [self.managedOsmElement removeTagWithOsmKey:managedOsmTag.key];
    [self.managedOsmElement addTagsObject:managedOsmTag];
    [self checkSaveButton];
    [nodeInfoTableView reloadData];
}

-(void)newType:(OPEManagedReferencePoi *)newType;
{
    [self.managedOsmElement newType:newType];
}

-(void)setNewType:(NSManagedObjectID *)managedReferencePoiID
{
    //[self newType:(OPEManagedReferencePoi *)[OPEMRUtility managedObjectWithID:managedReferencePoiID]];
    [self newType:(OPEManagedReferencePoi *)[editContext existingObjectWithID:managedReferencePoiID error:nil]];
    
    [self reloadTags];
    [nodeInfoTableView reloadData];
    [self checkSaveButton];
}

-(BOOL)tagsHaveChanged
{
    return ![originalTags isEqualToSet:self.managedOsmElement.tags];
}


- (void)checkSaveButton
{
    //NSLog(@"cAndT count %d",[catAndType count]);
    if ([self tagsHaveChanged] && managedOsmElement.type) {
        self.saveButton.enabled = YES;
    }
    else
    {
        self.saveButton.enabled= NO;
    }

}
-(void) uploadComplete:(NSNotification *)notification
{
    NSLog(@"got notification");
    
    
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
    NSString *myConsumerKey = osmConsumerKey;     // pre-registered with service
    NSString *myConsumerSecret = osmConsumerSecret; // pre-assigned by service
    
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

#pragma OPEOsmDataDelegate

-(void)didOpenChangeset:(int64_t)changesetNumber withMessage:(NSString *)message
{
    self.HUD.labelText = @"Uploading...";
    
}
-(void)didCloseChangeset:(int64_t)changesetNumber
{
    self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    self.HUD.labelText = @"Complete";
    [self.delegate removeAnnotationWithOsmElementID:self.managedOsmElement.objectID];
    [self.HUD hide:YES afterDelay:3.0];
    [self checkSaveButton];
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(dismissViewController) userInfo:nil repeats:nil];
    //[self.navigationController dismissModalViewControllerAnimated: YES];
    
}
-(void)uploadFailed:(NSError *)error
{
    self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    self.HUD.labelText =@"Error";
    [self.HUD hide:YES afterDelay:2.0];
    [self checkSaveButton];
    
}

-(void)dismissViewController
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
