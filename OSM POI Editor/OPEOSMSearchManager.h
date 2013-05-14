//
//  OPEOSMSearchManager.h
//  OSM POI Editor
//
//  Created by David on 5/6/13.
//
//

#import <Foundation/Foundation.h>

#import "OPEManagedOsmElement.h"
#import "FMDatabaseQueue.h"
#import "OPEOSMData.h"

@interface OPEOSMSearchManager : NSObject
{
    OPEManagedOsmElement * currentElement;
    FMDatabaseQueue * databaseQueue;
    OPEOSMData * osmData;
}


-(NSDictionary *)nearbyValuesForElement:(OPEManagedOsmElement *)element withOsmKey:(NSString *)osmKey;
-(NSArray *)noNameHighways;

+(NSDictionary *)nearbyValuesForElement:(OPEManagedOsmElement *)element withOsmKey:(NSString *)osmKey;

@end
