#import "OPEManagedObject.h"

@interface OPEManagedOsmTag : OPEManagedObject {}

@property (nonatomic,strong) NSString * key;
@property (nonatomic,strong) NSString * value;

+(OPEManagedOsmTag *)fetchOrCreateWithKey:(NSString *)key value:(NSString *)value;
+(NSArray *)uniqueValuesForOsmKeys:(NSArray *)keys;



@end
