//
//  OPEAppVersionMigration.m
//  OSM POI Editor
//
//  Created by David Chiles on 4/10/14.
//
//

#import "OPEAppVersionMigration.h"

#import "AFOAuth1Client.h"
#import "GTMOAuthViewControllerTouch.h"
#import "OPEAPIConstants.h"
#import "OPEConstants.h"

@implementation OPEAppVersionMigration

+ (void)migrateToCurrentVersion
{
    [self moveOAuthToken];
}

+ (void)moveOAuthToken
{
    GTMOAuthAuthentication *auth = [[GTMOAuthAuthentication alloc] initWithSignatureMethod:@"" consumerKey:@"" privateKey:@""];
    NSString *serviceName = @"OSMPOIEditor";
    
    BOOL status = [GTMOAuthViewControllerTouch authorizeFromKeychainForName:serviceName authentication:auth];
    if (status) {
        AFOAuth1Token *token = [[AFOAuth1Token alloc] init];
        token.key = auth.token;
        token.secret = auth.tokenSecret;
        [AFOAuth1Token storeCredential:token withIdentifier:kOPEUserOAuthTokenKey];
        [[GTMOAuthKeychain defaultKeychain] removePasswordForService:serviceName account:@"OAuth" error:nil];
    }
}

@end
