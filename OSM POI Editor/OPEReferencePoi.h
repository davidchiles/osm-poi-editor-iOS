#import "OPEObject.h"

@interface OPEReferencePoi : OPEObject {}


@property (nonatomic,strong) NSString * name;
@property (nonatomic,strong) NSString * categoryName;
@property (nonatomic) BOOL isLegacy;
@property (nonatomic) BOOL editOnly;
@property (nonatomic) NSString * imageString;
@property (nonatomic,strong) OPEReferencePoi * currentTagMethod;
@property (nonatomic,strong) OPEReferencePoi * oldTagMethod;
@property (nonatomic,strong) NSMutableSet * optionalsSet;
@property (nonatomic,strong) NSMutableDictionary * tags;


-(NSString *)sqliteTagsInsertString;
-(NSString *)sqliteInsertString;
-(NSString *)sqliteOptionalInsertString;
-(NSInteger)numberOfOptionalSections;
-(id)initWithName:(NSString *)name withCategory:(NSString *)categoryName andDictionary:(NSDictionary *)dictionary;
-(id)initWithSqliteResultDictionary:(NSDictionary *)dictionary;
-(NSString *)refName;


@end
