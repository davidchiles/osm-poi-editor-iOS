//
//  OPEObject.m
//  OSM POI Editor
//
//  Created by David on 4/25/13.
//
//

#import "OPEObject.h"

@implementation OPEObject

@synthesize rowID,databaseQueue=_databaseQueue;


-(FMDatabaseQueue *)databaseQueue
{
    if(!_databaseQueue)
    {
        _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:[OPEConstants databasePath]];
    }
    return _databaseQueue;
}

-(void)loadWithResult:(FMResultSet *)set
{
    return;
}
-(NSString *)sqliteInsertString
{
    return nil;
}

@end
