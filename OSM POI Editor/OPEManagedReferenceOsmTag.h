#import "_OPEManagedReferenceOsmTag.h"

@interface OPEManagedReferenceOsmTag : _OPEManagedReferenceOsmTag {}


+(OPEManagedReferenceOsmTag *)fetchOrCreateWithName:(NSString *)name key:(NSString *)key value:(NSString *)value;

@end
