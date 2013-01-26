#import "_OPEManagedReferencePoiCategory.h"

@interface OPEManagedReferencePoiCategory : _OPEManagedReferencePoiCategory {}

+(OPEManagedReferencePoiCategory *)fetchOrCreateWithName:(NSString * )name;
+(NSArray *)allSortedCategories;
-(NSArray *)allSortedPois;

@end
