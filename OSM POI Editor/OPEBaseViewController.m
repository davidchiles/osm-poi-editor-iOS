//
//  OPEBaseViewController.m
//  OSM POI Editor
//
//  Created by David on 3/27/13.
//
//

#import "OPEBaseViewController.h"
#import "OPEStrings.h"

#define authErrorTag 101

@interface OPEBaseViewController ()

@end

@implementation OPEBaseViewController
@synthesize HUD,numberOfOngoingParses;
@synthesize osmData = _osmData;
@synthesize apiManager = _apiManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.numberOfOngoingParses = 0;
	//self.osmData = [[OPEOSMData alloc] init];
    //self.osmData.delegate = self;
}

-(OPEOSMAPIManager *)apiManager
{
    if (!_apiManager) {
        _apiManager = [[OPEOSMAPIManager alloc] init];
    }
    return _apiManager;
}

-(OPEOSMData *)osmData
{
    if(!_osmData)
    {
        _osmData = [[OPEOSMData alloc] init];
    }
    return _osmData;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showAuthError
{
    if (HUD)
    {
        [HUD hide:YES];
    }
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"OAuth Error"
                                                      message:@"You need to login to OpenStreetMap"
                                                     delegate:self
                                            cancelButtonTitle:@"Canel"
                                            otherButtonTitles:@"Login", nil];
    message.tag = authErrorTag;
    [message show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == authErrorTag && buttonIndex != alertView.cancelButtonIndex)
    {
        [self signIntoOSM];
    }
}

- (void)signIntoOSM {
    
    
    NSURL *requestURL = [NSURL URLWithString:@"http://www.openstreetmap.org/oauth/request_token"];
    NSURL *accessURL = [NSURL URLWithString:@"http://www.openstreetmap.org/oauth/access_token"];
    NSURL *authorizeURL = [NSURL URLWithString:@"http://www.openstreetmap.org/oauth/authorize"];
    NSString *scope = @"http://api.openstreetmap.org/";
    
    GTMOAuthAuthentication *auth = [OPEOSMAPIManager osmAuth];
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
    [self findishedAuthWithError:error];
    //[self updateUI];
}

-(void)findishedAuthWithError:(NSError *)error
{
    NSLog(@"AUTH ERROR: %@",error);
}


-(void)startSave
{
    [self.navigationController.view addSubview:HUD];
    [HUD setLabelText:[NSString stringWithFormat:@"%@...",SAVING_STRING]];
    [HUD show:YES];
}

#pragma OPEOsmDataDelegate

-(void)didOpenChangeset:(int64_t)changesetNumber withMessage:(NSString *)message
{
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.labelText = [NSString stringWithFormat:@"%@...",UPLOADING_STRING];
    
}
-(void)didCloseChangeset:(int64_t)changesetNumber
{
    self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    self.HUD.labelText = @"Complete";
    [self.HUD hide:YES afterDelay:1.0];
}
-(void)uploadFailed:(NSError *)error
{
    self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    self.HUD.labelText =ERROR_STRING;
    [self.HUD hide:YES afterDelay:2.0];
}

@end
