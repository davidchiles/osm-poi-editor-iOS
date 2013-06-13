//
//  OPEWikipediaAPIManager.m
//  OSM POI Editor
//
//  Created by David on 6/11/13.
//
//

#import "OPEWikipediaManager.h"
#import "AFNetworking.h"


@implementation OPEWikipediaManager

-(NSArray *)seperateRawWikipediaValue:(NSString *)rawValue
{
    NSString * languageString = @"en"; //FIXME needs to be locilized
    NSString * wikipediaString = @"";
    if ([rawValue length]) {
        wikipediaString = rawValue;
        NSError * error = nil;
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"([^:]+):" options:0 error:&error];
        NSArray* matches = [regex matchesInString:rawValue options:0 range:NSMakeRange(0, [rawValue length])];
        if ([matches count]) {
            NSTextCheckingResult * match = matches[0];
            NSString * tempLanguage = [rawValue substringWithRange:match.range];
            if ([tempLanguage rangeOfString:@"http"].location == NSNotFound)
            {
                languageString = tempLanguage;
                wikipediaString = [wikipediaString componentsSeparatedByString:languageString][1];
                languageString = [languageString substringToIndex:[languageString length]-1];
            }
            
        }
    }
    
    
    return @[languageString,wikipediaString];
    
}

-(void)fetchSuggesionsWithLanguage:(NSString *)language query:(NSString *)query success:(void (^)(NSArray *results))success failure:(void (^)(NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    if (![language length]) {
        language = @"en";
    }
    NSString * urlString = [NSString stringWithFormat:@"http://%@.wikipedia.org/w/api.php?action=opensearch&search=%@&limit=10&format=json",language,[query stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
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

-(void)fetchAllWikipediaLanguagesSucess:(void (^)(NSArray *results))success failure:(void (^)(NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSString * urlString = @"http://de.wikipedia.org/w/api.php?action=query&meta=siteinfo&siprop=languages&format=json";
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    AFJSONRequestOperation * jsonOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSDictionary * results = (NSDictionary *)JSON;
        if (success) {
            success(results[@"query"][@"languages"]);
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure) {
            failure(response,error,JSON);
        }
    }];
    [jsonOperation start];
}

-(void)fetchNearbyPoint:(CLLocationCoordinate2D)center withLocale:(NSString *)locale success:(void (^)(NSArray *results))success failure:(void (^)(NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSString * urlString = [NSString stringWithFormat:@"http://en.wikipedia.org/w/api.php?action=query&list=geosearch&gsradius=10000&gscoord=%@|%@&format=json",[[NSNumber numberWithDouble:center.latitude] stringValue],[[NSNumber numberWithDouble:center.longitude] stringValue]];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    AFJSONRequestOperation * jsonOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSDictionary * results = (NSDictionary *)JSON;
        if (success) {
            success([results[@"query"][@"geosearch"] valueForKey:@"title"]);
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure) {
            failure(response,error,JSON);
        }
    }];
    [jsonOperation start];
    
}

-(NSArray *)mostPopularLanguages
{
    NSError * error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"wikipediaLanguages" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    NSArray * array = (NSArray *)[NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&error];
    
    return array;
}
@end

