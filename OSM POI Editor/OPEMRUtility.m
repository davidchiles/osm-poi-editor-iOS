//
//  OPEMRUtility.m
//  OSM POI Editor
//
//  Created by David on 1/23/13.
//
//

#import "OPEMRUtility.h"
#import "OPEManagedOsmElement.h"
#import "OPEManagedOsmNode.h"
#import "OPEManagedOsmWay.h"
#import "OPEManagedOsmRelation.h"
#import "OPEManagedOsmRelationMember.h"
#import "OPEManagedOsmTag.h"

@implementation OPEMRUtility

+(NSManagedObject *)managedObjectWithID:(NSManagedObjectID *)managedObjectID
{
    NSError * error = nil;
    NSManagedObject * managedObject = (OPEManagedOsmElement *)[[NSManagedObjectContext MR_contextForCurrentThread] existingObjectWithID:managedObjectID error:&error];
    if (error) {
        NSLog(@"Error: %@",error);
    }
    return managedObject;
}
+(void)saveAll
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    [context MR_saveToPersistentStoreAndWait];
}

+(void)deleteDownloaded
{
    
    NSPredicate *osmTagFilter = [NSPredicate predicateWithFormat:@"referencePois.@count == 0 AND referenceOsmTag.@count == 0"];
    
    NSUInteger count = [OPEManagedOsmTag MR_countOfEntities];
    count = [OPEManagedOsmNode MR_countOfEntities];
    count = [OPEManagedOsmWay MR_countOfEntities];
    
    NSArray * result = [OPEManagedOsmTag MR_findAllWithPredicate:osmTagFilter];
    for(OPEManagedOsmTag * tag in result)
    {
        [tag MR_deleteEntity];
    }
    [OPEManagedOsmElement MR_truncateAll];
    [OPEManagedOsmNode MR_truncateAll];
    [OPEManagedOsmWay MR_truncateAll];
    [OPEManagedOsmRelation MR_truncateAll];
    [OpeManagedOsmRelationMember MR_truncateAll];
    
    
    
    
    [OPEMRUtility saveAll];
}

@end
