//
//  OPEBaseViewController.m
//  OSM POI Editor
//
//  Created by David on 3/27/13.
//
//

#import "OPEBaseViewController.h"
#import "OPEStrings.h"

#import "OPELog.h"
#import "AFOAuth1Client.h"
#import "OPEAPIConstants.h"

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
    
    NSString *scope = @"http://api.openstreetmap.org/";
    
    NSURL *baseUrl = [NSURL URLWithString:@"https://www.openstreetmap.org/oauth/"];
    
    AFOAuth1Client *oAuthClient = [[AFOAuth1Client alloc] initWithBaseURL:baseUrl
                                                                      key:osmConsumerKey
                                                                   secret:osmConsumerSecret];
    
    NSURL *callbackUrl = [NSURL URLWithString:@"OSMPOIEDITOR://oauth"];
    
    [oAuthClient authorizeUsingOAuthWithRequestTokenPath:@"request_token" userAuthorizationPath:@"authorize" callbackURL:callbackUrl accessTokenPath:@"access_token" accessMethod:@"GET" scope:scope success:^(AFOAuth1Token *accessToken, id responseObject) {
        
        [AFOAuth1Token storeCredential:accessToken withIdentifier:kOPEUserOAuthTokenKey];
        [self findishedAuthWithError:nil];
        
        DDLogInfo(@"Sucess");
    } failure:^(NSError *error) {
        [self findishedAuthWithError:error];
        DDLogError(@"Error: %@",error);
    }];
    
    return;
}

-(void)findishedAuthWithError:(NSError *)error
{
    DDLogError(@"AUTH ERROR: %@",error);
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
