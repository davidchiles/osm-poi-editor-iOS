//
//  OPEManagedObject.m
//  OSM POI Editor
//
//  Created by David on 4/25/13.
//
//

#import "OPEManagedObject.h"

@implementation OPEManagedObject

@synthesize rowID,databaseQueue=_databaseQueue;


-(FMDatabaseQueue *)databaseQueue
{
    if(!_databaseQueue)
    {
        _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:kDatabasePath];
    }
    return _databaseQueue;
}

@end
