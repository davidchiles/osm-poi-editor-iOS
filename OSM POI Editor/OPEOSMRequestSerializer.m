//
//  OPEOSMRequestSerializer.m
//  OSM POI Editor
//
//  Created by David on 9/24/13.
//
//

#import "OPEOSMRequestSerializer.h"

@implementation OPEOSMRequestSerializer

@synthesize auth;


- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters
{
    NSMutableURLRequest * request = [super requestWithMethod:method URLString:URLString parameters:parameters];
    if (![method isEqualToString:@"GET"]) {
        [self.auth authorizeRequest:request];
    }
    return request;
}

@end
