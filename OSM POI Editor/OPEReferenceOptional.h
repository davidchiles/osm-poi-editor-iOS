#import "OPEReferenceOsmTag.h"
#import "OPEObject.h"
#import "OPEConstants.h"


@interface OPEReferenceOptional : OPEObject {}

@property (nonatomic,strong) NSString * displayName;
@property (nonatomic,strong) NSString * name;
@property (nonatomic,strong) NSString * osmKey;
@property (nonatomic) OPEOptionalType type;
@property (nonatomic) NSInteger sectionSortOrder;
@property (nonatomic,strong) NSString * sectionName;
@property (nonatomic,strong) NSMutableSet * optionalTags;


-(id)initWithDictionary:(NSDictionary *)dictionary withName:(NSString * )newNamed;
-(NSString *)displayNameForKey:(NSString *)osmKey withValue:(NSString *)osmValue;
-(NSArray *)allDisplayNames;
-(NSArray *)allSortedTags;
-(OPEReferenceOsmTag *)referenceOsmTagWithName:(NSString *)name;
-(NSString *)sqliteInsertString;

-(NSString *)sqliteOptionalTagsInsertString;
@end
