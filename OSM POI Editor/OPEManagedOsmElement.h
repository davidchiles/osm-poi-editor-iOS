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


-(id)initWithDictionary:(NSDictionary *)dictionary;
-(NSString *)valueForOsmKey:(NSString *)osmKey;
-(NSString *)tagsDescription;
-(void)addKey:(NSString *)key value:(NSString *)value;

-(NSString *)tagsXML;

-(NSData *) uploadXMLforChangset: (int64_t)changesetNumber;
-(NSData *) deleteXMLforChangset: (int64_t) changesetNumber;

-(NSString *)osmType;
-(NSDictionary *)nearbyHighwayNames;
-(NSDictionary *)nearbyValuesForOsmKey:(NSString *)osmKey;
-(void)updateLegacyTags;

+ (NSInteger)minID;
+(NSArray *)allElementsWithTag:(OPEManagedOsmTag *)tag;

+(OPEManagedOsmElement *)fetchOrCreateWithOsmID:(int64_t)ID;
-(BOOL)memberOfOtherElement;

+(OPEManagedOsmElement *)fetchOrCreateWithOsmID:(int64_t)ID type:(NSString *)typeString;

+(OPEManagedOsmElement *)elementWithBasicOsmElement:(Element *)element;
+(OPEManagedOsmElement *)elementWithType:(NSString *)elementTypeString withDictionary:(NSDictionary *)dictionary;

//+(OPEManagedOsmElement *)fetchOrCreateElementWithOsmID:(int64_t)elementID;

@end
