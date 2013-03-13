#import "_OPEManagedOsmElement.h"
#import "CoreLocation/CoreLocation.h"
#import "TBXML.h"

@interface OPEManagedOsmElement : _OPEManagedOsmElement {}

-(CLLocationCoordinate2D) center;
-(BOOL) findType;
-(NSString *)name;
-(NSString *)valueForOsmKey:(NSString *)osmKey;
-(void)removeTagWithOsmKey:(NSString *)osmKey;
-(void)newType:(OPEManagedReferencePoi *)type;
-(NSString *)tagsDescription;
-(void)addKey:(NSString *)key value:(NSString *)value;

-(void)setMetaData:(NSDictionary *)dictionary;

-(NSString *)tagsXML;

- (NSData *) updateXMLforChangset: (int64_t) changesetNumber;

+ (NSInteger)minID;


//+(OPEManagedOsmElement *)fetchOrCreateElementWithOsmID:(int64_t)elementID;

@end
