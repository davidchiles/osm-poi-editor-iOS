//
//  OPEManagedOsmTag.m
//  OSM POI Editor
//
//  Created by David on 1/21/13.
//
//

#import "OPEManagedOsmTag.h"


@implementation OPEManagedOsmTag

@dynamic key;
@dynamic value;


+(OPEManagedOsmTag *)fetchOrCreateWithKey:(NSString *)key value:(NSString *)value
{
    NSPredicate *osmTagFilter = [NSPredicate predicateWithFormat:@"key == %@ AND value == %@",key,value];
    
    NSArray * results = [OPEManagedOsmTag MR_findAllWithPredicate:osmTagFilter];
    
    OPEManagedOsmTag * osmTag = nil;
    
    if(![results count])
    {
        osmTag = [OPEManagedOsmTag MR_createEntity];
        osmTag.key = key;
        osmTag.value = value;
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
        [context MR_saveToPersistentStoreAndWait];
    }
    else
    {
        osmTag = [results objectAtIndex:0];
        NSLog(@"Retrieve \n key: %@\nvalue: %@",osmTag.key,osmTag.value);
    }

    
    return osmTag;
}

@end
