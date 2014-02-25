//
//  OPEDatabaseManager.h
//  OSM POI Editor
//
//  Created by David Chiles on 2/24/14.
//
//

#import <Foundation/Foundation.h>

@class FMDatabaseQueue;

@interface OPEDatabaseManager : NSObject

+(FMDatabaseQueue *)defaultDatabaseQueue;

@end
