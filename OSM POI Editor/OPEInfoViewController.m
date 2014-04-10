//
//  OPEInfoViewController.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/15/12.
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

#import "OPEInfoViewController.h"
#import "OPEAPIConstants.h"
#import "UVConfig.h"
#import "UserVoice.h"
#import "OPEUtility.h"
#import "OPEConstants.h"
#import "OPEStrings.h"

#import "OPELog.h"
#import "AFOAuth1Client.h"


@implementation OPEInfoViewController

@synthesize delegate;
@synthesize currentNumber;
@synthesize settingsTableView;
@synthesize attributionString;
@synthesize showNoNameStreetsSwitch;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    apiManager = [[OPEOSMAPIManager alloc] init];
    
    settingsTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [settingsTableView setDataSource:self];
    [settingsTableView setDelegate:self];
    settingsTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    if ([OPEUtility currentValueForSettingKey:kTileSourceNumber]) {
        currentNumber = [[OPEUtility currentValueForSettingKey:kTileSourceNumber] intValue];
    }
    else {
        currentNumber = 0;
    }
    
    [self.view addSubview:settingsTableView];
    
    showNoNameStreetsSwitch = [[UISwitch alloc] init];
    [showNoNameStreetsSwitch addTarget:self action:@selector(toggleSwitch:) forControlEvents:UIControlEventValueChanged];
    showNoNameStreetsSwitch.on = [[OPEUtility currentValueForSettingKey:kShowNoNameStreetsKey] boolValue];
    
}

- (void) signOutOfOSM
{
    [AFOAuth1Token deleteCredentialWithIdentifier:kOPEUserOAuthTokenKey];
    [settingsTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}
-(void)findishedAuthWithError:(NSError *)error
{
    [settingsTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma - TableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    }
    else if (section == 3)
    {
        return 2;
    }
    else {
        return 1;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return TILE_SOURCE_STRING;
    }
    else {
        return @"";
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(section == 0 && self.attributionString)
    {
        return self.attributionString;
    }
    return @"";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    static NSString * tileIdentifier = @"Cell";
    static NSString * buttonIdentifier = @"Cell1";
    static NSString * aboutIdentifier = @"Cell2";
    if (indexPath.section == 0) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:tileIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tileIdentifier];
        }
        
        if (indexPath.row == 0){
            cell.textLabel.text = BING_AERIAL_STRING;
        }
        else if (indexPath.row == 1){
            cell.textLabel.text = MAPQUEST_AERIAL_STRING;
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = OSM_DEFAULT_STRING;
        }
        
        if (indexPath.row == currentNumber) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    
    }
    else if (indexPath.section == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:buttonIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:buttonIdentifier];
        }
        
        if(!apiManager.oAuthToken)
        {
            cell.textLabel.text = LOGIN_STRING;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else
            cell.textLabel.text = LOGOUT_STRING;
        
    }
    else if (indexPath.section == 2)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:aboutIdentifier];

        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:aboutIdentifier];
        }
        if (indexPath.row == 0) {
            cell.textLabel.text = FEEDBACK_STRING;
        }
        else
        {
            cell.textLabel.text = ABOUT_STRING;
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentNumber inSection:0]]; //Switch check marks
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        currentNumber = indexPath.row;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        [OPEUtility setSettingsValue:[NSNumber numberWithUnsignedInteger:indexPath.row] forKey:kTileSourceNumber];
        id <RMTileSource> newTileSource = [OPEUtility currentTileSource];
        
        [delegate setTileSource:newTileSource];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (indexPath.section == 1)
    {
        if(!apiManager.oAuthToken)
        {
            [self signIntoOSM];
        }
        else
            [self signOutOfOSM];
        
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            //USer voice Feedback
#ifdef USERVOICE_ENABLED
            UVConfig *config = [UVConfig configWithSite:USERVOICE_SITE
                                                 andKey:USERVOICE_KEY
                                              andSecret:USERVOICE_SECRET];
            [UserVoice presentUserVoiceInterfaceForParentViewController:self andConfig:config];
#endif
        }
        else
        {
            [self infoButtonPressed:nil];
        }
        
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - View lifecycle

-(void)infoButtonPressed:(id)sender
{
    OPECreditViewController * view = [[OPECreditViewController alloc] init];
    view.title = @"About";
    [self.navigationController pushViewController:view animated:YES];
}
-(void)toggleSwitch:(id)sender
{
    UISwitch * currentSwitch = (UISwitch *)sender;
    [OPEUtility setSettingsValue:[NSNumber numberWithBool:currentSwitch.on] forKey:kShowNoNameStreetsKey]; 
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self.settingsTableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[settingsTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}
-(void)viewWillDisappear:(BOOL)animated
{
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    //[self.navigationController setToolbarHidden:NO animated:YES];
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
