#import "_OPEManagedReferenceOptional.h"

@interface OPEManagedReferenceOptional : _OPEManagedReferenceOptional {}

-(NSString *)displayNameForKey:(NSString *)osmKey withValue:(NSString *)osmValue;
-(NSArray *)allDisplayNames;
-(NSArray *)allSortedTags;
-(OPEManagedReferenceOsmTag *)managedReferenceOsmTagWithName:(NSString *)name;

+ (OPEManagedReferenceOptional *) fetchOrCreateWithName:(NSString *)name didCreate:(BOOL *)didCreate;
@end
