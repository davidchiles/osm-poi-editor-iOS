#import "OPEManagedOsmTag.h"


@interface OPEManagedOsmTag ()

// Private interface goes here.

@end


@implementation OPEManagedOsmTag

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
    
    }
    else
    {
        osmTag = [results lastObject];
    }
    
    
    return osmTag;
}

+(NSArray *)uniqueValuesForOsmKeys:(NSArray *)keys
{
    NSMutableArray * predicates = [NSMutableArray array];
    for (NSString * key in keys)
    {
        NSPredicate * tagPredicate = [NSPredicate predicateWithFormat:@"%K == %@",OPEManagedOsmTagAttributes.key,key];
        [predicates addObject:tagPredicate];
    }
 
    NSPredicate * allPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
    
    NSArray * tags = [OPEManagedOsmTag MR_findAllWithPredicate:allPredicates];
    
    NSArray *values = [tags valueForKeyPath:@"@distinctUnionOfObjects.value"];
    
    return values;
}
@end
