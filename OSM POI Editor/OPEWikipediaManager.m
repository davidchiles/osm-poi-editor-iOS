//
//  OPEWikipediaAPIManager.m
//  OSM POI Editor
//
//  Created by David on 6/11/13.
//
//

#import "OPEWikipediaManager.h"
#import "AFNetworking.h"
#import "OPETranslate.h"


@implementation OPEWikipediaManager

-(NSArray *)seperateRawWikipediaValue:(NSString *)rawValue
{
    
    NSString * languageString = @"";
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
    AFHTTPRequestOperation * requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    requestOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray * results = (NSArray *)responseObject;
        if (success) {
            success(results[1]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation.response,error,operation.responseData);
        }
    }];
    
    [requestOperation start];
}

-(void)fetchAllWikipediaLanguagesSucess:(void (^)(NSArray *results))success failure:(void (^)(NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSString * urlString = @"http://en.wikipedia.org/w/api.php?action=query&meta=siteinfo&siprop=languages&format=json";
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    AFHTTPRequestOperation * requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    requestOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary * results = (NSDictionary *)responseObject;
        if (success) {
            success(results[@"query"][@"languages"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation.response,error,operation.responseData);
        }
    }];
    [requestOperation start];
}

-(void)fetchNearbyPoint:(CLLocationCoordinate2D)center withLocale:(NSString *)locale success:(void (^)(NSArray *results))success failure:(void (^)(NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSString * urlString = [NSString stringWithFormat:@"http://%@.wikipedia.org/w/api.php?action=query&list=geosearch&gsradius=10000&gscoord=%@|%@&format=json",locale,[[NSNumber numberWithDouble:center.latitude] stringValue],[[NSNumber numberWithDouble:center.longitude] stringValue]];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    AFHTTPRequestOperation * requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    requestOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary * results = (NSDictionary *)responseObject;
        if (success) {
            success([results[@"query"][@"geosearch"] valueForKey:@"title"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation.response,error,operation.responseData);
        }
    }];
    [requestOperation start];
    
}

-(NSArray *)mostPopularLanguages
{
    NSError * error = nil;
    NSString * systemLanguage = [[OPETranslate systemLocale] componentsSeparatedByString:@"-"][0];
    NSLocale *currentLocale = [[NSLocale alloc] initWithLocaleIdentifier:systemLanguage];
    NSDictionary * systemLanguageDictionary = @{@"code": systemLanguage,@"*":[currentLocale displayNameForKey:NSLocaleIdentifier value:systemLanguage]};
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"wikipediaLanguages" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    NSArray * jsonArray = (NSArray *)[NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&error];
    NSMutableArray * array = [NSMutableArray array];
    [jsonArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLocale *currentLocale = [[NSLocale alloc] initWithLocaleIdentifier:systemLanguage];
        NSDictionary * systemLanguageDictionary = @{@"code": obj,@"*":[currentLocale displayNameForKey:NSLocaleIdentifier value:obj]};
        [array addObject:systemLanguageDictionary];
    }];
    
    
    [array removeObject:systemLanguageDictionary];
    [array insertObject:systemLanguageDictionary atIndex:0];
    
    return array;
}
@end

