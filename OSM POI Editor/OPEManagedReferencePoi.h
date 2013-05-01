#import "OPEManagedObject.h"

@interface OPEManagedReferencePoi : OPEManagedObject {}


@property (nonatomic,strong) NSString * name;
@property (nonatomic,strong) NSString * categoryName;
@property (nonatomic) BOOL isLegacy;
@property (nonatomic) BOOL canAdd;
@property (nonatomic) NSString * imageString;
@property (nonatomic,strong) OPEManagedReferencePoi * currentTagMethod;
@property (nonatomic,strong) OPEManagedReferencePoi * oldTagMethod;
@property (nonatomic,strong) NSSet * optionalsSet;
@property (nonatomic,strong) NSDictionary * tags;


-(NSString *)sqliteTagsInsertString;
-(NSString *)sqliteOptionalInsertString;
-(NSInteger)numberOfOptionalSections;
-(NSArray *)optionalDisplayNames;
-(id)initWithName:(NSString *)name withCategory:(NSString *)categoryName andDictionary:(NSDictionary *)dictionary;
-(id)initWithSqliteResultDictionary:(NSDictionary *)dictionary;

+(NSArray *) allTypes;


@end
