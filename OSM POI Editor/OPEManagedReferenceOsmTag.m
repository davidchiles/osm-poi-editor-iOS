//
//  OPEManagedReferenceOsmTag.m
//  OSM POI Editor
//
//  Created by David on 1/21/13.
//
//

#import "OPEManagedReferenceOsmTag.h"
#import "OPEManagedOsmTag.h"


@implementation OPEManagedReferenceOsmTag

@dynamic name;
@dynamic tag;

+(OPEManagedReferenceOsmTag *)fetchOrCreateWithName:(NSString *)name key:(NSString *)key value:(NSString *)value;
{
    NSPredicate *osmTagFilter = [NSPredicate predicateWithFormat:@"name == %@ AND (tag.key == %@ AND tag.value == %@)",name,key,value];
    NSArray * results = [OPEManagedReferenceOsmTag MR_findAllWithPredicate:osmTagFilter];
    
    OPEManagedReferenceOsmTag * referenceOsmTag = nil;
    
    if(![results count])
    {
        referenceOsmTag = [OPEManagedReferenceOsmTag MR_createEntity];
        referenceOsmTag.name = name;
        referenceOsmTag.tag = [OPEManagedOsmTag fetchOrCreateWithKey:key value:value];
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
        [context MR_saveToPersistentStoreAndWait];
    }
    else
    {
        referenceOsmTag = [results objectAtIndex:0];
        NSLog(@"found \nname: %@\nkey: %@\nvalue: %@",referenceOsmTag.name,referenceOsmTag.tag.key,referenceOsmTag.tag.value);
    }
    
    return referenceOsmTag;
    
    
    
}

@end
