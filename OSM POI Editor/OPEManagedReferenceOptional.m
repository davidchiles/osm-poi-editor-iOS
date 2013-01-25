#import "OPEManagedReferenceOptional.h"
#import "OPEManagedReferenceOsmTag.h"


@interface OPEManagedReferenceOptional ()

// Private interface goes here.

@end


@implementation OPEManagedReferenceOptional


-(NSString *)displayNameForKey:(NSString *)osmKey withValue:(NSString *)osmValue
{
    NSPredicate * tagFilter = [NSPredicate predicateWithFormat:@"tag.key == %@ AND tag.value == %@",osmKey,osmValue];
    NSSet * filteredSet = [self.tags filteredSetUsingPredicate:tagFilter];
    
    if ([filteredSet count]) {
        OPEManagedReferenceOsmTag * managedReferenceOsmTag =  [filteredSet anyObject];
        return managedReferenceOsmTag.name;
    }
    return osmValue;
    
}

-(NSArray *)allDisplayNames
{
    NSMutableArray * finalArray = [NSMutableArray array];
    for(OPEManagedReferenceOsmTag * managedReferecneOsmTag in self.tags)
    {
        [finalArray addObject:managedReferecneOsmTag.name];
    }
    return finalArray;
    
}

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
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
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
