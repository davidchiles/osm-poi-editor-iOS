#import "OPEManagedOsmTag.h"


@interface OPEManagedOsmTag ()

// Private interface goes here.

@end


@implementation OPEManagedOsmTag

@synthesize key,value;

-(void)loadWithResult:(FMResultSet *)set
{
    self.key = [set stringForColumn:@"key"];
    self.value = [set stringForColumn:@"value"];
}

+(OPEManagedOsmTag *)fetchOrCreateWithKey:(NSString *)key value:(NSString *)value
{
    
}

/*
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
 */
@end
