#import "_OPEManagedReferencePoi.h"

@interface OPEManagedReferencePoi : _OPEManagedReferencePoi {}

-(NSInteger)numberOfOptionalSections;
-(NSArray *)optionalDisplayNames;

+(NSArray *) allTypes;
+(OPEManagedReferencePoi *) fetchOrCreateWithName:(NSString *)name category:(OPEManagedReferencePoiCategory *)category didCreate:(BOOL *)didCreate;
@end
