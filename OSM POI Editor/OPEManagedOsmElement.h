#import "CoreLocation/CoreLocation.h"
#import "TBXML.h"
#import "OPEConstants.h"
#import "Element.h"
#import "OPEManagedReferencePoi.h"
#import "OPEManagedOsmTag.h"

@interface OPEManagedOsmElement : NSObject {}

@property (nonatomic) int typeID;
@property (nonatomic,strong) OPEManagedReferencePoi *type;
@property (nonatomic,strong) Element * element;
@property (nonatomic) BOOL isVisible;
@property (nonatomic,strong) NSString * action;
@property (nonatomic) int64_t elementID;
@property (nonatomic,readonly) NSString * idKey;
@property (nonatomic,readonly) NSString * idKeyPrefix;


-(id)initWithDictionary:(NSDictionary *)dictionary;
-(NSString *)valueForOsmKey:(NSString *)osmKey;
-(NSString *)tagsDescription;

-(NSString *)tagsXML;

-(NSData *) uploadXMLforChangset: (int64_t)changesetNumber;
-(NSData *) deleteXMLforChangset: (int64_t) changesetNumber;

-(NSString *)osmType;

+(OPEManagedOsmElement *)elementWithBasicOsmElement:(Element *)element;
+(OPEManagedOsmElement *)elementWithType:(NSString *)elementTypeString withDictionary:(NSDictionary *)dictionary;

-(NSString *)displayNameForChangeset;

//+(OPEManagedOsmElement *)fetchOrCreateElementWithOsmID:(int64_t)elementID;

@end
