#import "_OPEManagedReferencePoi.h"

@interface OPEManagedReferencePoi : _OPEManagedReferencePoi {}

-(NSInteger)numberOfOptionalSections;
-(NSArray *)optionalDisplayNames;

+(OPEManagedReferencePoi *) fetchOrCreateWithName:(NSString *)name category:(NSString *)category didCreate:(BOOL *)didCreate;
@end
