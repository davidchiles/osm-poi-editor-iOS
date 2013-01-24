#import "_OPEManagedOsmTag.h"

@interface OPEManagedOsmTag : _OPEManagedOsmTag {}

+(OPEManagedOsmTag *)fetchOrCreateWithKey:(NSString *)key value:(NSString *)value;



@end
