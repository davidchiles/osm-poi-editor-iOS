//
//  OPEManagedReferenceOptional.m
//  OSM POI Editor
//
//  Created by David on 1/21/13.
//
//

#import "OPEManagedReferenceOptional.h"
#import "OPEManagedReferenceOsmTag.h"


@implementation OPEManagedReferenceOptional

@dynamic displayName;
@dynamic name;
@dynamic section;
@dynamic sectionSortOrder;
@dynamic tags;

+(OPEManagedReferenceOptional *)fetchOrCreateWithName:(NSString *)name didCreate:(BOOL *)didCreate
{
    NSPredicate * optionalFilter = [NSPredicate predicateWithFormat:@"name == %@",name];
    
    NSArray * results = [OPEManagedReferenceOptional MR_findAllWithPredicate:optionalFilter];
    
    OPEManagedReferenceOptional * referenceOptional = nil;
    
    if(![results count])
    {
        *didCreate = YES;
        referenceOptional = [OPEManagedReferenceOptional MR_createEntity];
        referenceOptional.name = name;
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
        [context MR_saveToPersistentStoreAndWait];
    }
    else
    {
        *didCreate = NO;
        referenceOptional = [results objectAtIndex:0];
    }
    return referenceOptional;
}

@end
