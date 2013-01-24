#import "OPEManagedReferenceOptional.h"


@interface OPEManagedReferenceOptional ()

// Private interface goes here.

@end


@implementation OPEManagedReferenceOptional

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
