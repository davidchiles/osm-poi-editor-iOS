//
//  OPEOSMSearchManager.h
//  OSM POI Editor
//
//  Created by David on 5/6/13.
//
//

#import <Foundation/Foundation.h>

#import "OPEOsmElement.h"
#import "FMDatabaseQueue.h"
#import "OPEOSMData.h"

@interface OPEOSMSearchManager : NSObject
{
    OPEOsmElement * currentElement;
    FMDatabaseQueue * databaseQueue;
    OPEOSMData * osmData;
}


-(NSArray *)nearbyValuesForElement:(OPEOsmElement *)element withOsmKey:(NSString *)osmKey;
-(NSArray *)sortedNearbyValuesForCoordinate:(CLLocationCoordinate2D)coordinate withOsmKey:(NSString *)osmKey;
-(NSDictionary *)localReverseGeocode:(CLLocationCoordinate2D)coordinate;
-(NSArray *)noNameHighways;
-(NSArray *)recentlyUsedPoisArrayWithLength:(NSInteger)length;

+(NSArray *)sortedNearbyValuesForElement:(OPEOsmElement *)element withOsmKey:(NSString *)osmKey;

@end
