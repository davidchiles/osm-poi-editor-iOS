//
//  OPEOSMRequestSerializer.m
//  OSM POI Editor
//
//  Created by David on 9/24/13.
//
//

#import "OPEOSMRequestSerializer.h"

#import "AFOAuth1Client.h"
#import "OPEConstants.h"
#import "OPEAPIConstants.h"
#import "GTMOAuthAuthentication.h"

@interface OPEOSMRequestSerializer ()

@property (nonatomic, strong) AFOAuth1Token *oAuthToken;

@end

@implementation OPEOSMRequestSerializer

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters error:(NSError *__autoreleasing *)error
{
    NSMutableURLRequest * request = [super requestWithMethod:method URLString:URLString parameters:parameters error:error];
    
    if (self.oAuthToken) {
        GTMOAuthAuthentication *auth = [self osmAuth];
        auth.token = self.oAuthToken.key;
        auth.tokenSecret = self.oAuthToken.secret;
        
        [auth authorizeRequest:request];
    }
    
    
    return request;
}

- (AFOAuth1Token *)oAuthToken
{
    if (!_oAuthToken) {
        _oAuthToken = [AFOAuth1Token retrieveCredentialWithIdentifier:kOPEUserOAuthTokenKey];
    }
    return _oAuthToken;
}

- (GTMOAuthAuthentication *)osmAuth
{
    GTMOAuthAuthentication *auth;
    auth = [[GTMOAuthAuthentication alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1
                                                       consumerKey:osmConsumerKey
                                                        privateKey:osmConsumerSecret];
    
    auth.serviceProvider = @"OSMPOIEditor";
    
    return auth;
}

@end
