//
//  OPEWikipediaAPIManager.m
//  OSM POI Editor
//
//  Created by David on 6/11/13.
//
//

#import "OPEWikipediaManager.h"
#import "AFNetworking.h"

//http://fr.wikipedia.org/w/api.php?action=opensearch&search=state&limit=10&format=json

@implementation OPEWikipediaManager


-(void)fetchSuggesionsWithLanguage:(NSString *)language query:(NSString *)query success:(void (^)(NSArray *results))success failure:(void (^)(NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSString * urlString = [NSString stringWithFormat:@"http://%@.wikipedia.org/w/api.php?action=opensearch&search=%@&limit=10&format=json",language,query];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    AFJSONRequestOperation * jsonOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSArray * results = (NSArray *)JSON;
        if (success) {
            success(results[1]);
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure) {
            failure(response,error,JSON);
        }
    }];
    [jsonOperation start];
    
}

@end

