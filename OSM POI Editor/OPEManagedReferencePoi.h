#import "_OPEManagedReferencePoi.h"

@interface OPEManagedReferencePoi : _OPEManagedReferencePoi {}
+(OPEManagedReferencePoi *) fetchOrCreateWithName:(NSString *)name category:(NSString *)category didCreate:(BOOL *)didCreate;
@end
