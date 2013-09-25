//
//  OPEOSMRequestSerializer.h
//  OSM POI Editor
//
//  Created by David on 9/24/13.
//
//

#import "AFURLRequestSerialization.h"
#import "GTMOAuthAuthentication.h"

@interface OPEOSMRequestSerializer : AFHTTPRequestSerializer


@property (nonatomic,strong) GTMOAuthAuthentication * auth;

@end
