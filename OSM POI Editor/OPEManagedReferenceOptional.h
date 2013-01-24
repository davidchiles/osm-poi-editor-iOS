#import "_OPEManagedReferenceOptional.h"

@interface OPEManagedReferenceOptional : _OPEManagedReferenceOptional {}
+ (OPEManagedReferenceOptional *) fetchOrCreateWithName:(NSString *)name didCreate:(BOOL *)didCreate;
@end
