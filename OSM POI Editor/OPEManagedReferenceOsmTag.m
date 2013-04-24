#import "OPEManagedReferenceOsmTag.h"
#import "OPEManagedOsmTag.h"
#import "OPETranslate.h"

@interface OPEManagedReferenceOsmTag ()

// Private interface goes here.

@end


@implementation OPEManagedReferenceOsmTag

+(OPEManagedReferenceOsmTag *)fetchOrCreateWithName:(NSString *)name key:(NSString *)key value:(NSString *)value;
{
    NSPredicate *osmTagFilter = [NSPredicate predicateWithFormat:@"name == %@ AND (tag.key == %@ AND tag.value == %@)",name,key,value];
    NSArray * results = [OPEManagedReferenceOsmTag MR_findAllWithPredicate:osmTagFilter];
    
    OPEManagedReferenceOsmTag * referenceOsmTag = nil;
    
    if(![results count])
    {
        referenceOsmTag = [OPEManagedReferenceOsmTag MR_createEntity];
        referenceOsmTag.name = name;
        referenceOsmTag.tag = [OPEManagedOsmTag fetchOrCreateWithKey:key value:value];
    }
    else
    {
        referenceOsmTag = [results objectAtIndex:0];
        NSLog(@"found \nname: %@\nkey: %@\nvalue: %@",referenceOsmTag.name,referenceOsmTag.tag.key,referenceOsmTag.tag.value);
    }
    
    return referenceOsmTag;
    
    
    
}

-(NSString *)name
{
    [self willAccessValueForKey:@"name"];
    NSString *myName = [self primitiveName];
    [self didAccessValueForKey:@"name"];
    return [OPETranslate translateString:myName];
}

@end
