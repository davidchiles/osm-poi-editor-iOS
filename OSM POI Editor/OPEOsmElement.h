#import "CoreLocation/CoreLocation.h"
#import "TBXML.h"
#import "OPEConstants.h"
#import "Element.h"
#import "OPEReferencePoi.h"
#import "OPEOsmTag.h"

@interface OPEOsmElement : NSObject {}


@property (nonatomic, strong) OPEReferencePoi *type;
@property (nonatomic, strong) Element * element;
@property (nonatomic, strong) NSString * action;
@property (nonatomic,readonly) NSString * idKey;
@property (nonatomic,readonly) NSString * idKeyPrefix;
@property (nonatomic) BOOL isVisible;
@property (nonatomic) int typeID;
@property (nonatomic) int64_t elementID;

-(id)initWithDictionary:(NSDictionary *)dictionary;
-(NSString *)valueForOsmKey:(NSString *)osmKey;
-(NSString *)tagsDescription;

-(NSString *)tagsXML;

-(NSData *) uploadXMLforChangset: (int64_t)changesetNumber;
-(NSData *) deleteXMLforChangset: (int64_t) changesetNumber;

-(NSString *)osmType;

+(OPEOsmElement *)elementWithBasicOsmElement:(Element *)element;
+(OPEOsmElement *)elementWithType:(NSString *)elementTypeString withDictionary:(NSDictionary *)dictionary;

-(NSString *)displayNameForChangeset;

//+(OPEOsmElement *)fetchOrCreateElementWithOsmID:(int64_t)elementID;

@end
