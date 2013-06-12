//
//  OPEWikipediaAPIManager.h
//  OSM POI Editor
//
//  Created by David on 6/11/13.
//
//

#import <Foundation/Foundation.h>

@interface OPEWikipediaManager : NSObject

-(void)fetchSuggesionsWithLanguage:(NSString *)language query:(NSString *)query success:(void (^)(NSArray *results))success failure:(void (^)(NSHTTPURLResponse *response, NSError *error, id JSON))failure;

@end
