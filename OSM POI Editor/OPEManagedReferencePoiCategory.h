

@interface OPEManagedReferencePoiCategory : NSObject {}

+(OPEManagedReferencePoiCategory *)fetchOrCreateWithName:(NSString * )name;
+(NSArray *)allSortedCategories;
-(NSArray *)allSortedPois;

@end
