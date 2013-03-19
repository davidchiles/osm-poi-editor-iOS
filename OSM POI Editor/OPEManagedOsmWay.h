#import "_OPEManagedOsmWay.h"
#import "CoreLocation/CoreLocation.h"

@interface OPEManagedOsmWay : _OPEManagedOsmWay {}
// Custom logic goes here.


+(OPEManagedOsmWay *)fetchOrCreatWayWithOsmID:(int64_t)wayID;

-(NSArray *)points;
-(BOOL)noNameStreet;

@end
