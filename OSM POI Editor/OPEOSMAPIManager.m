//
//  OPEOSMAPIManager.m
//  OSM POI Editor
//
//  Created by David on 6/6/13.
//
//

#import "OPEOSMAPIManager.h"
#import "AFNetworking.h"

@implementation OPEOSMAPIManager
@synthesize delegate;

-(void)reverseLookupAddress:(CLLocationCoordinate2D)coordinate
{
    NSString * urlString = [NSString stringWithFormat:@"http://open.mapquestapi.com/nominatim/v1/reverse.php?format=json&lat=%@&lon=%@&zoom=18&addressdetails=1",[NSNumber numberWithDouble:coordinate.latitude],[NSNumber numberWithDouble:coordinate.longitude]];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    AFJSONRequestOperation * jsonOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if ([self.delegate respondsToSelector:@selector(didFindAddress:)]) {
            [self.delegate didFindAddress:[JSON objectForKey:@"address"]];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error!");
    }];
    [jsonOperation start];
}

@end
