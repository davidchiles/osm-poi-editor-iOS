#import "_OPEManagedReferenceOptional.h"

@interface OPEManagedReferenceOptional : _OPEManagedReferenceOptional {}

-(NSString *)displayNameForKey:(NSString *)osmKey withValue:(NSString *)osmValue;
-(NSArray *)allDisplayNames;

+ (OPEManagedReferenceOptional *) fetchOrCreateWithName:(NSString *)name didCreate:(BOOL *)didCreate;
@end
