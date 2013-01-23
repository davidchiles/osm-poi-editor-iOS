//
//  OPEManagedReferencePoi.m
//  OSM POI Editor
//
//  Created by David on 1/22/13.
//
//

#import "OPEManagedReferencePoi.h"
#import "OPEManagedOsmTag.h"
#import "OPEManagedReferenceOptional.h"
#import "OPEManagedReferencePoi.h"


@implementation OPEManagedReferencePoi

@dynamic canAdd;
@dynamic category;
@dynamic imageString;
@dynamic isLegacy;
@dynamic name;
@dynamic newTagMethod;
@dynamic optional;
@dynamic tags;

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
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
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
