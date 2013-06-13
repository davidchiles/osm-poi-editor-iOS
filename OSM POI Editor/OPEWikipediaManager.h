//
//  OPEWikipediaAPIManager.h
//  OSM POI Editor
//
//  Created by David on 6/11/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface OPEWikipediaManager : NSObject


-(NSArray *)seperateRawWikipediaValue:(NSString *)rawValue;

-(void)fetchSuggesionsWithLanguage:(NSString *)language query:(NSString *)query success:(void (^)(NSArray *results))success failure:(void (^)(NSHTTPURLResponse *response, NSError *error, id JSON))failure;

-(void)fetchAllWikipediaLanguagesSucess:(void (^)(NSArray *results))success failure:(void (^)(NSHTTPURLResponse *response, NSError *error, id JSON))failure;

-(void)fetchNearbyPoint:(CLLocationCoordinate2D)center withLocale:(NSString *)locale success:(void (^)(NSArray *results))success failure:(void (^)(NSHTTPURLResponse *response, NSError *error, id JSON))failure;

-(NSArray *)mostPopularLanguages;

@end
