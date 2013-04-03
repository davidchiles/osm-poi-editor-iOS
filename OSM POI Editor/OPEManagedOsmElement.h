#import "_OPEManagedOsmElement.h"
#import "CoreLocation/CoreLocation.h"
#import "TBXML.h"
#import "OPEConstants.h"

@interface OPEManagedOsmElement : _OPEManagedOsmElement {}


-(CLLocationCoordinate2D) center;
-(BOOL) findType;
-(NSString *)name;
-(NSString *)valueForOsmKey:(NSString *)osmKey;
-(void)removeTagWithOsmKey:(NSString *)osmKey;
-(void)newType:(OPEManagedReferencePoi *)type;
-(NSString *)tagsDescription;
-(void)addKey:(NSString *)key value:(NSString *)value;

-(NSString *)tagsXML;

-(NSData *) uploadXMLforChangset: (int64_t)changesetNumber;
-(NSData *) deleteXMLforChangset: (int64_t) changesetNumber;

-(NSString *)osmType;
-(NSDictionary *)nearbyHighwayNames;
-(NSDictionary *)nearbyValuesForOsmKey:(NSString *)osmKey;

+ (NSInteger)minID;
+(NSArray *)allElementsWithTag:(OPEManagedOsmTag *)tag;

+(OPEManagedOsmElement *)fetchOrCreatWayWithOsmID:(int64_t)ID;


//+(OPEManagedOsmElement *)fetchOrCreateElementWithOsmID:(int64_t)elementID;

@end
