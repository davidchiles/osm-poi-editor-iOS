#import "OPEManagedReferenceOptionalCategory.h"
#import "OPETranslate.h"


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
        referenceOptionalCategory = [results lastObject];
    }
    return referenceOptionalCategory;

}

-(NSString *)displayName
{
    [self willAccessValueForKey:@"displayName"];
    NSString *myName = [self primitiveDisplayName];
    [self didAccessValueForKey:@"displayName"];
    return [OPETranslate translateString:myName];
}

@end
