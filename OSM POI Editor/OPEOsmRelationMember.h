#import "OPEOsmElement.h"

@interface OPEOsmRelationMember : NSObject {}

@property (nonatomic,strong) NSString * role;
@property (nonatomic,strong) NSString * type;
@property (nonatomic) int64_t ref;

@property (nonatomic,strong) OPEOsmElement * element;

-(id)initWithDictionary:(NSDictionary *)dictionary;



@end
