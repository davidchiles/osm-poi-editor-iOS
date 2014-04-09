//
//  OPEOSMRequestSerializer.m
//  OSM POI Editor
//
//  Created by David on 9/24/13.
//
//

#import "OPEOSMRequestSerializer.h"

@implementation OPEOSMRequestSerializer

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters error:(NSError *__autoreleasing *)error
{
    NSMutableURLRequest * request = [super requestWithMethod:method URLString:URLString parameters:parameters error:error];
    if (![method isEqualToString:@"GET"] || YES) {
        [self.auth authorizeRequest:request];
    }
    return request;
}

@end
