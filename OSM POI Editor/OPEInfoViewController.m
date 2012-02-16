//
//  OPEInfoViewController.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OPEInfoViewController.h"


@implementation OPEInfoViewController

@synthesize loginButton;

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
}

- (IBAction)logoutButtonPressed:(id)sender
{
    NSLog(@"Logout Button Pressed");
    [self signOutOfOSM];
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
        NSLog(@"succeeeeeeded");
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
    GTMOAuthViewControllerTouch *viewController;
    viewController = [[GTMOAuthViewControllerTouch alloc] initWithScope:scope
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
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
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
