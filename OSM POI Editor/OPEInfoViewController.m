//
//  OPEInfoViewController.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OPEInfoViewController.h"
#import "OPEStamenTerrain.h"
#import "OPEStamenToner.h"
#import "OPEMapquestAerial.h"
#import "RMOpenStreetMapSource.h"


@implementation OPEInfoViewController

@synthesize loginButton, logoutButton, textBox;
@synthesize delegate, currentNumber;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)doneButtonPressed:(id)sender
{
    GTMOAuthAuthentication *auth = [self osmAuth];
    BOOL didAuth = NO;
    BOOL canAuth = NO;
    if (auth) {
        didAuth = [GTMOAuthViewControllerTouch authorizeFromKeychainForName:@"OSMPOIEditor"
                                                                  authentication:auth];
        canAuth = [auth canAuthorize];
    }
    NSLog(@"didAuth %d",didAuth);
    NSLog(@"canAuth %d",canAuth);
}

- (IBAction)loginButtonPressed:(id)sender
{
    NSLog(@"Login Button Pressed");
    [self signInToOSM];
    loginButton.hidden = YES;
    logoutButton.hidden = NO;
}

- (IBAction)logoutButtonPressed:(id)sender
{
    NSLog(@"Logout Button Pressed");
    [self signOutOfOSM];
    loginButton.hidden = NO;
    logoutButton.hidden = YES;
}

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
        [self.loginButton setTitle:@"Logout of OSM" forState:UIControlStateNormal];
        self.loginButton.tag = 1;
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
    
    [[self navigationController] pushViewController:viewController
                                           animated:YES];
}

- (void) signOutOfOSM
{
    [GTMOAuthViewControllerTouch removeParamsFromKeychainForName:@"OSMPOIEditor"];
    self.loginButton.tag = 0;
    [self.loginButton setTitle:@"Login to OSM" forState:UIControlStateNormal];
}

- (void) setLoginButtons
{
    GTMOAuthAuthentication *auth = [self osmAuth];
    BOOL didAuth= NO;
    BOOL canAuth= NO;
    if (auth) {
        didAuth = [GTMOAuthViewControllerTouch authorizeFromKeychainForName:@"OSMPOIEditor"
                                                             authentication:auth];
        canAuth = [auth canAuthorize];
    }
    if (didAuth && canAuth) {
        loginButton.hidden = YES;
        logoutButton.hidden = NO;
    }
    else
    {
        loginButton.hidden = NO;
        logoutButton.hidden = YES; 
    }

    
}
#pragma - TableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 4;
    }
    else {
        return 1;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Tile Source";
    }
    else {
        return @"";
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    static NSString * tileIdentifier = @"Cell";
    static NSString * buttonIdentifier = @"Cell1";
    if (indexPath.section == 0) {
        
        //cell = [tableView dequeueReusableCellWithIdentifier:tileIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tileIdentifier];
        }
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Terrain";
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = @"OSM Default";
        }
        else if (indexPath.row == 2){
            cell.textLabel.text = @"Toner";
        }
        else if (indexPath.row == 3){
            cell.textLabel.text = @"OpenMapquest Aerial";
        }
        
        if (indexPath.row == currentNumber) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    
    }
    else if (indexPath.section == 1)
    {
        //cell = [tableView dequeueReusableCellWithIdentifier:buttonIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:buttonIdentifier];
        }
        loginButton.frame = cell.contentView.bounds;
        NSLog(@"bounds: %f",cell.contentView.bounds.size.width);
        NSLog(@"button: %f",loginButton.frame.size.width);
        loginButton.frame = CGRectMake(loginButton.frame.origin.x, loginButton.frame.origin.y, 300.0f, loginButton.frame.size.height);
        
        [cell.contentView addSubview:loginButton];
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
        
        id <RMTileSource> newTileSource = nil;
        if (indexPath.row == 0) {
            newTileSource = [[OPEStamenTerrain alloc] init];
        }
        else if (indexPath.row == 1) {
            newTileSource = [[RMOpenStreetMapSource alloc] init];
        }
        else if (indexPath.row == 2) {
            newTileSource = [[OPEStamenToner alloc] init];
        }
        else if (indexPath.row == 3) {
            newTileSource = [[OPEMapquestAerial alloc] init];
        }
        [delegate setTileSource:newTileSource at:indexPath.row ];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma - TileSource

-(void)changeTileSourceTo:(NSString *) newSoureceName
{
    id <RMTileSource> newTileSource = nil;
    newTileSource = [[OPEStamenTerrain alloc] init];
    
    //[delegate setTileSource:newTileSource a];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self setLoginButtons];
    
        // if the auth object contains an access token, didAuth is now true
    
    // retain the authentication object, which holds the auth tokens
    //
    // we can determine later if the auth object contains an access token
    // by calling its -canAuthorize method
    //[self setAuthentication:auth];
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [button addTarget:self action:@selector(infoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *info = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.rightBarButtonItem = info;
    
    [self checkButtonStatus];
    
    [self.loginButton addTarget:self action:@selector(osmButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)checkButtonStatus
{
    GTMOAuthAuthentication *auth = [self osmAuth];
    BOOL didAuth= NO;
    BOOL canAuth= NO;
    BOOL hasAuth= NO;
    if (auth) {
        didAuth = [GTMOAuthViewControllerTouch authorizeFromKeychainForName:@"OSMPOIEditor" authentication:auth];
        canAuth = [auth canAuthorize];
        hasAuth = [auth hasAccessToken];
    }
    
    if (didAuth && canAuth && hasAuth) {
        NSLog(@"All three true");
        
        [self.loginButton setTitle:@"Logout of OSM" forState:UIControlStateNormal];
        loginButton.tag = 1;
    }
    else
    {
        NSLog(@"did: %@ can: %@ has: %@",(didAuth ? @"YES" : @"NO"),(canAuth ? @"YES" : @"NO"),(hasAuth ? @"YES" : @"NO"));
        [self.loginButton setTitle:@"Login to OSM" forState:UIControlStateNormal];
        loginButton.tag = 0;
    }
    
}

-(void)osmButtonPressed:(id)sender
{
    if (loginButton.tag == 0) {
        [self signInToOSM];
    }
    else {
        [self signOutOfOSM];
    }
}
-(void)infoButtonPressed:(id)sender
{
    OPECreditViewController * view = [[OPECreditViewController alloc] init];
    view.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:view animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
        
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
