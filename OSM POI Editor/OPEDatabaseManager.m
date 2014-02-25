//
//  OPEDatabaseManager.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/24/14.
//
//

#import "OPEDatabaseManager.h"

#import "FMDatabaseQueue.h"
#import "OPEConstants.h"

@implementation OPEDatabaseManager


+(FMDatabaseQueue *)defaultDatabaseQueue
{
    static FMDatabaseQueue *databaseQueue = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        databaseQueue = [FMDatabaseQueue databaseQueueWithPath:[OPEConstants databasePath]];
    });
    
    return databaseQueue;
    
}

@end
