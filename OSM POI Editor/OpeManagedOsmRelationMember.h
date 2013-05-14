#import "OPEManagedOsmElement.h"

@interface OpeManagedOsmRelationMember : NSObject {}

@property (nonatomic,strong) NSString * role;
@property (nonatomic,strong) NSString * type;
@property (nonatomic) int64_t ref;

@property (nonatomic,strong) OPEManagedOsmElement * element;

-(id)initWithDictionary:(NSDictionary *)dictionary;



@end
