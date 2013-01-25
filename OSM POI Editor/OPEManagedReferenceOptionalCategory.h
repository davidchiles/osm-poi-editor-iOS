#import "_OPEManagedReferenceOptionalCategory.h"

@interface OPEManagedReferenceOptionalCategory : _OPEManagedReferenceOptionalCategory {}
// Custom logic goes here.

+(OPEManagedReferenceOptionalCategory *) fetchOrCreateWithName:(NSString *)name sortOrder:(NSInteger) sortOrder;
+(OPEManagedReferenceOptionalCategory *) fetchWithName:(NSString *)name;

@end
