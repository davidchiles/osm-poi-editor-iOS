#import "OPEManagedReferencePoi.h"


@interface OPEManagedReferencePoi ()

// Private interface goes here.

@end


@implementation OPEManagedReferencePoi

+(OPEManagedReferencePoi *) fetchOrCreateWithName:(NSString *)name category:(NSString *)category didCreate:(BOOL *)didCreate
{
    NSPredicate *osmPoiFilter = [NSPredicate predicateWithFormat:@"name == %@ AND category == %@",name,category];
    NSArray * results = [OPEManagedReferencePoi MR_findAllWithPredicate:osmPoiFilter];
    
    OPEManagedReferencePoi * referencePoi = nil;
    
    if(![results count])
    {
        referencePoi = [OPEManagedReferencePoi MR_createEntity];
        referencePoi.name = name;
        referencePoi.category = category;
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        [context MR_saveToPersistentStoreAndWait];
        
        *didCreate = YES;
    }
    else
    {
        *didCreate = NO;
        referencePoi = [results objectAtIndex:0];
    }
    return referencePoi;
}

@end
