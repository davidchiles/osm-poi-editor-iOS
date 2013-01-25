#import "OPEManagedReferenceOptionalCategory.h"


@interface OPEManagedReferenceOptionalCategory ()

// Private interface goes here.

@end


@implementation OPEManagedReferenceOptionalCategory

+(OPEManagedReferenceOptionalCategory *)fetchOrCreateWithName:(NSString *)name sortOrder:(NSInteger) sortOrder
{
    NSPredicate *categoryPoiFilter = [NSPredicate predicateWithFormat:@"displayName == %@",name];
    NSArray * results = [OPEManagedReferenceOptionalCategory MR_findAllWithPredicate:categoryPoiFilter];
    
    OPEManagedReferenceOptionalCategory * referenceOptionalCategory = nil;
    
    if(![results count])
    {
        referenceOptionalCategory = [OPEManagedReferenceOptionalCategory MR_createEntity];
        [referenceOptionalCategory setDisplayName:name];
        [referenceOptionalCategory setSortOrderValue:sortOrder];
        
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        [context MR_saveToPersistentStoreAndWait];
    }
    else
    {
        referenceOptionalCategory = [results objectAtIndex:0];
    }
    return referenceOptionalCategory;
}
+(OPEManagedReferenceOptionalCategory *) fetchWithName:(NSString *)name
{
    NSPredicate *categoryPoiFilter = [NSPredicate predicateWithFormat:@"displayName == %@",name];
    NSArray * results = [OPEManagedReferenceOptionalCategory MR_findAllWithPredicate:categoryPoiFilter];
    
    OPEManagedReferenceOptionalCategory * referenceOptionalCategory = nil;
    
    if([results count])
    {
        referenceOptionalCategory = [results objectAtIndex:0];
    }
    return referenceOptionalCategory;

}

@end
