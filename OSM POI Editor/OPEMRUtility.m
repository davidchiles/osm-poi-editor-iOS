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
    
    [OPEManagedOsmTag MR_deleteAllMatchingPredicate:osmTagFilter];
    
    [OPEManagedOsmElement MR_deleteAllMatchingPredicate:nil];
    [OPEManagedOsmNode MR_deleteAllMatchingPredicate:nil];
    [OPEManagedOsmWay MR_deleteAllMatchingPredicate:nil];
    [OPEManagedOsmRelation MR_deleteAllMatchingPredicate:nil];
    [OpeManagedOsmRelationMember MR_deleteAllMatchingPredicate:nil];
    
    
    
    
    [OPEMRUtility saveAll];
}

@end
