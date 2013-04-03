#import "_OPEManagedOsmWay.h"
#import "CoreLocation/CoreLocation.h"

@interface OPEManagedOsmWay : _OPEManagedOsmWay {}
// Custom logic goes here.

-(NSArray *)points;
-(BOOL)noNameStreet;

-(NSString *)highwayType;

@end
